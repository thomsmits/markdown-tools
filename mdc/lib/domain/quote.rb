require_relative 'block_element'

module Domain
  ##
  # Quote
  class Quote < BlockElement
    attr_accessor :source, :source_nodes

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
      c = render_sub_nodes(renderer)
      s = if @source_nodes.nil?
            nil
          else
            @source_nodes.render(renderer.line_renderer)
          end
      renderer.quote(c, s)
    end
  end
end
