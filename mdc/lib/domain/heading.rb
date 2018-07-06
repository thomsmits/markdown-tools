# -*- coding: utf-8 -*-

require_relative 'element'
require_relative 'line_element'

module Domain

  ##
  # Heading
  class Heading < LineElement

    attr_reader :level, :title

    ##
    # Create a new heading
    # @param [Fixnum] level of the heading
    # @param [String] title title of the heading
    def initialize(level, title)
      super()
      @level, @title = level, title
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.heading(@level, @title)
    end

    ##
    # Create a digest of the content
    # @return [String] a digest of the slide
    def digest
      @title
    end

    ##
    # Return a string representation of this element
    # @return [String] string representation
    def to_s
      @title
    end
  end
end
