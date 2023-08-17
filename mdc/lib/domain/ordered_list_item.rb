require_relative 'unordered_list'

module Domain
  ##
  # Item of an ordered list
  class OrderedListItem < BlockElement
    attr_accessor :parent

    render_method :ol_item

    ##
    # Create a new element with the given content
    # @param [String] content content of the item
    def initialize(content)
      super(content)
      @parent = nil
    end
  end
end
