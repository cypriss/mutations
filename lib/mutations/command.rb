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
        c = new(*args).execute!
      end
      
      def run!(*args)
        c = run(*args)
        if c.success?
          c.result
        else
          raise ValidationException.new(c.errors)
        end
      end
      
      def input_filters
        @input_filters ||= begin
          if Command === self.superclass
            self.superclass.input_filters.dup
          else
            HashFilter.new
          end
        end
      end
      
    end
  
    # Instance methods
    def initialize(*args)
      input = args.shift
      args.each do |a|
        input = input.merge(a) if input.is_a?(Hash) && a.is_a?(Hash)
      end
      
      @success = nil # Did the command successfully execute?
      @errors = nil  # nil, symbol, or hash of the validation error
      
      @filtered_input, @errors = self.inputs_filters.filter(input)
    end
    
    def input_filters
      self.class.input_filters
    end
    
    def execute!
      @success = nil
      
      if valid?
        r = execute
        if valid? # Execute can add errors
          @result = r
          @success = true
        else
          @result = nil
          @success = false
        end
      end
      self
    end
    
    # add_error("name", :too_short)
    # add_error("colors.foreground", :not_a_color) # => to create errors = {colors: {foreground: :not_a_color}}
    def add_error(key, kind)
      raise "Invalid kind" unless kind.is_a?(Symbol)
      @errors ||= {}
      cur_errors = @errors
      parts = key.to_s.split(".")
      while part = parts.shift
        part = part.to_sym
        if parts.length > 0
          cur_errors[part] = {} unless cur_errors[part].is_a?(Hash)
          cur_errors = cur_errors[part]
        else
          cur_errors[part] = kind
        end
      end
      @errors
    end
    
    def add_errors(hash)
      @errors ||= {}
      @errors.merge!(hash)
    end
    
    def inputs
      @filtered_input
    end
    
    def execute
      # Meant to be overridden
    end
    
    def valid?
      @errors.nil?
    end
    
    def success?
      @success
    end
    
    def result
      @result
    end
    
    def errors
      Errors.new(@errors, self.input_filters) unless valid?
    end
  end
end