# -*- coding: utf-8 -*-

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
  end
end