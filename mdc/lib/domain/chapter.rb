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
      @title = title
      @id = id
      @slides = []
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
      @title.to_s
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
    # @param [Renderer] renderer renderer used for generation
    def >>(renderer)
      page_number = !@slides.empty? ? @slides[0].number - 1 : 0

      renderer.chapter_start(title, page_number, id)
      @slides.each { |slide| slide >> renderer }
      renderer.chapter_end
    end
  end
end
