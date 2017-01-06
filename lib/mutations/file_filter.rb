module Mutations
  class FileFilter < AdditionalFilter
    @default_options = {
      :nils => false,       # true allows an explicit nil to be valid. Overrides any other options
      :upload => false,     # if true, also checks the file is has original_filename and content_type methods.
      :size => nil          # An integer value like 1_000_000 limits the size of the file to 1M bytes
    }

    def filter(data)

      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end
      
      # Now check if it's empty:
      return [data, :empty] if data == ""

      # Ensure the data responds to each of the methods
      methods = [:read, :size]
      methods.concat([:original_filename, :content_type]) if options[:upload]
      methods.each do |method|
        return [data, :file] unless data.respond_to?(method)
      end

      if options[:size].is_a?(Integer)
        return [data, :size] if data.size > options[:size]
      end

      # We win, it's valid!
      [data, nil]
    end
  end
end
