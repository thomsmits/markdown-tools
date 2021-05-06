require_relative 'element'
require_relative 'line_element'

module Domain
  ##
  # A multiple choice element
  class MultipleChoice < LineElement
    attr_accessor :text, :correct

    ##
    # Create a new object.
    # @param [String] text The text of the multiple choice element
    # @param [Boolean] correct Indicator whether this is the correct choice
    def initialize(text, correct)
      super()
      @text = text
      @correct = correct
    end

    ##
    # Return a string representation of this element
    # @return [String] string representation
    def to_s
      "[X] #{@text}"  if @correct
      "[ ] #{@text}"  unless @correct
    end

    ##
    # Call the provided block on each content element.
    def each_content_element(&block)
      block.call(self.class, @text)
    end
  end
end
