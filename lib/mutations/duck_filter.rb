module Mutations
  class DuckFilter < AdditionalFilter
    @default_options = {
      :nils => false,       # true allows an explicit nil to be valid. Overrides any other options
      :methods => nil       # The object needs to respond to each of the symbols in this array.
    }

    def _filter(data)
      # Ensure the data responds to each of the methods
      Array(options[:methods]).each do |method|
        return [data, :duck] unless data.respond_to?(method)
      end

      # We win, it's valid!
      [data, nil]
    end
  end
end
