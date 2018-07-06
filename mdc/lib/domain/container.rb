# -*- coding: utf-8 -*-

require_relative 'element'

module Domain

  ##
  # Base class for all presentation elements that can contain other elements
  class Container < Element

    attr_accessor :elements

    ##
    # Create a new instance
    def initialize
      super()
      @elements = [ ]
    end

    ##
    # Add an element to the container
    # @param [Element] element element to be added
    def add(element)
      @elements << element
    end

    ##
    # Return the last element added
    # @return [Element] last element added
    def current_element
      @elements.last
    end

    ##
    # Create a digest of the content
    # @return [String] a digest of the slide
    def digest
      digest = ''
      @elements.each { |element| digest << element.digest << ' '}
      digest
    end
  end
end
