# -*- coding: utf-8 -*-

require_relative 'renderer_html'
require_relative '../messages'

module Rendering

  ##
  # Renderer to HTML for presentations
  class RendererHTMLPresentation < RendererHTML

    ## ERB templates to be used by the renderer
    TEMPLATES = {
        button: erb(
            %q|
           <button onclick='executeNew(this);' class='runbutton'>
           <%= LOCALIZED_MESSAGES[:run] %>
           </button><span style='display: none;' name='log' class='output'>&nbsp;</span>
           |
        ),

        button_with_log: erb(
            %q|
            <button onclick='executeNew(this);' class='runbutton'>
            <%= LOCALIZED_MESSAGES[:run] %>
            </button><div name='log' class='output_small'></div>
           |
        ),

        button_with_log_pre: erb(
            %q|
            <button onclick='executePre(this);' class='runbutton'>
            <%= LOCALIZED_MESSAGES[:run] %>
            </button><div name='log' class='output_small'></div>
           |
        ),

        link_previous: erb(
            %q|
            <div class='outputhtml plain' id='<%= line_id %>' name='html_output'>&nbsp;</div>
            <script>attachPreviousHandler($('#<%= line_id %>'));</script>
           |
        ),

        live_css: erb(
            %q|
            <iframe name='dest' src='' class='framed_wide'></iframe>
            <script id='<%= line_id %>'>attachHandlerCSS($('#<%= line_id %>'), <%= fragment %>);</script>
           |
        ),

        live_preview: erb(
            %q|
            <div class='outputhtml plain' id='<%= line_id %>' name='html_output'>&nbsp;</div>
            <script>attachHandler($('#<%= line_id %>'));</script>
           |
        ),

        live_preview_float: erb(
            %q|
            <div class='outputhtml' style='float: right;' id='<%= line_id %>' name='html_output'>&nbsp;</div>
            <script>synchronize($('#<%= line_id %>'));</script>
           |
        ),

        comment_start: erb(
            %q|
            <div class='more'><img src='img/help.png' onclick="$('#dialog_<%= @dialog_counter %>').dialog('open')"></div>
            <div id='dialog_<%= @dialog_counter %>' title='<%= LOCALIZED_MESSAGES[:more_info] %>'><p>
            |
        ),

        comment_end: erb(
            %q|
            <p></div>
            <script>$('#dialog_<%= @dialog_counter %>').dialog( { width: 900, autoOpen: false  %> );</script>
            |
        ),

        image: erb(
            %q|
            <img class='presentation' src='<%= chosen_image %>' alt='<%= alt %>' title='<%= title %>'<%= width_attr %>>
            <div class='img_info'><%= inline(title) %></div>
            |
        ),

        uml: erb(
            %q|
            <img src='<%= img_path %>' width='<%= width_slide %>'>
            |
        ),

        chapter_start: erb(
            %q|
            <section id='<%= id %>' class='chapter' data-number='<%= number %>'>
            <h1 class='trenner'><%= title %></h1>
            </section>
           |
        ),

        chapter_end: erb(
            %q|
            |
        ),

        slide_start: erb(
            %q|
            <section id='<%= id %>' class='slide' data-number='<%= number %>'>
            <h2 class='title'><%= inline_code(title) %></h2>
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
              <meta name='apple-mobile-web-app-capable' content='yes' />
              <meta name='apple-mobile-web-app-status-bar-style' content='black-translucent' />
              <link rel='stylesheet' href='css/plain.css'>
              <link rel='stylesheet' href='css/zenburn.css'>
              <link rel='stylesheet' href='css/ui-lightness/jquery-ui-1.10.3.css'>
              <link rel='stylesheet' href='css/main.css'>
              <link rel='stylesheet' href='css/thomas.css'>

              <script src='lib/js/head.min.js'></script>
              <script src='js/thomas.js'></script>
              <script src='lib/js/highlight.js'></script>
              <script src='lib/js/jquery-1.9.1.js'></script>
              <script src='lib/mathjax/MathJax.js?config=TeX-AMS_HTML'></script>
              <script src='lib/js/jquery-ui-1.10.3.js'></script>
            </head>

            <body>
            <div class='reveal'>
            <!-- Used to fade in a background when a specific slide state is reached -->
            <div class='state-background'></div>

            <!-- Any section element inside of this container is displayed as a slide -->
            <div class='slides'>

            <section data-number=''>
              <h1><%= title1 %></h1>
              <h2><%= title2 %></h2>
              <div class='kapitel_nr' style='margin-top: 50%'><%= section_number %></div>
              <div class='kapitel'><%= section_name %></div>
              <img class='plain' style='position: absolute; bottom: -10px; right: 0;' src='img/logo_title.png' alt='Telefon'>
            </section>
            |
        ),

        presentation_end: erb(
            %Q?
            </div>

            <!-- The navigational controls UI -->
            <aside class='controls'>
            <a class='left' href='#'>&#x25C4;</a>
            <a class='right' href='#'>&#x25BA;</a>
            <a class='up' href='#'>&#x25B2;</a>
            <a class='down' href='#'>&#x25BC;</a>
            </aside>

            <!-- Presentation progress bar -->
            <div class='progress'><span></span></div>

            </div>
            <div class='menu'>
            <ul id='menu'>
            <li id='menu-inhalt'><%= LOCALIZED_MESSAGES[:contents] %>
            <%= toc_menu %>
            </ul>
            </div>
            <div class='copyright'>
            <%= title1 %> | <%= copyright %>
            </div>
              <div class='nummer'>
              <span id='slide_nr'>&nbsp;</span>
            </div>
              <script src='lib/js/reveal.min.js'></script>
              <script src='js/settings.js'></script>

              <script>$('code.inline').each(function(i, e) { hljs.highlightBlock(e) } );</script>
              <script>$(function() { $('#menu').menu({ position: { my: 'left bottom', at: 'right-5 top+5' } }); });</script>
              <script>Reveal.addEventListener( 'slidechanged', function( event ) { $('#slide_nr').html($(event.currentSlide).attr('data-number')); } );</script>
              </body>
            </html>
            ?
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
      @dialog_counter = 1   # counter for dialog popups
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

      if width_slide
          width_attr = " width='#{width_slide}'"
      end

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
    # Small TOC menu for presentation slides for quick navigation
    def toc_menu

      result = ''

      result << '<ul>' << nl

      @toc.entries.each do |e|
        result << "  <li><a href='##{e.id}'>#{e.name}</a>" << nl

        if e.entries.length > 0
          result << '    <ul>' << nl

          e.entries.each do |se|
            unless se.name == @last_toc_name
              result << "      <li><a href='##{se.id}'>#{se.name}</a>" << nl
              @last_toc_name = se.name
            end
          end
        end

        result << '    </ul>' << nl
      end

      result << '    </ul>' << nl
      result
    end
  end
end
