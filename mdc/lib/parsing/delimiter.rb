class Delimiter
  attr_accessor :type, :node, :active, :status

  def initialize(type, node)
    @type = type
    @node = node
    @active = true
  end

  def to_s
    "#{type}: #{node}, active=#{active}"
  end

  def ==(other)
    other.type == type &&
        other.node == node &&
        other.active == active
  end

  def pos
    @node.pos
  end
end
