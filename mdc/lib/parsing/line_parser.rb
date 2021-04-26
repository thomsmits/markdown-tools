require 'stringio'
require_relative '../domain/line_nodes'

##
# One line of input.
class Line
  attr_accessor :elements

  def initialize(line)
    @elements = [ UnparsedNode.new(line) ]
  end

  def complete?
    unparsed = false
    @elements.each { |e| result ||= e.is_a? UnparsedNode }
    !unparsed
  end

  def render(renderer)
    @elements.each { |e| e.render(renderer) }
  end

  def next_unparsed_node
    result = []
    @elements.each do |e|
      if e.is_a? UnparsedNode
        replacement = yield(e)
        result << replacement
      else
        result << e
      end
    end
    changed = result != @elements
    @elements = result.flatten
    changed
  end
end

class MatcherForLineElements
  def initialize(regex, proc)
    @regex = regex
    @proc = proc
  end

  def execute(text, elements)
    @regex.each do |regex|
      md = regex.match(text)

      if md
        @proc.call(elements, md)
        return true
      end
    end
    false
  end

  def self.pre_post(md)
    pre = ''
    post = ''
    pre << md.pre_match   if md.pre_match != ''
    pre << md[:pre]       if md.names.include?("pre")

    post << md[:post]     if md.names.include?("post")
    post << md.post_match if md.post_match != ''

    [ pre, post ]
  end

  def self.add_elements(elements, md, newNode)
    pre, post = MatcherForLineElements.pre_post(md)
    elements << UnparsedNode.new(pre)  if pre != ''
    elements << newNode
    elements << UnparsedNode.new(post) if post != ''
  end
end

