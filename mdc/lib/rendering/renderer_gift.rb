# frozen_string_literal: true

require_relative 'renderer_html'
require_relative 'line_renderer_gift'
require_relative '../messages'

module Rendering
  ##
  # Renderer to GIFT (Moodle exam format)
  class RendererGIFT < RendererHTML
    ## ERB templates to be used by the renderer
    TEMPLATES = {
      button: erb(''),
      button_with_log: erb(''),
      button_with_log_pre: erb(''),
      link_previous: erb(''),
      live_css: erb(''),
      live_preview: erb(''),
      live_preview_float: erb(''),
      comment_start: erb('// '),
      comment_end: erb(''),
      code_start: erb('<code><pre>'),
      code: erb('<%= line_renderer.code(content) %>'),
      code_end: erb('</pre></code><% -%>'),
      image: erb(''),
      uml: erb(''),
      chapter_start: erb(''),
      chapter_end: erb(''),
      slide_start: erb('::<%= line_renderer.meta(title) %>::[html]<% -%>'),
      slide_end: erb(''),
      presentation_start: erb(''),
      presentation_end: erb(''),
      vertical_space: erb(''),
      equation: erb('\\\\[<%= line_renderer.formula(contents) %>\\\\]<%- -%>'),
      ol_start: erb("<ol start='<%= number %>'><%- -%>"),
      ol_item: erb('<li><%= content %><%- -%>'),
      ol_end: erb('</ol><%- -%>'),
      ul_start: erb('<ul><%- -%>'),
      ul_item: erb('  <li><%= content %><%- -%>'),
      ul_end: erb('</ul><%- -%>'),
      quote: erb(''),
      important: erb(''),
      question: erb(''),
      box: erb(''),
      script: erb(''),
      table_start: erb('<table><thead><tr><%-  -%>'),
      table_separator: erb(''),
      table_end: erb('</tbody></table><%-  -%>'),
      text: erb(%q|<p><%= content.strip.gsub("\n", '<br>') %></p><%-  -%>|),
      heading: erb(''),
      toc_start: erb(''),
      toc_entry: erb(''),
      toc_end: erb(''),
      toc_sub_entries_start: erb(''),
      toc_sub_entry: erb(''),
      toc_sub_entries_end: erb(''),
      index_start: erb(''),
      index_entry: erb(''),
      index_end: erb(''),
      html: erb(''),
      multiple_choice_start: erb('<%- -%>{<%- -%>'),
      multiple_choice_end: erb('<%- -%>}'),
      input_question: erb("{<%= if values.length > 0 then '=' + line_renderer.render_text(values.join(',')) else '' end %>}"),
      matching_question_start: erb("{<%= ' ' -%>"),
      matching_question_end: erb('<%- -%>}'),
      matching_question: erb(" =<%= left %> -> <%= right %><%= ' ' -%>")
    }.freeze

    def nl
      ''
    end

    ##
    # Initialize the renderer
    # @param [IO, StringIO] io target of output operations
    # @param [String] prog_lang the default language for code snippets
    # @param [String] result_dir location for results
    # @param [String] image_dir location for generated images (relative to result_dir)
    # @param [String] temp_dir location for temporary files
    def initialize(io, prog_lang, result_dir, image_dir, temp_dir)
      super(io, prog_lang, result_dir, image_dir, temp_dir)

      # Replace the line renderer in our parent
      @line_renderer = LineRendererGIFT.new(prog_lang)

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
    # Return a css class for the given alignment constant
    # @param [Fixnum] alignment for the alignment
    # @return [String] css class string to be used in HTML page
    def class_for_constant(_alignment)
      ''
    end

    ##
    # Start of slide
    # @param [String] title the title of the slide
    # @param [String] number the number of the slide
    # @param [String] id the unique id of the slide (for references)
    # @param [Boolean] contains_code indicates whether the slide contains code fragments
    def slide_start(title, number, id, contains_code)
      @io << @templates[:slide_start].result(binding)
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
      # do nothing. GIFT does not support images
    end

    ##
    # Start a chapter
    # @param [String] title the title of the chapter
    # @param [String] number the number of the chapter
    # @param [String] id the unique id of the chapter (for references)
    def chapter_start(title, number, id)
      @io << @templates[:chapter_start].result(binding)
    end

    ##
    # Render multiple choice question
    # @param [String] text text of the question
    # @param [Boolean] correct indicates if this is a correct answer
    # @param [Float] p_correct percentage for correct answers
    # @param [Float] _p_wrong percentage for wrong answers
    # @param [bool] _inline should we use inline checkboxes
    def multiple_choice(text, correct, p_correct = 100, _p_wrong = 100, _inline = false)
      if p_correct < 100
        @io << "~%#{p_correct}%#{text} "  if correct
        @io << "~%-#{p_correct}%#{text} " unless correct
      else
        @io << "=#{text} " if correct
        @io << "~#{text} " unless correct
      end
    end

    ##
    # Beginning of a comment section, i.e. explanations to the current slide
    def comment_start(_spacing = 0)
      @orig_io = @io
      @io = StringIO.new
    end

    ##
    # End of comment section
    def comment_end
      @io = @orig_io
    end
  end
end
