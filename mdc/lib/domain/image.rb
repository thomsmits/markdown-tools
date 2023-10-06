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
    # @param [String, nil] width_slide width for slides
    # @param [String, nil] width_plain width for plain text
    def initialize(location, alt, title, width_slide, width_plain)
      super()
      @location = location
      @alt = alt
      @title = title
      @width_slide = width_slide
      @width_plain = width_plain
      @formats = []
      @license = nil
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] other Renderer to be used..
    def >>(other)
      other.image(@location, @formats, @alt, @title, @width_slide,
                  @width_plain, @license&.source)
    end

    ##
    # Return a string representation of this element
    # @return [String] string representation
    def to_s
      @location
    end
  end
end
