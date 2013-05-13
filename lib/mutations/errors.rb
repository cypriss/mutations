module Mutations

  # Offers a non-localized, english only, non configurable way to get error messages.  This probably isnt good enough for users as-is.
  class DefaultErrorMessageCreator

    MESSAGES = Hash.new("is invalid").tap do |h|
      h.merge!(
        # General
        :nils => "can't be nil",
        :required => "is required",

        # Datatypes
        :string => "isn't a string",
        :integer => "isn't an integer",
        :boolean => "isn't a boolean",
        :hash => "isn't a hash",
        :array => "isn't an array",
        :model => "isn't the right class",

        # Date
        :date => "date doesn't exist",
        :before => "isn't before given date",
        :after => "isn't after given date",

        # String
        :empty => "can't be blank",
        :max_length => "is too long",
        :min_length => "is too short",
        :matches => "isn't in the right format",
        :in => "isn't an option",

        # Array
        :class => "isn't the right class",

        # Integer
        :min => "is too small",
        :max => "is too big",

        # Model
        :new_records => "isn't a saved model"
      )
    end

    # key: the name of the field, eg, :email. Could be nil if it's an array element
    # error_symbol: the validation symbol, eg, :matches or :required
    # options:
    #  :index -- index of error if it's in an array
    def message(key, error_symbol, options = {})
      if options[:index]
        "#{(key || 'array').to_s.titleize}[#{options[:index]}] #{MESSAGES[error_symbol]}"
      else
        "#{key.to_s.titleize} #{MESSAGES[error_symbol]}"
      end
    end
  end

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
      @index = options[:index]
    end

    def symbolic
      @symbol
    end

    def message
      @message ||= Mutations.error_message_creator.message(@key, @symbol, :index => @index)
    end

    def message_list
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
  class ErrorHash < Hash

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
    def message_list
      list = []
      each do |k, v|
        list.concat(v.message_list)
      end
      list
    end
  end

  class ErrorArray < Array
    def symbolic
      map {|e| e && e.symbolic }
    end

    def message
      map {|e| e && e.message }
    end

    def message_list
      compact.map {|e| e.message_list }.flatten
    end
  end
end
