require 'bigdecimal'

module Mutations
  class MoneyFilter < InputFilter
    @default_options = {
      nils: false,       # true allows an explicit nil to be valid. Overrides any other options
      empty: false,      # true allows the value to be empty
      min: nil,          # lowest value, inclusive
      max: nil           # highest value, inclusive
    }

    def filter(data)

      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      # Ensure it's the correct data type (Float)
      if !data.is_a?(Float)
        if data.is_a?(String) && data =~ /^[-+]?\d*[.,]?\d+/
          data = BigDecimal.new(data.gsub(',', '.'))
        elsif data.is_a?(Fixnum)
          data = BigDecimal.new(data.to_s)
        elsif data == "" and !options[:empty]
          return [data, :empty]
        elsif data != ""
          return [data, :money]
        end
      end

      return [data, :min] if options[:min] && data < options[:min]
      return [data, :max] if options[:max] && data > options[:max]

      # We win, it's valid!
      [data, nil]
    end
  end
end
