# -*- coding: utf-8 -*-

require_relative 'renderer'
require_relative '../messages'
require_relative '../constants'

module Rendering

  ##
  # Render the presentation into a latex file for further processing
  # using LaTeX
  class RendererLatex < Renderer

    ##
    # Initialize the renderer
    # @param [IO] io target of output operations
    # @param [String] language the default language for code snippets
    # @param [String] result_dir location for results
    # @param [String] image_dir location for generated images (relative to result_dir)
    # @param [String] temp_dir location for temporary files
    def initialize(io, language, result_dir, image_dir, temp_dir)
      super(io, language, result_dir, image_dir, temp_dir)
      @ul_level, @ol_level = 1, 1
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
          result << p.content.gsub(/\[(.+?)\]\((.+?)\)/, '\href{\2}{\1}')
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

      #result.gsub!(/(^|[ (>])([A-Za-z0-9])_([A-Za-z0-9+-]{1,})$/,               '\1\begin{math}\2\textsubscript{\3}\end{math}')
#      result.gsub!(/^([A-Za-z0-9])_([A-Za-z0-9+-]{1,})([,.;) ])/,             '\begin{math}\1\textsubscript{\2}\end{math}\3')
#      result.gsub!(/^([A-Za-z0-9])_([A-Za-z0-9+-]{1,})$/,                     '\begin{math}\1\textsubscript{\2}\end{math}')

#      result.gsub!(/ ([A-Za-z0-9])\^([A-Za-z0-9+-]{1,})$/,              ' \begin{math}\1\textsuperscript{\2}\end{math}')
#      result.gsub!(/ ([A-Za-z0-9])\^([A-Za-z0-9+-]{1,})([,.;) ])/,      ' \begin{math}\1\textsuperscript{\2}\end{math}\3')
#      result.gsub!(/^([A-Za-z0-9])\^([A-Za-z0-9+-]{1,})$/,              ' \begin{math}\1\textsuperscript{\2}\end{math}')
#      result.gsub!(/^([A-Za-z0-9])\^([A-Za-z0-9+-]{1,})([,.;) ])/,      ' \begin{math}\1\textsuperscript{\2}\end{math}\3')
#      result.gsub!(/>([A-Za-z0-9])\^([A-Za-z0-9+-]{1,})$/,              '>\begin{math}\1\textsuperscript{\2}\end{math}')
#      result.gsub!(/>([A-Za-z0-9])\^([A-Za-z0-9+-]{1,})([,.;) ])/,      '>\begin{math}\1\textsuperscript{\2}\end{math}\3')

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
      #result.gsub!(/s\[(.+?)\]\((.+?)\)/, '\href{\2}{\1}')
      #result.gsub!(/\[(.+?)\]\((.+?)\)/,  '\href{\2}{\1}')
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
      #result.gsub!('"',                   '{\textquotedbl}')
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
    # Vertical space
    def vertical_space
      @io << '\vspace{4mm}' << nl
    end

    ##
    # Equation
    # @param [String] contents LaTeX source of equation
    def equation(contents)
      @io << '\begin{align*}' << nl << "#{contents}" << '\end{align*}' << nl
    end

    ##
    # Start of an ordered list
    # @param [Fixnum] number start number of list
    def ol_start(number = 1)
      @io << "\\begin{ol#{@ol_level}}" << nl
      @ol_level += 1
    end

    ##
    # End of ordered list
    def ol_end
      @ol_level -= 1
      @io << "\\end{ol#{@ol_level}}" << nl
    end

    ##
    # Item of an ordered list
    # @param [String] content content
    def ol_item(content)
      ul_item(content)
    end

    ##
    # Start of an unordered list
    def ul_start
      @io << "\\begin{ul#{@ul_level}}" << nl
      @ul_level += 1
    end

    ##
    # Simple text
    # @param [String] content the text
    def text(content)
      @io <<  "#{inline_code(content)}" << nl << nl
    end

    ##
    # End of an unordered list
    def ul_end
      @ul_level -= 1
      @io << "\\end{ul#{@ul_level}}" << nl
    end

    ##
    # Item of an unordered list
    # @param [String] content content
    def ul_item(content)
      @io << "\\item #{inline_code(content)}" << nl
    end

    ##
    # Quote
    # @param [String] content the content
    # @param [String] source the source of the quote
    def quote(content, source)
      if !source.nil? && source.length > 0
        @io << "\\quoted{#{inline_code(content)}}{#{inline(source)}}" << nl
      else
        @io << "\\quotedns{#{inline_code(content)}}" << nl
      end
    end

    ##
    # Important
    # @param [String] content the box
    def important(content)
      @io << "\\important{#{inline_code(content, false, true)}}" << nl
    end

    ##
    # Important
    # @param [String] content the box
    def question(content)
      @io << "\\question{#{inline_code(content, false, true)}}" << nl
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

      @io << <<-ENDOFTEXT
      \\begin{lstblock}
      {\\setstretch{1.3}\\small
      \\begin{lstlisting}[language=#{language},#{caption_command}#{column_style}basicstyle=\\scriptsize\\ttfamily]
      ENDOFTEXT
    end

    ##
    # End of a code fragment
    # @param [String] caption caption of the sourcecode
    def code_end(caption)
      @io << '\end{lstlisting}}' << nl
      @io << '\end{lstblock}' << nl
    end

    ##
    # Output code
    # @param [String] content the code content
    def code(content)
      @io  << content
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

      @io << <<-ENDOFTEXT
      \\begin{center}
      \\vspace{2mm}
      \\renewcommand{\\arraystretch}{1.1}
      {\\sffamily
      \\begin{footnotesize}\\tablefont
      \\begin{tabular}{#{column_line}}
      \\toprule
      ENDOFTEXT

      result = ''
      i = 0

      headers.each_with_index do |e, k|
        result << "\\textbf{#{inline_code(e)}} " if alignment[k] != Constants::SEPARATOR
        result << ' & ' if i < headers.size - 1 && alignment[k] != Constants::SEPARATOR
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

        if /\\newline/ =~ text
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
    # End of the table
    def table_end
      @io <<  <<-ENDOFTEXT
      \\bottomrule
      \\end{tabular}
      \\end{footnotesize}}
      \\end{center}
      ENDOFTEXT
    end

    ##
    # Heading of a given level
    # @param [Fixnum] level heading level
    # @param [String] title title of the heading
    def heading(level, title)
      ## TODO: subheadings
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

      if width
        new_width = calculate_width(width)
        @io << "\\bild{#{stripped_location}}{#{new_width}}{#{full_title}}" << nl
      else
        @io <<  "\\bild{#{stripped_location}}{\\textwidth}{#{full_title}}" << nl
      end
    end

    ##
    # Transform width given in % into a latex compatible format
    # @param [String] width width in %, e.g. "80%"
    def calculate_width(width)

      new_width = width

      if /%/ =~ new_width
        new_width.gsub!(/%/, '')
        width_num = new_width.to_i / 100.0
        new_width = "#{width_num.to_s}\\textwidth"
      end

      new_width
    end
  end
end

