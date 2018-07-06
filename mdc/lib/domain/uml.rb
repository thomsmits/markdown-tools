# -*- coding: utf-8 -*-

require_relative 'block_element'

module Domain

  ##
  # Inline UML, embedded in the slide and compiled to a graphic
  class UML < BlockElement

    attr_accessor :picture_name, :width_slide, :width_plain

    ##
    # Create a new element
    def initialize(picture_name, width_slide, width_plain)
      super('')
      @picture_name = picture_name
      @width_slide, @width_plain = width_slide, width_plain
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.uml(@picture_name, @content, @width_slide, @width_plain)
    end
  end
end
