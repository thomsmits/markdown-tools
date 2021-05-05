require_relative '../rendering/line_renderer'

module Domain

  ##
  # One line of input, split into nodes.
  class LineNodes
    attr_accessor :elements

    ##
    # Create a new object for the given String
    # @param [String] line
    def initialize(line)
      @elements = [ UnparsedNode.new(line) ]
    end

    ##
    # Renders the line, using the given renderer. Before calling
    # this method, the line's content should be parsed to avoid
    # getting unparsed nodes as output.
    # @para [Rendering::LineRenderer] renderer the renderer to be used
    # @return [String] the result of the rendering
    def render(renderer)
      result = ''
      @elements.each { |e| result << e.render(renderer) }
      result
    end
  end

  ##
  # Node with simple text in it. Base class for all other
  # nodes.
  class TextNode
    attr_accessor :content, :children

    ##
    # Creates a new text node with the given content.
    # @param [String] content the line's content as text
    def initialize(content = '')
      @content = content
      # @type [Array<TextNode>] sub nodes
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
    # @param [Symbol] name optional name for the method
    def self.add_renderer(name = nil)
      method_name = name || 'render_' + self.name.downcase.gsub('node', '').gsub('domain::', '')
      define_method(:render) do |renderer|
        sub_content = render_children(renderer)
        if sub_content
          renderer.send(method_name, sub_content)
        else
          renderer.send(method_name, @content)
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
  # Header field of a table |NAME|
  class TableHeaderNode < TextNode
    add_renderer :render_text
  end

  ##
  # Header cell of a table |value|
  class TableCellNode < TextNode
    add_renderer :render_text
  end

  ##
  # [[key]]
  class CitationNode < TextNode
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
