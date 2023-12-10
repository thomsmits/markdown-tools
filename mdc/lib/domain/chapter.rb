require_relative 'element'
require_relative 'footnote'

module Domain
  ##
  # Represents a single chapter of the presentation.
  class Chapter < Element
    attr_accessor :title, :id, :slides, :links

    ##
    # Create a new chapter
    # @param [String] title title of the chapter
    # @param [String] id chapter id for references
    def initialize(title, id = '')
      super()
      @title = title
      @id = id
      @slides = []
      @links = []
    end

    # Add a slide to the presentation
    # @param [Slide] slide the slide to be added
    # @return self
    def <<(slide)
      @slides << slide
      self
    end

    ##
    # Add a link to the presentation
    # @param [Footnote] link the link to be added
    def add_link(link)
      @links << link
    end

    ##
    # Return string representation
    def to_s
      @title.to_s
    end

    ##
    # Iterate over all slides of the chapter
    def each(&block)
      @slides.each(&block)
    end

    ##
    # Call the provided block on each content element.
    def each_content_element(&block)
      @slides.each { |s| s.each_content_element(&block) }
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
    # @param [Renderer] other renderer used for generation
    def >>(other)
      page_number = !@slides.empty? ? @slides[0].number - 1 : 0

      other.chapter_start(title, page_number, id)
      @slides.each { |slide| slide >> other }
      other.chapter_end
    end
  end
end
