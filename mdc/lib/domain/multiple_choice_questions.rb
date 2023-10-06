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
    # @param [Rendering::Renderer] other Renderer to be used..
    def >>(other)
      p_correct, p_wrong = percentages
      other.multiple_choice_start(@inline)
      @questions.each do |e|
        text = e.render_sub_nodes(other)
        correct = e.correct
        other.multiple_choice(text, correct, p_correct, p_wrong, @inline)
      end
      other.multiple_choice_end(@inline)
    end

    ##
    # Call the provided block on each content element.
    def each_content_element(&block)
      @questions.each { |e| e.each_content_element(&block) }
    end

    ##
    # Get the number of correct questions
    # @return [Integer] number of correct questions
    def number_correct
      @questions.count(&:correct)
    end

    ##
    # Get the percentage for correct and wrong questions
    # @return [Array<Integer|Float, Integer|Float>] percentage for correct and wrong answers
    def percentages
      no_correct = number_correct
      percentage_correct = (1.0 / no_correct * 100).round(5)
      percentage_wrong   = (1.0 / (@questions.length - no_correct) * 100).round(5)
      [percentage_correct, percentage_wrong]
    end
  end
end
