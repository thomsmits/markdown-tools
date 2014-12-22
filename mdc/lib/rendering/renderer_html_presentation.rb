# -*- coding: utf-8 -*-

require_relative 'renderer_html'
require_relative '../messages'

module Rendering

  ##
  # Renderer to HTML for presentations
  class RendererHTMLPresentation < RendererHTML

    ##
    # Stylesheets used by this renderer
    INCLUDED_STYLESHEETS = [
        CSS_PLAIN,
        CSS_ZENBURN,
        CSS_LIGHTNESS,
        CSS_MAIN,
        CSS_THOMAS,
    ]

    ##
    # JavaScripts used in the header
    INCLUDED_SCRIPTS_HEAD = [
        JS_HEAD,
        JS_THOMAS,
        JS_HIGHLIGHT,
        JS_JQUERY,
        JS_JQUERY_UI,
        JS_MATHJAX,
    ]

    ##
    # JavaScript used in the footer
    INCLUDED_SCRIPTS_FOOTER = [
        JS_REVEAL,
        JS_SETTINGS,
    ]

    ##
    # Inline scripts
    JAVASCRIPTS = [
        "$('code.inline').each(function(i, e) { hljs.highlightBlock(e) } );",
        "$(function() { $('#menu').menu({ position: { my: 'left bottom', at: 'right-5 top+5' } }); });",
        "Reveal.addEventListener( 'slidechanged', function( event ) { $('#slide_nr').html($(event.currentSlide).attr('data-number')); } );",
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
    end

    ##
    # Indicates whether the renderer handles animations or not. false indicates
    # that slides should not be repeated.
    def handles_animation?
      true
    end

    ##
    # Render a button
    # @param [String] line_id internal ID of the line
    def button(line_id)
      @io << <<-ENDOFTEXT
      <button onclick='executeNew(this);' class='runbutton'>
      #{LOCALIZED_MESSAGES[:run]}
      </button><span style='display: none;' name='log' class='output'>&nbsp;</span>
      ENDOFTEXT
    end

    ##
    # Start a chapter
    # @param [String] title the title of the chapter
    # @param [String] number the number of the chapter
    # @param [String] id the uniquie id of the chapter (for references)
    def chapter_start(title, number, id)
      @io << <<-ENDOFTEXT
      <section id='#{id}' class='chapter' data-number='#{number}'>
        <h1 class='trenner'>#{title}</h1>
      </section>
      ENDOFTEXT
    end

    ## End of a chapter
    def chapter_end
      @io << nl
    end

    ##
    # Render a button with log area
    # @param [String] line_id internal ID of the line
    def button_with_log(line_id)
      @io << <<-ENDOFTEXT
      <button onclick='executeNew(this);' class='runbutton'>
      #{LOCALIZED_MESSAGES[:run]}
      </button><div name='log' class='output_small'></div>
      ENDOFTEXT
    end

    ##
    # Render a button with output
    # @param [String] line_id internal ID of the line
    def button_with_log_pre(line_id)
      @io << <<-ENDOFTEXT
      <button onclick='executePre(this);' class='runbutton'>
      #{LOCALIZED_MESSAGES[:run]}
      </button><div name='log' class='output_small'></div>
      ENDOFTEXT
    end

    ##
    # Link to previous slide (for active HTML)
    # @param [String] line_id internal ID of the line
    def link_previous(line_id)
      @io << <<-ENDOFTEXT
      <div class='outputhtml plain' id='#{line_id}' name='html_output'>&nbsp;</div>
      <script>attachPreviousHandler($('##{line_id}'));</script>
      ENDOFTEXT
    end

    ##
    # Link to previous slide (for active CSS)
    # @param [String] line_id internal ID of the line
    # @param [String] fragment HTML fragment used for CSS styling
    def live_css(line_id, fragment)
      @io << <<-ENDOFTEXT
      <iframe name='dest' src='' class='framed_wide'></iframe>
      <script id='#{line_id}'>attachHandlerCSS($('##{line_id}'), #{fragment});</script>
      ENDOFTEXT
    end

    ##
    # Link to previous slide (for active CSS)
    # @param [String] line_id internal ID of the line
    def live_preview(line_id)
      @io << <<-ENDOFTEXT
      <div class='outputhtml plain' id='#{line_id}' name='html_output'>&nbsp;</div>
      <script>attachHandler($('##{line_id}'));</script>
      ENDOFTEXT
    end

    ##
    # Perform a live preview
    # @param [String] line_id internal ID of the line
    def live_preview_float(line_id)
      @io << <<-ENDOFTEXT
      <div class='outputhtml' style='float: right;' id='#{line_id}' name='html_output'>&nbsp;</div>
      <script>synchronize($('##{line_id}'));</script>
      ENDOFTEXT
    end

    ##
    # Beginning of a comment section, i.e. explanations to the current slide
    def comment_start
      @io << <<-ENDOFTEXT
      <div class='more'><img src='img/help.png' onclick="$('#dialog_#{@dialog_counter}').dialog('open')"></div>
      <div id='dialog_#{@dialog_counter}' title='#{LOCALIZED_MESSAGES[:more_info]}'><p>
      ENDOFTEXT
    end

    ##
    # End of comment section
    def comment_end
      @io << <<-ENDOFTEXT
      <p></div>
      <script>$('#dialog_#{@dialog_counter}').dialog( { width: 900, autoOpen: false } );</script>
      ENDOFTEXT

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

      if width_slide
          width_attr = " width='#{width_slide}'"
      end

      @io << "<img class='presentation' src='#{chosen_image}' alt='#{alt}' title='#{title}'#{width_attr}>" << nl
      @io << "<div class='img_info'>#{inline(title)}</div>" << nl
    end

    ##
    # Render an UML inline diagram using an external tool
    # @param [String] picture_name name of the picture
    # @param [String] contents the embedded UML
    # @param [String] width_slide width of the diagram on slides
    # @param [String] width_plain width of the diagram on plain documents
    def uml(picture_name, contents, width_slide, width_plain)
      img_path = super(picture_name, contents, width_slide, width_plain, 'svg')
      @io << "<img src='#{img_path}' width='#{width_slide}'>" << nl
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
      @io << <<-ENDOFTEXT
      <!DOCTYPE html>
      <html lang='de'>

      <head>
        <meta charset='utf-8'>
        <title>#{title1}: #{section_name}</title>
        <meta name='author' content='#{author}'>
        <meta name='apple-mobile-web-app-capable' content='yes' />
        <meta name='apple-mobile-web-app-status-bar-style' content='black-translucent' />
        #{include_css(INCLUDED_STYLESHEETS)}
        #{include_javascript(INCLUDED_SCRIPTS_HEAD)}
      </head>

      <body>
      <div class='reveal'>
      <!-- Used to fade in a background when a specific slide state is reached -->
      <div class='state-background'></div>

      <!-- Any section element inside of this container is displayed as a slide -->
      <div class='slides'>

      <section data-number=''>
        <h1>#{title1}</h1>
        <h2>#{title2}</h2>
        <div class='kapitel_nr' style='margin-top: 50%'>#{section_number}</div>
        <div class='kapitel'>#{section_name}</div>
        <img class='plain' style='position: absolute; bottom: -10px; right: 0;' src='img/logo_title.png' alt='Telefon'>
      </section>
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
      @io << <<-ENDOFTEXT
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
      <li id='menu-inhalt'>#{LOCALIZED_MESSAGES[:contents]}
      #{toc_menu}
      </ul>
      </div>
      <div class='copyright'>
      #{title1} | #{copyright}
      </div>
      <div class='nummer'>
      <span id='slide_nr'>&nbsp;</span>
      </div>
      #{include_javascript(INCLUDED_SCRIPTS_FOOTER)}
      #{scripts(JAVASCRIPTS)}
      </body>
      </html>
      ENDOFTEXT
    end

    ##
    # Small TOC menu for presentation slides for quick navigation
    def toc_menu

      result = ''

      result << '<ul>' << nl

      @toc.entries.each { |e|
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
      }

      result << '    </ul>' << nl
      result
    end

    ##
    # Start of slide
    # @param [String] title the title of the slide
    # @param [String] number the number of the slide
    # @param [String] id the unique id of the slide (for references)
    # @param [Boolean] contains_code indicates whether the slide contains code fragments
    def slide_start(title, number, id, contains_code)
      @io << <<-ENDOFTEXT
      <section id='#{id}' class='slide' data-number='#{number}'>
        <h2 class='title'>#{inline_code(title)}</h2>
      ENDOFTEXT
    end

    ##
    # End of slide
    def slide_end
      @io << '</section>' << nl
    end
  end
end
