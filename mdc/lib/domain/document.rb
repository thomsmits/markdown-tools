# frozen_string_literal: true
module Domain

  ##
  # A generic document.
  class Document
    attr_accessor :chapters, :toc, :title

    ##
    # Create a new presentation
    # @param [String] title
    #
    def initialize(title)
      @title = title
      @chapters = []
      @toc = TOC.new
    end

    ##
    # Add a chapter to the presentation
    # @param [Domain::Chapter] chapter the chapter to add
    # @return self
    def <<(chapter)
      @chapters << chapter
      self
    end

    ##
    # Build the table of contents from the contained data. This method must be
    # called after all chapters have been added to the document
    def build_toc
      @chapters.each do |chapter|
        @toc.add(chapter.id, chapter.title)

        chapter.each do |slide|
          toc.add_sub_entry(chapter.id, slide.id, slide.title) unless slide.skip
        end
      end
    end

    ##
    # Render the document
    # @param [Rendering::Renderer] other Renderer to be used..
    def >>(other)
      build_toc
      other.document_start(@title)
      other.render_toc(@toc)
      @chapters.each { |chapter| chapter >> other }
      other.document_end(@title)
    end

    ##
    # Iterate over all chapters.
    def each(&block)
      @chapters.each(&block)
    end
  end
end
