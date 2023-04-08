module Mutations
  class TypeFilter < AdditionalFilter
    @default_options = {
      :nils => false,    # true allows an explicit nil to be valid. Overrides any other options
      :klass => nil,     # require the input to be of this type
    }

    def filter(data)
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      klass = options[:klass]
      return [nil, :klass] unless klass.is_a?(Class)
      return [nil, :invalid] unless data.is_a?(klass)

      [data, nil]
    end
  end
end
