# -*- coding: utf-8 -*-

require_relative 'renderer'
require_relative '../messages'

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
      @ul_level = 1
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
    # @return [String] Text with replacements performed
    def inline(input)

      return ''  if input.nil?

      result = input

      result.gsub!(/\\/,                  '{\textbackslash}')
      result.gsub!(/__(.+?)__/,           '\term{\1}')
      result.gsub!(/_(.+?)_/,             '\strong{\1}')
      result.gsub!(/\*\*(.+?)\*\*/,       '\strongenglish{\1}')
      result.gsub!(/\*(.+?)\*/,           '\termenglish{\1}')
      result.gsub!(/~~(.+?)~~/,           '\strikeout{\1}')
      result.gsub!(/s\[(.+?)\]\((.+?)\)/, '\href{\2}{\1}')
      result.gsub!(/\[(.+?)\]\((.+?)\)/,  '\href{\2}{\1}')
      result.gsub!(/z\.B\./,              'z.\\\\,B.')
      result.gsub!(/d\.h\./,              'd.\\\\,h.')
      result.gsub!(/u\.a\./,              'u.\\\\,a.')
      result.gsub!(/\$/,                  '\$')
      result.gsub!(/<br>/,                "\\newline\n")
      result.gsub!(/"/,                   '{\textquotedbl}')
      result.gsub!(/#/,                   '\\\\#')
      result.gsub!(/&/,                   '\\\\&')
      result.gsub!(/_/,                   '\\\\_*')
      result.gsub!(/</,                   '{\\textless}')
      result.gsub!(/>/,                   '{\\textgreater}')

      result
    end

    ##
    # Replace `inline code` in input
    # @param [String] input the input
    # @return the input with replaced code fragments
    def inline_code(input, table = false)
      parts = tokenize_line(input)

      result = ''
      size = table ? ',basicstyle=\scriptsize' : ''

      parts.each { |p|
        if p.code
          result << "\\lstinline[language=#{@language}#{size}]|#{p.content}|"
        else
          result << inline(p.content)
        end
      }

      result
    end

    ##
    # Equation
    # @param [String] contents LaTeX source of equation
    def equation(contents)
      @io << '\begin{displaymath}' << nl << "#{contents}" << '\end{displaymath}' << nl
    end

    ##
    # Start of an ordered list
    # @param [Fixnum] number start number of list
    def ol_start(number = 1)
      @io << '\begin{enumerate}' << nl
      @ul_level += 1
    end

    ##
    # End of ordered list
    def ol_end
      @io << '\end{enumerate}' << nl
      @ul_level -= 1
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
    def quote(content)
      @io << '\begin{quote}' << nl
      @io << "#{inline_code(content)}" << nl
      @io << '\end{quote}' << nl
    end

    ##
    # Start of a code fragment
    # @param [String] language language of the code fragment
    def code_start(language)
      @io << <<-ENDOFTEXT
      {\\setstretch{1.3}\\small
      \\begin{lstlisting}[language=#{language},basicstyle=\\scriptsize\\ttfamily]
      ENDOFTEXT
    end

    ##
    # End of a code fragment
    def code_end
      @io << '\end{lstlisting}}'
    end

    ##
    # Output code
    # @param [String] content the code content
    def code(content)
      @io  << content
    end

    ##
    # Start of a table
    def table_start(num_columns)
      column_line = ''
      i = 0

      while i < num_columns + 1 do
        column_line << 'l '
        i += 1
      end

      @io << <<-ENDOFTEXT
      \\vspace{2mm}
      \\renewcommand{\\arraystretch}{1.1}
      {\\sffamily
      \\begin{footnotesize}\\tablefont
      \\begin{tabular}{#{column_line}}
      \\toprule
      ENDOFTEXT
    end

    ##
    # Header of table
    # @param [Array] headers the headers
    def table_header(headers)

      result = ''
      i = 0

      headers.each { |e|
        result << "\\textbf{#{inline_code(e)}} "
        result << ' & '  if i < headers.size - 1
        i += 1
      }

      @io << "#{result} \\\\" << nl
      @io << '\midrule' << nl
    end

    ##
    # Row of the table
    # @param [Array] row row of the table
    def table_row(row)

      result = ''
      i = 0

      row.each { |e|
        text = inline_code(e, true)

        if /\\newline/ =~ text
          text = "\\specialcell[t]{#{text}}"
          text.gsub!(/\\newline/, '\\\\\\\\')
        end

        result << text
        result << ' & '  if i < row.size - 1
        i += 1
      }

      @io << "#{result} \\\\" << nl
    end

    ##
    # End of the table
    def table_end
      @io <<  <<-ENDOFTEXT
      \\bottomrule
      \\end{tabular}
      \\end{footnotesize}}
      ENDOFTEXT
    end

    ##
    # Simple text
    # @param [String] content the text
    def text(content)
      @io <<  "#{inline_code(content)}" << nl << nl
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
    # @param [String] alt alt text
    # @param [String] title title of image
    # @param [String] width_slide width for slide
    # @param [String] width_plain width for plain text
    def image(location, alt, title, width_slide, width_plain)
      stripped_location = location.gsub(/\..../, '')

      if width_slide
        @io << "\\bild{#{stripped_location}}{#{width_slide}}{#{title}}" << nl
      else
        @io <<  "\\bild{#{stripped_location}}{\\textwidth}{#{title}}" << nl
      end
    end

    ##
    # Render an UML inline diagram using an external tool
    # @param [String] picture_name name of the picture
    # @param [String] contents the embedded UML
    def uml(picture_name, contents, width)

      if /%/ =~ width
        width.gsub!(/%/, '')
        width_num = width.to_i / 100.0
        width = "#{width_num.to_s}\\textwidth"
      end

      img_path = super(picture_name, contents, width, 'pdf')
      image(img_path, '', '', width, width)
    end
  end
end
