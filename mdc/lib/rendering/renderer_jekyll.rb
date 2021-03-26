require_relative 'renderer_html'
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
        ```<%= language %>
        |
      ),

      code: erb(
        '<%= content %>'
      ),

      code_end: erb(
        '```'
      ),

      image: erb(
        %q{
        <%- unless /^0$/ === width_plain || /^0%$/ === width_plain -%>
        <figure class="picture">
        <img alt="<%= alt %>" src="<%= chosen_image %>"<%= width_attr_plain %>>
        <figcaption class="fs-2"><%= inline(full_title) %></figcaption>
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
      %q|title: <%= title %>
          nav_order: <%= nav_order %>
          ---
        <%- if @has_equation -%>
          <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
          <script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
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
        "---
          layout: page
          parent: <%= section_name %>"
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
        '  <li><%= inline_code(content) %></li>'
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
        '  <li><%= inline_code(content) %></li>'
      ),

      ul_end: erb(
        '</ul>'
      ),

      quote: erb(
        %q|
        <div class="bg-grey-lt-100" style="padding: 0.5em 1.0em">
        <%= inline_code(content) %>
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
        <%= inline_code(content) %>
        </div>
        |
    ),

      question: erb(
        %q|
        <div class="bg-green-000" style="padding: 0.5em 1.0em">
        <%= inline_code(content) %>
        </div>
        |
    ),

      box: erb(
        %q|
        <div class="bg-grey-lt-100" style="padding: 0.5em 1.0em">
        <%= inline_code(content) %>
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
        <p><%= inline_code(content) %></p>
        '
    ),

      heading: erb(
      '
        ### <%= title %>
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

    ## Inline replacements
    INLINE = [
      [/"(.*?)"/,                        '&bdquo;\1&ldquo;'],
      [/\[\^(.*?)\]/,                    '<sup><span title=\'\1\'>&#x22C6;</span></sup>'],
      [/(^|[ _*(>])([A-Za-z0-9\-+]{1,2})_([A-Za-z0-9+\-]{1,})([_*<,.;:!) ]|$)/,
       '\1\2<sub>\3</sub>\4'],
      [/(^|[ _*(>])([A-Za-z0-9\-+]{1,2})\^([A-Za-z0-9+\-]{1,})([_*<,.;:!) ]|$)/,
       '\1\2<sup>\3</sup>\4'],
      [/__(.+?)__/,                      '<em class="text-purple-100 fw-500">\1</em>'],
      [/_(.+?)_/,                        '<strong class="text-purple-100 fw-500">\1</strong>'],
      [/\*\*(.+?)\*\*/,                  '<em class="text-grey-dk-000 fw-500">\1</em>'],
      [/\*(.+?)\*/,                      '<strong class="text-grey-dk-000 fw-300">\1</strong>'],
      [/~~(.+?)~~/,                      '<del>\1</del>'],
      [/~(.+?)~/,                        '<u>\1</u>'],
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
    # Method returning the inline replacements. Should be overwritten by the
    # subclasses.
    # @param [Boolean] _alternate should alternate replacements be used
    # @return [String[]] the templates
    def all_inline_replacements(_alternate = false)
      INLINE
    end

    ##
    # Initialize the renderer
    # @param [IO] io target of output operations
    # @param [String] language the default language for code snippets
    # @param [String] result_dir location for results
    # @param [String] image_dir location for generated images (relative to result_dir)
    # @param [String] temp_dir location for temporary files
    # @param [Numeric] nav_order navigation order of the page
    # @param [Boolean] has_equation indicates that the presentation contains an equation
    def initialize(io, language, result_dir, image_dir, temp_dir, nav_order, has_equation)
      super(io, language, result_dir, image_dir, temp_dir)
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
      escaped_title = inline_code(title)
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

    ##
    # Replace inline elements like emphasis (_..._)
    #
    # @param [String] input Text to be replaced
    # @param [boolean] alternate alternate emphasis to be used
    # @return [String] Text with replacements performed
    def inline(input, alternate = false, inline_math_start = '\(', inline_math_end = '\)')
      super(input, alternate, '<span>\(', '\)</span>')
    end
  end
end
