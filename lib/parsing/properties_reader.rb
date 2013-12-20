# -*- coding: utf-8 -*-

module Parsing

  ## Helper class to read and parse Java like properties files
  class PropertiesReader

    ##
    # Create a new instance
    # @param [String] file_name name of properties file
    def initialize(file_name)
      lines = File.readlines(file_name, "\n", :encoding => 'UTF-8')
      @result = {}

      lines.each { |line|
        next  if /^[ ]*#.*/ =~ line

        if /(.*)=(.*)/ =~ line
          @result[ $1.strip ] = $2.strip
        end
      }
    end

    ##
    # Read the value for the given properties key
    # @param [String] key the key to look up
    # @return [String] the value for the key
    def get(key)
      @result[key]
    end
  end
end
