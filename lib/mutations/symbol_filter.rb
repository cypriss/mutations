module Mutations
  class SymbolFilter < AdditionalFilter
    @default_options = {
      :nils => false,    # true allows an explicit nil to be valid. Overrides any other options
    }

    def filter(data)
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      case data
      when Symbol # we're good!
      when String then data = data.to_sym
      else return [nil, :symbol]
      end

      [data, nil]
    end
  end
end
