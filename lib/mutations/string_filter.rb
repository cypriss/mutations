module Mutations
  class StringFilter < InputFilter
    @default_options = {
      strip: true,       # true calls data.strip if data is a string
      nils: false,       # true allows an explicit nil to be valid. Overrides any other options
      empty: false,      # false disallows "".  true allows "" and overrides any other validations (b/c they couldn't be true if it's empty)
      length: nil,       # Can be a number like 5, for max length, or a range, like 3..10
      matches: nil,      # Can be a regexp
      in: nil            # Can be an array like %w(red blue green)
    }
    
    def filter(data)
      puts data.inspect
      puts "that was it"
      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end
      
      # At this point, data is not nil. If it's a symbol, convert it to a string
      data = data.to_s if data.is_a?(Symbol)
      data = data.to_s if data.is_a?(Fixnum)
      
      # Now ensure it's a string:
      return [data, :string] unless data.is_a?(String)
      
      # At this point, data is a string.  Now transform it using strip:
      data = data.strip if options[:strip]
      
      # Now check if it's blank:
      if data == ""
        if options[:empty]
          return [data, nil]
        else
          return [data, :empty]
        end
      end
      
      # Now check to see if it's the correct size:
      len = options[:length]
      if len
        if len.is_a?(Fixnum)
          return [data, :length] if data.length > len
        elsif len.is_a?(Range)
          return [data, :length] unless len.include?(data)
        else
          raise "Invalid length option"
        end
      end
      
      # Ensure it match
      return [data, :in] if options[:in] && !options[:in].include?(data)
      
      # Ensure it matches the regexp
      return [data, :matches] if options[:matches] && (options[:matches] !~ data)
      
      # We win, it's valid!
      [data, nil]
    end
  end
end
