# -*- coding: utf-8 -*-

module Parsing

  ## Helper class to read and parse Java like properties files
  class PropertiesReader

    ##
    # Create a new instance
    # @param [String] file_name name of properties file
    # @param [String] defaults_file file containing the default values
    # @param [String] separator the separation character
    def initialize(file_name, separator = '=', defaults_file = nil)
      @result = read_file_into_array(file_name, separator)

      if defaults_file.nil?
        @defaults = {}
      else
        @defaults = read_file_into_array(defaults_file, separator)
      end
    end

    ##
    # Read the contents of a java properties file into an associative array
    # @param [String] file_name name of properties file
    # @param [String] separator the separation character
    def read_file_into_array(file_name, separator)
      lines = File.readlines(file_name, "\n", :encoding => 'UTF-8')
      result = {}

      regex = Regexp.new("(.*?)#{separator}(.*)")

      lines.each { |line|
        next  if /^[ ]*#.*/ =~ line

        if regex.match(line)
          result[ $1.strip ] = $2.strip
        end
      }

      result
    end

    ##
    # Read the value for the given properties key
    # @param [String] key the key to look up
    # @return [String] the value for the key
    def get(key)

      value = @result[key]

      if value.nil?
        value = @defaults[key]
      end

      value
    end

    def to_s
      @result.to_s + @defaults.to_s
    end
  end
end
