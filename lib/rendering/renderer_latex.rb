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
    def initialize(io, language)
      super(io, language)
      @ul_level = 1
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
      result.gsub!(/s\[(.+?)\]\((.+?)\)/, '[\1]')
      result.gsub!(/\[(.+?)\]\((.+?)\)/,  '[\1]')
      result.gsub!(/z\.B\./,              'z.\\\\,B.')
      result.gsub!(/d\.h\./,              'd.\\\\,h.')
      result.gsub!(/u\.a\./,              'u.\\\\,a.')
      result.gsub!(/\$/,                  '\$')
      result.gsub!(/<br>/,                "\\newline\n")
      result.gsub!(/"/,                   '{\textquotedbl}')
      result.gsub!(/#/,                   '\\\\#')
      result.gsub!(/&/,                   '\\\\&')
      result.gsub!(/_/,                   '\\\\_*')
      result.gsub!(/</,                   '\\textless')
      result.gsub!(/>/,                   '\\textgreater')

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
      @io << '\[' << nl << "#{contents}" << nl << '\]' << nl
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
      \\sffamily
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
      \\end{footnotesize}
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
    # Start a chapter
    # @param [String] title the title of the chapter
    # @param [String] number the number of the chapter
    # @param [String] id the uniquie id of the chapter (for references)
    def chapter_start(title, number, id)
      @io << <<-ENDOFTEXT
      \\section{#{title}}\\label{#{id}}
      \\begin{frame}
        \\separator{#{title}}
      \\end{frame}
      ENDOFTEXT
    end

    ## End of a chapter
    def chapter_end
      @io << nl
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
      \\include{preambel}
      \\include{lst_javascript}
      \\mode<presentation>{\\input{beamer-template}}
      \\newcommand{\\copyrightline}[0]{#{title1} | #{copyright}}
      \\title{#{title1} \\\\ \\small #{title2} \\\\ \\Large \\vspace{8mm} #{section_name}}
      \\author{\\small #{author}}
      \\date{\\color{grau} \\small #{term}}
      \\begin{document}
      \\begin{frame}
        \\maketitle
      \\end{frame}

      \\begin{frame}
        \\separator{#{LOCALIZED_MESSAGES[:toc]}}
      \\end{frame}

      \\begin{frame}\\frametitle<presentation>{#{LOCALIZED_MESSAGES[:toc]}}
        \\tableofcontents
      \\end{frame}
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
      @io << "\\begin{frame}[fragile]{#{inline_code(title)}}\\label{#{id}}" << nl
    end

    ##
    # End of slide
    def slide_end
      @io << '\end{frame}' << nl << nl
    end
  end
end
