module Mutations
  module Outcome
    def self.new(is_success, result, errors, inputs)
      if defined?(::Mutations::SuccessOutcome)
        if is_success
          ::Mutations::SuccessOutcome.new(result, inputs: inputs)
        else
          ::Mutations::FailureOutcome.new(errors, inputs: inputs)
        end
      else
        ::Mutations::ClassicOutcome.new(is_success, result, errors, inputs)
      end
    end
  end

  class ClassicOutcome
    include Outcome
    attr_reader :result, :errors, :inputs

    def initialize(is_success, result, errors, inputs)
      @success, @result, @errors, @inputs = is_success, result, errors, inputs
    end

    def success?
      @success
    end
  end
  
  begin
    require 'dry/monads/either'

    module MonadicOutcome
      def initialize(value, options = {})
        super(value)
        @inputs = options[:inputs]
      end
      
      def result(*args)
        args.empty? ? (@value || @right if success?) : super
      end
      
      def errors
        @value || @left unless success?
      end
    end

    class SuccessOutcome < Dry::Monads::Either::Right
      include Outcome
      include MonadicOutcome
      
      attr_reader :inputs
    end

    class FailureOutcome < Dry::Monads::Either::Left
      include Outcome
      include MonadicOutcome

      attr_reader :inputs

      def or_fmap(*args, &block)
        SuccessOutcome.new(self.or(*args, &block), inputs: @inputs)
      end

      def flip
        SuccessOutcome.new(@value, inputs: @inputs)
      end
    end
  rescue LoadError
    puts "dry/monads integration not available. Load the dry-monads gem before mutations if needed."
  end
  
end
