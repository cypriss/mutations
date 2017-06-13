module Mutations
  class RangeFilter < AdditionalFilter
    @default_options = {
      :nils => false,          # true allows an explicit nil to be valid. Overrides any other options
      :min => nil,             # lowest value, inclusive
      :max => nil,             # highest value, inclusive
      :type => nil             # range inner type, nil accepts any type
    }

    def filter(data)
      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      # Now check if it's empty:
      return [data, :empty] if data == ""

      # Ensure it's the correct data type (Range)
      return [data, :range] unless data.is_a?(Range)

      unless options[:type].nil?
        return [data, :type] unless options[:type] >= data.begin.class
        return [data, :type] unless options[:type] >= data.end.class
      end

      return [data, :min] if options[:min] && data.begin < options[:min]
      return [data, :max] if options[:max] && data.end > options[:max]

      # We win, it's valid!
      [data, nil]
    end
  end
end
