require_relative 'element'
require_relative 'line_element'

module Domain
  ##
  # Heading
  class Link < LineElement
    attr_reader :key, :target, :title

    ##
    # Create a new heading
    # @param [String] key key of the link
    # @param [String] target target URL of the link
    # @param [String] title an (optional) title
    def initialize(key, target, title=nil)
      super()
      @key = key
      @target = target
      @title = title
    end

    ##
    # Return a string representation of this element
    # @return [String] string representation
    def to_s
      @target
    end

    ##
    # Compare this object with another one
    # @param [Footnote] other the other one
    def ==(other)
      @key == other.key && @target == other.target
    end
  end
end

