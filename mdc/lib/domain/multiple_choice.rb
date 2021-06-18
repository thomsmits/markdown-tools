require_relative 'element'
require_relative 'block_element'

module Domain
  ##
  # A multiple choice element
  class MultipleChoice < BlockElement
    attr_accessor :correct

    ##
    # Create a new object.
    # @param [String] content The text of the multiple choice element
    # @param [Boolean] correct Indicator whether this is the correct choice
    def initialize(content, correct)
      super()
      @content = content
      @correct = correct
    end

    ##
    # Return a string representation of this element
    # @return [String] string representation
    def to_s
      "[X] #{@content}"  if @correct
      "[ ] #{@content}"  unless @correct
    end

    ##
    # Call the provided block on each content element.
    def each_content_element(&block)
      block.call(self, self.class, @content)
    end
  end
end
