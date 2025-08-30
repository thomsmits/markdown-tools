module Domain
  ##
  # Element of the section. Base class for
  # all elements that can appear on a page.
  class Element
    attr_accessor :order

    ##
    # Create a new element with the given content
    # @param [Fixnum] order the order of displaying the item
    def initialize(order = 0)
      @order = order
    end

    ##
    # Call the provided block on each content element.
    def each_content_element(&block)
      # Do nothing
    end
  end
end
