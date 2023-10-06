require_relative 'element'
require_relative 'button'

module Domain
  ##
  # Link CSS to output
  class ButtonLiveCSS < Button
    ## Create a new button
    # @param [String] line_id id of the source line
    # @param [String] fragment html code the button refers to
    def initialize(line_id, fragment)
      super(line_id)
      @fragment = fragment
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] other Renderer to be used.
    def >>(other)
      other.live_css(@line_id, @fragment)
    end
  end
end
