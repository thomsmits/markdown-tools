require_relative 'block_element'

module Domain
  ##
  # Group of multiple choice questions
  class MultipleChoiceQuestions < BlockElement
    attr_reader :questions
    attr_accessor :inline

    ##
    # Create a new instance
    # @param [Boolean] inline true if all checkboxes should be in one line
    def initialize(inline = false)
      super('')
      @questions = []
      @inline = inline
    end

    ##
    # Add a new question to the group
    # @param [Domain::MultipleChoice] question the question to be added
    def <<(question)
      @questions << question
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def >>(renderer)
      renderer.multiple_choice_start(@inline)
      @questions.each do |e|
        renderer.multiple_choice(e)
      end
      renderer.multiple_choice_end(@inline)
    end
  end
end
