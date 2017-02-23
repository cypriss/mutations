module Mutations
  class StringFilter < AdditionalFilter
    @default_options = {
      :strip => true,          # true calls data.strip if data is a string
      :strict => false,        # If false, then symbols, numbers, and booleans are converted to a string with to_s.
      :nils => false,          # true allows an explicit nil to be valid. Overrides any other options
      :empty => false,         # false disallows "".  true allows "" and overrides any other validations (b/c they couldn't be true if it's empty)
      :min_length => nil,      # Can be a number like 5, meaning that 5 codepoints are required
      :max_length => nil,      # Can be a number like 10, meaning that at most 10 codepoints are permitted
      :matches => nil,         # Can be a regexp
      :in => nil,              # Can be an array like %w(red blue green)
      :discard_empty => false, # If the param is optional, discard_empty: true drops empty fields.
      :allow_control_characters => false    # false removes unprintable characters from the string
    }

    def filter(data)

      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      # At this point, data is not nil. If it's not a string, convert it to a string for some standard classes
      data = data.to_s if !options[:strict] && [TrueClass, FalseClass, Integer, Float, BigDecimal, Symbol].any? { |klass| data.is_a?(klass) }

      # Now ensure it's a string:
      return [data, :string] unless data.is_a?(String)

      # At this point, data is a string. Now remove unprintable characters from the string:
      data = data.gsub(/[^[:print:]\t\r\n]+/, ' ') unless options[:allow_control_characters]

      # Transform it using strip:
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
      return [data, :min_length] if options[:min_length] && data.length < options[:min_length]
      return [data, :max_length] if options[:max_length] && data.length > options[:max_length]

      # Ensure it match
      return [data, :in] if options[:in] && !options[:in].include?(data)

      # Ensure it matches the regexp
      return [data, :matches] if options[:matches] && (options[:matches] !~ data)

      # We win, it's valid!
      [data, nil]
    end
  end
end
