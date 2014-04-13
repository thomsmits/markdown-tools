# -*- coding: utf-8 -*-

require_relative '../parsing/properties_reader'

module Domain
  ##
  # License information
  class License

    attr_accessor :url, :downloaded, :date, :license, :creator, :title, :source

    ##
    # Create a new instance.
    # @param [String] url url where the object can be found
    # @param [String] downloaded date the object was downloaded
    # @param [String] license license of the object
    # @param [String] creator person who created the object
    # @param [String] title title of the object
    # @param [String] source source of the object to be noted
    def initialize(url = nil, downloaded = nil, date = nil, license = nil, creator = nil, title = nil, source = nil)
      @url, @downloaded, @date, @license, @creator, @title, @source =
          url, downloaded, date, license, creator, title, source
    end

    ##
    # Create license from properties
    # @param [Parsing::PropertiesReader] props properties to be used
    def self.create_from_props(props)
      License.new(props.get('URL'),
                  props.get('Downloaded'),
                  props.get('Date'),
                  props.get('License'),
                  props.get('Creator'),
                  props.get('Title'),
                  props.get('Source'))
    end
  end
end
