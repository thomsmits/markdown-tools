# -*- coding: utf-8 -*-

require_relative 'element'
require_relative 'line_element'

module Domain

  ##
  # Button with output
  class ButtonWithLogPre < Button
    render_method :button_with_log_pre
  end
end
