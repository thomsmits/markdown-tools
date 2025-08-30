require_relative 'element'
require_relative 'block_elements/footnote'

module Domain
  ##
  # Represents a single chapter of the presentation.
  class Chapter < Element
    attr_accessor :title, :id, :sections, :links

    ##
    # Create a new chapter
    # @param [String] title title of the chapter
    # @param [String] id chapter id for references
    def initialize(title, id = '')
      super()
      @title = title
      @id = id
      @sections = []
      @links = []
    end

    # Add a slide to the presentation
    # @param [Section] section the section to be added
    # @return self
    def <<(section)
      @sections << section
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
      @sections.each(&block)
    end

    ##
    # Call the provided block on each content element.
    def each_content_element(&block)
      @sections.each { |s| s.each_content_element(&block) }
    end

    ##
    # Render contents
    # @param [Renderer] other renderer used for generation
    def >>(other)
      page_number = !@sections.empty? ? @sections[0].number - 1 : 0

      other.chapter_start(title, page_number, id)
      @sections.each { |section| section >> other }
      other.chapter_end
    end
  end
end
