# -*- coding: utf-8 -*-

require_relative 'element'
require_relative 'line_element'

module Domain

  ##
  # Image
  class Image < LineElement

    attr_accessor :location, :formats, :license
    attr_reader :alt, :title, :width_slide, :width_plain

    ##
    # Create a new image
    # @param [String] location path of the image
    # @param [String] alt alternate text
    # @param [String] title title
    # @param [String] width_slide width for slides
    # @param [String] width_plain width for plain text
    def initialize(location, alt, title, width_slide, width_plain)
      super()
      @location, @alt, @title, @width_slide, @width_plain = location, alt, title, width_slide, width_plain
      @formats = [ ]
      @license = nil
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def >>(renderer)
      renderer.image(@location, @formats, @alt, @title, @width_slide, @width_plain,
                     @license.nil? ? nil : @license.source )
    end

    ##
    # Return a string representation of this element
    # @return [String] string representation
    def to_s
      @location
    end
  end
end
