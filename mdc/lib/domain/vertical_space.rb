# -*- coding: utf-8 -*-

require_relative 'element'
require_relative 'line_element'

module Domain

  ##
  # A vertical space
  class VerticalSpace < LineElement

    ##
    # Create a new object
    def initialize
      super()
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def >>(renderer)
      renderer.vertical_space
    end

    ##
    # Return a string representation of this element
    # @return [String] string representation
    def to_s
      ''
    end
  end
end
