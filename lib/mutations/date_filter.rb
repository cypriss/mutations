module Mutations
  class DateFilter < InputFilter
    @default_options = {
      nils: false   # true allows an explicit nil to be valid. Overrides any other options
    }

    def filter(data)
      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      if data.is_a? Date
        return [data, nil]
      else
        return [data, :date]
      end
    end
  end
end
