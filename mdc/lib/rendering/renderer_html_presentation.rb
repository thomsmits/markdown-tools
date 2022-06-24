require_relative 'renderer_html'
require_relative '../messages'

module Rendering
  ##
  # Renderer to HTML for presentations
  class RendererHTMLPresentation < RendererHTML
    ## ERB templates to be used by the renderer
    TEMPLATES = {
      button: erb(
        "
         <button onclick='executeNew(this);' class='runbutton'>
         <%= translate(:run) %>
         </button><span style='display: none;' name='log' class='output'>&nbsp;</span>
         "
      ),

      button_with_log: erb(
        "
        <button onclick='executeNew(this);' class='runbutton'>
        <%= translate(:run) %>
        </button><div name='log' class='output_small'></div>
       "
      ),

      button_with_log_pre: erb(
        "
        <button onclick='executePre(this);' class='runbutton'>
        <%= translate(:run) %>
        </button><div name='log' class='output_small'></div>
       "
      ),

      link_previous: erb(
        "
        <div class='outputhtml plain r-stretch' id='<%= line_id %>' name='html_output'>&nbsp;</div>
        <script>attachPreviousHandler($('#<%= line_id %>'));</script>
       "
      ),

      live_css: erb(
        "
        <iframe name='dest' src='' class='framed_wide'></iframe>
        <script id='<%= line_id %>'>attachHandlerCSS($('#<%= line_id %>'), <%= fragment %>);</script>
       "
      ),

      live_preview: erb(
        "
        <div class='outputhtml plain r-stretch' id='<%= line_id %>' name='html_output'>&nbsp;</div>
        <script>attachHandler($('#<%= line_id %>'));</script>
       "
      ),

      live_preview_float: erb(
        "
        <div class='outputhtml r-stretch' style='float: right;' id='<%= line_id %>' name='html_output'>&nbsp;</div>
        <script>synchronize($('#<%= line_id %>'));</script>
       "
      ),

      comment_start: erb(
        %q|<!--|
      ),

      comment_end: erb(
        "-->"
      ),

      image: erb(
        "
        <img class='presentation r-stretch' src='<%= chosen_image %>' alt='<%= alt %>' title='<%= title %>'<%= width_attr_slide %>>
        <div class='img_info'><%= line_renderer.meta(full_title) %></div>
        "
      ),

      uml: erb(
        "
        <img src='<%= img_path %>' width='<%= width_slide %>'>
        "
      ),

      chapter_start: erb(
        "
        <section id='<%= id %>' class='chapter center' data-number='<%= number %>'>
        <h1 class='trenner'><%= title %></h1>
        </section>
       "
      ),

      chapter_end: erb(
        '
        '
      ),

      slide_start: erb(
        "
        <section id='<%= id %>' class='slide' data-number='<%= number %>'>
        <h2 class='title'><%= line_renderer.meta(title) %></h2>
        "
      ),

      slide_end: erb(
        '
        </section>
        '
      ),

      presentation_start: erb(
        %q{
        <!DOCTYPE html>
        <html lang='de'>

        <head>
          <meta charset='utf-8'>
          <title><%= title1 %>: <%= section_name %></title>
          <meta name='author' content='<%= author %>'>
          <meta name='apple-mobile-web-app-capable' content='yes' />
          <meta name='apple-mobile-web-app-status-bar-style' content='black-translucent' />
          <link rel='stylesheet' href='dist/reset.css'>
          <link rel='stylesheet' href='dist/reveal.css'>
          <link rel="stylesheet" href="plugin/highlight/github.css">
          <link rel="stylesheet" href="dist/theme/white.css">
          <link rel="stylesheet" href="css/custom.css">

          <script src='js/jquery-3.6.0.js'></script>
          <script src='js/custom.js'></script>
        </head>

        <body>
        <div class='reveal'>
        <!-- Used to fade in a background when a specific slide state is reached -->
        <div class='state-background'></div>

        <!-- Any section element inside of this container is displayed as a slide -->
        <div class='slides'>

        <section data-number='' class="title_page center">
          <h1 class="titlepage"><%= title1 %></h1>
          <div class="titlepage"><%= title2 %></div>
          <h2 class="titlepage"><%= section_name %></h2>
          <h3 class="titlepage"><%= author %></h3>
          <h4 class="titlepage"><%= term %></h3>
          <h4 class="titlepage"><%= Time.now.strftime("%Y-%m-%d") %></h3>
        </section>
        }
      ),

      presentation_end: erb(
        %?
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
        <div class='copyright'>
        <%= title1 %> | <%= copyright %>
        </div>
          <div class='nummer'>
          <span id='slide_nr'>&nbsp;</span>
        </div>
          <script src='dist/reveal.js'></script>
          <script src="plugin/math/math.js"></script>
          <script src="plugin/highlight/highlight.js"></script>

          <script>
            Reveal.initialize({
              plugins: [ RevealMath.KaTeX, RevealHighlight ],
              progress: true,
              controlsLayout: 'bottom-right',
              controls: true,
              controlsTutorial: false,
              slideNumber: false,
              hashOneBasedIndex: true,
              hash: true,
              transition: 'none', // none/fade/slide/convex/concave/zoom
              transitionSpeed: 'default', // default/fast/slow
              backgroundTransition: 'fade',
              center: false,
            });
          </script>

          <script>Reveal.addEventListener( 'slidechanged', function( event ) { $('#slide_nr').html($(event.currentSlide).attr('data-number')); } );</script>

          </body>
        </html>
        ?
      )
    }.freeze

    ##
    # Initialize the renderer
    # @param [StringIO] io target of output operations
    # @param [String] prog_lang the default language for code snippets
    # @param [String] result_dir location for results
    # @param [String] image_dir location for generated images (relative to result_dir)
    # @param [String] temp_dir location for temporary files
    def initialize(io, prog_lang, result_dir, image_dir, temp_dir)
      super(io, prog_lang, result_dir, image_dir, temp_dir)
      @dialog_counter = 1 # counter for dialog popups
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
      true
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

        unless e.entries.empty?
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
