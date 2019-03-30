require_relative 'element'
require_relative 'line_element'

module Domain
  ##
  # Button with output
  class ButtonWithLog < Button
    render_method :button_with_log
  end
end
