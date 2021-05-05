module Rendering

  ##
  # Default implementation of the line renderer.
  # This class does nothing but return the Markdown
  # code. You have to overwrite it with the desired
  # behavior.
  class LineRenderer

    ##
    # Initialize the renderer
    # @param [String] language the default language for code snippets
    def initialize(language)
      @language = language
    end

    ##
    # Method returning the inline replacements. Should be overwritten by the
    # subclasses.
    # @return [Array<Array<String, String>>] the templates
    def all_inline_replacements
      [[ '', '' ]]
    end

    ##
    # Method returning the meta replacements. Should be overwritten by the
    # subclasses.
    # @return [Array<Array<String, String>>] the templates
    def meta_replacements
      [[ '', '' ]]
    end

    ##
    # Replace meta characters.
    # @param [String] input Input string
    # @return [String] result with replaced meta characters
    def meta(input)
      result = input

      meta_replacements.each do |m|
        result.gsub!(m[0], m[1]);
      end
      result
    end

    ##
    # Render a text node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_text(content)
      result = content
      all_inline_replacements.each { |e| result.gsub!(e[0], e[1]) }
      result
    end

    ##
    # Render a `code` node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_code(content)
      "`#{content}`"
    end

    ##
    # Render a __strong__ node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_strongunderscore(content)
      "__#{content}__"
    end

    ##
    # Render a **strong** node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_strongstar(content)
      "**#{content}**"
    end

    ##
    # Render a _em_ node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_emphasisunderscore(content)
      "_#{content}_"
    end

    ##
    # Render a *em* node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_emphasisstar(content)
      "*#{content}*"
    end

    ##
    # Render a ^superscript node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_superscript(content)
      "^#{content}"
    end

    ##
    # Render a ^subscript node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_subscript(content)
      "_#{content}"
    end

    ##
    # Render a [[citation]] node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_citation(content)
      "[[#{content}]]"
    end

    ##
    # Render a [](link) node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_link(content, target, title)
      if title.nil?
        %Q{[#{meta(content)}](#{meta(target)})}
      else
        %Q{[#{meta(content)}](#{meta(target)} "#{title}")}
      end
    end

    def render_reflink(content)
      # TODO: Implement
    end

    ##
    # Render a \[ formula \] node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_formula(content)
      "\\[ #{content} \\]"
    end

    ##
    # Render a ~~deleted~~ node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_deleted(content)
      "~~#{content}~~"
    end

    ##
    # Render a ~underlined~ node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_underline(content)
      "~#{content}~"
    end

    ##
    # This method should never be called.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_unparsed(content)
      "UNPARSED NODE - SHOULD NOT BE RENDERED!!!! #{content}"
    end
  end
end
