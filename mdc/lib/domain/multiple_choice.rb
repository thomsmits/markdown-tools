require_relative 'element'
require_relative 'line_element'

module Domain
  ##
  # A multiple choice element
  class MultipleChoice < LineElement
    attr_accessor :text, :correct

    ##
    # Create a new object
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
  end
end
