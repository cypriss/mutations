module Mutations
  class HashFilter < InputFilter
    @default_options = {
      nils: false,            # true allows an explicit nil to be valid. Overrides any other options
      key_class: nil,         # Can be a string or Class. If present, all keys must be of this class. Note that this field can't be set if a block is passed.
      value_class: nil        # Can be a string or Class. If present, all values must be of this class. Note that this field can't be set if a block is passed.
    }
    
    attr_accessor :general_inputs  # defaults to false
    attr_accessor :optional_inputs
    attr_accessor :required_inputs
    
    # There's two types of Hash filters:
    #  - those that accept specific inputs (eg, the hash needs to have an email key with a string value matching %r{...})
    #  - those that accept general hashes (eg, the hash needs to have String keys and values, but can have any such k/v's)
    def initialize(opts = {}, &block)
      super(opts)
      
      raise ArgumentError, "Can't use key_class/value_class with a block." if block_given? && (options[:key_class] || options[:value_class])
      
      if options[:key_class] || options[:value_class]
        @general_inputs = true
      else
        @general_inputs = false
        @optional_inputs = {}
        @required_inputs = {}
        @current_inputs = @required_inputs
      end
      
      if block_given?
        instance_eval &block
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
      dupped.general_inputs = @general_inputs
      dupped
    end
    
    def required(&block)
      raise ArgumentError, "Can't use specific filters if you're filtering by key." if general_inputs
      
      # TODO: raise if nesting is wrong
      @current_inputs = @required_inputs
      instance_eval &block
    end
    
    def optional(&block)
      raise ArgumentError, "Can't use specific filters if you're filtering by key." if general_inputs
      
      # TODO: raise if nesting is wrong
      @current_inputs = @optional_inputs
      instance_eval &block
    end
    
    def required_keys
      @required_inputs.keys
    end
    
    def optional_keys
      @optional_inputs.keys
    end
    
    # Basic types:
    def string(name, options = {})
      @current_inputs[name.to_sym] = StringFilter.new(options)
    end
    
    def integer(name, options = {})
      @current_inputs[name.to_sym] = IntegerFilter.new(options)
    end
    
    def boolean(name, options = {})
      @current_inputs[name.to_sym] = BooleanFilter.new(options)
    end
    
    def hash(name, options = {}, &block)
      unless block_given?
        options.reverse_merge!(key_class: String, value_class: String)
      end
      @current_inputs[name.to_sym] = HashFilter.new(options, &block)
    end
    
    # Advanced types
    def model(name, options = {})
      name_sym = name.to_sym
      @current_inputs[name_sym] = ModelFilter.new(name_sym, options)
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
      
      if @general_inputs
        key_class_const = options[:key_class] || raise
        key_class_const = key_class_const.constantize if key_class_const.is_a?(String)
        
        value_class_const = options[:value_class] || raise
        value_class_const = value_class_const.constantize if value_class_const.is_a?(String)
        data.each_pair do |k, v|
          if k.is_a?(key_class_const) && v.is_a?(value_class_const)
            filtered_data[k] = v
          else
            k_string = k.to_s
            if !k.is_a?(key_class_const)
              errors[k_string] = ErrorAtom.new(k_string, :key_class)
            else
              errors[k_string] = ErrorAtom.new(k_string, :value_class)
            end
          end
        end
      else
        [[@required_inputs, true], [@optional_inputs, false]].each do |(inputs, is_required)|
          inputs.each_pair do |key, filterer|
            data_element = data[key]
            default_used = false
            if !data.has_key?(key) && filterer.has_default?
              data_element = filterer.default
              default_used = true
            end
            
            if data.has_key?(key) || default_used
              sub_data, sub_error = filterer.filter(data_element)
      
              if sub_error.nil?
                filtered_data[key] = sub_data
              else
                sub_error = ErrorAtom.new(key, sub_error) if sub_error.is_a?(Symbol)
                errors[key] = sub_error
              end
            elsif is_required
              errors[key] = ErrorAtom.new(key, :required)
            end
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