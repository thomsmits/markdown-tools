require_relative 'element'
require_relative 'line_element'
require_relative 'text'

module Domain
  ##
  # A multiple choice element
  class MatchingQuestion < Container
    attr_accessor :left, :right

    ##
    # Create a new object.
    # @param [Domain::Text|String] left left part
    # @param [Domain::Text|String] right right part
    def initialize(left, right)
      super()
      @left = left             if left.is_a? Text
      @left = Text.new(left)   if left.is_a? String

      @right = right           if right.is_a? Text
      @right = Text.new(right) if right.is_a? String
    end

    ##
    # Return a string representation of this element
    # @return [String] string representation
    def to_s
      "#{@left} -> #{@right}"
    end

    ##
    # Call the provided block on each content element.
    def each_content_element(&block)
      block.call(@left,  @left.class,  @left.content)
      block.call(@right, @right.class, @right.content)
    end
  end
end
