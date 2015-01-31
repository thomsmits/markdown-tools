# -*- coding: utf-8 -*-

require_relative 'renderer_latex'
require_relative '../messages'

module Rendering

  ##
  # Render the presentation into a latex file for further processing
  # using LaTeX
  class RendererLatexPresentation < RendererLatex

    ## ERB templates to be used by the renderer
    TEMPLATES = {
        presentation_start: erb(
            %q!
            \include{preambel_presentation}
            \include{lst_javascript}
            \include{lst_console}
            \include{lst_css}
            \include{lst_html}
            \mode<presentation>{\input{beamer-template}}
            \newcommand{\copyrightline}[0]{<%= title1 %> | <%= copyright %>}
            \title{<%= title1 %>\\\\ \small <%= title2 %>\\\\ \Large \vspace{8mm} <%= section_name %>}
            \author{\small <%= author %>}
            \date{\color{grau} \small <%= term %>}
            \begin{document}
            \begin{frame}
            \maketitle
            \end{frame}

            \begin{frame}
            \separator{<%= LOCALIZED_MESSAGES[:toc] %>}
            \end{frame}

            \begin{frame}\frametitle<presentation>{<%= LOCALIZED_MESSAGES[:toc] %>}
            \tableofcontents
            \end{frame}
            !
        ),

        presentation_end: erb(
            %q|
            \end{document}
            |
        ),

        chapter_start: erb(
            %q|
            \section{<%= title %>}\label{<%= id %>}
            \begin{frame}
            \separator{<%= title %>}
            \end{frame}
            |
            ),

        chapter_end: erb(
            %q|
            |
        ),

        slide_start: erb(
            %q|
            \begin{frame}[fragile]{<%= inline_code(title) %>}\label{<%= id %>}
            |
        ),

        slide_end: erb(
            %q|
            \end{frame}
            |
        ),

        comment_start: erb(
            %q|
            \end{frame}
            |
        ),

        comment_end: erb(
            %q|
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
              \vspace{0.2mm}
            <% elsif @ul_level == 2 %>
              \vspace{0.2mm}
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
    end

    ##
    # Method returning the templates used by the renderer. Should be overwritten by the
    # subclasses.
    # @return [Hash] the templates
    def all_templates
      @templates = super.merge(TEMPLATES)
    end

    ##
    # Indicates whether the renderer handles animations or not. false indicates
    # that slides should not be repeated.
    # @return [Boolean] +true+ if animations are supported, otherwise +false+
    def handles_animation?
      true
    end

    ##
    # End of slide
    def slide_end
      @io << @templates[:slide_end].result(binding)  unless @slide_ended
    end

    ##
    # Render an image
    # @param [String] location path to image
    # @param [Array] formats available file formats
    # @param [String] alt alt text
    # @param [String] title title of image
    # @param [String] width_slide width for slide
    # @param [String] width_plain width for plain text
    # @param [String] source source of the image
    def image(location, formats, alt, title, width_slide, width_plain, source = nil)
      # alt contains source, title the description of the image
      # we only render the source
      image_latex(location, alt, width_slide, source)
    end

    ##
    # Render an UML inline diagram using an external tool
    # @param [String] picture_name name of the picture
    # @param [String] contents the embedded UML
    # @param [String] width_slide width of the diagram on slides
    # @param [String] width_plain width of the diagram on plain documents
    def uml(picture_name, contents, width_slide, width_plain)
      new_width = calculate_width(width_slide)
      formats = %w(pdf eps)
      img_path = super(picture_name, contents, width_slide, width_plain, 'pdf')
      image(img_path, formats, '', '', new_width, new_width)
    end
  end
end
