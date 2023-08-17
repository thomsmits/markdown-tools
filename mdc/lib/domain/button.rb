require_relative 'element'
require_relative 'line_element'

module Domain
  ##
  # Button to cause some action
  class Button < LineElement
    ##
    # Add the correct rendering method to the class
    # @param [Symbol] name name of the render method
    def self.render_method(name)
      # Inject a new method '>>' to the class
      define_method(:>>) do |renderer|
        renderer.send(name, @line_id)
      end
    end

    attr_accessor :line_id

    render_method :button

    ## Create a new button
    # @param [String] line_id id of the source line
    def initialize(line_id)
      super()
      @line_id = line_id
    end
  end
end
