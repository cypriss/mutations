# IDEA i just had (protected parameters):
# optional do
#   boolean :skip_confirmation, protected: true
# end
# Given the above, skip_confirmation is only accepted as a parameter if it's passed in a later hash, eg this would make it take:
# User::ChangeEmail.run!(params, user: current_user, skip_confirmation: true)
# But this would not:
# params = {user: current_user, skip_confirmation: true}
# User::ChangeEmail.run!(params)


module Mutations
  class Command

    ##
    ##
    ##
    class << self
      def required(&block)
        self.input_filters.required(&block)

        self.input_filters.required_keys.each do |key|
          define_method(key) do
            @filtered_input[key]
          end

          define_method("#{key}_present?") do
            @filtered_input.has_key?(key)
          end

          define_method("#{key}=") do |v|
            @filtered_input[key] = v
          end
        end
      end

      def optional(&block)
        self.input_filters.optional(&block)

        self.input_filters.optional_keys.each do |key|
          define_method(key) do
            @filtered_input[key]
          end

          define_method("#{key}_present?") do
            @filtered_input.has_key?(key)
          end

          define_method("#{key}=") do |v|
            @filtered_input[key] = v
          end
        end
      end

      def run(*args)
        new(*args).execute!
      end

      def run!(*args)
        m = run(*args)
        if m.success?
          m.result
        else
          raise ValidationException.new(m.errors)
        end
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
      @original_hash = args.each_with_object({}.with_indifferent_access) do |arg, h|
        raise ArgumentError.new("All arguments must be hashes") unless arg.is_a?(Hash)
        h.merge!(arg)
      end
      @filtered_input, @errors = self.input_filters.filter(@original_hash)
    end

    def input_filters
      self.class.input_filters
    end

    def has_errors?
      not(@errors.nil?)
    end

    def execute!
      return Outcome.new(false, nil, @errors) if has_errors?

      # IDEA/TODO: run validate block

      r = execute
      if has_errors? # Execute can add errors
        return Outcome.new(false, nil, @errors)
      else
        return Outcome.new(true, r, nil)
      end
    end

    # Runs input thru the filter and sets @filtered_input and @errors
    def validation_outcome
      Outcome.new(!has_errors?, nil, @errors)
    end

    # add_error("name", :too_short)
    # add_error("colors.foreground", :not_a_color) # => to create errors = {colors: {foreground: :not_a_color}}
    # or, supply a custom message:
    # add_error("name", :too_short, "The name 'blahblahblah' is too short!")
    def add_error(key, kind, message = nil)
      raise ArgumentError.new("Invalid kind") unless kind.is_a?(Symbol)

      (@errors ||= ErrorHash.new).tap do |errs|
        *path, last = key.to_s.split(".")
        inner = path.inject(errs){|cut_errors,part|
          cur_errors[part.to_sym] ||= ErrorHash.new
        }
        inner[last] = ErrorAtom.new(key, kind, message: message)
      end
    end

    def merge_errors(hash)
      @errors ||= ErrorHash.new
      @errors.merge!(hash)
    end

    def inputs
      @filtered_input
    end

    def execute
      # Meant to be overridden
    end
  end
end