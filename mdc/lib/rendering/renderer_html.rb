require 'erb'

require_relative 'renderer'
require_relative '../messages'
require_relative '../constants'

module Rendering
  ##
  # Base class for rendering slides to HTML
  class RendererHTML < Renderer
    PREFERRED_IMAGE_FORMATS = %w[svg png jpg].freeze

    ## ERB templates to be used by the renderer
    TEMPLATES = {
      vertical_space: erb(
        '
          <br>
          '
      ),

      equation: erb(
        %q(
        \[
        <%= contents %>
        \]
        )
      ),

      ol_start: erb(
        "<ol start='<%= number %>'>"
      ),

      ol_item: erb(
        '  <li><%= inline_code(content) %>'
      ),

      ol_end: erb(
        '
        </ol>
        '
      ),

      ul_start: erb(
        '<ul>'
      ),

      ul_item: erb(
        '  <li><%= inline_code(content) %>'
      ),

      ul_end: erb(
        '</ul>'
      ),

      quote: erb(
        "
        <blockquote><%= inline_code(content) %>
        <% if !source.nil? %>
          <div class='quote_source'><%= source %></div>
        <% end %>
        </blockquote>
        "
      ),

      important: erb(
        "
        <blockquote class='important'><%= inline_code(content) %>
        </blockquote>
        "
      ),

      question: erb(
        "
        <blockquote class='question'><%= inline_code(content) %>
        </blockquote>
        "
      ),

      box: erb(
        "
        <blockquote class='box'><%= inline_code(content) %>
        </blockquote>
        "
      ),

      script: erb(
        '
        <script><%= content %></script>
        '
      ),

      code_start: erb(
        "<figure class='code'><%= caption_command %><pre><code class='<%= language %>' contenteditable>"
      ),

      code: erb(
        '<%= entities(content) %>'
      ),

      code_end: erb(
        '</code></pre></figure>'
      ),

      table_start: erb(
        "
        <table class='small content'>
        <thead><tr>
        "
      ),

      table_separator: erb(
        '
        '
      ),

      table_end: erb(
        '
        </tbody></table>
        '
      ),

      text: erb(
        '
        <p><%= inline_code(content) %></p>
        '
      ),

      heading: erb(
        '
        <h<%= level %>><%= title %></h<%= level %>>
        '
      ),

      toc_start: erb(
        "
        <section data-number='2'>
        <h1 class='title toc'><%= translate(:toc) %></h1>
        <ul>
        "
      ),

      toc_entry: erb(
        "
        <li><a href='#<%= anchor %>'><%= name %></a>
        "
      ),

      toc_end: erb(
        '
        </ul>
        </section>
        '
      ),

      toc_sub_entries_start: erb(
        "
        <ul class='subentry'>
        "
      ),

      toc_sub_entry: erb(
        "
        <li><a href='#<%= anchor %>'><%= name %></a>
        "
      ),

      toc_sub_entries_end: erb(
        '
        </ul>
        '
      ),

      index_start: erb(
        "
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset='utf-8'>
          <title><%= title1 %></title>
          <link rel='stylesheet' href='css/plain.css'>
          <link rel='stylesheet' href='css/book.css'>
          <link rel='stylesheet' href='css/zenburn.css'>
          <script src='lib/js/head.min.js'></script>
          <script src='js/thomas.js'></script>
          <script src='lib/js/highlight.js'></script>
          <script src='lib/js/jquery-1.9.1.js'></script>
          <script src='lib/mathjax/MathJax.js?config=TeX-AMS_HTML'></script>
        </head>
        <body>
        <div class='title_first'><%= title1 %></div>
        <div class='title_second'><%= title2 %></div>
        <div class='copyright'><%= copyright%></div>
        <div class='description'><%= description%></div>
        <br>
        <table>
        <tr><th><%= translate(:chapter) %></th>
        <th colspan='2'><%= translate(:material) %></th></tr>
        "
      ),

      index_entry: erb(
        "
        <tr>
        <td><%= chapter_number %> - <%= chapter_name %></td>
        <td><a href='<%= slide_file %>'><%= slide_name %></a></td>
        <td><a href='<%= plain_file %>'><%= plain_name %></a></td>
        </tr>
        "
      ),

      index_end: erb(
        '
        </table>
        </div>
        </body>
        </html>
        '
      ),

      html: erb(
        '<%= content %>'
      )
    }.freeze

    ## Inline replacements
    INLINE = [
      [/ ([A-Za-z0-9])_([A-Za-z0-9]) /, ' \1<sub>\2</sub> '],
      [/ ([A-Za-z0-9])\^([A-Za-z0-9]) /, ' \1<sup>\2</sup> '],
      [/([A-Za-z0-9])\^([A-Za-z0-9])$/,  ' \1<sup>\2</sup>'],
      [/([A-Za-z0-9])\^([A-Za-z0-9]) /,  ' \1<sup>\2</sup> '],
      [/__(.+?)__/,                      '<strong>\1</strong>'],
      [/_(.+?)_/,                        '<em>\1</em>'],
      [/\*\*(.+?)\*\*/,                  '<strong class="alternative">\1</strong>'],
      [/\*(.+?)\*/,                      '<em class="alternative">\1</em>'],
      [/~~(.+?)~~/,                      '<del>\1</del>'],
      [/Z\.B\./,                         'Z.&nbsp;B.'],
      [/z\.B\./,                         'z.&nbsp;B.'],
      [/D\.h\./,                         'D.&nbsp;h.'],
      [/d\.h\./,                         'd.&nbsp;h.'],
      [/u\.a\./,                         'u.&nbsp;a.'],
      [/s\.o\./,                         's.&nbsp;o.'],
      [/s\.u\./,                         's.&nbsp;u.'],
      [/i\.e\./,                         'i.&nbsp;e.'],
      [/e\.g\./,                         'e.&nbsp;g.'],
      [/---/,                            '&mdash;'],
      [/--/,                             '&ndash;'],
      [/\.\.\./,                         '&hellip;'],

      [/\[\^(.*?)\]/,         '<sup><span title=\'\1\'>*</span></sup>'],

      [/^-> /,                '&rarr; '],
      ['(-> ',                '(&rarr; '],
      ['(->)',                '(&rarr;)'],
      ['{-> ',                '{&rarr; '],
      [' -> ',                ' &rarr; '],
      ['<br>-> ',             '<br>&rarr; '],

      [/^=> /,                '&rArr; '],
      ['(=> ',                '(&rArr; '],
      ['(=>)',                '(&rArr;)'],
      ['{=> ',                '{&rArr; '],
      [' => ',                ' &rArr; '],
      ['<br>=> ',             '<br>&rArr; '],

      [/^<- /,                '&larr; '],
      ['(<- ',                '(&larr; '],
      ['(<-)',                '(&larr;)'],
      [' <- ',                ' &larr; '],
      ['{<- ',                '{&larr; '],
      ['<br><- ',             '<br>&larr; '],

      [/^<= /,                '&lArr; '],
      ['(<= ',                '(&lArr; '],
      ['(<=)',                '(&lArr;)'],
      ['{<= ',                '{&lArr; '],
      [' <= ',                ' &lArr; '],
      ['<br><= ',             '<br>&lArr; '],

      [/^<=> /,               '&hArr; '],
      ['(<=> ',               '(&hArr; '],
      ['(<=>)',               '(&hArr;)'],
      ['{<=> ',               '{&hArr; '],
      [' <=> ',               ' &hArr; '],
      ['<br><=> ',            '<br>&hArr; '],

      [/^<-> /,               '&harr; '],
      ['(<-> ',               '(&harr; '],
      ['(<->)',               '(&harr;)'],
      ['{<-> ',               '{&harr; '],
      [' <-> ',               ' &harr; '],
      ['<br><-> ',            '<br>&harr; ']

    ].freeze

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
    def all_templates
      @templates = super.merge(TEMPLATES)
    end

    ##
    # Method returning the inline replacements.Should be overwritten by the
    # subclasses.
    # @param [Boolean] _alternate should alternate replacements be used
    # @return [String[]] the templates
    def all_inline_replacements(_alternate = false)
      INLINE
    end

    ##
    # Replace inline elements like emphasis (_..._)
    #
    # @param [String] input Text to be replaced
    # @param [boolean] alternate alternate emphasis to be used
    # @return [String] Text with replacements performed
    def inline(input, alternate = false)
      # Separate Hyperlinks from other contents
      parts = tokenize_line(input, /(\[.+?\]\(.+?\))/)
      result = ''

      parts.each do |p|
        if p.matched
          # Hyperlink
          result << p.content.gsub(/\[(.+?)\]\((.+?)\)/, '<a href="\2">\1</a>')
        elsif p.content =~ /\\\[(.*?)\\\]/
          # Inline formula, treat special
          sub_parts = tokenize_line(p.content, /\\\[(.*?)\\\]/)
          sub_parts.each do |sp|
            result << replace_inline_content(sp.content, alternate) unless sp.matched
            result << '\(' << sp.content << '\)' if sp.matched
          end
        else
          # No Hyperlink, no inline formula
          result << replace_inline_content(p.content)
        end
      end

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

      parts.each do |p|
        result << if p.matched
                    "<code class='inline #{@language}'>#{entities(p.content)}</code>"
                  else
                    inline(p.content)
                  end
      end

      result
    end

    ##
    # Start of a code fragment
    # @param [String] language language of the code fragment
    # @param [String] caption caption of the sourcecode
    def code_start(language, caption)
      if caption.nil?
        caption_command = ''
      else
        replaced_caption = replace_inline_content(caption)
        caption_command = "<figcaption>#{replaced_caption}</figcaption>"
      end

      @io << @templates[:code_start].result(binding).chomp
    end

    ##
    # Replace []() links in input
    # @param [String] input the input
    # @return the input with replaced code fragments
    def inline_links(input)
      parts = tokenize_line(input, /`(.+?)`/)
      result = ''

      parts.each do |p|
        result << if p.code
                    "<code class='inline #{@language}'>#{entities(p.content)}</code>"
                  else
                    inline(p.content)
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
    # Separator in the table
    # @param [Array] headers the headers
    def table_separator(headers)
      colspan = headers.count
      @io << @templates[:table_separator].result(binding)
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

      @io << '</tr>' << nl
    end

    ##
    # Return the most suitable image file for the given
    # @param [String] file_name name of the image
    # @param [Array] formats available file formats
    # @return the most preferred image filen ame
    def choose_image(file_name, formats)
      format = formats.each do |f|
        break f if PREFERRED_IMAGE_FORMATS.include?(f)
      end

      if /(.*?)\.[A-Za-z]{3,4}/ =~ file_name
        "#{Regexp.last_match(1)}.#{format}"
      else
        "#{file_name}.#{format}"
      end
    end
  end
end
