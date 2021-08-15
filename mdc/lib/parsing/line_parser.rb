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
      if md
        @proc.call(elements, md)
      end
      !!md
    end

    ##
    # Test if any of the matchers may fit
    # @param [String] text Text to be parsed
    # @return [MatchData, nil] the match or nil, if no match was found
    def test_for_match(text)
      @regex.each do |regex|
        md = regex.match(text)

        if md
          return md
        end
      end
      nil
    end

  private

    ##
    # Helper function to extract matches from the provided object
    # @param [MatchData] md Match data
    # @return [Array<String, String>] pre and post data
    def self.pre_post(md)
      pre = ''
      post = ''
      pre << md.pre_match   if md.pre_match != ''
      pre << md[:pre]       if md.names.include?("pre")

      post << md[:post]     if md.names.include?("post")
      post << md.post_match if md.post_match != ''

      [ pre, post ]
    end

    ##
    # Helper method to add elements to the collection
    # @param [Array<TextNode>] elements The elements
    # @param [MatchData] md Match data
    # @param [TextNode] new_node node to be added
    def self.add_elements(elements, md, new_node)
      pre, post = MatcherForLineElements.pre_post(md)
      elements << Domain::UnparsedNode.new(pre)  if pre != ''
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
                                   /``[ \n]([\s\S]*?[^\s][\s\S]*?)[ \n]``/,
                                   /``([\s\S]*?[^\s][\s\S]*?)``/,
                                   /`([^` ][^`]*?)`/ ,
                                   /` (.*[^\s].*) `/ ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md, Domain::CodeNode.new(md[1].gsub("\n", ' ')))
                                 end),

      MatcherForLineElements.new([
                                   /^\*\*(?<em>[^\s].*?[^\s])\*\*/,
                                   /(?<pre>[\s])\*\*(?<em>[^\s].*?[^\s])\*\*/,
                                   /(?<pre>[\w])\*\*(?<em>[\w]*?[^\s])\*\*/,
                                   /(?<pre>[().,;?\- ])\*\*(?<em>[\w].*?[^\s])\*\*(?<post>[().,;?\- <])/ ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md, Domain::StrongStarNode.new(md[:em]))
                                 end),

      MatcherForLineElements.new([
                                   /(?<pre>^|[\s().,;?\-:>])__(?<em>[\S().,;?\-].*?[\S().,;?\-])__(?<post>$|[\s().,;?\-:<\/])/,
                                   /(?<pre>^|[\s().,;?\-:>])__(?<em>[\S().,;?\-])__(?<post>$|[\s().,;?\-:<\/])/,
                                   /^__(?<em>[\S().,;:?\-].*?[\S().,;?\-])__(?<post>[\s().,;:?\-\/])/,
                                   /(?<pre>[\s().,;?\-\/])__(?<em>[\w().,;?\-].*?[\S().,;?\-])__/ ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md, Domain::StrongUnderscoreNode.new(md[:em]))
                                 end),

      MatcherForLineElements.new([
                                   /^\*(?<em>[^\s*].*?[^\s])\*/,
                                   /(?<pre>[\s])\*(?<em>[^\s*].*?[^\s])\*/,
                                   /(?<pre>[\w])\*(?<em>[\w]*?[^\s*])\*/, ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md, Domain::EmphasisStarNode.new(md[:em]))
                                 end),

      MatcherForLineElements.new([
                                   /(?<pre>^|[\s().,;?\-: >])_(?<em>[A-Za-z0-9().,;?\-].*?[\S().,;?\-])_(?<post>$|[!\s().,;?\- <\/])/,
                                   /(?<pre>^|[\s().,;?\-: >])_(?<em>[A-Za-z0-9().,;?\-])_(?<post>$|[!\s().,;?\- <\/])/,
                                   /^_(?<em>[A-Za-z0-9().,;:?\-].*?[\S().,;?\-])_(?<post>[!\s().,;:?\- <\/])/,
                                   /(?<pre>[().,;:?\-\/])_(?<em>[\w().,;?\-].*?[\S().,:;?\-])_/, ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md, Domain::EmphasisUnderscoreNode.new(md[:em]))
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
                                   MatcherForLineElements.add_elements(elements, md, Domain::LinkNode.new(url, md[:text], title))
                                 end),

      MatcherForLineElements.new([
                                   /\\\[(.*?)\\\]/, ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md, Domain::FormulaNode.new(md[1]))
                                 end),

      MatcherForLineElements.new([
                                   /(?<pre>^|[\s(*<,.;:!>-])(?<lower>[A-Za-z0-9]{1,4})_(?<sub>[A-Za-z0-9]{1,4})(?<post>$|[\s(*<,.;:!>-])/,],
                                 lambda do |elements, md|
                                   pre, post = MatcherForLineElements.pre_post(md)
                                   elements << Domain::UnparsedNode.new(pre + md[:lower])
                                   elements << Domain::SubscriptNode.new(md[:sub])
                                   elements << Domain::UnparsedNode.new(post)                    if post != ''
                                 end),

      MatcherForLineElements.new([
                                   /(?<pre>^|[\s(*<,.;:!>-])(?<lower>[A-Za-z0-9]{1,4})\^(?<sup>[A-Za-z0-9]{1,4})(?<post>$|[\s(*<,.;:!>-])/, ],
                                 lambda do |elements, md|
                                   pre, post = MatcherForLineElements.pre_post(md)
                                   elements << Domain::UnparsedNode.new(pre + md[:lower])
                                   elements << Domain::SuperscriptNode.new(md[:sup])
                                   elements << Domain::UnparsedNode.new(post)                     if post != ''
                                 end),

      MatcherForLineElements.new([ /~~(.+?)~~/ ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md, Domain::DeletedNode.new(md[1]))
                                 end),

      MatcherForLineElements.new([ /~(.+?)~/ ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md, Domain::UnderlineNode.new(md[1]))
                                 end),
      MatcherForLineElements.new([ /\[\[(.+?)\]\]/ ],
                                 lambda do |elements, md|
                                   MatcherForLineElements.add_elements(elements, md, Domain::CitationNode.new(md[1]))
                                 end),
    ]

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
      [ touched, result ]
    end

    ##
    # Parse a single node into sub nodes
    # @param [TextNode] node The node to be parsed
    # @return Array<Boolean, Array<TextNode>> the created nodes and an
    #         indicator whether a change has happened.
    def parse_node(node)

      changed = false

      if node.children.length > 0
        # Node has sub nodes, parse them
        result = []
        node.children.each do |child|
          c, es = parse_node(child)
          result << es
          changed ||= c
        end
        node.children = result.flatten
        result = [ node ]
      else
        if node.is_a? Domain::UnparsedNode
          # Node has not been parsed
          touched, result = apply_parsers(node)
          unless touched
            result << Domain::TextNode.new(node.content)
          end
          changed = true
        elsif node.class != Domain::TextNode && node.class != Domain::CodeNode && node.class != Domain::FormulaNode && node.respond_to?(:content)
          # Node has the potential for parsing into sub nodes
          _, result = apply_parsers(node)
          if result.length > 1
            node.children = result
            changed = true
          else
            node.children = [ Domain::TextNode.new(node.content) ]
          end
          result = [ node ]
        else
          # Nothing to be done
          result = [ node ]
        end
      end
      [ changed, result.flatten ]
    end

    ##
    # Parse the given line of text
    # @param [String] line_text The line to be parsed
    # @return [Domain::LineNodes] the resulting line object
    def parse(line_text)

      line = Domain::LineNodes.new(line_text)
      changed = true

      while changed
        changed = false
        elements = []

        line.elements.each do |node|
          c, es = parse_node(node)
          elements << es
          changed ||= c
        end
        line.elements = elements.flatten
      end

      line

    end
  end
end
