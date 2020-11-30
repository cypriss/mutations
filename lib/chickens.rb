require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/inflections'
require 'date'
require 'time'
require 'bigdecimal'

require 'chickens/version'
require 'chickens/exception'
require 'chickens/errors'
require 'chickens/input_filter'
require 'chickens/additional_filter'
require 'chickens/string_filter'
require 'chickens/integer_filter'
require 'chickens/float_filter'
require 'chickens/boolean_filter'
require 'chickens/duck_filter'
require 'chickens/date_filter'
require 'chickens/time_filter'
require 'chickens/file_filter'
require 'chickens/model_filter'
require 'chickens/array_filter'
require 'chickens/hash_filter'
require 'chickens/symbol_filter'
require 'chickens/outcome'
require 'chickens/command'

module Chickens
  class << self
    def error_message_creator
      @error_message_creator ||= DefaultErrorMessageCreator.new
    end

    def error_message_creator=(creator)
      @error_message_creator = creator
    end

    def cache_constants=(val)
      @cache_constants = val
    end

    def cache_constants?
      @cache_constants
    end
  end
end

Chickens.cache_constants = true
