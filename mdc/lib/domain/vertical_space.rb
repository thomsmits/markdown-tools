require_relative 'element'
require_relative 'line_element'

module Domain
  ##
  # A vertical space
  class VerticalSpace < LineElement
    ##
    # Render the element
    # @param [Rendering::Renderer] other Renderer to be used..
    def >>(other)
      other.vertical_space
    end

    ##
    # Return a string representation of this element
    # @return [String] string representation
    def to_s
      ''
    end
  end
end
