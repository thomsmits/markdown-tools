require 'erb'

require_relative 'renderer'
require_relative 'line_renderer_html'
require_relative '../messages'
require_relative '../constants'

module Rendering
  ##
  # Base class for rendering slides to HTML
  class RendererHTML < Renderer
    PREFERRED_IMAGE_FORMATS = %w[svg png jpg jpeg].freeze

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
        '  <li><%= content %>'
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
        '  <li><%= content %>'
      ),

      ul_end: erb(
        '</ul>'
      ),

      quote: erb(
        "
        <blockquote><%= content %>
        <% if !source.nil? %>
          <div class='quote_source'><%= source %></div>
        <% end %>
        </blockquote>
        "
      ),

      important: erb(
        "
        <blockquote class='important'><%= content %>
        </blockquote>
        "
      ),

      question: erb(
        "
        <blockquote class='question'><%= content %>
        </blockquote>
        "
      ),

      box: erb(
        "
        <blockquote class='box'><%= content %>
        </blockquote>
        "
      ),

      script: erb(
        '
        <script><%= content %></script>
        '
      ),

      code_start: erb(
        "<figure class='code'><%= caption_command %><pre><code class='<%= prog_lang %>' contenteditable>"
      ),

      code: erb(
        '<%= line_renderer.meta(content) %>'
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
        '<p><%= content %></p>
        '
      ),

      heading: erb(
        '
        <h<%= level %>><%= line_renderer.meta(title) %></h<%= level %>>
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
          <script src='js/custom.js'></script>
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

    ##
    # Initialize the renderer
    # @param [IO, StringIO] io target of output operations
    # @param [String] prog_lang the default language for code snippets
    # @param [String] result_dir location for results
    # @param [String] image_dir location for generated images (relative to result_dir)
    # @param [String] temp_dir location for temporary files
    def initialize(io, prog_lang, result_dir, image_dir, temp_dir)
      super(io, LineRendererHTML.new(prog_lang), prog_lang, result_dir, image_dir, temp_dir)
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
    # Start of a code fragment
    # @param [String] prog_lang language of the code fragment
    # @param [String] caption caption of the sourcecode
    def code_start(prog_lang, caption)
      if caption.nil?
        caption_command = ''
      else
        replaced_caption = line_renderer.meta(caption)
        caption_command = "<figcaption>#{replaced_caption}</figcaption>"
      end

      @io << @templates[:code_start].result(binding).chomp
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

        @io << "<th#{css_class}>#{e}</th>" << nl if alignment[i] != Constants::SEPARATOR
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

        @io << "<td#{css_class}>#{e}</td>" << nl if alignment[i] != Constants::SEPARATOR
        @io << "<td#{css_class}></td>" << nl if alignment[i] == Constants::SEPARATOR
      end

      @io << '</tr>' << nl
    end

    ##
    # Render an image
    # @param [String] location path to image
    # @param [Array] formats available file formats
    # @param [String] alt alt text
    # @param [String] title title of image
    # @param [String] width_slide width for slide
    # @param [String] width_plain width for plain text
    # @param [String] source source of the image
    def image(location, formats, alt, title, width_slide, width_plain, source = nil)
      chosen_image = choose_image(location, formats)

      width_attr_plain = ''
      width_attr_plain = " width='#{width_plain}'" if width_plain

      width_attr_slide = ''
      width_attr_slide = " width='#{width_slide}'" if width_slide

      full_title = title

      unless source.nil?
        full_title << ', ' if !full_title.nil? && !full_title.empty?
        full_title = "#{full_title}#{translate(:source)}#{source}"
      end

      @io << @templates[:image].result(binding)
    end

    ##
    # Return the most suitable image file for the given
    # @param [String] file_name name of the image
    # @param [Array] formats available file formats
    # @return the most preferred image file name
    def choose_image(file_name, formats)

      format = nil

      formats.each do |f|
        if PREFERRED_IMAGE_FORMATS.include?(f)
          format = f
          break
        end
      end

      if format.nil?
        raise Exception, "No suitable format found for image #{file_name}; Found: #{formats}; Supported: #{PREFERRED_IMAGE_FORMATS}"
      end

      if /(.*?)\.[A-Za-z]{3,4}/ =~ file_name
        "#{Regexp.last_match(1)}.#{format}"
      else
        "#{file_name}.#{format}"
      end
    end
  end
end
