module Mutations
  class IntegerFilter < AdditionalFilter
    @default_options = {
      :nils => false,          # true allows an explicit nil to be valid. Overrides any other options
      :min => nil,             # lowest value, inclusive
      :max => nil,             # highest value, inclusive
      :in => nil,              # Can be an array like %w(3 4 5) or a callable object that returns an array
    }

    def filter(data)

      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      # Now check if it's empty:
      return [data, :empty] if data == ""

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
      if allowed_values = options[:in]
        allowed_values = allowed_values.call if allowed_values.respond_to?(:call)
        return [data, :in] if !allowed_values.include?(data)
      end

      # We win, it's valid!
      [data, nil]
    end
  end
end
