require 'minitest/autorun'
require_relative '../lib/rendering/renderer'
require_relative '../lib/rendering/line_renderer'
require_relative '../lib/parsing/parser'

##
# Test the parser
#
class RendererTest < Minitest::Test

  ##
  # Create array of lines from a string
  # @param [String] string the string to be converted
  # @return [Array<String>] array of lines
  def lines(string)
    io = StringIO.new(string)
    result = io.readlines
    io.close

    result
  end

  def parse_and_render(input)
    presentation = Domain::Presentation.new('DE', 'Title1', 'Title2', 3, 'Section 3', '(c) 2014',
                                            'Thomas Smits', 'java', 'Test Presentation', 'WS2014',
                                            false, nil)

    parser = Parsing::Parser.new(5, Parsing::ParserHandler.new(true))
    parser.parse_lines(lines(input), 'testfile.md', 'java', presentation)
    parser.second_pass(presentation)

    output = StringIO.new
    renderer = Rendering::Renderer.new(output, Rendering::LineRenderer.new('java'), 'DE', '/tmp', '.', '/tmp')
    presentation >> renderer
    output.string
  end

  def test_renderer_1

    input = <<-ENDOFTEXT
# Chapter
## Slide

Text before the list

  * Item 1
  * Item 2
    * Item 2.1
    * Item 2.2

Text after the list
    ENDOFTEXT

    result = parse_and_render(input).gsub("\n", "")
    assert_equal(input.gsub("\n", ""), result)
  end

  def test_renderer_2

    input = <<-ENDOFTEXT
# Chapter
## Slide

Text `before` the list

  * Item `1`
  * Item __2__
    * Item *2.1*
    * Item ***2.2**

Text after *the* _list_
    ENDOFTEXT

    result = parse_and_render(input).gsub("\n", "")
    assert_equal(input.gsub("\n", ""), result)
  end

  def test_renderer_3
    input = <<-ENDOFTEXT
# Chapter
## Slide 1.2

```java
int i = 7;
i++;
```
    ENDOFTEXT

    result = parse_and_render(input).gsub("\n", "")
    assert_equal(input.gsub("\n", ""), result)
  end

  def test_renderer_4
    input = <<-ENDOFTEXT
# Chapter
## Slide 2

> This is *very* **very** important with _emphasis_ and __strongness__

>! This is *very* **very** important with _emphasis_ and __strongness__

This is (*very*) (**very**) important with (_emphasis_ and) and (__strongness__ and)

>? This is *very* **very** important with _emphasis_ and __strongness__

> Even `code` is possible here

> This is ~underlined~ and ~~deleted~~
    ENDOFTEXT

    result = parse_and_render(input).gsub("\n", "")
    assert_equal(input.gsub("\n", ""), result)
  end


  def test_renderer_5
    input = <<-ENDOFTEXT
# Chapter
## Slide 3

All moves to the comment. A citation [[Miller2009]]

---
> This is *very* **very** important with _emphasis_ and __strongness__

>! This is *very* **very** important with _emphasis_ and __strongness__

>? This is *very* **very** important with _emphasis_ and __strongness__

> Even `code` is possible here

> This is ~underlined~ and ~~deleted~~
    ENDOFTEXT

    result = parse_and_render(input).gsub("\n", "")
    assert_equal(input.gsub("\n", ""), result)
  end

  def test_mc
    input = <<-ENDOFTEXT
# Chapter
## Slide 4.1

Some text

[ ] A question
[X] A correct `question`
[ ] A question

Some text at the end

## Slide 4.2

Some text

[ ]. A question
[X]. A correct **question**
[ ]. A question
    ENDOFTEXT

    result = parse_and_render(input).gsub("\n", "")
    assert_equal(input.gsub("\n", ""), result)
  end

  def test_table
    input = <<-ENDOFTEXT
# Chapter
## Slide 5.1

| Dezimal | Binär    | Oktal | Hexadezimal |
|---|---|---|---|
| 521,125 |          |       |             |
|         | 1011,11  |       |             |
|         |          |  15,7 |             |
|         |          |       | AC,8        |

## Slide 5.2

|  Dezimal  |  Binär          |  Oktal  |  Hexadezimal  |
|---|---|---|---|
|  521,125  |  1000001001,001 |  1011,1 |  209,2        |
|   11,75   |        1011,11  |    13,6 |    B,C        |
|   13,875  |        1101,111 |    15,7 |    D,E        |
|  172,5    |    10101100,1   |   254,4 |   AC,8        |

    ENDOFTEXT

    result = parse_and_render(input).gsub("\n", "").gsub(' ', '')
    assert_equal(input.gsub("\n", "").gsub(' ', ''), result)
  end

  def test_formula
    input = <<-ENDOFTEXT
# Chapter
## Slide 6.1

Die Formel ist \\[ f(x) = x^2 \\] aber hier haben wir einen x^2 exponenten CO_2

    ENDOFTEXT

    result = parse_and_render(input).gsub("\n", "").gsub(' ', '')
    assert_equal(input.gsub("\n", "").gsub(' ', ''), result)
  end

  def test_links
    input = <<-ENDOFTEXT
# Chapter
## Slide 7.1

This is a [link](http://www.example.com) and this another one [link](http://www.example.com "Title")
    ENDOFTEXT

    result = parse_and_render(input).gsub("\n", "")
    assert_equal(input.gsub("\n", ""), result)
  end
end
