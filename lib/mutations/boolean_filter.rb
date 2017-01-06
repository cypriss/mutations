module Mutations
  class BooleanFilter < AdditionalFilter
    @default_options = {
      :nils => false   # true allows an explicit nil to be valid. Overrides any other options
    }

    BOOL_MAP = {"true" => true, "1" => true, "false" => false, "0" => false}

    def filter(data)

      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end
      
      # Now check if it's empty:
      return [data, :empty] if data == ""

      # If data is true or false, we win.
      return [data, nil] if data == true || data == false

      # If data is an Integer, like 1, let's convert it to a string first
      data = data.to_s if data.is_a?(Integer)

      # If data's a string, try to convert it to a boolean. If we can't, it's invalid.
      if data.is_a?(String)
        res = BOOL_MAP[data.downcase]
        return [res, nil] unless res.nil?
        return [data, :boolean]
      else
        return [data, :boolean]
      end
    end
  end
end
