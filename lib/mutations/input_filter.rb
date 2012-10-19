module Mutations
  class InputFilter
    @default_options = {}
    
    def self.default_options
      @default_options
    end
    
    attr_accessor :options
    
    def initialize(opts = {})
      self.options = (self.class.default_options || {}).merge(opts)
    end
    
    # returns -> [sanitized data, error]
    # If an error is returned, then data will be nil
    def filter(data)
      [data, nil]
    end
    
    def has_default?
      self.options.has_key?(:default)
    end
    
    def default
      self.options[:default]
    end
  end
end
