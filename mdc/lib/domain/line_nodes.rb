
##
# Node with simple text in it.
class TextNode
  attr_accessor :content

  ##
  # Creates a new text node with the given content.
  def initialize(content = '')
    @content = content
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

  def render(renderer)
    renderer.render_text(self)
  end

  def self.add_renderer
    method_name = 'render_' + self.name.downcase.gsub('node', '')
    define_method(:render) do |renderer|
      renderer.method(method_name).call(self)
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
    @target = target
    @content = content
    @title = title
  end

  add_renderer
end

##
# Link [Name][REF]
class RefLinkNode < TextNode
  attr_accessor :ref, :title

  def initialize(ref, content)
    @ref = ref
    @content = content
  end

  add_renderer
end

##
# Delete Text ~~delete~~
class DeletedNode < TextNode
  add_renderer
end

##
#  Unterline Text ~underline~
class UnderlineNode < TextNode
  add_renderer
end

##
# Reference node [ref]: URL "TITLE"
class Reference
  attr_accessor :key, :url, :title

  def initialize(key, url, title = nil)
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
