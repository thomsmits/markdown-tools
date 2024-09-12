require 'stringio'
require_relative '../domain/line_nodes'

module Parsing
  ##
  # Helper class for the matchers used to parse the line into nodes
  class MatcherForLineElements
    ##
    # Create a new instance
    # @param [Array<Regexp>] regex Regular expression used
    # @param [Proc] proc Lambda to be called if one of the expression matches
    def initialize(regex, proc)
      @regex = regex
      @proc = proc
    end

    ##
    # Executes the matcher
    # @param [String] text Text to be parsed
    # @param [Array<TextNode>] elements Array of already parsed nodes
    # @return [Boolean] true, if a match was found, otherwise false
    def execute_matchers(text, elements)
      md = test_for_match(text)
      @proc.call(elements, md) if md
      !!md
    end

    ##
    # Test if any of the matchers may fit
    # @param [String] text Text to be parsed
    # @return [MatchData, nil] the match or nil, if no match was found
    def test_for_match(text)
      @regex.each do |regex|
        md = regex.match(text)

        return md if md
      end
      nil
    end

    ##
    # Helper function to extract matches from the provided object
    # @param [MatchData] md Match data
    # @return [Array<String, String>] pre and post data
    def self.pre_post(md)
      pre = ''
      post = ''
      pre << md.pre_match   if md.pre_match != ''
      pre << md[:pre]       if md.names.include?('pre')

      post << md[:post]     if md.names.include?('post')
      post << md.post_match if md.post_match != ''

      [pre, post]
    end

    ##
    # Helper method to add elements to the collection
    # @param [Array<TextNode>] elements The elements
    # @param [MatchData] md Match data
    # @param [TextNode] new_node node to be added
    def self.add_elements(elements, md, new_node)
      pre, post = MatcherForLineElements.pre_post(md)
      elements << Domain::UnparsedNode.new(pre) if pre != ''
      elements << new_node
      elements << Domain::UnparsedNode.new(post) if post != ''
    end
  end

  ##
  # Class to parse a line of string into the nodes, representing the elements
  # of that line
  class LineParser
    PARSERS = [

      MatcherForLineElements.new([
                                   %r{(?<pre>^|\s+|[-().,;?:>/])__`(?<em>.*?)`__(?<post>[-+!().,;?:> /"]+|$)}
                                 ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md,
                                                                       Domain::StrongUnderscoreCodeNode.new(md[:em]))
                                 end),

      MatcherForLineElements.new([
                                   /``[ \n]([\s\S]*?\S[\s\S]*?)[ \n]``/,
                                   /``([\s\S]*?\S[\s\S]*?)``/,
                                   /`([^` ][^`]*?)`/,
                                   /` (.*\S.*) `/
                                 ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md,
                                                                       Domain::CodeNode.new(md[1].gsub("\n", ' ')))
                                 end),

      MatcherForLineElements.new([
                                   /` (.*?[^ ])`/
                                 ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md,
                                                                       Domain::CodeNode.new(" #{md[1].gsub("\n", ' ')}"))
                                 end),

      MatcherForLineElements.new([
                                   %r{(<[^>]+>.*</[^>]+>)}
                                 ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md, Domain::HtmlNode.new(md[1]))
                                 end),

      MatcherForLineElements.new([
                                   /\[(?<text>.*?)\]\(<(?<url>.*?)> ["'(](?<title>.*?)["')]\)/,
                                   /\[(?<text>.*?)\]\((?<url>\S*?) ["'(](?<title>.*?)["')]\)/,
                                   /\[(?<text>.*?)\]\(<(?<url>.*?)>\)/,
                                   /\[(?<text>.*?)\]\((?<url>\S*?)\)/
                                 ],
                                 lambda do |elements, md|
                                   title = md.names.include?('title') ? md[:title] : nil
                                   url = md[:url]
                                   url.gsub!(' ', '%20')
                                   MatcherForLineElements.add_elements(elements, md,
                                                                       Domain::LinkNode.new(url, md[:text], title))
                                 end),

      MatcherForLineElements.new([
                                   /"(.*?)"/
                                 ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md, Domain::QuotedNode.new(md[1]))
                                 end),

      MatcherForLineElements.new([
                                   %r{(?<pre>^|\s+|[\p{L}\p{N}]|[().,;?\-:> /\[])\*\*(?<em>\S.*?\S|[\p{L}\p{N}\[])\*\*(?<post>[-+!().,;?:> /"\]]?)}
                                 ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md,
                                                                       Domain::StrongStarNode.new(md[:em]))
                                 end),

      MatcherForLineElements.new([
                                   %r{(?<pre>^|\s+|[-().,;?:>/])__(?<em>[\p{L}\p{N}(\[].*?[\p{L}\p{N}+)\]]|[\p{L}\p{N}+)\]!]+?)__(?<post>[-+!().,;?:> /"]+|$)}
                                 ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md,
                                                                       Domain::StrongUnderscoreNode.new(md[:em]))
                                 end),

      MatcherForLineElements.new([
                                   %r{(?<pre>^|\s+|[\p{L}\p{N}]|[().,;?\-:> /])\*(?<em>[\p{L}\p{N}]|[\p{L}\p{N}(].*?[\p{L}\p{N})!])\*(?<post>[-+!().,;?:> /"]?|$)}
                                 ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md,
                                                                       Domain::EmphasisStarNode.new(md[:em]))
                                 end),

      MatcherForLineElements.new([
                                   %r{(?<pre>^|\s+|[().,;?\-:> /])_(?<em>[\p{L}\p{N}]|[\p{L}\p{N}(].*?[\p{L}\p{N})!])_(?<post><br>|[-+!().,;?:> /"]+|$)}
                                 ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md,
                                                                       Domain::EmphasisUnderscoreNode.new(md[:em]))
                                 end),

      MatcherForLineElements.new([
                                   /\\\[(.*?)\\\]/
                                 ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md, Domain::FormulaNode.new(md[1]))
                                 end),

      MatcherForLineElements.new([
                                   /(?<pre>^|[\s(*<,.;:!>-])(?<lower>[A-Za-z0-9]{1,4})_(?<sub>[A-Za-z0-9]{1,5})(?<post>$|[\s(*<,.;:!>-])/
                                 ],
                                 lambda do |elements, md|
                                   pre, post = MatcherForLineElements.pre_post(md)
                                   elements << Domain::UnparsedNode.new(pre + md[:lower])
                                   elements << Domain::SubscriptNode.new(md[:sub])
                                   elements << Domain::UnparsedNode.new(post) if post != ''
                                 end),

      MatcherForLineElements.new([
                                   /(?<pre>^|[\s(*<,.;:!>-])(?<lower>[A-Za-z0-9]{1,4})\^(?<sup>[A-Za-z0-9]{1,5})(?<post>$|[\s(*<,.;:!>-])/
                                 ],
                                 lambda do |elements, md|
                                   pre, post = MatcherForLineElements.pre_post(md)
                                   elements << Domain::UnparsedNode.new(pre + md[:lower])
                                   elements << Domain::SuperscriptNode.new(md[:sup])
                                   elements << Domain::UnparsedNode.new(post) if post != ''
                                 end),

      MatcherForLineElements.new([/~~(.+?)~~/],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md, Domain::DeletedNode.new(md[1]))
                                 end),

      MatcherForLineElements.new([/~(.+?)~/],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md, Domain::UnderlineNode.new(md[1]))
                                 end),

      MatcherForLineElements.new([/\[\[(.+?)\]\]/],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md, Domain::CitationNode.new(md[1]))
                                 end),

      MatcherForLineElements.new([/<br>/],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md, Domain::NewLineNode.new(''))
                                 end),

      MatcherForLineElements.new([
                                   /(?<pre>.*?)(?<char>__|\*\*)(?<post>.*)/,
                                   /(?<pre>.*?)(?<char>[_*])(?<post>.*)/
                                 ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md,
                                                                       Domain::SingleEmphOrStrong.new(md[:char]))
                                 end),

      MatcherForLineElements.new([
                                   /\[\^(.*?)\]/,
                                 ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md,
                                                                       Domain::FootnoteNode.new(md[1]))
                                 end),
    ].freeze

    ##
    # Applies all parsers to the node.
    # @param [TextNode] node The node to be parsed.
    # @return [Array<Boolean, Array<TextNode>>] A boolean indicating whether
    #         a change has happened and the resulting nodes
    def apply_parsers(node)
      touched = false
      result = []
      PARSERS.each do |p|
        touched = p.execute_matchers(node.content, result)
        break if touched
      end
      [touched, result]
    end

    ##
    # Parse a single node into sub nodes
    # @param [TextNode] node The node to be parsed
    # @return Array<Boolean, Array<TextNode>> the created nodes and an
    #         indicator whether a change has happened.
    def parse_node(node)
      changed = false

      if node.children.length.positive?
        # Node has sub nodes, parse them
        result = []
        node.children.each do |child|
          c, es = parse_node(child)
          result << es
          changed ||= c
        end
        node.children = result.flatten
        result = [node]
      elsif node.is_a? Domain::UnparsedNode
        touched, result = apply_parsers(node)
        result << Domain::TextNode.new(node.content) unless touched
        changed = true
      # Node has not been parsed
      elsif node.class != Domain::HtmlNode && node.class != Domain::TextNode && node.class != Domain::CodeNode && node.class != Domain::StrongUnderscoreCodeNode && node.class != Domain::FormulaNode && node.class != Domain::SingleEmphOrStrong && node.respond_to?(:content)
        # Node has the potential for parsing into sub nodes
        _, result = apply_parsers(node)
        if result.length >= 1
          node.children = result
          changed = true
        else
          node.children = [Domain::TextNode.new(node.content)]
        end
        result = [node]
      else
        # Nothing to be done
        result = [node]
      end
      [changed, result.flatten]
    end

    ALLOWED_BEFORE_AND_AFTER = [
      ' ', ';', '.', '-', "\n", "\t", '<', '>', ':'
    ].freeze
    # TODO: Check charset

    # TODO: Explain
    def patch_nodes(elements)
      # search for start
      start_idx = elements.index { |n| n.instance_of?(Domain::SingleEmphOrStrong) }
      end_idx   = elements.rindex { |n| n.instance_of?(Domain::SingleEmphOrStrong) }

      if start_idx &&
         end_idx &&
         start_idx != end_idx &&
         elements[start_idx].content == elements[end_idx].content

        # There must not be a space after the start or before the end
        if start_idx < elements.size - 1 && elements[start_idx + 1].instance_of?(Domain::TextNode) && elements[start_idx + 1].content.start_with?(
          ' ', "\n", "\t"
        )
          return elements
        end

        if end_idx.positive? && elements[end_idx - 1].instance_of?(Domain::TextNode) && elements[end_idx - 1].content.end_with?(
          ' ', "\n", "\t"
        )
          return elements
        end

        # There must be a space before the start and after the end
        if start_idx.positive? && elements[start_idx - 1].instance_of?(Domain::TextNode) && !elements[start_idx - 1].content.end_with?(*ALLOWED_BEFORE_AND_AFTER)
          return elements
        end

        if end_idx < elements.size - 1 && elements[end_idx + 1].instance_of?(Domain::TextNode) && !elements[end_idx + 1].content.start_with?(*ALLOWED_BEFORE_AND_AFTER)
          return elements
        end

        result = []
        result << elements[0...start_idx]
        node_clazz = case elements[start_idx].content
                     when '_'
                       Domain::EmphasisUnderscoreNode
                     when '__'
                       Domain::StrongUnderscoreNode
                     when '*'
                       Domain::EmphasisStarNode
                     when '**'
                       Domain::StrongStarNode
                     end
        node = node_clazz.new
        node.children = elements[(start_idx + 1)...end_idx]
        result << node
        result << elements[(end_idx + 1)..] if end_idx < elements.size

        result.flatten
      else
        elements
      end
    end

    ##
    # Parse the given line of text
    # @param [String] line_text The line to be parsed
    # @param [Array[Footnotes]] footnotes the footnotes
    # @return [Domain::LineNodes] the resulting line object
    def parse(line_text, footnotes)
      line = Domain::LineNodes.new(line_text)
      changed = true

      while changed
        changed = false
        elements = []

        line.elements.each do |node|
          c, es = parse_node(node)
          elements << es
          changed ||= c
          node.footnotes = footnotes if node.respond_to? :footnotes=
        end
        line.elements = elements.flatten
      end

      line.elements = patch_nodes(line.elements)

      line
    end
  end
end
