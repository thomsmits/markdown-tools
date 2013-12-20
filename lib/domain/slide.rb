# -*- coding: utf-8 -*-

require_relative 'container'

module Domain

  ##
  # A single slide of the presentation
  class Slide < Container

    attr_accessor :title, :id, :number, :skip

    ##
    # Create a new instance
    # @param [String] id slide id
    # @param [String] title title of the slide
    # @param [Fixnum] number number of slide
    # @param [Boolean] skip indicates a hidden slide
    def initialize(id, title, number, skip)
      super()
      @title, @id, @number, @skip = title, id, number, skip
    end

    ##
    # Render the Slide
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      return  if @skip
      renderer.slide_start(@title, @number, @id, contains_code?)
      @elements.each { |e| e.render(renderer) }
      renderer.slide_end
    end

    ##
    # Indicate whether the slide contains code
    # @return [Boolean] true if slide contains code, otherwise false
    def contains_code?
      @elements.each { |e| return true  if e.instance_of?(Source) }
      false
    end

    ##
    # Return a string representation
    # @return [String] string representation
    def to_s
      "#{@title}"
    end
  end
end