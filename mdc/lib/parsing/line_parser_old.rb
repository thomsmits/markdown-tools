require 'strscan'

require 'minitest/autorun'

require_relative 'delimiter'
require_relative 'delimiter_stack'
require_relative 'node_list'
require_relative 'nodes'
require_relative 'line'

class LineParser

  def parse_images(line)
    if %r{!\[(.*)\]\((.*) "(.*)"\)/(.*)//(.*)/} =~ line
      [ ImageNode.new(line.pos, $2, $3, $1, $4, $5), $&.length ]
    elsif %r{!\[(.*)\]\((.*) "(.*)"\)<!-- /(.*)//(.*)/ -->} =~ line
      [ ImageNode.new(line.pos, $2, $3, $1, $4, $5), $&.length ]
    elsif %r{!\[(.*)\]\((.*) "(.*)"\)/(.*)/} =~ line
      [ ImageNode.new(line.pos, $2, $3, $1, $4, $4), $&.length ]
    elsif %r{!\[(.*)\]\((.*) "(.*)"\)<!-- /(.*)/ -->} =~ line
      [ ImageNode.new(line.pos, $2, $3, $1, $4, $4), $&.length ]
    elsif %r{!\[(.*)\]\((.*?)\)/(.*)//(.*)/} =~ line
      [ ImageNode.new(line.pos, $2, '', $1, $3, $4), $&.length ]
    elsif %r{!\[(.*)\]\((.*?)\)<!-- /(.*)//(.*)/ -->} =~ line
      [ ImageNode.new(line.pos, $2, '', $1, $3, $4), $&.length ]
    elsif %r{!\[(.*)\]\((.*?)\)/(.*?)/} =~ line
      [ ImageNode.new(line.pos, $2, '', $1, '', ''), $&.length ]
    elsif %r{!\[(.*)\]\((.*?)\)<!-- /(.*?)/ -->} =~ line
      [ ImageNode.new(line.pos, $2, '', $1, $3, $3), $&.length ]
    elsif %r{!\[(.*)\]\((.*?) "(.*?)"\)} =~ line
      [ ImageNode.new(line.pos, $2, '', $1, '', ''), $&.length ]
    elsif %r{!\[(.*?)\]\((.*?)\)} =~ line
      [ ImageNode.new(line.pos, $2, '', $1, '', ''), $&.length ]
    else
      [ nil, 0 ]
    end
  end

  def parse_links(line)
    if %r{\[(.*?)\]\((.*?)\)} =~ line
      [ LinkNode.new(line.pos, $1, $2), $&.length ]
    elsif %r{\[(.*?)\]\((.*?) "(.*?)"\)} =~ line
      [ LinkNode.new(line.pos, $1, $2, $3), $&.length ]
    elsif %r{^\[(.*?)\]: <(.*?)> "(.*?)"} =~ line
      [ LinkNode.new(line.pos, $1, $2, $3), $&.length ]
    elsif %r{^\[(.*?)\]: <(.*?)> '(.*?)'} =~ line
      [ LinkNode.new(line.pos, $1, $2, $3), $&.length ]
    elsif %r{^\[(.*?)\]: <(.*?)> \((.*?)\)} =~ line
      [ LinkNode.new(line.pos, $1, $2, $3), $&.length ]
    elsif %r{^\[(.*?)\]: (.*?) '(.*?)'} =~ line
      [ LinkNode.new(line.pos, $1, $2, $3), $&.length ]
    elsif %r{^\[(.*?)\]: (.*?) "(.*?)"} =~ line
      [ LinkNode.new(line.pos, $1, $2, $3), $&.length ]
    elsif %r{^\[(.*?)\]: (.*?) \((.*?)\)} =~ line
      [ LinkNode.new(line.pos, $1, $2, $3), $&.length ]
    elsif %r{^\[(.*?)\]: <(.*?)>} =~ line
      [ LinkNode.new(line.pos, $1, $2), $&.length ]
    elsif %r{^\[(.*?)\]: (.*)} =~ line
      [ LinkNode.new(string_pos, $1, $2), $&.length ]
    elsif %r{\[(.+?)\]\((.+?)\)} =~ line
      [ LinkNode.new(line.pos, $1, $2), $&.length ]
    else
      [ nil, 0 ]
    end
  end

  def delimiter_run(scanner)

    punctuation = '\[\]!"#$%&\'\(\)+,./:;<=>?@^_`{|}~-'
    delimiter = '[*_]{1,}'

    # A left-flanking delimiter run is a delimiter run that is
    # (1) not followed by Unicode whitespace, and either
    # (2a) not followed by a punctuation character, or
    # (2b) followed by a punctuation character and preceded by Unicode whitespace or a punctuation character.
    # For purposes of this definition, the beginning and the end of the line count as Unicode whitespace.
    left_flanking_regex = /((#{delimiter})[^*\s#{punctuation}])|(([\s#{punctuation}](#{delimiter}))[#{punctuation}])/

    # A right-flanking delimiter run is a delimiter run that is
    # (1) not preceded by Unicode whitespace, and either
    # (2a) not preceded by a punctuation character, or
    # (2b) preceded by a punctuation character and followed by Unicode whitespace or a punctuation character.
    # For purposes of this definition, the beginning and the end of the line count as Unicode whitespace.
    right_flanking_regex = /([^*\s#{punctuation}](#{delimiter}))|([#{punctuation}](#{delimiter})[\s#{punctuation}])/

    delimiters = ''

    if scanner.check(left_flanking_regex)
      context = scanner.matched
      delimiters = scanner.values_at(2, 4).join('')
      type = :left_flanking

      if context =~ right_flanking_regex
        type = :both_flanking
      else
        type = :left_flanking
      end
    end

    if scanner.check(right_flanking_regex)
      context = scanner.matched
      delimiters = scanner.values_at(2, 4).join('')

      if context =~ left_flanking_regex
        type = :both_flanking
      else
        type = :right_flanking
      end
    end

    puts delimiters

    # 1. A single * character can open emphasis iff it is part of a left-flanking delimiter run.
    if delimiters == '*' && type == :left_flanking
      return :open
    end

    # 2. A single _ character can open emphasis iff it is part of a left-flanking delimiter run and either
    # (a) not part of a right-flanking delimiter run or
    # (b) part of a right-flanking delimiter run preceded by punctuation.
    if delimiters == '_'
      if type == :left_flanking
        return :open
      elsif type == :both_flanking
        # TODO: preceded by punctuation
      end
    end

    # 3. A single * character can close emphasis iff it is part of a right-flanking delimiter run.
    if delimiters == '*' && type == :right_flanking
      return :close
    end

    # 4. A single _ character can close emphasis iff it is part of a right-flanking delimiter run and either
    # (a) not part of a left-flanking delimiter run or
    # (b) part of a left-flanking delimiter run followed by punctuation.
    if delimiters == '_'
      if type == :right_flanking
        return :close
      elsif type == :both_flanking
        # TODO: followed by punctuation
      end
    end

    # 5. A double ** can open strong emphasis iff it is part of a left-flanking delimiter run.
    if delimiters == '**' && type == :left_flanking
      return :open
    end

    # 6. A double __ can open strong emphasis iff it is part of a left-flanking delimiter run and either
    # (a) not part of a right-flanking delimiter run or
    # (b) part of a right-flanking delimiter run preceded by punctuation.
    if delimiters == '__'
      if type == :left_flanking
        return :open
      elsif type == :both_flanking
        # TODO: preceded by punctuation
      end
    end

    # 7. A double ** can close strong emphasis iff it is part of a right-flanking delimiter run.
    if delimiters == '**' && type == :right_flanking
      return :close
    end

    # 8. A double __ can close strong emphasis iff it is part of a right-flanking delimiter run and either
    # (a) not part of a left-flanking delimiter run or
    # (b) part of a left-flanking delimiter run followed by punctuation.
    if delimiters == '__'
      if type == :right_flanking
        return :close
      elsif type == :both_flanking
        # TODO: followed by punctuation
      end
    end

    # 9. Emphasis begins with a delimiter that can open emphasis
    # and ends with a delimiter that can close emphasis,
    # and that uses the same character (_ or *) as the opening delimiter.
    # The opening and closing delimiters must belong to separate delimiter runs.
    # If one of the delimiters can both open and close emphasis, then the sum of the
    # lengths of the delimiter runs containing the opening and closing delimiters
    # must not be a multiple of 3 unless both lengths are multiples of 3.

    # 10. Strong emphasis begins with a delimiter that can open strong emphasis
    # and ends with a delimiter that can close strong emphasis,
    # and that uses the same character (_ or *) as the opening delimiter.
    # The opening and closing delimiters must belong to separate delimiter runs.
    # If one of the delimiters can both open and close strong emphasis, then the sum of the
    # lengths of the delimiter runs containing the opening and closing delimiters
    # must not be a multiple of 3 unless both lengths are multiples of 3.

    # 11. A literal * character cannot occur at the beginning or end
    # of *-delimited emphasis or **-delimited strong emphasis,
    # unless it is backslash-escaped.

    # 12. A literal _ character cannot occur at the beginning or end
    # of _-delimited emphasis or __-delimited strong emphasis,
    # unless it is backslash-escaped.

    # 13. The number of nestings should be minimized.
    # Thus, for example, an interpretation <strong>...</strong>
    # is always preferred to <em><em>...</em></em>.

    # 15. An interpretation <em><strong>...</strong></em> is
    # always preferred to <strong><em>...</em></strong>.

    # 16. When two potential emphasis or strong emphasis spans overlap,
    # so that the second begins before the first ends and ends after the first ends,
    # the first takes precedence. Thus, for example, *foo _bar* baz_ is parsed as <em>foo _bar</em> baz_
    # rather than *foo <em>bar* baz</em>.

    # 17. When there are two potential emphasis or strong emphasis spans with the same closing delimiter,
    # the shorter one (the one that opens later) takes precedence.
    # Thus, for example, **foo **bar baz** is parsed as **foo <strong>bar baz</strong>
    # rather than <strong>foo **bar baz</strong>.

    # 18. Inline code spans, links, images, and HTML tags group more tightly than emphasis.
    # So, when there is a choice between an interpretation that contains one of these elements
    # and one that does not, the former always wins.
    # Thus, for example, *[foo*](bar) is parsed as *<a href="bar">foo*</a> rather than as <em>[foo</em>](bar)

    return :none
  end

  def look_for_link_or_image(stack, nodes, line)

    string_pos = line.pos

    stack.search_backwards(%w{![ [}) do |delimiter|
      # Search backward for the first opening delimiter

      if delimiter.type == '!['
        # Image start tag

        # Parse the line and try to match image information
        image_node, length = parse_images(line[delimiter])

        if image_node
          nodes.delete_node_and_after(delimiter.node)
          stack.delete(delimiter)
          nodes.add_node(image_node)
          line.pos = image_node.pos # rewind line
          line.skip_char(length) # skip over the matched element
          return
        end
      elsif delimiter.type == '['
        # Link start tag
        link_node, length = parse_links(line[delimiter])

        if link_node
          # disable all opening delimiters
          stack.disable('[', delimiter)

          nodes.delete_node_and_after(delimiter.node)
          stack.delete(delimiter)
          nodes.add_node(link_node)
          line.pos = link_node.pos # rewind line
          line.skip_char(length) # skip over the matched element
          return
        end
      else
        stack.delete(delimiter)
        nodes.add(TextNode.new(string_pos, ']'))
      end
    end
  end

  def process_emphasis(delimiters, nodes, line, stack_bottom = nil)
    sub_stack = delimiters.sub_stack(stack_bottom)
    pos = delimiters.length - 1
    openers_bottom = pos

    while true
      if delimiters[pos].type == '*'

      elsif delimiters[pos].type = '_'
      end

      pos -= 1
    end



  end

  def parse_line(text)
    line = Line.new(text)
    nodes = NodeList.new
    delimiters = DelimiterStack.new


    until line.eos

      c = line.fetch_next_char

      if c == '\\' && line.peek_next_char
        # next character is escaped, add it as a text node
        # without further interpretation
        nodes.current_node << line.fetch_next_char
      elsif c == '!' && line.peek_next_char == '['
        node = nodes.add_node(TextNode.new(line.pos - 1, '!['))
        line.skip_char
        delimiters << Delimiter.new('![', node)
      elsif (c == '*') || (c == '_') || (c == '[')
        node = nodes.add_node(TextNode.new(line.pos - 1, c))
        delimiters << Delimiter.new(c, node)
      elsif c == ']'
        nodes.close_node
        look_for_link_or_image(delimiters, nodes, line)
      else
        nodes.current_node << c
      end
    end

    nodes.add_node(nodes.current_node)

    #
    # process_emphasis(delimiters, nodes, line, nil)

    puts delimiters
    puts nodes
  end


end

class StringScanner
  def to_s
    string[pos..]
  end
end

#LineParser.new.parse_line('Test \\* *fett* _fetter_ ![img](/url) [[Link](/url) Test *')

class TestLineParser < Minitest::Test

  def prepare_scan(string, first, second)
    s = StringScanner.new(string)
    l = LineParser.new

    s.skip(/[^_*]+/)
    r_first = l.delimiter_run(s)
    s.skip(/[_*]/)
    s.skip(/[^_*]+/)
    s.pos = s.pos - 1
    r_second = l.delimiter_run(s)
    assert_equal(first, r_first)
    assert_equal(second, r_second)
  end

  def test_parser
    prepare_scan(%Q{*foo bar*}, :open, :close)
    prepare_scan(%Q{a * foo bar*}, :none, :close)
    prepare_scan(%Q{a*"foo"*}, :none, :none)
    prepare_scan(%Q{* a *}, :none, :none)
    prepare_scan(%Q{foo*bar*}, :open, :close)
    prepare_scan(%Q{5*6*78}, :open, :close)
  end
end

TestLineParser.new('test').test_parser
