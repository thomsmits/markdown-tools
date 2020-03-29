require_relative 'element'
require_relative 'line_element'

module Domain
  ##
  # Heading
  class Footnote < LineElement
    attr_reader :key, :text

    ##
    # Create a new heading
    # @param [String] key key of the footnote
    # @param [String] text text of the footnote
    def initialize(key, text)
      super()
      @key = key
      @text = text
    end

    ##
    # Return a string representation of this element
    # @return [String] string representation
    def to_s
      @text
    end

    ##
    # Compare this object with another one
    # @param [Footnote] other the other one
    def ==(other)
      @key == other.key && @text == other.text
    end
  end
end

