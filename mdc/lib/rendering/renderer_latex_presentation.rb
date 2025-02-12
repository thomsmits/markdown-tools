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
          \newenvironment{theindex}
           {\let\item\par
            %definitions for subitem etc
           }{}
          \newcommand\indexspace{}
          \makeindex

          <%- if slide_language == 'DE' -%>
            \usepackage[main=ngerman, english]{babel}       % Deutsch und Englisch unterstützen
            \selectlanguage{ngerman}
            <% locale = 'de_DE' %>
          <%- else -%>
            \usepackage[main=english, ngerman]{babel}       % Deutsch und Englisch unterstützen
            \selectlanguage{english}
            <% locale = 'de_DE' %>
          <%- end -%>

          <%- unless bibliography.nil? -%>
            \setbeamertemplate{bibliography item}{}

            \usepackage[backend=biber,
              isbn=false,                     % ISBN nicht anzeigen, gleiches geht mit nahezu allen anderen Feldern
              sortlocale=<%= locale %>,
              autocite=inline,                % regelt Aussehen für \autocite (inline=\parancite)
              hyperref=true,                  % Hyperlinks für Ziate
              %style=ieee                     % Zitate als Zahlen [1]
              %style=alphabetic               % Zitate als Kürzel und Jahr [Ein05]
              style=authoryear                % Zitate Author und Jahr [Einstein (1905)]
            ]{biblatex}                       % Literaturverwaltung mit BibLaTeX
            \addbibresource{<%= bibliography %>}   % BibLaTeX-Datei mit Literaturquellen einbinden
          <%- end -%>

          \hypersetup{
              pdftitle={<%= title1 %>: <%= section_name %>},
              pdfauthor={<%= author %>},
              pdfsubject={<%= title2 %>}
          }

          \usepackage[euler]{textgreek}

          \mode<presentation>{\input{beamer-template}}
          \newcommand{\copyrightline}[0]{<%= title1 %> | <%= copyright %>}
          \title{<%= title1 %>\\\\ \small <%= title2 %>\\\\ \Large \vspace{8mm} <%= section_name %>}
          \author{\small <%= author %>}
          \date{\color{grau} \small <%= term %>\tiny\vspace{2mm}\\\\ <%= last_change %>}
          \begin{document}
          <% section_id = 'sect_' + Random.rand(10000000).to_s(16) %>
          \begin{frame}\label{<%= section_id %>}
          \pdfbookmark[1]{<%= section_name %>}{<%= section_id %>}
          \maketitle
          \end{frame}

          \begin{frame}
          \pdfbookmark[2]{<%= translate(:toc) %>}{<%= translate(:toc) %>}
          \separator{<%= translate(:toc) %>}
          \end{frame}

          \begin{frame}\frametitle<presentation>{<%= translate(:toc) %>}
          \tableofcontents
          \end{frame}
          !
      ),

      presentation_end: erb(
        %q|

        <%- unless bibliography.nil? -%>
            \section{<%= translate(:literature) %>}
            \begin{frame}
            \separator{<%= translate(:literature) %>}
            \end{frame}

            \begin{frame}[allowframebreaks]{<%= translate(:literature) %>}
            \printbibliography
            \end{frame}
        <%- end -%>

        <%- if create_index -%>
          \section{<%= translate(:index) %>}
          \begin{frame}
          \separator{<%= translate(:index) %>}
          \end{frame}
          \begin{frame}[allowframebreaks]{<%= translate(:index) %>}
          \footnotesize
          \printindex
          \end{frame}
        <%- end -%>
        \end{document}
        |
      ),

      chapter_start: erb(
        %q|
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        \section{<%= line_renderer.render_text(title) %>}\label{<%= id %>}
        \begin{frame}
        \separator{<%= line_renderer.render_text(title) %>}
        \end{frame}|
      ),

      chapter_end: erb(
        '
        '
      ),

      slide_start: erb(
        %q|
        % ********************************************************************************************
        \begin{frame}[fragile]{<%= line_renderer.render_text(title) %>}\label{<%= id %>}
        |
      ),

      slide_end: erb(
        %q(
        \end{frame})
      ),

      comment_start: erb(
        %q(\iffalse)
      ),

      comment_end: erb(
        '\fi'
      ),

      text: erb(
        %q(
        <%= content %>
        \vspace{0.1mm}
        )
      ),

      ul_start: erb(
        %q(
        <%- if @ul_level == 1 -%>
          \vspace{0.2mm}
        <%- elsif @ul_level == 2 -%>
          \vspace{0.2mm}
        <%- end -%>
        \begin{ul<%= @ul_level %>})
      ),

      heading_3: erb(
        %q|
          \vspace{1.5mm}
          \textbf{<%= line_renderer.meta(title) %>}
          \vspace{2mm}
        |
      )

    }.freeze

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
      @io << @templates[:slide_end].result(binding)
    end

    ##
    # Render an image
    # @param [String] location path to image
    # @param [Array] _formats available file formats
    # @param [String] alt alt text
    # @param [String] _title title of image
    # @param [String] width_slide width for slide
    # @param [String] _width_plain width for plain text
    # @param [String] source source of the image
    def image(location, _formats, alt, _title, width_slide, _width_plain, source = nil)
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
      formats = %w[pdf eps]
      img_path = super(picture_name, contents, width_slide, width_plain, 'pdf')
      image(img_path, formats, '', '', new_width, new_width)
    end
  end
end
