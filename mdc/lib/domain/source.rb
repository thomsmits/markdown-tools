require_relative 'block_element'

module Domain
  ##
  # Source code
  class Source < BlockElement
    attr_accessor :language, :caption

    ##
    # Create a new source code fragment with the given language
    # @param [String] language the programming language
    # @param [String] caption caption of the source code
    # @param [Fixnum] order the order of displaying the item
    def initialize(language, caption = nil, order = 0)
      super('', order)
      @language = language
      @caption = caption
    end

    ##
    # Return a string representation of the object
    # @return [String] a string representation
    def to_s
      @content.chomp
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def >>(renderer)
      renderer.code_start(@language, @caption)
      renderer.code(@content)
      renderer.code_end(@caption)
    end
  end
end
