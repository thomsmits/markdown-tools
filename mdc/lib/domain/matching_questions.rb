require_relative 'block_element'

module Domain
  ##
  # Group of multiple choice questions
  class MatchingQuestions < BlockElement
    attr_reader :questions
    attr_accessor :shuffle

    ##
    # Create a new instance
    # @param [Symbol] shuffle type of shuffling
    def initialize(shuffle = :question)
      super('')
      @questions = []
      @shuffle = shuffle
    end

    ##
    # Add a new question to the group
    # @param [Domain::MatchingQuestion] question the question to be added
    def <<(question)
      @questions << question
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] other Renderer to be used..
    def >>(other)
      other.matching_question_start(@shuffle)
      @questions.each do |e|
        left = e.left.render_sub_nodes(other)
        right = e.right.render_sub_nodes(other)
        other.matching_question(left, right)
      end
      other.matching_question_end(@shuffle)
    end

    ##
    # Call the provided block on each content element.
    def each_content_element(&block)
      @questions.each { |e| e.each_content_element(&block) }
    end
  end
end
