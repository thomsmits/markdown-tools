require_relative 'renderer'
require_relative 'line_renderer_typst'
require_relative '../messages'
require_relative '../constants'
require_relative 'renderer_typst'

module Rendering

  class RendererTypstPresentation < RendererTypst
    TEMPLATES = {
      presentation_start: erb(
        '#include "slide-template.typst"
          #show: slides.with(
            title: "<%= title1 %>",
            subtitle: "<%= title2 %>",
            chapter: "<%= section_name %>",
            copyright: "<%= copyright %>",
            date: "<%= last_change %>",
            term: "<%= term %>",
            author: " <%= author %>",
            ratio: 16/9,
            count: "number",
            title-color: color_accent1,
      )'
      ),

      section_start: erb(
        '
        == <%= line_renderer.render_text(title) %><<%= id %>>
        '
      ),

      comment_start: erb(
        '/*
        '
      ),

      comment_end: erb(
        '
        */
        '
      ),

      image: erb(
        '
          #align(center)[
            #image("<%= chosen_image %>", width: <%= width %>)
            #v(-0.95em)
            #text(size: 6pt, fill: color_accent4)[<%= line_renderer.meta(full_title) %>]#v(-0.4em)
          ]
      '),

      code_start: erb(
        '
      <%- if caption then -%>
      #text(size: 8pt, fill: color_accent4, weight: "bold")[<%= caption %>]#v(-0.7em)
      <%- end -%>
      ```<%= prog_lang %>
      '
        ),
    }.freeze

    ##
    # Indicates whether the renderer handles animations or not. false indicates
    # that slides should not be repeated.
    # @return [Boolean] +true+ if animations are supported, otherwise +false+
    def handles_animation?
      true
    end

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
    # @param [String] width_slide width for slide
    # @param [String] source source of the image
    def image(location, formats, _alt, title, width_slide, _width_plain, source = nil)
      calculated_width = ((width_slide.gsub('%', '').to_i / 100.0) * 17).to_s + "cm"
      image_typst(location, formats, title, calculated_width, source)
    end
  end
end
