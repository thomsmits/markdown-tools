module Domain
  ##
  # Element of the presentation
  class Element
    attr_accessor :order

    ##
    # Create a new element with the given content
    # @param [Fixnum] order the order of displaying the item
    def initialize(order = 0)
      @order = order
    end

    ##
    # Create a digest of the content
    # @return [String] a digest of the slide
    def digest
      ''
    end

    ##
    # Call the provided block on each content element.
    def each_content_element(&block)
      # Do nothing
    end
  end
end
