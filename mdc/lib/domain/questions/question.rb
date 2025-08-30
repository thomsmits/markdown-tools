require_relative '../block_elements/block_element'

module Domain
  ##
  # Question
  class Question < BlockElement
    render_method :question
  end
end
