require_relative 'renderer_html'
require_relative 'line_renderer_jekyll'
require_relative '../messages'

module Rendering
  ##
  # Renderer to HTML for plain (book) like output
  class RendererJekyll < RendererHTML
    ## ERB templates to be used by the renderer
    TEMPLATES = {
      button: erb(
        "
          "
      ),

      button_with_log: erb(
        "
        "
      ),

      button_with_log_pre: erb(
        "
        "
      ),

      link_previous: erb(
        "
        "
      ),

      live_css: erb(
        "
        "
      ),

      live_preview: erb(
        "
        "
      ),

      live_preview_float: erb(
        "
        "
      ),

      comment_start: erb(
        ""
      ),

      comment_end: erb(
        ''
      ),

      code_start: erb(
        %q|<div class="fw-300 fs-3"><%= caption_command %></div>
        {% raw  %}
        ```<%= prog_lang %>
        |
      ),

      code: erb(
        '<%= content %>'
      ),

      code_end: erb(
        %q|```
        {% endraw %}
        |
      ),

      image: erb(
        %q{
        <%- unless /^0$/ === width_plain || /^0%$/ === width_plain -%>
        <figure class="picture">
        <img alt="<%= alt %>" src="<%= chosen_image %>"<%= width_attr_plain %>>
        <figcaption class="fs-2"><%= line_renderer.meta(full_title) %></figcaption>
        </figure>
        <%- end -%>
        }
      ),

      uml: erb(
        "
        <img src='<%= img_path %>' width='<%= width_plain %>'>
        "
      ),

      chapter_start: erb(
        %q|title: "<%= title %>"
          nav_order: <%= nav_order %>
          ---
        <%- if @has_equation -%>
          <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.2/dist/katex.min.css" integrity="sha384-bYdxxUwYipFNohQlHt0bjN/LCpueqWz13HufFEV1SUatKs1cm4L6fFgCi1jT643X" crossorigin="anonymous">
          <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.2/dist/katex.min.js" integrity="sha384-Qsn9KnoKISj6dI8g7p1HBlNpVx0I8p1SvlwOldgi3IorMle61nQy4zEahWYtljaz" crossorigin="anonymous"></script>
          <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.2/dist/contrib/auto-render.min.js" integrity="sha384-+VBxd3r6XgURycqtZ117nYw44OOcIax56Z4dCRWbxyPt0Koah1uHoK0o4+/RRE05" crossorigin="anonymous"
            onload="renderMathInElement(document.body);">
          </script>
        <%- end -%>
        <h1 class="fw-700 text-purple-300"><%= title %></h1>|
      ),

      chapter_end: erb(
        '
        '
      ),

      slide_start: erb(
        ""
      ),

      slide_end: erb(
        ''
      ),

      presentation_start: erb(
        %q|---
          layout: page
          parent: "<%= section_name %>"|
      ),

      presentation_end: erb(
        ""
      ),

      vertical_space: erb(
        '
          <br>
          '
      ),

      equation: erb(
        %q(
        <div>
        \[
        \begin{align*}
        <%= contents %>
        \end{align*}
        \]
        </div>
        )
      ),

      ol_start: erb(
        %q|<ol start="<%= number %>"><% no = number %>|
      ),

      ol_item: erb(
        '  <li><%= content %></li>'
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
        '  <li><%= content %></li>'
      ),

      ul_end: erb(
        '</ul>'
      ),

      quote: erb(
        %q|
        <div class="bg-grey-lt-100" style="padding: 0.5em 1.0em">
        <%= content %>
        <% if !source.nil? %>
          <br>
          <span class='fw-300'><%= source %></span>
        <% end %>
        </div>
        |
    ),

      important: erb(
        %q|
        <div class="bg-yellow-000" style="padding: 0.5em 1.0em">
        <%= content %>
        </div>
        |
    ),

      question: erb(
        %q|
        <div class="bg-green-000" style="padding: 0.5em 1.0em">
        <%= content %>
        </div>
        |
    ),

      box: erb(
        %q|
        <div class="bg-grey-lt-100" style="padding: 0.5em 1.0em">
        <%= content %>
        </div>
        |
    ),

      script: erb(
        '
        <script><%= content %></script>
        '
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
        <p><%= content %></p>
        '
    ),

      heading: erb(
        '
        ### <%= line_renderer.meta(title) %>
        '
    ),

      toc_start: erb(
        ""
    ),

      toc_entry: erb(
        ""
    ),

      toc_end: erb(
        ''
    ),

      toc_sub_entries_start: erb(
        ""
    ),

      toc_sub_entry: erb(
        ""
    ),

      toc_sub_entries_end: erb(
        ''
    ),

      index_start: erb(
        ""
    ),

      index_entry: erb(
        ""
    ),

      index_end: erb(
        ''
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
    # @param [Numeric] nav_order navigation order of the page
    # @param [Boolean] has_equation indicates that the presentation contains an equation
    def initialize(io, prog_lang, result_dir, image_dir, temp_dir, nav_order, has_equation)
      super(io, prog_lang, result_dir, image_dir, temp_dir)
      @line_renderer = LineRendererJekyll.new(prog_lang)
      @dialog_counter = 1   # counter for dialog popups
      @last_title = ''      # last slide title
      @nav_order = nav_order
      @has_equation = has_equation
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
      escaped_title = line_renderer.meta(title)
      @io << @templates[:slide_start].result(binding)

      unless title == @last_title
        @io << "## #{escaped_title}" << nl
        @last_title = title
      end
    end

    ##
    # Start a chapter
    # @param [String] title the title of the chapter
    # @param [String] number the number of the chapter
    # @param [String] id the unique id of the chapter (for references)
    def chapter_start(title, number, id)
      nav_order = @nav_order
      @io << @templates[:chapter_start].result(binding)
    end
  end
end
