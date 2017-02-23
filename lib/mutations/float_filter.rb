module Mutations
  class FloatFilter < AdditionalFilter
    @default_options = {
      :nils => false,       # true allows an explicit nil to be valid. Overrides any other options
      :min => nil,          # lowest value, inclusive
      :max => nil           # highest value, inclusive
    }

    def filter(data)

      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end
      
      # Now check if it's empty:
      return [data, :empty] if data == ""

      # Ensure it's the correct data type (Float)
      if !data.is_a?(Float)
        if data.is_a?(String) && data =~ /^[-+]?\d*\.?\d+/
          data = data.to_f
        elsif data.is_a?(Integer)
          data = data.to_f
        else
          return [data, :float]
        end
      end

      return [data, :min] if options[:min] && data < options[:min]
      return [data, :max] if options[:max] && data > options[:max]

      # We win, it's valid!
      [data, nil]
    end
  end
end