$parsers = [
  MatcherForLineElements.new([
    /``[ \n]([\s\S]*?[^\s][\s\S]*?)[ \n]``/,
    /``([\s\S]*?[^\s][\s\S]*?)``/,
    /` (.*[^\s].*) `/,
    /`([^`]*?)`/ ],
    lambda do |elements, md|
      MatcherForLineElements.add_elements(elements, md, CodeNode.new(md[1].gsub("\n", ' ')))
    end),

  MatcherForLineElements.new([
    /^\*\*(?<em>[^\s].*?[^\s])\*\*/,
    /(?<pre>[\s])\*\*(?<em>[^\s].*?[^\s])\*\*/,
    /(?<pre>[\w])\*\*(?<em>[\w]*?[^\s])\*\*/ ],
    lambda do |elements, md|
      MatcherForLineElements.add_elements(elements, md, StrongStarNode.new(md[:em]))
    end),

  MatcherForLineElements.new([
    /^__(?<em>[\S().,;?\-].*?[\S().,;?\-])__$/,
    /^__(?<em>[\S().,;?\-].*?[\S().,;?\-])__(?<post>[\s().,;?\-])/,
    /(?<pre>[().,;?\-])__(?<em>[\w().,;?\-].*?[\S().,;?\-])__/ ],
    lambda do |elements, md|
      MatcherForLineElements.add_elements(elements, md, StrongUnderscoreNode.new(md[:em]))
    end),

  MatcherForLineElements.new([
    /^\*(?<em>[^\s*].*?[^\s])\*/,
    /(?<pre>[\s])\*(?<em>[^\s*].*?[^\s])\*/,
    /(?<pre>[\w])\*(?<em>[\w]*?[^\s*])\*/, ],
    lambda do |elements, md|
      MatcherForLineElements.add_elements(elements, md, EmphasisStarNode.new(md[:em]))
    end),

  MatcherForLineElements.new([
    /^_(?<em>[A-Za-z0-9().,;?\-].*?[\S().,;?\-])_$/,
    /^_(?<em>[A-Za-z0-9().,;?\-].*?[\S().,;?\-])_(?<post>[\s().,;?\-])/,
    /(?<pre>[().,;?\-])_(?<em>[\w().,;?\-].*?[\S().,;?\-])_/, ],
    lambda do |elements, md|
      MatcherForLineElements.add_elements(elements, md, EmphasisUnderscoreNode.new(md[:em]))
    end),

  MatcherForLineElements.new([
    /\[(?<text>.*?)\]\(<(?<url>.*?)> ["'(](?<title>.*?)["')]\)/,
    /\[(?<text>.*?)\]\((?<url>\S*?) ["'(](?<title>.*?)["')]\)/,
    /\[(?<text>.*?)\]\(<(?<url>.*?)>\)/,
    /\[(?<text>.*?)\]\((?<url>\S*?)\)/, ],
    lambda do |elements, md|
      title = if md.names.include?("title") then md[:title] else nil end
      url = md[:url]
      url.gsub!(' ', '%20')
      MatcherForLineElements.add_elements(elements, md, LinkNode.new(url, md[:text], title))
    end),

  MatcherForLineElements.new([
    /\[(?<text>.*?)\]\[(?<ref>.*?)\]/, ],
    lambda do |elements, md|
      MatcherForLineElements.add_elements(elements, md, RefLinkNode.new(md[:ref], md[:text]))
    end),

  MatcherForLineElements.new([
    /\[(?<ref>.*?)\]: (?<url>.*?) ["'(](?<title>.*?)["')]/,
    /\[(?<ref>.*?)\]: (?<url>.*?)/, ],
    lambda do |elements, md|
      title = if md.names.include?("title") then md[:title] else nil end
      MatcherForLineElements.add_elements(elements, md, Reference.new(md[:ref], md[:url], title))
    end),

  MatcherForLineElements.new([
    /\\\[(.*?)\\\]/, ],
    lambda do |elements, md|
      MatcherForLineElements.add_elements(elements, md, FormulaNode.new(md[1]))
   end),

  MatcherForLineElements.new([
    /(?<pre>^|[\s(*<,.;:!>-])(?<lower>[A-Za-z0-9]{1,4})_(?<sub>[A-Za-z0-9]{1,4})(?<post>$|[\s(*<,.;:!>-])/,],
    lambda do |elements, md|
      pre, post = MatcherForLineElements.pre_post(md)
      elements << UnparsedNode.new(pre + md[:lower])
      elements << SubscriptNode.new(md[:sub])
      elements << UnparsedNode.new(post)                    if post != ''
    end),

  MatcherForLineElements.new([
    /(?<pre>^|[\s(*<,.;:!>-])(?<lower>[A-Za-z0-9]{1,4})\^(?<sup>[A-Za-z0-9]{1,4})(?<post>$|[\s(*<,.;:!>-])/, ],
    lambda do |elements, md|
      pre, post = MatcherForLineElements.pre_post(md)
      elements << UnparsedNode.new(pre + md[:lower])
      elements << SuperscriptNode.new(md[:sup])
      elements << UnparsedNode.new(post)                     if post != ''
    end),

  MatcherForLineElements.new([ /~~(.+?)~~/ ],
    lambda do |elements, md|
      MatcherForLineElements.add_elements(elements, md, DeletedNode.new(md[1]))
    end),

  MatcherForLineElements.new([ /~(.+?)~/ ],
  lambda do |elements, md|
    MatcherForLineElements.add_elements(elements, md, UnderlineNode.new(md[1]))
  end),

]


class LineParser3
  def parse(line_text)

    line = Line.new(line_text)

    changed = true

    while changed
      changed = line.next_unparsed_node do |e|
        elements = []
        text = e.content
        touched = false

        $parsers.each do |p|
          touched = p.execute(text, elements)
          break if touched
        end

        unless touched
          elements << TextNode.new(text)
        end

        elements
      end
    end

    new_nodes = []
    # Second pass
    line.elements.each do |e|
      if e.class != TextNode && e.class != CodeNode && e.respond_to?(:content)
        parts = []
        $parsers.each do |p|
          touched = p.execute(e.content, parts)
          break if touched
        end
        if parts.length > 1
          # Make TextNodes from UnparsedNodes
          parts.map! { |e| if e.class == UnparsedNode then TextNode.new(e.content) else e end }
          # We were broken down
          e.content = parts
        end
      end
      new_nodes << e
    end

    line.elements = new_nodes
    line

  end
end

