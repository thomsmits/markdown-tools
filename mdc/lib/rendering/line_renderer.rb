module Rendering

  ##
  # Default implementation of the line renderer.
  # This class does nothing but return the Markdown
  # code.
  class LineRenderer

    ##
    # Method returning the inline replacements.Should be overwritten by the
    # subclasses.
    # @return [Array<String>] the templates
    def all_inline_replacements(alternate = false)
      [[ '', '' ]]
    end

    def render_text(content)
      result = content
      all_inline_replacements.each { |e| result.gsub!(e[0], e[1]) }
      result
    end

    def render_code(content)
      "`#{content}`"
    end

    def render_strongunderscore(content)
      "__#{content}__"
    end

    def render_strongstar(content)
      "**#{content}**"
    end

    def render_emphasisunderscore(content)
      "_#{content}_"
    end

    def render_emphasisstar(content)
      "*#{content}*"
    end

    def render_superscript(content)
      "^#{content}"
    end

    def render_subscript(content)
      "_#{content}"
    end

    def render_citation(content)
      "[[#{content}]]"
    end

    def render_link(content, target, title)
      if node.title.nil?
        %Q{[#{content}](#{target})}
      else
        %Q{[#{content}](#{target} "#{title}")}
      end
    end

    def render_reflink(content)
      # TODO: Implement
    end

    def render_formula(content)
      "\[ #{content} \]"
    end

    def render_deleted(content)
      "~~#{content}~~"
    end

    def render_underline(content)
      "~#{content}~"
    end

    def render_unparsed(content)
      "UNPARSED NODE - SHOULD NOT BE RENDERED!!!! #{content}"
    end
  end
end