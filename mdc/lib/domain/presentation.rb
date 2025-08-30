require_relative 'chapter'
require_relative 'toc'
require_relative 'document'

module Domain
  ##
  # Representation of the whole presentation
  class Presentation < Document
    attr_accessor :slide_language, :title2, :section_number,
                  :section_name, :author, :copyright,
                  :def_prog_lang, :chapters, :toc,
                  :description, :term, :create_index,
                  :bibliography, :last_change

    ##
    # Create a new presentation
    # @param [String] slide_language the language
    # @param [String] title1 first title
    # @param [String] title2 second title
    # @param [String|Integer] section_number number of the section
    # @param [String] section_name name of the section
    # @param [String] copyright copyright information
    # @param [String] author author of the presentation
    # @param [String] def_prog_lang default programming language
    # @param [String] description additional description, e.g.
    #                 copyright information
    # @param [String] term Term of the presentation
    # @param [Boolean] create_index Should the document
    #                  contain an index at the end
    # @param [String, nil] bibliography File with bibliography information
    #
    def initialize(slide_language, title1, title2, section_number, section_name,
                   copyright, author, def_prog_lang, description,
                   term, create_index, last_change, bibliography)
      super(title1)
      @slide_language = slide_language
      @title2 = title2
      @section_number = section_number
      @section_name = section_name
      @copyright = copyright
      @author = author
      @def_prog_lang = def_prog_lang
      @description = description
      @term = term
      @create_index = create_index
      @last_change = last_change
      @bibliography = bibliography
    end

    ##
    # Access to the first title.
    # @return [String] the first title.
    def title1
      @title
    end

    ##
    # Render the presentation
    # @param [Rendering::Renderer] other Renderer to be used..
    def >>(other)
      build_toc
      other.presentation_start(@slide_language, @title1,
                               @title2, @section_number, @section_name,
                               @copyright, @author, @description, @term, @last_change,
                               @bibliography)
      other.render_toc(@toc)
      @chapters.each { |chapter| chapter >> other }
      other.presentation_end(@slide_language, @title1,
                             @title2, @section_number, @section_name,
                             @copyright, @author, @create_index, @bibliography)
    end
  end
end
