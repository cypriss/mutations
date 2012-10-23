module Mutations  
  class Errors < HashWithIndifferentAccess
    ERROR_STRINGS = {
      nils: "can't be nil",
      empty: "can't be blank",
      matches: "doesn't match the regexp",
      length: "isn't the right length",
      in: "isn't an allowed value"
      #length: ""
    }
    
    # strip: true,       # true calls data.strip if data is a string
    # nils: false,       # true allows an explicit nil to be valid. Overrides any other options
    # empty: false,      # false disallows "".  true allows "" and overrides any other validations (b/c they couldn't be true if it's empty)
    # length: nil,       # Can be a number like 5, for max length, or a range, like 3..10
    # matches: nil,      # Can be a regexp
    # in: nil            # Can be an array like %w(red blue green)
    
    # Returns a 
    def messages
      
    end
    
  end
end