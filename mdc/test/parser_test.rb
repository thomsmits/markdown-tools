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


## Slide 1.5

> Quote Line 1
> Quote Line 2


## Slide 1.6

>! Important Line 1
>! Important Line 2
>? Question Line 1
>? Question Line 2


## Slide 1.7

Some text

---
Comment line


## Slide 1.8

```java
int i = 0;
```
<br>
```cpp
int k = 17;
```


## Slide 1.9

  1. Item 1
  2. Item 2
    1. Item 2.1
    2. Item 2.2


## Slide 1.10

<!-- Comment before -->
<script>
  alert('Javascript goes here!');
</script>
<!-- Comment after -->


# Chapter 2

## Slide 2.1

<b>Bold</b>


## Slide 2.2

((Link-Previous))
((Live-CSS Hugo))
((Live-Preview))
((Live-Preview-Float))
((Button))
((Button-With-Log))
((Button-With-Log-Pre))


## Slide 2.3

### Heading 3
#### Heading 4
##### Heading 5


## Slide 2.4

![](img/file.png)/10%//30%/

![](img/file.png)/10%/

![](img/file.png)


## Slide 2.5

![](img/file.png "Title of image")/10%//30%/

![](img/file.png "Title of image")/10%/

![](img/file.png "Title of image")


## Slide 2.6

![Alt title of image](img/file.png)/10%//30%/

![Alt title of image](img/file.png)/10%/

![Alt title of image](img/file.png)


## Slide 2.7

![Alt title of image](img/file.png "Title of image")/10%//30%/

![Alt title of image](img/file.png "Title of image")/10%/

![Alt title of image](img/file.png "Title of image")

