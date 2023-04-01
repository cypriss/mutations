module Mutations
  class IntegerFilter < AdditionalFilter
    @default_options = {
      :nils => false,          # true allows an explicit nil to be valid. Overrides any other options
      :empty_is_nil => false,  # if true, treat empty string as if it were nil
      :min => nil,             # lowest value, inclusive
      :max => nil,             # highest value, inclusive
      :in => nil,              # Can be an array like %w(3 4 5)
    }

    def filter(data)
      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      # Now check if it's empty:
      if data == ""
        if options[:empty_is_nil]
          return [nil, (:nils unless options[:nils])]
        else
          return [data, :empty]
        end
      end

      # Ensure it's the correct data type (Integer)
      if !data.is_a?(Integer)
        if data.is_a?(String)
          begin
            data = Integer(data)
          rescue ArgumentError
            return [data, :integer]
          end
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
