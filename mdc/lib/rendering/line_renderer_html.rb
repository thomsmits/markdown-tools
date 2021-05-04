require_relative 'line_renderer'

module Rendering
  class LineRendererHTML < LineRenderer

    REPLACEMENTS = [
      ['"',                              '&quot;'],
      ['<',                              '&lt;'],
      ['>',                              '&gt;'],
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
      [/\[\^(.*?)\]/,         '<sup><span title=\'\1\'>*</span></sup>'],

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
      ['<br><-> ',            '<br>&harr; ']].freeze

    def all_inline_replacements
      REPLACEMENTS
    end

    def render_code(content)
      "<code>#{content.gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')}</code>"
    end

    def render_strongunderscore(content)
      "<strong>#{content}</strong>"
    end

    def render_strongstar(content)
      "<strong>#{content}</strong>"
    end

    def render_emphasisunderscore(content)
      "<em>#{content}</em>"
    end

    def render_emphasisstar(content)
      "<em>#{content}</em>"
    end

    def render_superscript(content)
      "<sup>#{content}</sup>"
    end

    def render_subscript(content)
      "<sub>#{content}</sub>"
    end

    def render_link(content, target = '', title = '')
      if title.nil?
        %Q{<a href="#{target}">#{content}</a>}
      else
        %Q{<a href="#{target}" title="#{title}">#{content}</a>}
      end
    end

    def render_reflink(content, ref = '')
      if ref == "bar" # TODO: Hack!
        %Q{<a href="/url" title="title">#{content}</a>}
      elsif ref == "ref"
        %Q{<a href="/uri">#{content}</a>}
      else
        ''
      end
    end

    def render_formula(content)
      "$$#{content}$$"
    end

    def render_deleted(content)
      "<del>#{content}</del>"
    end

    def render_underline(content)
      "<u>#{content}</u>"
    end

    def render_unparsed(content)
      "UNPARSED NODE - SHOULD NOT BE RENDERED!!!! #{content}"
    end
  end
end
