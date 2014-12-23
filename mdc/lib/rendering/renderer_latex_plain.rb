# -*- coding: utf-8 -*-

require 'erb'

require_relative 'renderer_latex'
require_relative '../messages'

module Rendering

  ##
  # Render the presentation into a latex file for further processing
  # using LaTeX
  class RendererLatexPlain < RendererLatex

    ## ERB templates to be used by the renderer
    TEMPLATES = {
        presentation_start: erb(
            %q|
            \include{preambel_plain}
            \include{lst_javascript}
            \include{lst_console}
            \include{lst_html}
            \include{lst_css}
            \makeindex
            \titlehead{\vspace{-2cm}\bfseries\sffamily\titlelogo\\\\ \large <%= title1 %>\\\\ \vspace{2mm}\normalsize <%= title2 %>}
            %\titlehead{\vspace{3cm}\sffamily <%= title1 %>\\\\ \vspace{2mm} \small<%= title2 %>}
            \title{\vspace{3cm}<%= section_name  %>}
            \author{\small \sffamily <%= author %>}
            \date{\vspace{1cm}\color{grau} \Large\sffamily <%= term %>\\\\ \scriptsize\vspace{2mm}\today}
            \begin{document}
            \pagenumbering{roman}
            \dedication{\vspace{7cm} \sffamily \small \textit{<%= description %>}}
            %\publishers{Herausgeber}
            \maketitle
            \thispagestyle{empty}
            \newpage
            \changefont{ptm}{m}{n}  % Times New Roman
            \tableofcontents
            \newpage
            \pagenumbering{arabic}
            |
        ),

        presentation_end: erb(
            %q|
            \clearpage
            \pagenumbering{roman}
            \printindex
            \end{document}
            |
        ),

        chapter_start: erb(
            %q|\section{<%= title %>}\label{<%= id %>}

            |
        ),

        chapter_end: erb(
            %q|
            |
        ),

        slide_start: erb(
            %q|\subsection{<%= inline_code(title) %> [<%= number %>]}\label{<%= id %>}
            |
        ),

        slide_end: erb(
            %q|
            |.strip
        ),

        comment_start: erb(
            %q|
            \begin{comment}

            |
        ),

        comment_end: erb(
            %q|
            \end{comment}
            |
        ),

        text: erb(
            %q|
            <%= inline_code(content) %>
            \vspace{0.1mm}
            |
        ),

        ul_start: erb(
            %q|
            <% if @ul_level == 1 %>
              \vspace{0.1mm}
            <% elsif @ul_level == 2 %>
              \vspace{0.1mm}
            <% end %>
            \begin{ul<%= @ul_level %>}
            |
        ),
    }

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
      @last_title = nil
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
    # @param [String] id the unique id of the chapter (for references)
    def chapter_start(title, number, id)
      @io << TEMPLATES[:chapter_start].result(binding)
    end

    ## End of a chapter
    def chapter_end
      @io << TEMPLATES[:chapter_end].result(binding)
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
    # @param [String] description additional description
    def presentation_start(title1, title2, section_number, section_name, copyright, author, description, term = '')
      @io << TEMPLATES[:presentation_start].result(binding)
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
      @io << TEMPLATES[:presentation_end].result(binding)
    end

    ##
    # Start of slide
    # @param [String] title the title of the slide
    # @param [String] number the number of the slide
    # @param [String] id the unique id of the slide (for references)
    # @param [Boolean] contains_code indicates whether the slide contains code fragments
    def slide_start(title, number, id, contains_code)
      unless title == @last_title
        @io << TEMPLATES[:slide_start].result(binding)
        @slide_ended = false
        @last_title = title
      end
    end

    ##
    # End of slide
    def slide_end
      @io << TEMPLATES[:slide_end].result(binding)
    end

    ##
    # Beginning of a comment section, i.e. explanations to the current slide
    def comment_start
      @io << TEMPLATES[:comment_start].result(binding)
      @slide_ended = true
    end

    ##
    # End of comment section
    def comment_end
      @io << TEMPLATES[:comment_end].result(binding)
    end

    ##
    # Render an image
    # @param [String] location path to image
    # @param [Array] formats available file formats
    # @param [String] alt alt text
    # @param [String] title title of image
    # @param [String] width_slide width for slide
    # @param [String] source source of the image
    def image(location, formats, alt, title, width_slide, width_plain, source = nil)

      # Skip images with width 0
      unless /^0$/ === width_plain
        image_latex(location, title, width_plain, source)
      end
    end

    ##
    # Simple text
    # @param [String] content the text
    def text(content)
      @io << TEMPLATES[:text].result(binding)
    end

    ##
    # Start of an unordered list
    def ul_start
      @io << TEMPLATES[:ul_start].result(binding)
      @ul_level += 1
    end

    ##
    # Render an UML inline diagram using an external tool
    # @param [String] picture_name name of the picture
    # @param [String] contents the embedded UML
    # @param [String] width_slide width of the diagram on slides
    # @param [String] width_plain width of the diagram on plain documents
    def uml(picture_name, contents, width_slide, width_plain)
      new_width = calculate_width(width_plain)
      formats = %w(pdf eps)
      img_path = super(picture_name, contents, width_slide, width_plain, 'pdf')
      image(img_path, formats, '', '', new_width, new_width)
    end
  end
end

