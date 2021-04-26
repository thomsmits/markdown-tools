class NodeList
  attr_accessor :current_node

  def initialize
    @elements = []
    @current_node = TextNode.new(0)
  end

  def add_node(node)
    @elements << @current_node
    @elements << node
    @current_node = TextNode.new(@current_node.pos)
    node
  end

  def find_index(node)
    @elements.find_index(node)
  end

  def close_node
    @elements << @current_node
    @current_node = TextNode.new(@current_node.pos)
  end

  def replace_node(node)
    @elements << node
    @current_node = TextNode.new(@current_node.pos)
  end

  def length
    @elements.length
  end

  def delete_at(index)
    @elements.delete_at(index)
  end

  def delete(from, to)
    @elements = @elements[0...from] + @elements[(to + 1)..]
  end

  def delete_node_and_after(node)
    index = @elements.find_index(node)
    @elements = @elements[0...index]
  end

  def to_s
    @elements.join('')
  end
end