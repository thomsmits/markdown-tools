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
    # @return self
    def <<(slide)
      @slides << slide
      self
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
    # Create a digest of the content
    # @return [String] a digest of the slide
    def digest
      digest = ' '
      @slides.each { |slide| digest << slide.digest << ' ' }
      digest
    end

    ##
    # Render contents
    # @param [Renderer] renderer Rendering class used for generation
    def render(renderer)

      page_number = @slides.length > 0 ? @slides[0].number - 1 : 0

      renderer.chapter_start(title, page_number, id)
      @slides.each { |slide| slide.render(renderer) }
      renderer.chapter_end
    end
  end
end
