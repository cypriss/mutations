module Mutations
  class ModelFilter < InputFilter
    @default_options = {
      :nils => false,        # true allows an explicit nil to be valid. Overrides any other options
      :class => nil,         # default is the attribute name.to_s.camelize.constantize.  This overrides it with class or class.constantize
      :builder => nil,       # Could be a class or a string which will be constantized. If present, and a hash is passed, then we use that to construct a model
      :new_records => false, # If false, unsaved AR records are not valid. Things that don't respond to new_record? are valid.  true: anything is valid
    }

    def initialize(name, opts = {})
      super(opts)
      @name = name
    end

    # Initialize the model class and builder
    def initialize_constants!
      @initialize_constants ||= begin
        class_const = options[:class] || @name.to_s.camelize
        class_const = class_const.constantize if class_const.is_a?(String)
        options[:class] = class_const

        if options[:builder]
          options[:builder] = options[:builder].constantize if options[:builder].is_a?(String)
        end

        true
      end
      
      unless Mutations.cache_constants?
        options[:class] = options[:class].to_s.constantize if options[:class]
        options[:builder] = options[:builder].to_s.constantize if options[:builder]
      end
    end

    def filter(data)
      initialize_constants!

      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      # Passing in attributes.  Let's see if we have a builder
      if data.is_a?(Hash) && options[:builder]
        ret = options[:builder].run(data)

        if ret.success?
          data = ret.result
        else
          return [data, ret.errors]
        end
      end

      # We have a winner, someone passed in the correct data type!
      if data.is_a?(options[:class])
        return [data, :new_records] if !options[:new_records] && (data.respond_to?(:new_record?) && data.new_record?)
        return [data, nil]
      end

      return [data, :model]
    end

  end
end
