require 'chickens/hash_filter'
require 'chickens/array_filter'

module Chickens
  class AdditionalFilter < InputFilter
    def self.inherited(subclass)
      type_name = subclass.name[/^Chickens::([a-zA-Z]*)Filter$/, 1].underscore

      Chickens::HashFilter.register_additional_filter(subclass, type_name)
      Chickens::ArrayFilter.register_additional_filter(subclass, type_name)
    end
  end
end
