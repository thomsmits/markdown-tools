module Parsing
  ## Helper class to read and parse Java like properties files
  class PropertiesReader
    ##
    # Create a new instance
    # @param [String, IO] file name of properties file or IO object to read from
    # @param [String] defaults_file file containing the default values
    # @param [String] separator the separation character
    def initialize(file, separator = '=', defaults_file = nil)
      @result = read_file_into_array(file, separator)

      @defaults = if defaults_file.nil?
                    {}
                  else
                    read_file_into_array(defaults_file, separator)
                  end
    end

    ##
    # Read the contents of a java properties file into an associative array
    # @param [String, IO] file name of properties file or IO object to read from
    # @param [String] separator the separation character
    def read_file_into_array(file, separator)
      lines = if file.respond_to?(:readlines)
                file.readlines("\n")
              else
                File.readlines(file, "\n", encoding: 'UTF-8')
              end

      result = {}

      regex = Regexp.new("(.*?)#{separator}(.*)")

      lines.each do |line|
        # ignore comments
        next if /^[ ]*#.*/ =~ line

        # Add entry to the hash
        regex.match(line) { |m| result[m[1].strip] = m[2].strip }
      end

      result
    end

    ##
    # Read the value for the given properties key
    # @param [String] key the key to look up
    # @return [String] the value for the key
    def [](key)
      @result[key] || @defaults[key]
    end

    ##
    # Catch missing methods to allow simple retrieval of
    # properties using a method like syntax.
    # @param [String] name Name of the method
    def method_missing(name, *_args)
      key = name.to_s
      self[key]
    end

    ##
    # We respond to the missing method call.
    def respond_to_missing?(*_args)
      true
    end

    ##
    # Return string representation
    def to_s
      @result.to_s + @defaults.to_s
    end
  end
end
