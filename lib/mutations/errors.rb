module Mutations  
  class DefaultErrorMessageCreator
    def initialize
    end

    def message(key, error_symbol)
    end
  end

  # mutation = Foo.run(blah: 2)
  # mutation.errors.list
  # mutation.errors.symbolic
  # mutation.errors.message
  
  class ErrorAtom

    # NOTE: in the future, could also pass in:
    #  - error type
    #  - value (eg, string :name, length: 5 # value=5)

    # ErrorAtom.new(:name, :too_short)
    # ErrorAtom.new(:name, :too_short, message: "is too short")
    def initialize(key, error_symbol, options = {})
      @key = key
      @symbol = error_symbol
      @message = options[:message]
    end

    def symbolic
      @symbol
    end

    def message
      @message ||= Mutations.error_message_creator.message(@key, @symbol)
    end

    def messeage_list
      Array(message)
    end
  end

  # mutation.errors is an ErrorHash instance like this:
  # {
  #   email: ErrorAtom(:matches),
  #   name: ErrorAtom(:too_weird, message: "is too weird"),
  #   adddress: { # Nested ErrorHash object
  #     city: ErrorAtom(:not_found, message: "That's not a city, silly!"),
  #     state: ErrorAtom(:in)
  #   }
  # }
  class ErrorHash < HashWithIndifferentAccess

    # Returns a nested HashWithIndifferentAccess where the values are symbols.  Eg:
    # {
    #   email: :matches,
    #   name: :too_weird,
    #   adddress: {
    #     city: :not_found,
    #     state: :in
    #   }
    # }
    def symbolic
      HashWithIndifferentAccess.new.tap do |hash|
        each do |k, v|
          hash[k] = v.symbolic
        end
      end
    end

    # Returns a nested HashWithIndifferentAccess where the values are messages. Eg:
    # {
    #   email: "isn't in the right format",
    #   name: "is too weird",
    #   adddress: {
    #     city: "is not a city",
    #     state: "isn't a valid option"
    #   }
    # }
    def message
      HashWithIndifferentAccess.new.tap do |hash|
        each do |k, v|
          hash[k] = v.message
        end
      end
    end

    # Returns a flat array where each element is a full sentence. Eg:
    # [
    #   "Email isn't in the right format.",
    #   "Name is too weird",
    #   "That's not a city, silly!",
    #   "State isn't a valid option."
    # ]
    def messeage_list
      list = []
      each do |k, v|
        list.concat(v.message_list)
      end
      list
    end
  end
end