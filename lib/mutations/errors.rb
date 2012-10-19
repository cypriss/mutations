module Mutations
  
  class Errors < HashWithIndifferentAccess
    ActiveRecordValidationErrorMap = {
      in: :inclusion,
      matches: :invalid,
      length: :wrong_length,
      empty: :empty,
      required: :blank,
      nils: :blank,
      min: :greater_than_or_equal_to,
      max: :less_than_or_equal_to,
      confirmation: :confirmation,
      taken: :taken
    }
    # messages:
    #   inclusion: "is not included in the list"
    #   exclusion: "is reserved"
    #   invalid: "is invalid"
    #   confirmation: "doesn't match confirmation"
    #   accepted: "must be accepted"
    #   empty: "can't be empty"
    #   blank: "can't be blank"
    #   too_long: "is too long (maximum is %{count} characters)"
    #   too_short: "is too short (minimum is %{count} characters)"
    #   wrong_length: "is the wrong length (should be %{count} characters)"
    #   taken: "has already been taken"
    #   not_a_number: "is not a number"
    #   greater_than: "must be greater than %{count}"
    #   greater_than_or_equal_to: "must be greater than or equal to %{count}"
    #   equal_to: "must be equal to %{count}"
    #   less_than: "must be less than %{count}"
    #   less_than_or_equal_to: "must be less than or equal to %{count}"
    #   odd: "must be odd"
    #   even: "must be even"
    #   record_invalid: "Validation failed: %{errors}"
    
    def initialize(errors, filters)
      super(errors)
      @filters = filters
    end
    
    def full_messages
      [].tap do |full_messages|
        messages.each do |k, v|
          if v.is_a?(Hash)
            full_messages << Errors.new(v, @filters).full_messages
          else
            full_messages << generate_full_message(k, v)
          end
        end
        
        full_messages.flatten!
      end
    end
    
    def messages
      HashWithIndifferentAccess.new.tap do |messages|
        each do |k, v|
          if v.is_a?(Hash)
            messages[k] = Errors.new(v, @filters).messages
          else
            messages[k] = generate_message(v, message_options(k, v))
          end
        end
      end
    end
    
    private
    
    def generate_full_message(attribute, message)      
      I18n.translate("activerecord.errors.full_messages.format", { 
        attribute: attribute, 
        message: message
      })
    end
    
    def generate_message(key, options = {})
      I18n.translate("activerecord.errors.messages.#{activerecord_keymap(key)}", options)
    end
    
    def message_options(attribute, key)      
      { count: @filters.lookup_attribute(attribute).options[key] }
    end
    
    def activerecord_keymap(key)
      ActiveRecordValidationErrorMap[key] || :invalid
    end
  end
end