ENDOFTEXT


  ##
  # Test parsing of slides from text into objects
  def test_slide_parsing

    presentation = Domain::Presentation.new('Title1', 'Title2', 3, 'Section 3', '(c) 2014',
                                            'Thomas Smits', 'java', 'Test Presentation', 'WS2014')

    parser =  Parsing::Parser.new(5, Parsing::ParserHandler.new(true))


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

    check_slide(slides[0], 'Slide 1.1', false, false,
                [ Domain::Text, Domain::UnorderedList, Domain::Text ],
                [ 'Text before the list', '', 'Text after the list' ] ) do |e|

      assert_equal('Item 1', e[1].entries[0].to_s)
      assert_equal('Item 2', e[1].entries[1].to_s)
      assert_equal('Item 2.1', e[1].entries[2].entries[0].to_s)
      assert_equal('Item 2.2', e[1].entries[2].entries[1].to_s)
    end

    check_slide(slides[1], 'Slide 1.2', true, false,
                [ Domain::Source ],
                [ "int i = 7;\ni++;" ]) { |e| assert_equal('java', e[0].language) }

    check_slide(slides[2], 'Slide 1.3', true, false,
                [ Domain::Source ],
                [ "int k = 9;\nk++;" ]) { |e| assert_equal('java', e[0].language) }

    check_slide(slides[3], 'Slide 1.4', false, true)

    check_slide(slides[4], 'Slide 1.5', false, false,
                [ Domain::Quote ],
                [ "Quote Line 1\nQuote Line 2" ])

    check_slide(slides[5], 'Slide 1.6', false, false,
                [ Domain::Important,
                  Domain::Question ],
                [ "Important Line 1\nImportant Line 2",
                  "Question Line 1\nQuestion Line 2" ])

    check_slide(slides[6], 'Slide 1.7', false, false,
                [ Domain::Text,
                  Domain::Comment ],
                [ 'Some text' ]) { |e| assert_equal('Comment line', e[1].elements[0].to_s) }

    check_slide(slides[7], 'Slide 1.8', true, false,
                [ Domain::Source,
                  Domain::VerticalSpace,
                  Domain::Source ],
                [ 'int i = 0;', '', 'int k = 17;' ])

    check_slide(slides[8], 'Slide 1.9', false, false,
                [ Domain::OrderedList ]) do |e|

      assert_equal('Item 1', e[0].entries[0].to_s)
      assert_equal('Item 2', e[0].entries[1].to_s)
      assert_equal('Item 2.1', e[0].entries[2].entries[0].to_s)
      assert_equal('Item 2.2', e[0].entries[2].entries[1].to_s)
    end

    check_slide(slides[9], 'Slide 1.10', false, false,
                [ Domain::Script ],
                [ "alert('Javascript goes here!');" ])

    chapter2 = presentation.chapters[1]

    slides = chapter2.slides

    assert_equal('Chapter 2', chapter2.title)

    check_slide(slides[0], 'Slide 2.1', false, false,
                [ Domain::HTML ],
                [ '<b>Bold</b>' ])

    check_slide(slides[1], 'Slide 2.2', false, false,
                [ Domain::LinkPrevious, Domain::LiveCSS, Domain::LivePreview, Domain::LivePreviewFloat,
                  Domain::Button, Domain::ButtonWithLog, Domain::ButtonWithLogPre ])

    check_slide(slides[2], 'Slide 2.3', false, false,
                [ Domain::Heading, Domain::Heading, Domain::Heading ],
                [ 'Heading 3', 'Heading 4', 'Heading 5' ]) do |e|
      assert_equal(3, e[0].level)
      assert_equal(4, e[1].level)
      assert_equal(5, e[2].level)
    end

    check_slide(slides[3], 'Slide 2.4', false, false,
                [ Domain::Image, Domain::Image, Domain::Image ],
                %w(img/file.png img/file.png img/file.png )) do |e|
      assert_equal('10%', e[0].width_slide)
      assert_equal('30%', e[0].width_plain)
      assert_equal('', e[0].alt)
      assert_equal('', e[0].title)

      assert_equal('10%', e[1].width_slide)
      assert_nil(e[1].width_plain)
      assert_equal('', e[1].alt)
      assert_equal('', e[1].title)

      assert_nil(e[2].width_slide)
      assert_nil(e[2].width_plain)
      assert_equal('', e[2].alt)
      assert_equal('', e[2].title)
    end

    check_slide(slides[4], 'Slide 2.5', false, false,
                [ Domain::Image, Domain::Image, Domain::Image ],
                %w(img/file.png img/file.png img/file.png )) do |e|
      assert_equal('10%', e[0].width_slide)
      assert_equal('30%', e[0].width_plain)
      assert_equal('', e[0].alt)
      assert_equal('Title of image', e[0].title)

      assert_equal('10%', e[1].width_slide)
      assert_nil(e[1].width_plain)
      assert_equal('', e[1].alt)
      assert_equal('Title of image', e[1].title)

      assert_nil(e[2].width_slide)
      assert_nil(e[2].width_plain)
      assert_equal('', e[2].alt)
      assert_equal('Title of image', e[2].title)
    end

    check_slide(slides[5], 'Slide 2.6', false, false,
                [ Domain::Image, Domain::Image, Domain::Image ],
                %w(img/file.png img/file.png img/file.png )) do |e|
      assert_equal('10%', e[0].width_slide)
      assert_equal('30%', e[0].width_plain)
      assert_equal('Alt title of image', e[0].alt)
      assert_equal('Alt title of image', e[0].title)

      assert_equal('10%', e[1].width_slide)
      assert_nil(e[1].width_plain)
      assert_equal('Alt title of image', e[1].alt)
      assert_equal('Alt title of image', e[1].title)

      assert_nil(e[2].width_slide)
      assert_nil(e[2].width_plain)
      assert_equal('Alt title of image', e[2].alt)
      assert_equal('Alt title of image', e[2].title)
    end

    check_slide(slides[6], 'Slide 2.7', false, false,
                [ Domain::Image, Domain::Image, Domain::Image ],
                %w(img/file.png img/file.png img/file.png )) do |e|
      assert_equal('10%', e[0].width_slide)
      assert_equal('30%', e[0].width_plain)
      assert_equal('Alt title of image', e[0].alt)
      assert_equal('Title of image', e[0].title)

      assert_equal('10%', e[1].width_slide)
      assert_nil(e[1].width_plain)
      assert_equal('Alt title of image', e[1].alt)
      assert_equal('Title of image', e[1].title)

      assert_nil(e[2].width_slide)
      assert_nil(e[2].width_plain)
      assert_equal('Alt title of image', e[2].alt)
      assert_equal('Title of image', e[2].title)
    end
  end

  private

  ##
  # Helper method to simplify checks
  # @param [Domain::Slide] slide the slide to check
  # @param [String] title expected title of the slide
  # @param [Boolean] code does the slide contain any kind of code
  # @param [Boolean] skipped is the slide skipped
  # @param [Class[]] content_types expected types of content
  # @param [String[]] contents expected Strings of content
  # @param [Proc] checks additional checks to be performed
  def check_slide(slide, title, code, skipped, content_types = [ ], contents = [ ], &checks)
    assert_equal(title, slide.title)
    assert_equal(code, slide.contains_code?)
    assert_equal(skipped, slide.skip)
    content_types.each_with_index { |e, i| assert_kind_of(e, slide.elements[i])  }
    contents.each_with_index { |e, i| assert_equal(e, slide.elements[i].to_s.strip)  }
    checks.call(slide.elements)  unless checks.nil?
  end

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
