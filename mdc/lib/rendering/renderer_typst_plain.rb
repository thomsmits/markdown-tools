require_relative 'renderer'
require_relative 'line_renderer_typst'
require_relative '../messages'
require_relative '../constants'
require_relative 'renderer_typst'

module Rendering

  class RendererTypstPlain < RendererTypst

    TEMPLATES = {
      chapter_start: erb(
        '#v(1.0em)
              == <%= line_renderer.render_text(title) %>
              '),

      section_start: erb(
        "<%- if suppress_numbering -%>
              ==== <%= line_renderer.render_text(title) %> <nonum-sec>
              <%- else -%>
              #v(-0.2em)
              === <%= line_renderer.render_text(title) %><<%= id %>>
              #v(-0.5em)
              <%- end -%>"
      ),

      code_start: erb(
        '
      <%- if caption then -%>
      #text(size: 9pt, fill: mittelgrau, font: "Liberation Sans", weight: "bold")[🖹 <%= line_renderer.meta(caption) %>]#v(-0.6em)
      <%- end -%>
      ```<%= prog_lang %>'
      ),

      chapter_end: erb(''),

      presentation_start: erb(
        '#import "../preambel.typst": *
        = <%= section_name  %>
        #minitoc'
      ),

      presentation_end: erb(''),

      heading_3: erb(
        '
        ==== <%= line_renderer.meta(title) %> <nonum-sec>
        '
      ),

      heading_4: erb(
        '
        ===== <%= line_renderer.meta(title) %>
        '
      ),

    }.freeze

    ##
    # Method returning the templates used by the renderer. Should be overwritten by the
    # subclasses.
    # @return [Hash] the templates
    def all_templates
      @templates = super.merge(TEMPLATES)
    end

    ##
    # Render an image
    # @param [String] location path to image
    # @param [Array] formats available file formats
    # @param [String] _alt alt text
    # @param [String] title title of image
    # @param [String] _width_slide width for slide
    # @param [String] source source of the image
    def image(location, formats, _alt, title, _width_slide, width_plain, source = nil)
      # Skip images with width 0
      return if /^0$/ =~ width_plain || /^0%$/ =~ width_plain || width_plain.nil?

      calculated_width = "#{(width_plain.gsub('%', '').to_i / 100.0) * 14.5}cm"
      image_typst(location, formats, title, calculated_width, source)
    end

    ##
    # Start of slide
    # @param [String] title the title of the slide
    # @param [String] number the number of the slide
    # @param [String] id the unique id of the slide (for references)
    # @param [Boolean] contains_code indicates whether the slide contains code fragments
    # @param [Boolean] suppress_numbering suppress numbering of chapters
    def section_start(title, number, id, contains_code, suppress_numbering)
      super unless title == @last_title
    end
  end
end
