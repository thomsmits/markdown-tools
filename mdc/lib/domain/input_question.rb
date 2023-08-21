require_relative 'block_element'

module Domain
  ##
  # Group of multiple choice questions
  class InputQuestion < BlockElement
    attr_reader :values

    ##
    # Create a new instance
    # @param [Array<String>] values possible answers
    def initialize(values)
      super('')
      @values = values
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] other Renderer to be used..
    def >>(other)
      other.input_question(@values)
    end
  end
end
