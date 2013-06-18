module Mutations
  class IntegerFilter < InputFilter
    @default_options = {
      :nils => false,       # true allows an explicit nil to be valid. Overrides any other options
      :empty => false,      # true allows the value to be empty
      :min => nil,          # lowest value, inclusive
      :max => nil,          # highest value, inclusive
      :in => nil            # Can be an array like %w(3 4 5)
    }

    def filter(data)

      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      # Check if the data is empty
      if data == ""
        if options[:empty]
          return [data, nil]
        else
          return [data, :empty]
        end
      end

      # Ensure it's the correct data type (Fixnum)
      if !data.is_a?(Fixnum)
        if data.is_a?(String) && data =~ /^-?\d/
          data = data.to_i
        else
          return [data, :integer]
        end
      end

      return [data, :min] if options[:min] && data < options[:min]
      return [data, :max] if options[:max] && data > options[:max]

      # Ensure it matches `in`
      return [data, :in] if options[:in] && !options[:in].include?(data)

      # We win, it's valid!
      [data, nil]
    end
  end
end
