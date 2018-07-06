# -*- coding: utf-8 -*-

require_relative 'element'
require_relative 'block_element'

module Domain

  ##
  # HTML code (can only be used in HTML slides)
  class HTML < BlockElement
    render_method :html
  end
end
