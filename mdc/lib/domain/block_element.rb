require_relative 'element'
require_relative '../constants'

module Domain
  ##
  # Base class for all elements that span more than one line
  class BlockElement < Element
    attr_accessor :content

    ##
    # Create a new element with the given content
    # @param [String] content of the element
    # @param [Fixnum] order the order of displaying the item
    def initialize(content = '', order = 0)
      super(order)
      @content = content
    end

    ##
    # Append a single line to the element
    # @param [String] line to be appended
    # @return self
    def <<(line)
      @content << line
      self
    end

    ##
    # Create a digest of the content
    # @return [String] a digest of the slide
    def digest
      @content
    end

    ##
    # Return a string representation of the object
    # @return [String] a string representation
    def to_s
      @content.strip
    end

    ##
    # Add the correct rendering method to the class
    # @param [Symbol] name name of the render method
    def self.render_method(name)
      # Inject a new method '>>' to the class
      define_method(:>>) do |renderer|
        renderer.send(name, @content)
      end
    end
  end
end
