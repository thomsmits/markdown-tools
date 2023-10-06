module Rendering
  ##
  # Default implementation of the line renderer.
  # This class does nothing but return the Markdown
  # code. You have to overwrite it with the desired
  # behavior.
  class LineRenderer
    ##
    # Initialize the renderer
    # @param [String] prog_lang the default language for code snippets
    def initialize(prog_lang)
      @prog_lang = prog_lang
    end

    ##
    # Method returning the inline replacements. Should be overwritten by the
    # subclasses.
    # @return [Array<Array<String, String>>] the templates
    def all_inline_replacements
      [['', '']]
    end

    ##
    # Method returning the meta replacements. Should be overwritten by the
    # subclasses.
    # @return [Array<Array<String, String>>] the templates
    def meta_replacements
      [['', '']]
    end

    ##
    # Method returning the replacements used inside a formula.
    # Should be overwritten by the subclasses.
    # @return [Array<Array<String, String>>] the templates
    def formula_replacements
      [['', '']]
    end

    ##
    # Replace meta characters.
    # @param [String] input Input string
    # @return [String] result with replaced meta characters
    def meta(input)
      result = input

      meta_replacements.each do |m|
        result = result.gsub(m[0], m[1])
      end
      result
    end

    ##
    # Replace characters inside math formula
    # @param [String] input Input string
    # @return [String] result with replaced meta characters
    def formula(input)
      result = input

      formula_replacements.each do |m|
        result = result.gsub(m[0], m[1])
      end
      result
    end

    ##
    # Render a text node. The inline replacements are applied
    # to the text before rendering the node.
    #
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
    # Render a HTML node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_html(content)
      content.to_s
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
        %{[#{meta(content)}](#{meta(target)})}
      else
        %{[#{meta(content)}](#{meta(target)} "#{title}")}
      end
    end

    ##
    # Render a \[ formula \] node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_formula(content)
      "\\[#{formula(content)}\\]"
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
    # Render a newline
    def render_newline(_content)
      '<br>'
    end

    ##
    # Render a quote
    def render_quoted(content)
      %("#{content}")
    end
  end
end
