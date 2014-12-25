# -*- coding: utf-8 -*-

require 'erb'

require_relative 'renderer'
require_relative '../messages'
require_relative '../constants'

module Rendering

  ##
  # Base class for rendering slides to HTML
  class RendererHTML < Renderer

    ##
    # Include CSS files
    # @param [Array] locations locations of the css files
    # @return [String] link tags
    def self.include_css(locations)
      result = ''
      locations.each { |l| result << css(l) }
      result
    end

    ##
    # Include JavaScript files
    # @param [Array] locations locations of the javscript files
    # @return [String] script tags
    def self.include_javascript(locations)
      result = ''
      locations.each { |l| result << js(l) }
      result
    end

    ##
    # Single css entry
    # @param [String] css location of css file
    def self.css(css)
      "<link rel='stylesheet' href='#{css}'>\n"
    end

    ##
    # Single JavaScript entry
    # @param [String] js location of JavaScript file
    def self.js(js)
      "<script src='#{js}'></script>\n"
    end

    ##
    # Include inline scripts
    # @param [Array] s scripts to be added
    def self.scripts(s)
      result = ''
      s.each { |f| result << "<script>#{f}</script>\n" }
      result
    end

    CSS_PLAIN     = 'css/plain.css'
    CSS_BOOK      = 'css/book.css'
    CSS_ZENBURN   = 'css/zenburn.css'
    CSS_LIGHTNESS = 'css/ui-lightness/jquery-ui-1.10.3.css'
    CSS_THOMAS    = 'css/thomas.css'
    CSS_MAIN      = 'css/main.css'
    JS_HEAD       = 'lib/js/head.min.js'
    JS_THOMAS     = 'js/thomas.js'
    JS_HIGHLIGHT  = 'lib/js/highlight.js'
    JS_JQUERY     = 'lib/js/jquery-1.9.1.js'
    JS_MATHJAX    = 'lib/mathjax/MathJax.js?config=TeX-AMS_HTML'
    JS_JQUERY_UI  = 'lib/js/jquery-ui-1.10.3.js'
    JS_REVEAL     = 'lib/js/reveal.min.js'
    JS_SETTINGS   = 'js/settings.js'

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

    ## ERB templates to be used by the renderer
    TEMPLATES = {
        vertical_space: erb(
            %q|
            <br>
            |
        ),

        equation: erb(
            %q|
            \[
            <%= contents %>
            \]
            |
        ),

        ol_start: erb(
            %q|
            <ol start='<%= number %>'>
            |
        ),

        ol_item: erb(
            %q|
            <li><%= inline_code(content) %>
            |
        ),

        ol_end: erb(
            %q|
            </ol>
            |
        ),

        ul_start: erb(
            %q|
            <ul>
            |
        ),

        ul_item: erb(
            %q|
            <li><%= inline_code(content) %>
            |
        ),

        ul_end: erb(
            %q|
            </ul>
            |
        ),

        quote: erb(
            %q|
            <blockquote><%= inline_code(content) %>
            <% if !source.nil? %>
              <div class='quote_source'><%= source %></div>
            <% end %>
            </blockquote>
            |
        ),

        important: erb(
            %q|
            <blockquote class='important'><%= inline_code(content) %>
            </blockquote>
            |
        ),

        question: erb(
            %q|
            <blockquote class='question'><%= inline_code(content) %>
            </blockquote>
            |
        ),

        script: erb(
            %q|
            <script><%= content %></script>
            |
        ),

        code_start: erb(
            %q|<pre><code class='<%= language %>' contenteditable>|
        ),

        code: erb(
            %q|<%= entities(content) %>|
        ),

        code_end: erb(
            %q|</code></pre>|
        ),

        table_start: erb(
            %q|
            <table class='small content'>
            <thead><tr>
            |
        ),

        table_end: erb(
            %q|
            </tbody></table>
            |
        ),


        text: erb(
            %q|
            <p><%= inline_code(content) %></p>
            |
        ),

        heading: erb(
            %q|
            <h<%= level %>><%= title %></h<%= level %>>
            |
        ),

        toc_start: erb(
            %q|
            <section data-number='2'>
            <h1 class='title toc'><%= LOCALIZED_MESSAGES[:toc] %></h1>
            <ul>
            |
        ),

        toc_entry: erb(
            %q|
            <li><a href='#<%= anchor %>'><%= name %></a>
            |
        ),

        toc_end: erb(
            %q|
            </ul>
            </section>
            |
        ),

        toc_sub_entries_start: erb(
            %q|
            <ul class='subentry'>
            |
        ),

        toc_sub_entry: erb(
            %q|
            <li><a href='#<%= anchor %>'><%= name %></a>
            |
        ),

        toc_sub_entries_end: erb(
            %q|
            </ul>
            |
        ),

        index_start: erb(
            %Q|
            <!DOCTYPE html>
            <html>
            <head>
              <meta charset='utf-8'>
              <title><%= title1 %></title>
              #{ include_javascript(INCLUDED_SCRIPTS) }
              #{ include_css(INCLUDED_STYLESHEETS) }
            </head>
            <body>
            <div class='title_first'><%= title1 %></div>
            <div class='title_second'>%= title2 %></div>
            <div class='copyright'>%= copyright%></div>
            <div class='description'>%= description%></div>
            <br>
            <table>
            <tr><th><%= LOCALIZED_MESSAGES[:chapter] %></th>
            <th colspan='2'><%= LOCALIZED_MESSAGES[:material] %></th></tr>
            |
        ),

        index_entry: erb(
            %q|
            <tr>
            <td><%= chapter_number %> - <%= chapter_name %></td>
            <td><a href='<%= slide_file %>'><%= slide_name %></a></td>
            <td><a href='<%= plain_file %>'><%= plain_name %></a></td>
            </tr>
            |
        ),

        index_end: erb(
            %q|
            </table>
            </div>
            </body>
            </html>
            |
        ),

        html: erb(
            %q|<%= content %>|
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
      @toc = nil            # table of contents
      @last_toc_name = ''   # last name of toc entry to skip double entries
    end

    ##
    # Method returning the templates used by the renderer. Should be overwritten by the
    # subclasses.
    # @return [Hash] the templates
    def templates
      @templates = super.merge(TEMPLATES)
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
          result << p.content.gsub(/\[(.+?)\]\((.+?)\)/, '<a href="\2">\1</a>')
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

      result.gsub!(/ ([A-Za-z0-9])_([A-Za-z0-9]) /,  ' \1<sub>\2</sub> ')
      result.gsub!(/ ([A-Za-z0-9])\^([A-Za-z0-9]) /, ' \1<sup>\2</sup> ')
      result.gsub!( /([A-Za-z0-9])\^([A-Za-z0-9])$/, ' \1<sup>\2</sup>')
      result.gsub!( /([A-Za-z0-9])\^([A-Za-z0-9]) /, ' \1<sup>\2</sup> ')
      result.gsub!(/__(.+?)__/,           '<strong>\1</strong>')
      result.gsub!(/_(.+?)_/,             '<em>\1</em>')
      result.gsub!(/\*\*(.+?)\*\*/,       '<strong class="alternative">\1</strong>')
      result.gsub!(/\*(.+?)\*/,           '<em class="alternative">\1</em>')
      result.gsub!(/~~(.+?)~~/,           '<del>\1</del>')
      #result.gsub!(/s\[(.+?)\]\((.+?)\)/, '<a class="small" href="\2">\1</a>')
      #result.gsub!(/\[(.+?)\]\((.+?)\)/,  '<a href="\2">\1</a>')
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
      parts = tokenize_line(input, /`(.+?)`/)
      result = ''

      parts.each { |p|
        if p.matched
          result << "<code class='inline #{@language}'>#{entities(p.content)}</code>"
        else
          result << inline(p.content)
        end
      }

      result
    end

    ##
    # Replace []() links in input
    # @param [String] input the input
    # @return the input with replaced code fragments
    def inline_links(input)
      parts = tokenize_line(input, /`(.+?)`/)
      result = ''

      parts.each do |p|
        if p.code
          result << "<code class='inline #{@language}'>#{entities(p.content)}</code>"
        else
          result << inline(p.content)
        end
      end

      result
    end

    ##
    # Return a css class for the given alignment constant
    # @param [Fixnum] alignment for the alignment
    # @return [String] css class string to be used in HTML page
    def class_for_constant(alignment)
      case alignment
        when Constants::LEFT then " class='left'"
        when Constants::RIGHT then " class='right'"
        when Constants::CENTER then " class='center'"
        when Constants::SEPARATOR then " class='separator'"
        else ''
      end
    end

    ##
    # Header of table
    # @param [Array] headers the headers
    # @param [Array] alignment alignments of the cells
    def table_start(headers, alignment)

      @io << @templates[:table_start].result(binding)

      headers.each_with_index do |e, i|

        css_class = class_for_constant(alignment[i])

        @io << "<th#{css_class}>#{inline_code(e)}</th>" << nl if alignment[i] != Constants::SEPARATOR
        @io << "<th#{css_class}></th>" << nl if alignment[i] == Constants::SEPARATOR
      end

      @io << '</tr></thead><tbody>' << nl
    end

    ##
    # Row of the table
    # @param [Array] row row of the table
    # @param [Array] alignment alignments of the cells
    def table_row(row, alignment)
      @io << '<tr>' << nl
      row.each_with_index do |e, i|

        css_class = class_for_constant(alignment[i])

        @io << "<td#{css_class}>#{inline_code(e)}</td>" << nl if alignment[i] != Constants::SEPARATOR
        @io << "<td#{css_class}></td>" << nl if alignment[i] == Constants::SEPARATOR
      end

      @io <<  '</tr>' << nl
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
