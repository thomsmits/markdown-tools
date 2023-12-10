# frozen_string_literal: true

require_relative 'line_renderer'

module Rendering
  class LineRendererHTML < LineRenderer
    META_REPLACEMENTS = [
      ['"',                   '&quot;'],
      ['<',                   '&lt;'],
      ['>',                   '&gt;']
    ].freeze

    REPLACEMENTS = [
      [/Z\.B\./,              'Z.&nbsp;B.'],
      [/z\.B\./,              'z.&nbsp;B.'],
      [/D\.h\./,              'D.&nbsp;h.'],
      [/d\.h\./,              'd.&nbsp;h.'],
      [/u\.a\./,              'u.&nbsp;a.'],
      [/s\.o\./,              's.&nbsp;o.'],
      [/s\.u\./,              's.&nbsp;u.'],
      [/i\.e\./,              'i.&nbsp;e.'],
      [/e\.g\./,              'e.&nbsp;g.'],
      [/---/,                 '&mdash;'],
      [/--/,                  '&ndash;'],
      [/\.\.\./,              '&hellip;'],
      [/\[\^(.*?)\]/,         '<sup><span title=\'\1\'>*</span></sup>'],

      [/([^<]|^)<->(\s|\))/,    '\1&harr;\2'],
      [/([^<]|^)<=>(\s|\))/,    '\1&hArr;\2'],
      [/([^<]|^)->(\s|\))/,     '\1&rarr;\2'],
      [/([^<]|^)=>(\s|\))/,     '\1&rArr;\2'],
      [/([^<]|^)<-(\s|\))/,     '\1&larr;\2'],
      [/([^<]|^)<=(\s|\))/,     '\1&lArr;\2']
    ].freeze

    ##
    # Method returning the inline replacements.Should be overwritten by the
    # subclasses.
    # @return [Array<Array<String>>] the templates
    def all_inline_replacements
      REPLACEMENTS + META_REPLACEMENTS
    end

    def meta_replacements
      META_REPLACEMENTS
    end

    def render_code(content)
      "<code>#{content.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')}</code>"
    end

    def render_strongunderscore(content)
      "<strong>#{content}</strong>"
    end

    def render_strongstar(content)
      %{<strong class="alternate">#{content}</strong>}
    end

    def render_emphasisunderscore(content)
      "<em>#{content}</em>"
    end

    def render_emphasisstar(content)
      %{<em class="alternate">#{content}</em>}
    end

    def render_superscript(content)
      "<sup>#{content}</sup>"
    end

    def render_subscript(content)
      "<sub>#{content}</sub>"
    end

    def render_link(content, target = '', title = '')
      if title.nil?
        %(<a href="#{target}">#{content}</a>)
      else
        %(<a href="#{target}" title="#{title}">#{content}</a>)
      end
    end

    def render_formula(content)
      "$$ #{content} $$"
    end

    def render_deleted(content)
      "<del>#{content}</del>"
    end

    def render_underline(content)
      "<u>#{content}</u>"
    end

    def render_quoted(content)
      if $language == 'de'
        "&bdquo;#{content}&ldquo;"
      elsif $language == 'en'
        "&ldquo;#{content}&rdquo;"
      else
        "&quot;#{content}&quot;"
      end
    end

    def render_footnote(content, _)
      %(<a href="#footnote_#{content}"><sup>#{content}</sup></a>)
    end
  end
end
