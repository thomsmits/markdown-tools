# -*- coding: utf-8 -*-

require_relative 'block_element'

module Domain

  ##
  # Question
  class Question < BlockElement
    render_method :question
  end
end
