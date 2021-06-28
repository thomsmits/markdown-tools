require_relative 'line_renderer_html'

module Rendering
  class LineRendererGIFT < LineRendererHTML

    META_REPLACEMENTS = [
      [ '\\', '\\\\\\'],
      [ '~', '\~' ],
      [ '=', '\=' ],
      [ '#', '\#' ],
      [ '{', '\{' ],
      [ '}', '\}' ],
      [ ':', '\:' ]
    ]

    REPLACEMENTS = [
    ].freeze

    ##
    # Method returning the inline replacements.Should be overwritten by the
    # subclasses.
    # @return [Array<String>] the templates
    def all_inline_replacements
      META_REPLACEMENTS + REPLACEMENTS
    end

    def meta_replacements
      META_REPLACEMENTS
    end

    def code(content)
      meta(content)
         .gsub("\n", '\n')
         .gsub('<', '&lt;')
         .gsub('>', '&gt;')
    end
    ##
    # Render a `code` node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_code(content)
      "<code>#{code(content)}</code>"
    end

    def formula_replacements(content)
      content.gsub('\\', '\\\\\\\\').gsub('{', '\{').gsub('}', '\}').gsub("\n", '\n').gsub('=', '\=')
    end

    def render_formula(content)
      "\\\\[#{formula_replacements(content)}\\\\]"
    end

    def render_strongunderscore(content)
      "<strong><em>#{content}</em></strong>"
    end

    alias render_strongstar render_strongunderscore


    def render_emphasisunderscore(content)
      "<strong>#{content}</strong>"
    end

    alias render_emphasisstar render_emphasisunderscore

  end
end
