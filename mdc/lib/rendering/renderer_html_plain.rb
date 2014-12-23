# -*- coding: utf-8 -*-

require_relative 'renderer_html'
require_relative '../messages'

module Rendering

  ##
  # Renderer to HTML for plain (book) like output
  class RendererHTMLPlain < RendererHTML

    ## ERB templates to be used by the renderer
    TEMPLATES = {
        button: erb(
            %q|
            <span style='visibility: hidden;' name='log' class='output'>&nbsp;</span>
            <script id='<%= line_id %>'>executeNew($('#<%= line_id %>'));</script>
            |
        ),

        button_with_log: erb(
            %q|
            <p class='ausgabe'><%= LOCALIZED_MESSAGES[:output] %>:</p><div name='log' class='output_small'></div>
            <script id='<%= line_id %>'>executeNew($('#<%= line_id %>'));</script>
            |
        ),

        button_with_log_pre: erb(
            %q|
            <p class='ausgabe'><%= LOCALIZED_MESSAGES[:output] %></p><div name='log' class='output_small'></div>
            <script id='<%= line_id %>'>executePre($('#<%= line_id %>'));</script>
            |
        ),

        link_previous: erb(
            %q|
             <div class='outputhtml plain' id='<%= line_id %>' name='html_output'>&nbsp;</div>
             <script>synchronizePrevious($('#<%= line_id %>'));</script>
            |
        ),

        live_css: erb(
            %q|
             <iframe name='dest' src='' class='framed_wide'></iframe>
             <script id='<%= line_id %>'>synchronizeCSS($('#<%= line_id %>'), <%= fragment %>);</script>
            |
        ),

        live_preview: erb(
            %q|
            <div class='outputhtml plain' id='<%= line_id %>' name='html_output'>&nbsp;</div>
            <script>synchronize($('#<%= line_id %>'));</script>
            |
        ),

        live_preview_float: erb(
            %q|
            <div class='outputhtml plain' sytle='float: right;' id='<%= line_id %>' name='html_output'>&nbsp;</div>
            <script>synchronize($('#<%= line_id %>'));</script>
            |
        ),

        comment_start: erb(
            %q|
            <hr><div class='comment'>
            |
        ),

        comment_end: erb(
            %q|
            <hr></div>
            |
        ),

        image: erb(
            %q|
            <figure class='picture'>
            <img alt='<%= alt %>' src='<%= chosen_image %>'<%= width_attr %>>
            <figcaption><%= inline(title) %></figcaption>
            </figure>
            |
        ),

        uml: erb(
            %q|
            <img src='<%= img_path %>' width='<%= width_plain %>'>
            |
        ),

        chapter_start: erb(
            %q|
            <section id='<%= id %>' class='chapter'><h1 class='trenner'><%= title %></h1>
            |
        ),

        chapter_end: erb(
            %q|
            </section>
            |
        ),

        slide_start: erb(
            %q|
            <section id='<%= id %>' class='slide'>
            |
        ),

        slide_end: erb(
            %q|
            </section>
            |
        ),

        presentation_start: erb(
            %q|
            <!DOCTYPE html>
            <html lang='de'>
            <head>
              <meta charset='utf-8'>
              <title><%= title1 %>: <%= section_name %></title>
              <meta name='author' content='<%= author %>'>
              <%= include_css(INCLUDED_STYLESHEETS) %>
            <%= include_javascript(INCLUDED_SCRIPTS_HEAD) %>
            </head>
            <body>
              <div class='title_first'><%= title1 %></div>
              <div class='title_first'><%= title2 %></div>
              <div class='kapitel_nr'><%= section_number %></div>
              <div class='kapitel'><%= section_name %></div>
              <div class='copyright'><%= copyright %></div>
            |
        ),

        presentation_end: erb(
            %q|
            </div>
            <%= scripts(JAVASCRIPTS) %>
            </body>
            </html>
            |
        ),
    }
    
    ##
    # Stylesheets used by this renderer
    INCLUDED_STYLESHEETS = [
        CSS_BOOK,
        CSS_ZENBURN,
    ]

    ##
    # JavaScripts used in the header
    INCLUDED_SCRIPTS_HEAD = [
        JS_HEAD,
        JS_THOMAS,
        JS_HIGHLIGHT,
        JS_JQUERY,
        JS_MATHJAX,
    ]

    ##
    # Inline scripts
    JAVASCRIPTS = [
        'hljs.initHighlighting();',
        "$('code.inline').each(function(i, e) { hljs.highlightBlock(e)} );",
    ]

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
    # Indicates whether the renderer handles animations or not. false indicates
    # that slides should not be repeated.
    def handles_animation?
      false
    end

    ##
    # Render a button
    # @param [String] line_id internal ID of the line
    def button(line_id)
      @io << TEMPLATES[:button].result(binding)
    end

    ##
    # Render a button with log area
    # @param [String] line_id internal ID of the line
    def button_with_log(line_id)
      @io << TEMPLATES[:button_with_log].result(binding)
    end

    ##
    # Render a button with output
    # @param [String] line_id internal ID of the line
    def button_with_log_pre(line_id)
      @io << TEMPLATES[:button_with_log_pre].result(binding)
    end

    ##
    # Link to previous slide (for active HTML)
    # @param [String] line_id internal ID of the line
    def link_previous(line_id)
      @io << TEMPLATES[:link_previous].result(binding)
    end

    ##
    # Link to previous slide (for active CSS)
    # @param [String] line_id internal ID of the line
    # @param [String] fragment HTML fragment used for CSS styling
    def live_css(line_id, fragment)
      @io << TEMPLATES[:live_css].result(binding)
    end

    ##
    # Link to previous slide (for active CSS)
    # @param [String] line_id internal ID of the line
    def live_preview(line_id)
      @io << TEMPLATES[:live_preview].result(binding)
    end

    ##
    # Perform a live preview
    # @param [String] line_id internal ID of the line
    def live_preview_float(line_id)
      @io << TEMPLATES[:live_preview_float].result(binding)
    end

    ##
    # Beginning of a comment section, i.e. explanations to the current slide
    def comment_start
      @io << TEMPLATES[:comment_start].result(binding)
    end

    ##
    # End of comment section
    def comment_end
      @io << TEMPLATES[:comment_end].result(binding)
      @dialog_counter += 1
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

      if width_plain
        width_attr = " width='#{width_plain}'"
      end

      @io << TEMPLATES[:image].result(binding)
    end

    ##
    # Render an UML inline diagram using an external tool
    # @param [String] picture_name name of the picture
    # @param [String] contents the embedded UML
    # @param [String] width_slide width of the diagram on slides
    # @param [String] width_plain width of the diagram on plain documents
    def uml(picture_name, contents, width_slide, width_plain)
      img_path = super(picture_name, contents, width_slide, width_plain, 'svg')
      @io << TEMPLATES[:uml].result(binding)
    end

    ##
    # Start a chapter
    # @param [String] title the title of the chapter
    # @param [String] number the number of the chapter
    # @param [String] id the uniquie id of the chapter (for references)
    def chapter_start(title, number, id)
      @io << TEMPLATES[:chapter_start].result(binding)
    end

    ## End of a chapter
    def chapter_end
      @io << TEMPLATES[:chapter_end].result(binding)
    end

    ##
    # Start of slide
    # @param [String] title the title of the slide
    # @param [String] number the number of the slide
    # @param [String] id the unique id of the slide (for references)
    # @param [Boolean] contains_code indicates whether the slide contains code fragments
    def slide_start(title, number, id, contains_code)
      escaped_title = inline_code(title)
      @io << TEMPLATES[:slide_start].result(binding)

      unless title == @last_title
        @io << "<h2 class='title'>#{escaped_title} <span class='title_number'>[#{number}]</span></h2>" << nl
        @last_title = title
      end
    end

    ##
    # End of slide
    def slide_end
      @io << TEMPLATES[:slide_end].result(binding)
    end

    ##
    # Start of presentation
    # @param [String] title1 first title
    # @param [String] title2 second title
    # @param [String] section_number number of the section
    # @param [String] section_name name of the section
    # @param [String] copyright copyright information
    # @param [String] author author of the presentation
    # @param [String] description additional description
    # @param [String] term of the lecture
    def presentation_start(title1, title2, section_number, section_name, copyright, author, description, term = '')
      @io << TEMPLATES[:presentation_start].result(binding)
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
      @io << TEMPLATES[:presentation_end].result(binding)
    end
  end
end
