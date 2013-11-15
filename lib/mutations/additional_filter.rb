require 'mutations/hash_filter'
require 'mutations/array_filter'

module Mutations
  class AdditionalFilter < InputFilter
    def self.inherited(subclass)
      type_name = subclass.name[/^Mutations::([a-zA-Z]*)Filter$/, 1].underscore

      Mutations::HashFilter.register_additional_filter(subclass, type_name)
      Mutations::ArrayFilter.register_additional_filter(subclass, type_name)
    end
  end
end
