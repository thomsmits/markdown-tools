require_relative 'element'

module Domain
  ##
  # Base class for all presentation elements that can contain other elements
  class Container < Element
    # Mix in the enumerable mixin
    include Enumerable

    attr_accessor :elements

    ##
    # Create a new instance
    def initialize
      super()
      # @type [Array<Element>]
      @elements = []
    end

    ##
    # Add an element to the container
    # @param [Element] element element to be added
    # @return self
    def <<(element)
      @elements << element
      self
    end

    ##
    # Return the last element added
    # @return [Element|nil] last element added
    def current_element
      @elements.last
    end

    ##
    # Create a digest of the content
    # @return [String] a digest of the slide
    def digest
      digest = ''
      @elements.each { |element| digest << element.digest << ' ' }
      digest
    end

    ##
    # Iterate over all contained elements.
    def each(&block)
      @elements.each(&block)
    end

    ##
    # Call the provided block on each content element.
    def each_content_element(&block)
      @elements.each { |e| e.each_content_element(&block) }
    end
  end
end
