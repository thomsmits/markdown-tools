# -*- coding: utf-8 -*-

require_relative 'block_element'

module Domain

  ##
  # Item of an unordered list
  class UnorderedListItem < BlockElement

    attr_accessor :parent
    render_method :ul_item

    ##
    # Create a new list item with the given content
    # @param [String] content content of the item
    def initialize(content)
      super(content)
      @parent = nil
    end
  end
end
