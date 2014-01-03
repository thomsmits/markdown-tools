# -*- coding: utf-8 -*-

require_relative 'renderer_latex'
require_relative '../messages'

module Rendering

  ##
  # Render the presentation into a latex file for further processing
  # using LaTeX
  class RendererLatexPlain < RendererLatex

    ##
    # Initialize the renderer
    # @param [IO] io target of output operations
    # @param [String] language the default language for code snippets
    # @param [String] result_dir location for results
    # @param [String] image_dir location for generated images (relative to result_dir)
    # @param [String] temp_dir location for temporary files
    def initialize(io, language, result_dir, image_dir, temp_dir)
      super(io, language, result_dir, image_dir, temp_dir)
      @ul_level = 1
    end

    ##
    # Indicates whether the renderer handles animations or not. false indicates
    # that slides should not be repeated.
    def handles_animation?
      false
    end

    ##
    # Start a chapter
    # @param [String] title the title of the chapter
    # @param [String] number the number of the chapter
    # @param [String] id the uniquie id of the chapter (for references)
    def chapter_start(title, number, id)
      @io << "\\section{#{title}}\\label{#{id}}" << nl << nl
    end

    ## End of a chapter
    def chapter_end
      @io << nl
    end

    ##
    # Start of presentation
    # @param [String] title1 first title
    # @param [String] title2 second title
    # @param [String] section_number number of the section
    # @param [String] section_name name of the section
    # @param [String] copyright copyright information
    # @param [String] author author of the presentation
    # @param [String] term the current term of the lecture/presentation
    def presentation_start(title1, title2, section_number, section_name, copyright, author, term = '')
      @io << <<-ENDOFTEXT
      \\include{preambel_plain}
      \\include{lst_javascript}
      \\include{lst_console}
      \\include{lst_css}
      \\begin{document}
      \\changefont{ptm}{m}{n}  % Times New Roman
      \\tableofcontents
      ENDOFTEXT
    end

    ##
    # End of presentation
    # @param [String] title1 first title
    # @param [String] title2 second title
    # @param [String] section_number number of the section
    # @param [String] section_name name of the section
    # @param [String] copyright copyright information
    # @param [String] author author of the presentation
    def presentation_end(title1, title2, section_number, section_name, copyright, author)
      @io << '\end{document}' << nl
    end

    ##
    # Start of slide
    # @param [String] title the title of the slide
    # @param [String] number the number of the slide
    # @param [String] id the unique id of the slide (for references)
    # @param [Boolean] contains_code indicates whether the slide contains code fragments
    def slide_start(title, number, id, contains_code)
      @io << "\\subsection{#{inline_code(title)}}\\label{#{id}}" << nl
      @slide_ended = false
    end

    ##
    # End of slide
    def slide_end
      @io << nl
    end

    ##
    # Beginning of a comment section, i.e. explanations to the current slide
    def comment_start
      @io << nl
      @slide_ended = true
    end

    ##
    # End of comment section
    def comment_end
    end
  end
end
