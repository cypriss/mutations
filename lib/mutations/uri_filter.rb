require 'uri'

module Mutations
  class UriFilter < AdditionalFilter
    @default_options = {
      :nils => false,    # true allows an explicit nil to be valid. Overrides any other options
      :scheme => nil,    # restrict the URI to a specific scheme, i.e. 'https'
    }

    def filter(data)
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      case data
      when URI # we're good!
      when String then
        return [nil, :blank] if blank?(data)
        begin
          data = URI.parse(data)
        rescue StandardError => e
          return [nil, e.message]
        end
      else return [nil, :invalid]
      end

      if !options[:scheme].nil?
        return [nil, :scheme] if blank?(data.scheme)
        return [nil, :scheme] if data.scheme.to_sym != options[:scheme]
      end

      [data, nil]
    end

    private

    def blank?(value)
      return true if value.nil?
      value = value.strip if value.is_a?(String)
      return value.empty? if value.respond_to?(:empty?)
      return false
    end
  end
end
