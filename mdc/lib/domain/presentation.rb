# -*- coding: utf-8 -*-

require_relative 'chapter'
require_relative 'toc'

module Domain

  ##
  # Representation of the whole presentation
  class Presentation

    attr_accessor :slide_language, :title1, :title2, :section_number, :section_name, :author, :copyright,
                  :default_language, :chapters, :toc, :description, :term, :comments, :create_index, :bibliography

    ##
    # Create a new presentation
    # @param [String] slide_language the language
    # @param [String] title1 first title
    # @param [String] title2 second title
    # @param [String] section_number number of the section
    # @param [String] section_name name of the section
    # @param [String] copyright copyright information
    # @param [String] author author of the presentation
    # @param [String] default_language default programming language
    # @param [String] description
    # @param [String] term Term of the presentation
    # @param [Boolean] create_index Should the document contain an index at the end
    # @param [String] bibliography File with bibliography information
    #
    def initialize(slide_language, title1, title2, section_number, section_name, copyright, author, default_language, description,
                   term, create_index, bibliography)
      @slide_language = slide_language
      @title1, @title2, @section_number, @section_name = title1, title2, section_number, section_name
      @copyright, @author, @default_language = copyright, author, default_language
      @description, @term = description, term
      @create_index = create_index
      @bibliography = bibliography

      @chapters = [ ]
      @comments = [ ]
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
    # called after all slides and chapters have been added to the presentation
    def build_toc
      @chapters.each do |chapter|

        @toc.add(chapter.id, chapter.title)

        chapter.each { |slide|
          toc.add_sub_entry(chapter.id, slide.id, slide.title) unless slide.skip
        }
      end
    end

    ##
    # Create a digest of the content with the given length
    # @param [Fixnum] length length of the digest in characters
    # @return [String] a digest of the presentation, i.e. the first length characters
    def digest(length)
      digest = ''
      @chapters.each { |chapter| digest << chapter.digest }
      digest.gsub!("\n", '')
      digest.gsub!('_', '')
      digest.gsub!('*', '')
      digest.squeeze!(' ')
      digest[0...length]
    end

    ##
    # Render the presentation
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      build_toc
      renderer.presentation_start(@slide_language, @title1, @title2, @section_number, @section_name, @copyright, @author, @description, @term, @bibliography)
      renderer.render_toc(@toc)
      @chapters.each { |chapter| chapter.render(renderer) }
      renderer.presentation_end(@slide_language, @title1, @title2, @section_number, @section_name, @copyright, @author, @create_index, @bibliography)
    end
  end
end
