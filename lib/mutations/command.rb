module Mutations
  class Command
    class << self
      def create_attr_methods(meth, &block)
        self.input_filters.send(meth, &block)
        keys = self.input_filters.send("#{meth}_keys")
        keys.each do |key|
          define_method(key) do
            @inputs[key]
          end

          define_method("#{key}_present?") do
            @inputs.has_key?(key)
          end

          define_method("#{key}=") do |v|
            @inputs[key] = v
          end
        end
      end
      private :create_attr_methods

      def required(&block)
        create_attr_methods(:required, &block)
      end

      def optional(&block)
        create_attr_methods(:optional, &block)
      end

      def run(*args)
        new(*args).run
      end

      def run!(*args)
        new(*args).run!
      end

      # Validates input, but doesn't call execute. Returns an Outcome with errors anyway.
      def validate(*args)
        new(*args).validation_outcome
      end

      def input_filters
        @input_filters ||= begin
          if Command == self.superclass
            HashFilter.new
          else
            self.superclass.input_filters.dup
          end
        end
      end

    end

    # Instance methods
    def initialize(*args)
      @raw_inputs = args.inject({}.with_indifferent_access) do |h, arg|
        raise ArgumentError.new("All arguments must be hashes") unless arg.respond_to?(:to_hash)
        h.merge!(arg)
      end

      # Do field-level validation / filtering:
      @inputs, @errors = self.input_filters.filter(@raw_inputs)

      # Run a custom validation method if supplied:
      validate unless has_errors?
    end

    def input_filters
      self.class.input_filters
    end

    def has_errors?
      !@errors.nil?
    end

    def run
      return validation_outcome if has_errors?
      validation_outcome(execute)
    end

    def run!
      outcome = run
      if outcome.success?
        outcome.result
      else
        raise ValidationException.new(outcome.errors)
      end
    end

    def validation_outcome(result = nil)
      Outcome.new(!has_errors?, has_errors? ? nil : result, @errors, @inputs)
    end

  protected

    attr_reader :inputs, :raw_inputs

    def validate
      # Meant to be overridden
    end

    def execute
      # Meant to be overridden
    end

    # add_error("name", :too_short)
    # add_error("colors.foreground", :not_a_color) # => to create errors = {colors: {foreground: :not_a_color}}
    # or, supply a custom message:
    # add_error("name", :too_short, "The name 'blahblahblah' is too short!")
    def add_error(key, kind, message = nil)
      raise ArgumentError.new("Invalid kind") unless kind.is_a?(Symbol)

      @errors ||= ErrorHash.new
      @errors.tap do |errs|
        path = key.to_s.split(".")
        last = path.pop
        inner = path.inject(errs) do |cur_errors,part|
          cur_errors[part.to_sym] ||= ErrorHash.new
        end
        inner[last] = ErrorAtom.new(key, kind, :message => message)
      end
    end

    def merge_errors(hash)
      if hash.any?
        @errors ||= ErrorHash.new
        @errors.merge!(hash)
      end
    end

  end
end
