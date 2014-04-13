# -*- coding: utf-8 -*-

require_relative 'renderer'
require_relative '../messages'
require_relative '../constants'

module Rendering

  ##
  # Base class for rendering slides to HTML
  class RendererHTML < Renderer

    CSS_PLAIN     = "css/plain.css"
    CSS_BOOK      = "css/book.css"
    CSS_ZENBURN   = "css/zenburn.css"
    CSS_LIGHTNESS = "css/ui-lightness/jquery-ui-1.10.3.css"
    CSS_THOMAS    = "css/thomas.css"
    CSS_MAIN      = "css/main.css"
    JS_HEAD       = "lib/js/head.min.js"
    JS_THOMAS     = "js/thomas.js"
    JS_HIGHLIGHT  = "lib/js/highlight.js"
    JS_JQUERY     = "lib/js/jquery-1.9.1.js"
    JS_MATHJAX    = "lib/mathjax/MathJax.js?config=TeX-AMS_HTML"
    JS_JQUERY_UI  = "lib/js/jquery-ui-1.10.3.js"
    JS_REVEAL     = "lib/js/reveal.min.js"
    JS_SETTINGS   = "js/settings.js"

    INCLUDED_STYLESHEETS = [
        CSS_PLAIN,
        CSS_BOOK,
        CSS_ZENBURN,
    ]

    INCLUDED_SCRIPTS = [
        JS_HEAD,
        JS_THOMAS,
        JS_HIGHLIGHT,
        JS_JQUERY,
        JS_MATHJAX,
    ]

    PREFERRED_IMAGE_FORMATS = %w(svg png jpg)

    ##
    # Initialize the renderer
    # @param [IO] io target of output operations
    # @param [String] language the default language for code snippets
    # @param [String] result_dir location for results
    # @param [String] image_dir location for generated images (relative to result_dir)
    # @param [String] temp_dir location for temporary files
    def initialize(io, language, result_dir, image_dir, temp_dir)
      super(io, language, result_dir, image_dir, temp_dir)
      @ul_level = 0
      @toc = nil            # table of contents
      @last_toc_name = ''   # last name of toc entry to skip double entries
    end

    ##
    # Replace inline elements like emphasis (_..._) etc.
    #
    # @param [String] input Text to be replaced
    # @return [String] Text with replacements performed
    def inline(input)

      return ''  if input.nil?

      result = input

      result.gsub!(/ ([A-Za-z0-9])_([A-Za-z0-9]) /,  ' \1<sub>\2</sub> ')
      result.gsub!(/ ([A-Za-z0-9])\^([A-Za-z0-9]) /, ' \1<sup>\2</sup> ')
      result.gsub!( /([A-Za-z0-9])\^([A-Za-z0-9])$/, ' \1<sup>\2</sup>')
      result.gsub!( /([A-Za-z0-9])\^([A-Za-z0-9]) /, ' \1<sup>\2</sup> ')
      result.gsub!(/__(.+?)__/,           '<strong>\1</strong>')
      result.gsub!(/_(.+?)_/,             '<em>\1</em>')
      result.gsub!(/\*\*(.+?)\*\*/,       '<strong class="alternative">\1</strong>')
      result.gsub!(/\*(.+?)\*/,           '<em class="alternative">\1</em>')
      result.gsub!(/~~(.+?)~~/,           '<del>\1</del>')
      result.gsub!(/s\[(.+?)\]\((.+?)\)/, '<a class="small" href="\2">\1</a>')
      result.gsub!(/\[(.+?)\]\((.+?)\)/,  '<a href="\2">\1</a>')
      result.gsub!(/z\.B\./,              'z.&nbsp;B.')
      result.gsub!(/d\.h\./,              'd.&nbsp;h.')
      result.gsub!(/u\.a\./,              'u.&nbsp;a.')
      result.gsub!(/ -> /,                ' &rarr; ')
      result.gsub!(/ => /,                ' &rArr; ')
      result.gsub!(/---/,                 '&mdash;')
      result.gsub!(/--/,                  '&ndash;')
      result.gsub!(/\.\.\./,              '&hellip;')

      result
    end

    ##
    # Replace HTML entities in input
    # @param [String] input string to replace entities in
    # @return [String] string with replacements
    def entities(input)
      result = input
      result.gsub!(/&/,           '&amp;')
      result.gsub!(/</,           '&lt;')
      result.gsub!(/>/,           '&gt;')

      result
    end

    ##
    # Replace `inline code` in input
    # @param [String] input the input
    # @return the input with replaced code fragments
    def inline_code(input)
      parts = tokenize_line(input)
      result = ''

      parts.each { |p|
        if p.code
          result << "<code class='inline #{@language}'>#{entities(p.content)}</code>"
        else
          result << inline(p.content)
        end
      }

      result
    end

    ##
    # Vertical space
    def vertical_space
      @io << '<br>' << nl
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
      indent(@ul_level * 2)
      @io << "<ol start='#{number}'>"
      @ul_level += 1
    end

    ##
    # End of ordered list
    def ol_end
      indent(@ul_level * 2)
      @io << '</ol>'
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
      indent(@ul_level * 2)
      @io << "<ul>\n"
      @ul_level += 1
    end

    ##
    # End of an unordered list
    def ul_end
      indent(@ul_level * 2)
      @io << "</ul>\n"
      @ul_level -= 1
    end

    ##
    # Item of an unordered list
    # @param [String] content content
    def ul_item(content)
      text = inline_code(content)
      indent(@ul_level)
      @io << "<li>#{text}\n"
    end

    ##
    # Quote
    # @param [String] content the content
    # @param [String] source the source of the quote
    def quote(content, source)
      @io << "<blockquote>#{inline_code(content)}" << nl
      @io << "<div class='quote_source'>#{source}</div>" << nl  unless source.nil?
      @io << '</blockquote>' << nl
    end

    ##
    # Important
    # @param [String] content the box
    def important(content);
      @io << "<blockquote class='important'>#{inline_code(content)}" << nl
      @io << '</blockquote>' << nlend
    end

    ##
    # Script
    # @param [String] content the script to be included
    def script(content)
      @io << "<script>#{content}</script>" << nl
    end

    ##
    # Start of a code fragment
    # @param [String] language language of the code fragment
    # @param [String] caption caption of the sourcecode
    def code_start(language, caption)
      @io << "<pre><code class='#{language}' contenteditable>"
    end

    ##
    # End of a code fragment
    # @param [String] caption caption of the sourcecode
    def code_end(caption)
      @io << '</code></pre>'
    end

    ##
    # Output code
    # @param [String] content the code content
    def code(content)
      @io << entities(content)
    end

    ##
    # Header of table
    # @param [Array] headers the headers
    # @param [Array] alignment alignments of the cells
    def table_start(headers, alignment)
      @io << "<table class='small content'>" << nl
      @io << '<thead><tr>' << nl

      headers.each_with_index { |e, i|

        css_class = " class='left'"       if alignment[i] == Constants::LEFT
        css_class = " class='right'"      if alignment[i] == Constants::RIGHT
        css_class = " class='center'"     if alignment[i] == Constants::CENTER
        css_class = " class='separator'"  if alignment[i] == Constants::SEPARATOR

        @io << "<th#{css_class}>#{inline_code(e)}</th>" << nl  if alignment[i] != Constants::SEPARATOR
        @io << "<th#{css_class}></th>" << nl  if alignment[i] == Constants::SEPARATOR
      }

      @io << '</tr></thead><tbody>' << nl
    end

    ##
    # Row of the table
    # @param [Array] row row of the table
    # @param [Array] alignment alignments of the cells
    def table_row(row, alignment)
      @io << '<tr>' << nl
      row.each_with_index { |e, i|

        css_class = " class='left'"       if alignment[i] == Constants::LEFT
        css_class = " class='right'"      if alignment[i] == Constants::RIGHT
        css_class = " class='center'"     if alignment[i] == Constants::CENTER
        css_class = " class='separator'"  if alignment[i] == Constants::SEPARATOR

        @io << "<td#{css_class}>#{inline_code(e)}</td>" << nl  if alignment[i] != Constants::SEPARATOR
        @io << "<td#{css_class}></td>" << nl  if alignment[i] == Constants::SEPARATOR
      }

      @io <<  '</tr>' << nl
    end

    ##
    # End of the table
    def table_end
      @io << '</tbody></table>' << nl
    end

    ##
    # Simple text
    # @param [String] content the text
    def text(content)
      @io << "<p>#{inline_code(content)}</p>" << nl
    end

    ##
    # Heading of a given level
    # @param [Fixnum] level heading level
    # @param [String] title title of the heading
    def heading(level, title)
      @io << "<h#{level}>#{title}</h#{level}>" << nl
    end

    ##
    # Start of the TOC
    def toc_start
      @io << "<section data-number='2'>" << nl
      @io << "  <h1 class='title toc'>#{LOCALIZED_MESSAGES[:toc]}</h1>" << nl
      @io << '  <ul>' << nl
    end

    ##
    # Start of sub entries in toc
    def toc_sub_entries_start
      @io << "    <ul class='subentry'>" << nl
    end

    ##
    # End of sub entries
    def toc_sub_entries_end
      @io <<  '    </ul>' << nl
    end

    ##
    # Output a toc sub entry
    # @param [String] name name of the entry
    # @param [String] anchor anchor of the entry
    def toc_sub_entry(name, anchor)
      return  if name == @last_toc_name
      @last_toc_name = name
      @io << "      <li><a href='##{anchor}'>#{name}</a>" << nl
    end

    ##
    # Output a toc entry
    # @param [String] name name of the entry
    # @param [String] anchor anchor of the entry
    def toc_entry(name, anchor)
      @io << "    <li><a href='##{anchor}'>#{name}</a>" << nl
    end

    ##
    # End of toc
    def toc_end
      @io << '  </ul>' << nl << '</section>' << nl
    end

    ##
    # Start of index file
    # @param [String] title1 title 1 of lecture
    # @param [String] title2 title 2 of lecture
    # @param [String] copyright copyright info
    # @param [String] description description
    def index_start(title1, title2, copyright, description)
      @io << <<-ENDOFTEXT
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset='utf-8'>
        <title>#{title1}</title>
      #{include_javascript(INCLUDED_SCRIPTS)}
      #{include_css(INCLUDED_STYLESHEETS)}
      </head>

      <body>
        <div class='title_first'>#{title1}</div>
        <div class='title_second'>#{title2}</div>
        <div class='copyright'>#{copyright}</div>
        <div class='description'>#{description}</div>
      <table>
      <tr><th>#{LOCALIZED_MESSAGES[:chapter]}</th>
      <th colspan='2'>#{LOCALIZED_MESSAGES[:material]}</th></tr>
      ENDOFTEXT
    end

    ##
    # End of index
    def index_end
      @io << <<-ENDOFTEXT
      </table>
      </div>
      </body>
      </html>
      ENDOFTEXT
    end

    ##
    # Single index entry
    # @param [Fixnum] chapter_number number of chapter
    # @param [String] chapter_name name of chapter
    # @param [String] slide_file file containing the slides
    # @param [String] plain_file file containing the plain version
    def index_entry(chapter_number, chapter_name, slide_file, slide_name, plain_file, plain_name)
      @io << "<tr><td>#{chapter_number} - #{chapter_name}</td>"
      @io << "<td><a href='#{slide_file}'>#{slide_name}</a></td>"
      @io << "<td><a href='#{plain_file}'>#{plain_name}</a></td></tr>" << nl
    end

    ##
    # HTML output
    # @param [String] content html
    def html(content)
      @io << content << nl
    end

    ##
    # Include CSS files
    # @param [Array] locations locations of the css files
    # @return [String] link tags
    def include_css(locations)
      result = ''
      locations.each { |l| result << css(l) }
      result
    end

    ##
    # Include JavaScript files
    # @param [Array] locations locations of the javscript files
    # @return [String] script tags
    def include_javascript(locations)
      result = ''
      locations.each { |l| result << js(l) }
      result
    end

    ##
    # Single css entry
    # @param [String] css location of css file
    def css(css)
      "<link rel='stylesheet' href='#{css}'>" << nl
    end

    ##
    # Single JavaScript entry
    # @param [String] js location of JavaScript file
    def js(js)
      "<script src='#{js}'></script>" << nl
    end

    ##
    # Include inline scripts
    # @param [Array] s scripts to be added
    def scripts(s)
      result = ''
      s.each { |s| result << "<script>#{s}</script>" << nl }
      result
    end

    ##
    # Render an UML inline diagram using an external tool
    # @param [String] picture_name name of the picture
    # @param [String] contents the embedded UML
    # @param [String] width width of the diagram
    def uml(picture_name, contents, width)
      img_path = super(picture_name, contents, width, 'svg')
      @io << "<img src='#{img_path}' width='#{width}'>" << nl
    end

    ##
    # Return the most suitable image file for the given
    # @param [String] file_name name of the image
    # @param [Array] formats available file formats
    # @return the most preferred image filen ame
    def choose_image(file_name, formats)

      format = formats.each { |f|
        break f  if PREFERRED_IMAGE_FORMATS.include?(f)
      }

      if /(.*?)\.[A-Za-z]{3,4}/ =~ file_name
        "#{$1}.#{format}"
      else
        "#{file_name}.#{format}"
      end
    end
  end
end
