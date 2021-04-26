class DelimiterStack
  include Enumerable

  def initialize(delimiters = [])
    @delimiters = delimiters
  end

  def <<(delimiter)
    @delimiters << delimiter
  end

  def each
    @delimiters.each { |d| yield d }
  end

  def delete(delimiter)
    @delimiters.delete(delimiter)
  end

  def sub_stack(delimiter = nil)
    index = @delimiters.find_index(delimiter) || 0
    DelimiterStack.new(@delimiters[index..].dup)
  end

  def search_backwards(types = nil)
    found = nil

    @delimiters.reverse_each do |delimiter|
      if delimiter.active && (!types || types.include?(delimiter.type))
        found = delimiter
        break
      end
    end

    yield found
  end

  def disable(type, delimiter)
    index = @delimiters.find_index(delimiter)
    @delimiters.each_with_index do |d, i|
      if i < index && d.type == type
        d.active = false
      end
    end
  end

  def [](index)
    @delimiters = index
  end

  def length
    @delimiters.length
  end

  def to_s
    @delimiters.join("\n")
  end
end