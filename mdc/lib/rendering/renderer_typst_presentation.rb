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
            title-color: blau,
      )'
      ),

      comment_start: erb(
        "/*"
      ),

      comment_end: erb(
        '*/'
      ),

      image: erb(
        '
          #align(center)[
            #image("<%= chosen_image %>", width: <%= width %>)
            #v(-0.4em)
            #text(size: 6pt, fill: mittelgrau)[<%= full_title %>]#v(-0.4em)
          ]
      '),

      code_start: erb(
        '
      <%- if caption then -%>
      #text(size: 7pt, fill: mittelgrau)[<%= caption %>]#v(-0.9em)
      <%- end -%>
      ```<%= prog_lang %>'
        ),
    }.freeze

    ##
    # Method returning the templates used by the renderer. Should be overwritten by the
    # subclasses.
    # @return [Hash] the templates
    def all_templates
      @templates = super.merge(TEMPLATES)
    end
  end
end
