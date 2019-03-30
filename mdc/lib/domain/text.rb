require_relative 'block_element'

module Domain
  ##
  # Text
  class Text < BlockElement
    render_method :text
  end
end
