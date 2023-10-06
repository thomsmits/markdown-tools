require_relative 'block_element'

module Domain
  ##
  # Inline UML, embedded in the slide and compiled to a graphic
  class UML < BlockElement
    attr_accessor :picture_name, :width_slide, :width_plain

    ##
    # Create a new element.
    # @param [String] picture_name Name of the picture
    # @param [String] width_slide Width in % or the picture on a slide
    # @param [String] width_plain Width in % or the picture on a plain rendering
    def initialize(picture_name, width_slide, width_plain)
      super('')
      @picture_name = picture_name
      @width_slide = width_slide
      @width_plain = width_plain
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] other Renderer to be used..
    def >>(other)
      other.uml(@picture_name, @content, @width_slide, @width_plain)
    end
  end
end
