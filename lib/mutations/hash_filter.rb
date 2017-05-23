module Mutations
  class HashFilter < InputFilter
    def self.register_additional_filter(type_class, type_name)
      define_method(type_name) do | *args, &block |
        name = args[0]
        options = args[1] || {}

        @current_inputs[name.to_sym] = type_class.new(options, &block)
      end
    end

    @default_options = {
      :nils => false,            # true allows an explicit nil to be valid. Overrides any other options
    }

    attr_accessor :optional_inputs
    attr_accessor :required_inputs

    def initialize(opts = {}, &block)
      super(opts)

      @optional_inputs = {}
      @required_inputs = {}
      @current_inputs = @required_inputs

      if block_given?
        instance_eval(&block)
      end
    end

    def dup
      dupped = HashFilter.new
      @optional_inputs.each_pair do |k, v|
        dupped.optional_inputs[k] = v
      end
      @required_inputs.each_pair do |k, v|
        dupped.required_inputs[k] = v
      end
      dupped
    end

    def required(&block)
      @current_inputs = @required_inputs
      instance_eval(&block)
    end

    def optional(&block)
      @current_inputs = @optional_inputs
      instance_eval(&block)
    end

    def required_keys
      @required_inputs.keys
    end

    def optional_keys
      @optional_inputs.keys
    end

    def hash(name, options = {}, &block)
      @current_inputs[name.to_sym] = HashFilter.new(options, &block)
    end

    def model(name, options = {})
      @current_inputs[name.to_sym] = ModelFilter.new(name.to_sym, options)
    end

    def array(name, options = {}, &block)
      name_sym = name.to_sym
      @current_inputs[name.to_sym] = ArrayFilter.new(name_sym, options, &block)
    end

    def filter(data)

      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      # Ensure it's a hash
      return [data, :hash] unless data.is_a?(Hash)

      # We always want a hash with indiffernet access
      unless data.is_a?(HashWithIndifferentAccess)
        data = data.with_indifferent_access
      end

      errors = ErrorHash.new
      filtered_data = HashWithIndifferentAccess.new
      wildcard_filterer = nil

      [[@required_inputs, true], [@optional_inputs, false]].each do |(inputs, is_required)|
        inputs.each_pair do |key, filterer|

          # If we are doing wildcards, then record so and move on
          if key == :*
            wildcard_filterer = filterer
            next
          end

          data_element = data[key]

          if data.has_key?(key)
            sub_data, sub_error = filterer.filter(data_element)

            if sub_error.nil?
              filtered_data[key] = sub_data
            elsif !is_required && filterer.discard_invalid?
              data.delete(key)
            elsif !is_required && sub_error == :empty && filterer.discard_empty?
              data.delete(key)
            elsif !is_required && sub_error == :nils && filterer.discard_nils?
              data.delete(key)
            else
              error_key = filterer.options[:error_key] || key
              sub_error = ErrorAtom.new(error_key, sub_error) if sub_error.is_a?(Symbol)
              errors[key] = sub_error
            end
          end

          if !data.has_key?(key)
            if filterer.has_default?
              filtered_data[key] = filterer.default
            elsif is_required
              error_key = filterer.options[:error_key] || key
              errors[key] = ErrorAtom.new(error_key, :required)
            end
          end
        end
      end

      if wildcard_filterer
        filtered_keys = data.keys - filtered_data.keys

        filtered_keys.each do |key|
          data_element = data[key]

          sub_data, sub_error = wildcard_filterer.filter(data_element)
          if sub_error.nil?
            filtered_data[key] = sub_data
          elsif wildcard_filterer.discard_invalid?
            data.delete(key)
          elsif sub_error == :empty && wildcard_filterer.discard_empty?
            data.delete(key)
          elsif sub_error == :nils && wildcard_filterer.discard_nils?
            data.delete(key)
          else
            sub_error = ErrorAtom.new(key, sub_error) if sub_error.is_a?(Symbol)
            errors[key] = sub_error
          end
        end
      end

      if errors.any?
        [data, errors]
      else
        [filtered_data, nil]     # We win, it's valid!
      end
    end
  end
end
