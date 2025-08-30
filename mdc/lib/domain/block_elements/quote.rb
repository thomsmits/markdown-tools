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
    # @param [Rendering::Renderer] other Renderer to be used..
    def >>(other)
      c = render_sub_nodes(other)
      s = if @source_nodes.nil?
            nil
          else
            @source_nodes.render(other.line_renderer)
          end
      other.quote(c, s)
    end
  end
end
