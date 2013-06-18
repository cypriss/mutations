module Mutations
  class DuckFilter < AdditionalFilter
    @default_options = {
      :nils => false,       # true allows an explicit nil to be valid. Overrides any other options
      :methods => nil       # The object needs to respond to each of the symbols in this array.
    }

    def filter(data)

      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      # Ensure the data responds to each of the methods
      Array(options[:methods]).each do |method|
        return [data, :duck] unless data.respond_to?(method)
      end

      # We win, it's valid!
      [data, nil]
    end
  end
end
