# -*- coding: utf-8 -*-

require_relative 'renderer'
require_relative '../messages'
require_relative '../constants'

module Rendering

  ##
  # Render the presentation into a latex file for further processing
  # using LaTeX
  class RendererLatex < Renderer

    ## ERB templates to be used by the renderer
    TEMPLATES = {
        vertical_space: erb(
          %q|
          \vspace{4mm}
         |
        ),

        equation: erb(
            %q|
            \begin{align*}'
            <%= contents %>
            \end{align*}
            |
        ),

        ol_start: erb(
            %q|
            \begin{ol<%= @ol_level %>}
            |
        ),

        ol_item: erb(
            %q|
            \item <%= inline_code(content) %>
            |
        ),

        ol_end: erb(
            %q|
            \end{ol<%= @ol_level %>}
            |
        ),

        ul_start: erb(
            %q|
            \begin{ul<%= @ul_level %>}
            |
        ),

        ul_item: erb(
            %q|
            \item <%= inline_code(content) %>
            |
        ),

        ul_end: erb(
            %q|
            \end{ul<%= @ul_level %>}
            |
        ),

        quote: erb(
            %q|
            <% if with_source %>
              \quoted{<%= inline_code(content) %>}{<%= inline(source) %>}
            <% else %>
              \quotedns{<%= inline_code(content) %>}
            <% end %>
            |
        ),

        important: erb(
            %q|
            \important{<%= inline_code(content, false, true) %>}
            |
        ),

        question: erb(
            %q|
            \question{<%= inline_code(content, false, true) %>}
            |
        ),

        script: erb(
            %q||
        ),

        code_start: erb(
            %q|
            \begin{lstblock}
            {\setstretch{1.3}\small
            \begin{lstlisting}[language=<%= language %>,<%= caption_command %><%= column_style %>basicstyle=\scriptsize\ttfamily]|
        ),

        code: erb(
            %q|<%= content %>|
        ),

        code_end: erb(
            %q|
            \end{lstlisting}}
            \end{lstblock}
            |
        ),

        table_start: erb(
            %q|
            \begin{center}
            \vspace{2mm}
            \renewcommand{\arraystretch}{1.1}
            {\sffamily
            \begin{footnotesize}\tablefont
            \begin{tabular}{<%= column_line %>}
            \toprule
            |
        ),

        table_end: erb(
            %q|
            \bottomrule
            \end{tabular}
            \end{footnotesize}}
            \end{center}
            |
        ),

        text: erb(
            %q|
            <%= inline_code(cleaned_content) %>
            \vspace{0.1mm}
            |
        ),

        # TODO: Handle headings
        heading: erb(
            %q||
        ),

        image: erb(
            %q!
            \bild{<%= stripped_location %>}{<%= new_width %>}{<%= full_title %>}
            !
        )
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
    def templates
      @templates = super.merge(TEMPLATES)
    end

    ##
    # Indicates whether the renderer handles animations or not. false indicates
    # that slides should not be repeated.
    def handles_animation?
      true
    end

    ##
    # Replace inline elements like emphasis (_..._)
    #
    # @param [String] input Text to be replaced
    # @param [boolean] alternate alternate emphasis to be used
    # @return [String] Text with replacements performed
    def inline(input, alternate = false)

      parts = tokenize_line(input, /(\[.+?\]\(.+?\))/)
      result = ''

      parts.each do |p|
        if p.matched
          result << p.content.gsub(/\[(.+?)\]\((.+?)\)/, '\href{\2}{\1}').gsub('_', '\_')
        else
          result << inline_replacements(p.content, alternate)
        end
      end

      result
    end

    ##
    # Apply regular expressions to replace inline content
    # @param [String] input Text to be replaced
    # @param [boolean] alternate alternate emphasis to be used
    # @return [String] Text with replacements performed
    def inline_replacements(input, alternate = false)
      return ''  if input.nil?

      result = input

      result.gsub!(/\\/,                  '\textbackslash ')
      result.gsub!('{',                   '\{')
      result.gsub!('}',                   '\}')

      result.gsub!(/(^|[ (>])([A-Za-z0-9\-+]{1,2})_([A-Za-z0-9+\-]{1,})([<,.;:!) ]|$)/,  '\1\begin{math}\2\textsubscript{\3}\end{math}\4')
      result.gsub!(/(^|[ (>])([A-Za-z0-9\-+]{1,2})\^([A-Za-z0-9+\-]{1,})([<,.;:!) ]|$)/,  '\1\begin{math}\2\textsuperscript{\3}\end{math}\4')
      result.gsub!(/"(.*?)"/, '"`\1"\'')

      if alternate
        result.gsub!(/__(.+?)__/,           '\termalt{\1}\index{\1}')
        result.gsub!(/_(.+?)_/,             '\strongalt{\1}')
        result.gsub!(/\*\*(.+?)\*\*/,       '\termenglishalt{\1}')
        result.gsub!(/\*(.+?)\*/,           '\strongenglishalt{\1}')
      else
        result.gsub!(/__(.+?)__/,           '\term{\1}\index{\1}')
        result.gsub!(/_(.+?)_/,             '\strong{\1}')
        result.gsub!(/\*\*(.+?)\*\*/,       '\termenglish{\1}')
        result.gsub!(/\*(.+?)\*/,           '\strongenglish{\1}')
      end

      result.gsub!(/~~(.+?)~~/,           '\strikeout{\1}')
      result.gsub!('Z.B.',                'Z.\,B.')
      result.gsub!('z.B.',                'z.\,B.')
      result.gsub!('D.h.',                'D.\,h.')
      result.gsub!('d.h.',                'd.\,h.')
      result.gsub!('u.a.',                'u.\,a.')
      result.gsub!('s.u.',                's.\,u.')
      result.gsub!('s.o.',                's.\,o.')
      result.gsub!('$',                   '\$')
      result.gsub!('%',                   '\%')
      result.gsub!('(-> ',                '($\rightarrow$ ')
      result.gsub!('(=> ',                '($\Rightarrow$ ')
      result.gsub!('<br>-> ',             '<br>$\rightarrow$ ')
      result.gsub!('<br>=> ',             '<br>$\Rightarrow$ ')
      result.gsub!(' -> ',                ' $\rightarrow$ ')
      result.gsub!(' => ',                ' $\Rightarrow$ ')
      result.gsub!(' <- ',                ' $\leftarrow$ ')
      result.gsub!(' <= ',                ' $\Leftarrow$ ')
      result.gsub!(' <=> ',               ' $\Leftrightarrow$ ')
      result.gsub!('<br><=> ',            '<br>$\Leftrightarrow$ ')
      result.gsub!(/<br>/,                "\\newline\n")
      result.gsub!('#',                   '\#')
      result.gsub!('&',                   '\\\\&')
      result.gsub!('_',                   '\_')
      result.gsub!('<<',                  '{\flqq}')
      result.gsub!('>>',                  '{\frqq}')
      result.gsub!('<',                   '{\textless}')
      result.gsub!('>',                   '{\textgreater}')
      result.gsub!('~',                   '{\textasciitilde}')
      result.gsub!('^',                   '{\textasciicircum}')
      result.gsub!('\textsubscript',      '_')
      result.gsub!('\textsuperscript',    '^')

      result
    end

    ##
    # Replace `inline code` in input
    # @param [String] input the input
    # @param [boolean] alternate alternate emphasis to be used
    # @return the input with replaced code fragments
    def inline_code(input, table = false, alternate = false)
      parts = tokenize_line(input, /`(.+?)`/)

      result = ''
      size = table ? ',basicstyle=\scriptsize' : ',style=inline'

      options = 'literate={-}{{\textminus}}1 {-\ }{{\textminus}\ }2,'

      parts.each { |p|
        if p.matched
          if p.content.include?('|')
            result << "\\lstinline[#{options}language=#{@language}#{size}]+#{p.content}+"
          else
            result << "\\lstinline[#{options}language=#{@language}#{size}]|#{p.content}|"
          end
        else
          result << inline(p.content, alternate)
        end
      }

      result
    end

    ##
    # Start of a code fragment
    # @param [String] language language of the code fragment
    # @param [String] caption caption of the sourcecode
    def code_start(language, caption)

      if language == 'console'
        column_style = 'columns=fixed,'
      else
        column_style = ''
      end

      if caption.nil?
        caption_command = ''
      else
        caption_command = "title={#{caption}},aboveskip=-0.4 \\baselineskip,"
      end

      @io << @templates[:code_start].result(binding)
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
        result << "\\textbf{#{inline_code(e)}} "  if alignment[k] != Constants::SEPARATOR
        result << ' & '  if i < headers.size - 1 && alignment[k] != Constants::SEPARATOR
        i += 1
      end

      @io << "#{result} \\\\" << nl
      @io << '\midrule' << nl
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

        text = inline_code(e, true)

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
        full_title << ', '  if !full_title.nil? && full_title.length > 0
        full_title = "#{full_title}#{LOCALIZED_MESSAGES[:source]}#{source}"
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
        new_width.gsub!(/%/, '')
        width_num = new_width.to_i / 100.0
        new_width = "#{width_num.to_s}\\textwidth"
      end

      new_width
    end
  end
end

