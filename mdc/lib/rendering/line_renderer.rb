

class LineRenderer

  ##
  # Initialize the renderer
  # @param [IO] io target of output operations
  def initialize(io)
    @io = io
  end

  def handle_array(node)
    if node.content.is_a? Array
      temp_io = StringIO.new
      r = self.class.new(temp_io)
      node.content.each { |e| e.render(r) }
      node.content = temp_io.string
    end
  end

  def render_text(node)
    handle_array(node)
    @io << node.content
  end

  def render_code(node)
    handle_array(node)
    @io << "`#{node.content}`"
  end

  def render_strongunderscore(node)
    handle_array(node)
    @io << "__#{node.content}__"
  end

  def render_strongstar(node)
    handle_array(node)
    @io << "**#{node.content}**"
  end

  def render_emphasisunderscore(node)
    handle_array(node)
    @io << "_#{node.content}_"
  end

  def render_emphasisstar(node)
    handle_array(node)
    @io << "*#{node.content}*"
  end

  def render_superscript(node)
    handle_array(node)
    @io << "^#{node.content}"
  end

  def render_subscript(node)
    handle_array(node)
    @io << "_#{node.content}"
  end

  def render_link(node)
    handle_array(node)
    @io << if node.title.nil?
             %Q{[#{node.content}](#{node.target})}
           else
             %Q{[#{node.content}](#{node.target} "#{node.title}")}
           end
  end

  def render_reflink(node)
    handle_array(node)
    # TODO: Implement
  end

  def render_formula(node)
    handle_array(node)
    @io << "\[ #{node.content} \]"
  end

  def render_deleted(node)
    handle_array(node)
    @io << "~~#{node.content}~~"
  end

  def render_underline(node)
    handle_array(node)
    @io << "~#{node.content}~"
  end

  def render_unparsed(node)
    handle_array(node)
    @io << "UNPARSED NODE - SHOULD NOT BE RENDERED!!!! #{node.content}"
  end
end
