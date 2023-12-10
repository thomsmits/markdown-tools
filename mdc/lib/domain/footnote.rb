require_relative 'element'
require_relative 'block_element'

module Domain
  ##
  # Heading
  class Footnote < BlockElement
    attr_reader :key, :footnotes

    ##
    # Create a new heading
    # @param [String] key key of the footnote
    # @param [String] content text of the footnote
    def initialize(key, content)
      super(content)
      @key = key
    end

    ##
    # Return a string representation of this element
    # @return [String] string representation
    def to_s
      @content
    end

    ##
    # Compare this object with another one
    # @param [Footnote] other the other one
    def ==(other)
      @key == other.key && @content == other.content
    end

    ##
    # Render contents
    # @param [Renderer] other renderer used for generation
    def >>(other)
      c = render_sub_nodes(other)
      other.footnote(@key, c)
    end
  end
end
