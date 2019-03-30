require_relative 'element'
require_relative 'line_element'

module Domain
  ##
  # Link output to code on previous slide
  class ButtonLinkPrevious < Button
    render_method :link_previous
  end
end
