class Node
  attr_reader :pos, :content

  def initialize(pos, content = '')
    @content = content
    @pos = pos
  end

  def <<(content)
    @content += content
  end

  def to_s
    @content
  end
end

class LinkNode < Node
  attr_reader :key, :target, :title

  ##
  # Create a new heading
  # @param [String] key key of the link
  # @param [String] target target URL of the link
  # @param [String] title an (optional) title
  def initialize(pos, key, target, title=nil)
    super(pos)
    @key = key
    @target = target
    @title = title
  end

  ##
  # Return a string representation of this element
  # @return [String] string representation
  def to_s
    "[#{@key}](#{@target})"
  end

  ##
  # Compare this object with another one
  # @param [Footnote] other the other one
  def ==(other)
    @key == other.key && @target == other.target
  end
end



class TextNode < Node
  def initialize(string_pos, content = '')
    super(string_pos, content)
  end
end

class ImageNode < Node
  attr_accessor :location, :formats, :license
  attr_reader :alt, :title, :width_slide, :width_plain

  ##
  # Create a new image
  # @param [String] location path of the image
  # @param [String] alt alternate text
  # @param [String] title title
  # @param [String] width_slide width for slides
  # @param [String] width_plain width for plain text
  def initialize(pos, location, alt, title, width_slide, width_plain)
    super(pos)
    @location = location
    @alt = alt
    @title = title
    @width_slide = width_slide
    @width_plain = width_plain
    @formats = []
    @license = nil
  end

  ##
  # Render the element
  # @param [Rendering::Renderer] renderer to be used
  def >>(renderer)
    renderer.image(@location, @formats, @alt, @title, @width_slide,
                   @width_plain, @license.nil? ? nil : @license.source)
  end

  ##
  # Return a string representation of this element
  # @return [String] string representation
  def to_s
    "![#{title}](#{location})"
  end
end
