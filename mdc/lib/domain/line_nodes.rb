module Domain

  ##
  # Node with simple text in it. Base class for all other
  # nodes.
  class TextNode
    attr_accessor :content, :children

    ##
    # Creates a new text node with the given content.
    def initialize(content = '')
      @content = content
      @children = [ ]
    end

    ##
    # Appends content to the node
    def <<(data)
      @content << data
    end

    ##
    # Return a string representation
    def to_s
      self.class.to_s + ": '" + @content + "'"
    end

    ##
    # Render the line
    # @param [Rendering::LineRenderer] renderer the renderer
    # @return [String] the rendered node content
    def render(renderer)
      renderer.render_text(@content)
    end

    ##
    # Macro to add a render method to the class.
    def self.add_renderer
      method_name = 'render_' + self.name.downcase.gsub('node', '').gsub('domain::', '')
      define_method(:render) do |renderer|
        sub_content = render_children(renderer)
        if sub_content
          renderer.method(method_name).call(sub_content)
        else
          renderer.method(method_name).call(@content)
        end
      end
    end

private
    def render_children(renderer)
      if @children.length > 0
        result = ''
        @children.each { |node| result << node.render(renderer) }
        result
      else
        nil
      end
    end
  end

  ##
  # Code `xxx` node
  class CodeNode < TextNode
    add_renderer
  end

  ##
  # Strong emphasis, using underscore: __text__
  class StrongUnderscoreNode < TextNode
    add_renderer
  end

  ##
  # Strong emphasis, using a star: **text**
  class StrongStarNode < TextNode
    add_renderer
  end

  ##
  # Emphasis, using underscore: _text_
  class EmphasisUnderscoreNode < TextNode
    add_renderer
  end

  ##
  # Emphasis, using a star: **text**
  class EmphasisStarNode < TextNode
    add_renderer
  end

  ##
  # Superscript using ^: a^2
  class SuperscriptNode < TextNode
    add_renderer
  end

  ##
  # Subscript using _: CO_2
  class SubscriptNode < TextNode
    add_renderer
  end

  ##
  # Link [Name](URL "TITLE")
  class LinkNode < TextNode
    attr_accessor :target, :title

    def initialize(target, content, title)
      super(content)
      @target = target
      @content = content
      @title = title
    end

    def render(renderer)
      sub_content = render_children(renderer)
      if sub_content
        renderer.render_link(sub_content, @target, @title)
      else
        renderer.render_link(@content, @target, @title)
      end
    end
  end

  ##
  # Link [Name][REF]
  class RefLinkNode < TextNode
    attr_accessor :ref, :title

    def initialize(ref, content)
      super(content)
      @ref = ref
      @content = content
    end

    def render(renderer)
      sub_content = render_children(renderer)
      if sub_content
        renderer.render_reflink(sub_content, @ref)
      else
        renderer.render_reflink(@content, @ref)
      end
    end
  end

  ##
  # Delete Text ~~delete~~
  class DeletedNode < TextNode
    add_renderer
  end

  ##
  #  Underline Text ~underline~
  class UnderlineNode < TextNode
    add_renderer
  end

  ##
  # Reference node [ref]: URL "TITLE"
  class ReferenceNode < TextNode
    attr_accessor :key, :url, :title

    def initialize(key, url, title = nil)
      super(content)
      @key = key
      @url = url
      @title = title
    end

    def render(renderer)
      ""
    end
  end

  ##
  # LaTeX Formula \[ FORMULA \]
  class FormulaNode < TextNode
    add_renderer
  end

  ##
  # Node not parsed
  class UnparsedNode < TextNode
    add_renderer
  end
end