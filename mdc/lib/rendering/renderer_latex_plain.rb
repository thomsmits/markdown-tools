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
          \makeindex
          \renewcommand{\maketitlehooka}{%
              \vspace{-3.5cm}\bfseries\sffamily\titlelogo\\\\
              \large <%= title1 %>\\\\ \vspace{2mm}\normalsize <%= title2 %>
              \vspace{5cm}
          }
          %\titlehead{\vspace{3cm}\sffamily <%= title1 %>\\\\ \vspace{2mm} \small<%= title2 %>}
          \title{<%= section_name  %>}
          \author{\small \sffamily <%= author %>}
          \date{\vspace{1cm}\color{grau} \Large\sffamily <%= term %>\\\\ \scriptsize\vspace{2mm}\today}

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

          \begin{document}
          \pagestyle{headings}
          \pagenumbering{roman}
          \renewcommand{\maketitlehookd}{%
            \vspace{7cm} \sffamily \small \textit{<%= description %>} %
          }
          %\publishers{Herausgeber}
          <% section_id = 'sect_' + Random.rand(10000000).to_s(16) %>
          \label{<%= section_id %>}
          \pdfbookmark[\contentsname]{<%= section_name %>}{<%= section_id %>}

          \thispagestyle{empty}
          \vspace{3cm}
          \maketitle
          \newpage
          \clearpage
          \tableofcontents
          \newcounter{frontmatterpage}
          \setcounter{frontmatterpage}{\value{page}}
          \newpage
          \pagenumbering{arabic}
          |
      ),

      presentation_end: erb(
        %q(
        \cleardoublepage
        \pagenumbering{roman}
        \setcounter{page}{\value{frontmatterpage}}
        <% unless bibliography.nil? %>
          \begin{flushleft}
          \printbibliography[heading=bibintoc]
          \end{flushleft}
        <% end %>

        \cleardoublepage
        \phantomsection
        \addcontentsline{toc}{section}{Index}
        \printindex

        \end{document}
        )
      ),

      chapter_start: erb(
        %q|
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        \Needspace{12\baselineskip}\chapter{<%= title %>}\label{<%= id %>}

        |
      ),

      chapter_end: erb(
        '
        '
      ),

      slide_start: erb(
        %q|
        % ********************************************************************************************
        \Needspace{5\baselineskip}\section{<%= line_renderer.render_text(title) %> [<%= number %>]}\label{<%= id %>}
        |
      ),

      slide_end: erb(
        '
        '.strip
      ),

      comment_start: erb(
        %q(\begin{comment})
      ),

      comment_end: erb(
        %q(\end{comment})
      ),

      text: erb(
        %q|<%= content %>
        \vspace{0.1mm}|
      ),

      ul_start: erb(
        %q(
        <%- if @ul_level == 1 -%>
          \vspace{0.1mm}
        <%- elsif @ul_level == 2 -%>
          \vspace{0.1mm}
        <%- end -%>
        \begin{ul<%= @ul_level %>})
      )
    }.freeze

    ##
    # Initialize the renderer
    # @param [IO, StringIO] io target of output operations
    # @param [String] prog_lang the default language for code snippets
    # @param [String] result_dir location for results
    # @param [String] image_dir location for generated images (relative to result_dir)
    # @param [String] temp_dir location for temporary files
    def initialize(io, prog_lang, result_dir, image_dir, temp_dir)
      super(io, prog_lang, result_dir, image_dir, temp_dir)
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
      false
    end

    ##
    # Start of slide
    # @param [String] title the title of the slide
    # @param [String] number the number of the slide
    # @param [String] id the unique id of the slide (for references)
    # @param [Boolean] contains_code indicates whether the slide contains code fragments
    def slide_start(title, number, id, contains_code)
      super unless title == @last_title
    end

    ##
    # Render an image
    # @param [String] location path to image
    # @param [Array] _formats available file formats
    # @param [String] _alt alt text
    # @param [String] title title of image
    # @param [String] _width_slide width for slide
    # @param [String] source source of the image
    def image(location, _formats, _alt, title, _width_slide, width_plain, source = nil)
      # Skip images with width 0
      unless /^0$/ === width_plain || /^0%$/ === width_plain
        image_latex(location, title, width_plain, source)
      end
    end

    ##
    # Render an UML inline diagram using an external tool
    # @param [String] picture_name name of the picture
    # @param [String] contents the embedded UML
    # @param [String] width_slide width of the diagram on slides
    # @param [String] width_plain width of the diagram on plain documents
    def uml(picture_name, contents, width_slide, width_plain)
      new_width = calculate_width(width_plain)
      formats = %w[pdf eps]
      img_path = super(picture_name, contents, width_slide, width_plain, 'pdf')
      image(img_path, formats, '', '', new_width, new_width)
    end
  end
end
