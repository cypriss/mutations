module Mutations
  class DateFilter < InputFilter
    @default_options = {
      nils: false,   # true allows an explicit nil to be valid. Overrides any other options
      format: "%d-%m-%Y"
    }

    def filter(data)
      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      if data.is_a? Date or data.is_a? DateTime
        return [data, nil]
      elsif data.is_a? String
        begin
          data = Date.strptime(data, options[:format])
          return [data, nil]
        rescue
          return [data, :format]
        end
      else
        return [data, :date]
      end
    end
  end
end
