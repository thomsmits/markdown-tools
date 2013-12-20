# -*- coding: utf-8 -*-

require_relative 'element'

module Domain

  ##
  # Represents a single chapter of the presentation.
  class Chapter < Element

    attr_accessor :title, :id, :slides

    ##
    # Create a new chapter
    # @param [String] title title of the chapter
    # @param [String] id chapter id for references
    def initialize(title, id = '')
      @title, @id, @slides = title, id, [ ]
    end

    # Add a slide to the presentation
    # @param [Slide] slide the slide to be added
    def add_slide(slide)
      @slides << slide
    end

    ##
    # Return string representation
    def to_s
      "#{@title}"
    end

    ##
    # Return all slides in the chapter
    def each
      @slides.each { |s| yield s }
    end

    ##
    # Render contents
    # @param [Renderer] renderer Rendering class used for generation
    def render(renderer)
      renderer.chapter_start(title, @slides[0].number - 1, id)
      @slides.each { |slide| slide.render(renderer) }
      renderer.chapter_end
    end
  end
end
