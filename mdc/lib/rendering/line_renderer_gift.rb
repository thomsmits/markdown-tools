require_relative 'line_renderer_html'

module Rendering
  class LineRendererGIFT < LineRendererHTML

    META_REPLACEMENTS = [
      ['"',  '&quot;'],
      ['<',  '&lt;'],
      ['>',  '&gt;'],
      [':',  '\:']
    ]

    REPLACEMENTS = [
      [ '#', '&\#x0023;' ],
      [ '[', '&\#x005B;' ],
      [ ']', '&\#x005D;' ],
      [ '{', '&\#x007B;' ],
      [ '}', '&\#x007D;' ],
      [ '=', '&\#x003D;' ],
      [ '~', '&\#x007E;' ],
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

    def formula_replacements(content)
      content.gsub('\\', '\\\\\\\\').gsub('{', '\{').gsub('}', '\}').gsub("\n", '\n').gsub('=', '\=')
    end

    def render_formula(content)
      "\\\\[#{formula_replacements(content)}\\\\]"
    end
  end
end
