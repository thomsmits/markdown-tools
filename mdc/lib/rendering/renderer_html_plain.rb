require_relative 'renderer_html'
require_relative '../messages'

module Rendering
  ##
  # Renderer to HTML for plain (book) like output
  class RendererHTMLPlain < RendererHTML
    ## ERB templates to be used by the renderer
    TEMPLATES = {
      button: erb(
        "
          <span style='visibility: hidden;' name='log' class='output'>&nbsp;</span>
          <script id='<%= line_id %>'>executeNew($('#<%= line_id %>'));</script>
          "
      ),

      button_with_log: erb(
        "
        <p class='ausgabe'><%= translate(:output) %>:</p><div name='log' class='output_small'></div>
        <script id='<%= line_id %>'>executeNew($('#<%= line_id %>'));</script>
        "
      ),

      button_with_log_pre: erb(
        "
        <p class='ausgabe'><%= translate(:output) %></p><div name='log' class='output_small'></div>
        <script id='<%= line_id %>'>executePre($('#<%= line_id %>'));</script>
        "
      ),

      link_previous: erb(
        "
         <div class='outputhtml plain' id='<%= line_id %>' name='html_output'>&nbsp;</div>
         <script>synchronizePrevious($('#<%= line_id %>'));</script>
        "
      ),

      live_css: erb(
        "
         <iframe name='dest' src='' class='framed_wide'></iframe>
         <script id='<%= line_id %>'>synchronizeCSS($('#<%= line_id %>'), <%= fragment %>);</script>
        "
      ),

      live_preview: erb(
        "
        <div class='outputhtml plain' id='<%= line_id %>' name='html_output'>&nbsp;</div>
        <script>synchronize($('#<%= line_id %>'));</script>
        "
      ),

      live_preview_float: erb(
        "
        <div class='outputhtml plain' sytle='float: right;' id='<%= line_id %>' name='html_output'>&nbsp;</div>
        <script>synchronize($('#<%= line_id %>'));</script>
        "
      ),

      comment_start: erb(
        "
        <div class='comment'>
        "
      ),

      comment_end: erb(
        '
        </div>
        '
      ),

      code_start: erb(
          "<figure class='code'><%= caption_command %><pre><code class='<%= language %>'>"
      ),

      image: erb(
        "
        <figure class='picture'>
        <img alt='<%= alt %>' src='<%= chosen_image %>'<%= width_attr %>>
        <figcaption><%= inline(title) %></figcaption>
        </figure>
        "
      ),

      uml: erb(
        "
        <img src='<%= img_path %>' width='<%= width_plain %>'>
        "
      ),

      chapter_start: erb(
        "
        <section id='<%= id %>' class='chapter'><h1 class='trenner'><%= title %></h1>"
      ),

      chapter_end: erb(
        '
        </section>
        '
      ),

      slide_start: erb(
        "
        <section id='<%= id %>' class='slide'>
        "
      ),

      slide_end: erb(
        '
        </section>
        '
      ),

      presentation_start: erb(
        "
        <!DOCTYPE html>
        <html lang='de'>
        <head>
          <meta charset='utf-8'>
          <title><%= title1 %>: <%= section_name %></title>
          <meta name='author' content='<%= author %>'>
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
          <div class='title_first'><%= title2 %></div>
          <div class='kapitel_nr'><%= section_number %></div>
          <div class='kapitel'><%= section_name %></div>
          <div class='copyright'><%= copyright %></div>
        "
      ),

      presentation_end: erb(
        "
        </div>
        <script>hljs.initHighlighting();</script>
        <script>$('code.inline').each(function(i, e) { hljs.highlightBlock(e)} );</script>
        </body>
        </html>
        "
      )
    }.freeze

    ##
    # Initialize the renderer
    # @param [IO] io target of output operations
    # @param [String] language the default language for code snippets
    # @param [String] result_dir location for results
    # @param [String] image_dir location for generated images (relative to result_dir)
    # @param [String] temp_dir location for temporary files
    def initialize(io, language, result_dir, image_dir, temp_dir)
      super(io, language, result_dir, image_dir, temp_dir)
      @dialog_counter = 1   # counter for dialog popups
      @last_title = ''      # last slide title
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

      width_attr = ''

      width_attr = " width='#{width_plain}'" if width_plain

      @io << @templates[:image].result(binding)
    end

    ##
    # Render an UML inline diagram using an external tool
    # @param [String] picture_name name of the picture
    # @param [String] contents the embedded UML
    # @param [String] width_slide width of the diagram on slides
    # @param [String] width_plain width of the diagram on plain documents
    def uml(picture_name, contents, width_slide, width_plain)
      img_path = super(picture_name, contents, width_slide, width_plain, 'svg')
      @io << @templates[:uml].result(binding)
    end

    ##
    # Start of slide
    # @param [String] title the title of the slide
    # @param [String] number the number of the slide
    # @param [String] id the unique id of the slide (for references)
    # @param [Boolean] contains_code indicates whether the slide contains code fragments
    def slide_start(title, number, id, contains_code)
      escaped_title = inline_code(title)
      @io << @templates[:slide_start].result(binding)

      unless title == @last_title
        @io << "<h2 class='title'>#{escaped_title} <span class='title_number'>[#{number}]</span></h2>" << nl
        @last_title = title
      end
    end
  end
end
