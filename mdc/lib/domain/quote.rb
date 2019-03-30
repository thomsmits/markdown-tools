require_relative 'block_element'

module Domain
  ##
  # Quote
  class Quote < BlockElement
    attr_accessor :source

    ##
    # Create a new quote with the given content
    # @param [String] content content of the quote
    def initialize(content = '')
      super(content)
      @source = nil
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def >>(renderer)
      renderer.quote(@content, source)
    end
  end
end
