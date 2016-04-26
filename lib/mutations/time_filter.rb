module Mutations
  class TimeFilter < AdditionalFilter
    @default_options = {
      :nils => false,       # true allows an explicit nil to be valid. Overrides any other options
      :format => nil,       # If nil, Time.parse will be used for coercion, otherwise we will use Time.strptime
      :after => nil,        # A Time object, representing the minimum time allowed, inclusive
      :before => nil        # A Time object, representing the maximum time allowed, inclusive
    }

    def filter(data)
      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      # Now check if it's empty:
      return [data, :empty] if '' == data

      if data.is_a?(Time) # Time
        actual_time = data
      elsif data.is_a?(String)
        begin
          actual_time = if options[:format]
                          Time.strptime(data, options[:format])
                        else
                          Time.parse(data)
                        end
        rescue ArgumentError
          return [nil, :time]
        end
      elsif data.respond_to?(:to_time) # Date, DateTime
        actual_time = data.to_time
      else
        return [nil, :time]
      end

      if options[:after]
        if actual_time <= options[:after]
          return [nil, :after]
        end
      end

      if options[:before]
        if actual_time >= options[:before]
          return [nil, :before]
        end
      end

      # We win, it's valid!
      [actual_time, nil]
    end
  end
end
