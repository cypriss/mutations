module Mutations
  class IntegerFilter < AdditionalFilter
    @default_options = {
      :nils => false,          # true allows an explicit nil to be valid. Overrides any other options
      :empty_is_nil => true,  # if true, treat empty string as if it were nil
      :min => nil,             # lowest value, inclusive
      :max => nil,             # highest value, inclusive
      :in => nil,              # Can be an array like %w(3 4 5)
    }

    def filter(data)

      if options[:empty_is_nil] && data == ""
        data = nil
      end

      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      # Now check if it's empty:
      return [data, :empty] if data == ""

      # Ensure it's the correct data type (Integer)
      if !data.is_a?(Integer)
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
