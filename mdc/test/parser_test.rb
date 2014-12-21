# -*- coding: utf-8 -*-

require 'minitest/autorun'
require_relative '../lib/parsing/parser'
require_relative '../lib/domain/presentation'
require_relative '../lib/domain/block_elements'
require_relative '../lib/domain/line_elements'

##
# Test the parser
#
class ParserTest < Minitest::Test

TEST_1 = <<-ENDOFTEXT

# Chapter 1

## Slide 1.1

Text before the list

  * Item 1
  * Item 2
    - Item 2.1
    - Item 2.2

Text after the list


## Slide 1.2

```java
int i = 7;
i++;
```

## Slide 1.3

    int k = 9;
    k++;

## Slide 1.4 --skip--

# Chapter 2

## Slide 2.1

ENDOFTEXT


  def test_slides

    presentation = Domain::Presentation.new('Title1', 'Title2', 3, 'Section 3', '(c) 2014',
                                            'Thomas Smits', 'java', 'Test Presentation', 'WS2014')

    parser =  Parsing::Parser.new(5)

    parser.parse_lines(lines(TEST_1), 'testfile.md', 'java', presentation)

    assert_equal('Thomas Smits',      presentation.author)
    assert_equal('Title1',            presentation.title1)
    assert_equal('Title2',            presentation.title2)
    assert_equal('Section 3',         presentation.section_name)
    assert_equal(3,                   presentation.section_number)
    assert_equal('(c) 2014',          presentation.copyright)
    assert_equal('java',              presentation.default_language)
    assert_equal('Test Presentation', presentation.description)

    chapter1 = presentation.chapters[0]

    assert_equal('Chapter 1', chapter1.title)

    slides = chapter1.slides

    slide = slides[0]
    assert_equal('Slide 1.1', slides[0].title)
    assert(!slide.contains_code?)
    assert(!slide.skip)
    assert_kind_of(Domain::Text, slide.elements[0])
    assert_equal('Text before the list', slide.elements[0].to_s)

    assert_kind_of(Domain::UnorderedList, slide.elements[1])
    assert_equal('Item 1', slide.elements[1].entries[0].to_s)
    assert_equal('Item 2', slide.elements[1].entries[1].to_s)

    assert_kind_of(Domain::UnorderedList, slide.elements[1].entries[2])
    assert_equal('Item 2.1', slide.elements[1].entries[2].entries[0].to_s)
    assert_equal('Item 2.2', slide.elements[1].entries[2].entries[1].to_s)

    assert_kind_of(Domain::Text, slide.elements[2])
    assert_equal('Text after the list', slide.elements[2].to_s)

    slide = slides[1]
    assert_equal('Slide 1.2', slide.title)
    assert(slide.contains_code?)
    assert(!slide.skip)
    assert_kind_of(Domain::Source, slide.elements[0])
    assert_equal("int i = 7;\ni++;", slide.elements[0].to_s)

    slide = slides[2]
    assert_equal('Slide 1.3', slide.title)
    assert(slide.contains_code?)
    assert(!slide.skip)
    assert_kind_of(Domain::Source, slide.elements[0])
    assert_equal('java', slide.elements[0].language)
    assert_equal("int k = 9;\nk++;", slide.elements[0].to_s)

    slide = slides[3]
    assert_equal('Slide 1.4', slide.title)
    assert(!slide.contains_code?)
    assert(slide.skip)

    chapter2 = presentation.chapters[1]

    assert_equal('Chapter 2', chapter2.title)

    # TODO: More test cases
  end

  private

  ##
  # Create array of lines from a string
  # @param [String] string the string to be converted
  # @return [String[]] array of lines
  def lines(string)
    io = StringIO.new(string)
    result = io.readlines
    io.close

    result
    end
end
