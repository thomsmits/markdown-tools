require_relative 'renderer'
require_relative 'line_renderer_latex'
require_relative '../messages'
require_relative '../constants'

module Rendering
  ##
  # Render the presentation into a latex file for further processing
  # Render the presentation into a latex file for further processing
  # using LaTeX
  class RendererLatex < Renderer
    ## ERB templates to be used by the renderer
    TEMPLATES = {
      vertical_space: erb(
        %q(
        \vspace{4mm}
       )
      ),

      equation: erb(
        %q(
        \abovedisplayskip=0mm
        \begin{align*}
        <%= line_renderer.formula(contents) %>\end{align*}
        \belowdisplayskip=0mm
        )
      ),

      ol_start: erb(
        %q(
        \begin{ol<%= @ol_level %>}
        <%- if counter > 0 -%>
          \setcounter{enumi}{<%= counter %>}
        <%- end -%>
        )
      ),

      ol_item: erb(
        %q|
        \item <%= content %>
        |
      ),

      ol_end: erb(
        %q(
        \end{ol<%= @ol_level %>}
        )
      ),

      ul_start: erb(
        %q(
        \begin{ul<%= @ul_level %>})
      ),

      ul_item: erb(
        %q|\item <%= content %>|
      ),

      ul_end: erb(
        %q|\end{ul<%= @ul_level %>}|
      ),

      quote: erb(
        %q|<%- if with_source -%>
          \quoted{<%= content %>}{<%= source.strip %>}
        <%- else -%>
          \quotedns{<%= content %>}
        <%- end -%>|
      ),

      important: erb(
        %q|
        \important{<%= content %>}
        |
      ),

      question: erb(
        %q|
        \question{<%= content %>}
        |
      ),

      box: erb(
        %q|
        \mybox{<%= content %>}
        |
      ),

      script: erb(
        ''
      ),

      code_start: erb(
        %q(\begin{lstblock}%
        {\setstretch{1.3}\small
        \begin{lstlisting}[language=<%= prog_lang %>,<%= caption_command %>,basicstyle=\scriptsize\ttfamily])
      ),

      code: erb(
        '<%= content %>'
      ),

      code_end: erb(
        %q(\end{lstlisting}}
        \end{lstblock}
        )
      ),

      table_start: erb(
        %q(
        \begin{center}
        \vspace{2mm}
        \renewcommand{\arraystretch}{1.1}
        {\sffamily
        \begin{footnotesize}\tablefont
        \begin{tabular}{<%= column_line %>}
        \toprule
        )
      ),

      table_separator: erb(
        %q(
        \midrule
        )
      ),

      table_end: erb(
        %q(
        \bottomrule
        \end{tabular}
        \end{footnotesize}}
        \end{center}
        )
      ),

      text: erb(
        %q|
        <%= cleaned_content %>
        \vspace{0.1mm}|
      ),

      heading_3: erb(
        %q|\subsubsection*{<%= line_renderer.meta(title) %>}|
      ),

      heading_4: erb(
        %q|\paragraph{<%= line_renderer.meta(title) %>}|
      ),

      image: erb(
        %q(
        \bild{<%= stripped_location %>}{<%= new_width %>}{<%= full_title %>}
        )
      ),

      multiple_choice_start: erb(
        %q(<%- if inline then -%>
          \begin{oneparcheckboxes}
        <%- else -%>
          \begin{checkboxes}
        <%- end -%>)
      ),

      multiple_choice_end: erb(
        %q(<%- if inline then -%>
          \end{oneparcheckboxes}
        <%- else -%>
          \end{checkboxes}
        <%- end -%>)
      ),

      multiple_choice: erb(
        %q(<%= if correct then '\CorrectChoice' else '\choice' end %> <%= text %>
        )
      ),

      input_question: erb(%q|\vspace{5mm}<%= translate(:answer) %>: \dotfill|),
    }.freeze

    ##
    # Initialize the renderer
    # @param [IO] io target of output operations
    # @param [String] prog_lang the default language for code snippets
    # @param [String] result_dir location for results
    # @param [String] image_dir location for generated images (relative to result_dir)
    # @param [String] temp_dir location for temporary files
    def initialize(io, prog_lang, result_dir, image_dir, temp_dir)
      super(io, LineRendererLatex.new(prog_lang), prog_lang, result_dir, image_dir, temp_dir)
    end

    ##
    # Method returning the templates used by the renderer. Should be overwritten by the
    # subclasses.
    # @return [Hash] the templates
    def all_templates
      @templates = super.merge(TEMPLATES)
    end

    ##
    # Start of a code fragment
    # @param [String] prog_lang language of the code fragment
    # @param [String] caption caption of the sourcecode
    def code_start(prog_lang, caption)
      if caption.nil?
        caption_command = ''
      else
        replaced_caption = line_renderer.meta(caption)
        caption_command = "title={\\fontfamily{phv}\\selectfont\\textbf{#{replaced_caption}}},aboveskip=-0.4 \\baselineskip,"
      end

      @io << @templates[:code_start].result(binding)
    end

    ##
    # Start of an ordered list
    # @param [Fixnum] number start number of list
    def ol_start(number = 1)
      @ol_level += 1
      counter = number.to_i - 1
      @io << @templates[:ol_start].result(binding)
    end

    ##
    # Heading of a given level
    # @param [Fixnum] level heading level
    # @param [String] title title of the heading
    def heading(level, title)
      @io << @templates[:heading_3].result(binding)  if level == 3
      @io << @templates[:heading_4].result(binding)  if level == 4
    end

    ##
    # Header of table
    # @param [Array] headers the headers
    # @param [Array] alignment alignments of the cells
    def table_start(headers, alignment)
      column_line = ''

      alignment.each do |a|
        column_line << 'l '  if a == Constants::LEFT
        column_line << 'r '  if a == Constants::RIGHT
        column_line << 'c '  if a == Constants::CENTER
        column_line << '| '  if a == Constants::SEPARATOR
      end

      @io << @templates[:table_start].result(binding)

      result = ''
      i = 0

      headers.each_with_index do |e, k|
        result << "\\textbf{#{e}} " if alignment[k] != Constants::SEPARATOR
        result << ' & ' if i < headers.size - 1 && alignment[k] != Constants::SEPARATOR
        i += 1
      end

      @io << "#{result} \\\\" << nl
    end

    ##
    # Row of the table
    # @param [Array] row row of the table
    # @param [Array] alignment alignments of the cells
    def table_row(row, alignment)
      result = ''
      i = 0

      row.each_with_index do |e, k|
        next if alignment[k] == Constants::SEPARATOR

        text = e

        if /\\newline/ === text
          text = "\\specialcell[t]{#{text}}"
          text.gsub!(/\\newline/, '\\\\\\\\')
        end

        result << text
        result << ' & ' if k < row.size - 1
        i += 1
      end

      @io << "#{result} \\\\" << nl
    end

    ##
    # Render an image
    # @param [String] location path to image
    # @param [String] title title of image
    # @param [String] width width for slide
    # @param [String] source source of the image
    def image_latex(location, title, width, source = nil)
      stripped_location = location.gsub(/\..../, '')

      full_title = title

      unless source.nil?
        full_title << ', ' if !full_title.nil? && !full_title.empty?
        full_title = "#{full_title}#{translate(:source)}#{source}"
      end

      new_width = width ? calculate_width(width) : '\textwidth'

      @io << @templates[:image].result(binding)
    end

    ##
    # Transform width given in % into a latex compatible format
    # @param [String] width width in %, e.g. "80%"
    def calculate_width(width)
      new_width = width

      if /%/ === new_width
        new_width.delete!('%')
        width_num = new_width.to_i / 100.0
        new_width = "#{width_num}\\textwidth"
      end

      new_width
    end
  end
end
