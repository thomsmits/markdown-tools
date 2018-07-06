# -*- coding: utf-8 -*-

require_relative 'block_element'

module Domain

  ##
  # Box
  class Box < BlockElement
    render_method :box
  end
end
