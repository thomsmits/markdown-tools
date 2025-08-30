require_relative '../block_elements/block_element'

module Domain
  ##
  # Group of multiple choice questions
  class InputQuestion < BlockElement
    attr_reader :values

    ##
    # Create a new instance
    # @param [Array<String>] values possible answers
    def initialize(values = [])
      super('')
      @values = values
    end

    ##
    # Add a value to the question.
    # @param [String] the value to be added.
    def <<(other)
      @values << other
    end
    ##
    # Render the element
    # @param [Rendering::Renderer] other Renderer to be used..
    def >>(other)
      other.input_question(@values)
    end
  end
end
