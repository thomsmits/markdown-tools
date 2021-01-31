
class Line
  attr_accessor :pos

  def initialize(content, pos = 0)
    @content = content
    @pos = pos
  end

  def eos
    @pos >= @content.length
  end

  def fetch_next_char
    result = @content[@pos]
    @pos = @pos + 1
    result
  end

  def peek_next_char
    @content[@pos]
  end

  def skip_char(num = 1)
    @pos += num
  end

  def rewind(num = 1)
    @pos -= num
  end

  def copy(pos = 0)
    Line.new(@content, pos)
  end

  def [](obj = nil)
    if obj && obj.respond_to?(:pos)
      pos = obj.pos
    elsif obj
      pos = obj.to_int
    else
      pos = 0
    end
    copy(pos)
  end

  def =~(regex)
    @content[pos..] =~ regex
  end

  def length
    @content[pos..].length
  end

  def to_s
    @content[pos..]
  end

  def to_str
    to_s
  end
end
