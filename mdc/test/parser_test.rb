require 'minitest/autorun'
require_relative '../lib/parsing/parser'
require_relative '../lib/domain/presentation'
require_relative '../lib/domain/block_element'
require_relative '../lib/domain/box'
require_relative '../lib/domain/equation'
require_relative '../lib/domain/html'
require_relative '../lib/domain/important'
require_relative '../lib/domain/multiple_choice_question'
require_relative '../lib/domain/ordered_list'
require_relative '../lib/domain/ordered_list_item'
require_relative '../lib/domain/question'
require_relative '../lib/domain/quote'
require_relative '../lib/domain/script'
require_relative '../lib/domain/source'
require_relative '../lib/domain/table'
require_relative '../lib/domain/text'
require_relative '../lib/domain/uml'
require_relative '../lib/domain/unordered_list'
require_relative '../lib/domain/unordered_list_item'
require_relative '../lib/domain/line_element'
require_relative '../lib/domain/button'
require_relative '../lib/domain/button_with_log'
require_relative '../lib/domain/button_with_log_pre'
require_relative '../lib/domain/button_link_previous'
require_relative '../lib/domain/button_live_css'
require_relative '../lib/domain/button_live_preview'
require_relative '../lib/domain/button_live_preview_float'
require_relative '../lib/domain/heading'
require_relative '../lib/domain/image'
require_relative '../lib/domain/multiple_choice'
require_relative '../lib/domain/vertical_space'

##
# Test the parser
#
class ParserTest < Minitest::Test
  def test_text
    <<-ENDOFTEXT

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

![](img/file.png)/10%//0%/

![](img/file.png)/10%//0/




## Slide 2.5

![](img/file.png "Title of image")/10%//30%/

![](img/file.png "Title of image")/10%/

![](img/file.png "Title of image")


## Slide 2.6

![Alt title of image](img/file.png)/10%//30%/

![Alt title of image](img/file.png)/10%/

![Alt title of image](img/file.png)


## Slide 2.6b

![Alt title of image](img/file.png)<!-- /10%//30%/ -->

![Alt title of image](img/file.png)<!-- /10%/ -->

![Alt title of image](img/file.png)


## Slide 2.7

![Alt title of image](img/file.png "Title of image")/10%//30%/

![Alt title of image](img/file.png "Title of image")/10%/

![Alt title of image](img/file.png "Title of image")


## Slide 2.7b

![Alt title of image](img/file.png "Title of image")<!-- /10%//30%/ -->

![Alt title of image](img/file.png "Title of image")<!-- /10%/ -->

![Alt title of image](img/file.png "Title of image")


## Slide 2.8

@startuml[100%][70%]
Class { Auto
  v : int
  vmax : int
  beschleunigen()
}

Instance { Porsche : Auto
  vmax = 289
  v = 0
}

Instance { M6 : Auto
  vmax = 305
  v = 0
}

Porsche : Auto --<<instantiate>>--.> Auto
M6 : Auto --<<instantiate>>--.> Auto
@enduml


## Slide 2.9

\\[
\\sum_{i=0}^N{P(X = i)} = 1
\\]


## Slide 2.10

```console
  0011      3             1101      -3             0111       7
+ 0010    + 2           + 1110    + -2           + 1011    + -5
------    ---           ------    ----           ------    ----
= 0101    = 5           = 1011    = -5           = 0010    =  2
```


## Slide 2.11

  * Item 1
  * Item 2

Example

  * Item 3
  * Item 4


## Slide 2.12

  1. Item 1
  2. Item 2
  3. Item 3

Text

  4. Item 4
  5. Item 5
  6. Item 6


## Slide 2.13

  4. Item 4
  5. Item 5
  6. Item 6

## Slide 2.14

  1. Item 1
  2. Item 2
    1. Item 2.1
    2. Item 2.2
  3. Item 3
  4. Item 4

## Slide 3.1

!INCLUDESRC "#{@temp_file.path}"
!INCLUDESRC[2] "#{@temp_file.path}"
!INCLUDESRC "#{@temp_file.path}" Java
!INCLUDESRC[2] "#{@temp_file.path}" Java

## Slide 4.1

Some text

[ ] A question
[*] A correct question
[ ] A question

Some text at the end

## Slide 4.2

Some text

[ ]. A question
[*]. A correct question
[ ]. A question

Some text at the end

## Slide 5.1

| Dezimal | Binär    | Oktal | Hexadezimal |
|---------|----------|-------|-------------|
| 521,125 |          |       |             |
|         | 1011,11  |       |             |
|         |          |  15,7 |             |
|         |          |       | AC,8        |

## Slide 5.2

|  Dezimal  |  Binär          |  Oktal  |  Hexadezimal  |
|-----------|-----------------|---------|---------------|
|  521,125  |  1000001001,001 |  1011,1 |  209,2        |
|   11,75   |        1011,11  |    13,6 |    B,C        |
|   13,875  |        1101,111 |    15,7 |    D,E        |
|  172,5    |    10101100,1   |   254,4 |   AC,8        |
    ENDOFTEXT
  end

  ##
  # Setup test environment
  def setup
    @temp_file = Tempfile.new('src.java')
    @temp_file.write("THIS IS SOURCE CODE\nAT LEAST SOME")
    @temp_file.close
  end

  ##
  # Clear test environment
  def teardown
    @temp_file.unlink
  end

  ##
  # Test parsing of slides from text into objects
  def test_slide_parsing
    presentation = Domain::Presentation.new('DE', 'Title1', 'Title2', 3, 'Section 3', '(c) 2014',
                                            'Thomas Smits', 'java', 'Test Presentation', 'WS2014',
                                            false, nil)

    parser = Parsing::Parser.new(5, Parsing::ParserHandler.new(true))

    parser.parse_lines(lines(test_text), 'testfile.md', 'java', presentation)

    assert_equal('DE',                presentation.slide_language)
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

    slide_index = 0

    slides = chapter1.slides

    check_slide(slides[slide_index], 'Slide 1.1', false, false,
                [Domain::Text, Domain::UnorderedList, Domain::Text],
                ['Text before the list', '', 'Text after the list']) do |e|

      assert_equal('Item 1', e[1].entries[0].to_s)
      assert_equal('Item 2', e[1].entries[1].to_s)
      assert_equal('Item 2.1', e[1].entries[2].entries[0].to_s)
      assert_equal('Item 2.2', e[1].entries[2].entries[1].to_s)
    end

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 1.2', true, false,
                [Domain::Source],
                ["int i = 7;\ni++;"]) { |e| assert_equal('java', e[0].language) }

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 1.3', true, false,
                [Domain::Source],
                ["int k = 9;\nk++;"]) { |e| assert_equal('java', e[0].language) }

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 1.4', false, true)

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 1.5', false, false,
                [Domain::Quote],
                ["Quote Line 1\nQuote Line 2"])

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 1.6', false, false,
                [Domain::Important,
                 Domain::Question],
                ["Important Line 1\nImportant Line 2",
                 "Question Line 1\nQuestion Line 2"])

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 1.7', false, false,
                [Domain::Text,
                 Domain::Comment],
                ['Some text']) { |e| assert_equal('Comment line', e[1].elements[0].to_s) }

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 1.8', true, false,
                [Domain::Source,
                 Domain::VerticalSpace,
                 Domain::Source],
                ['int i = 0;', '', 'int k = 17;'])

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 1.9', false, false,
                [Domain::OrderedList]) do |e|

      assert_equal('Item 1', e[0].entries[0].to_s)
      assert_equal('Item 2', e[0].entries[1].to_s)
      assert_equal('Item 2.1', e[0].entries[2].entries[0].to_s)
      assert_equal('Item 2.2', e[0].entries[2].entries[1].to_s)
    end

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 1.10', false, false,
                [Domain::Script],
                ["alert('Javascript goes here!');"])

    chapter2 = presentation.chapters[1]

    slides = chapter2.slides

    assert_equal('Chapter 2', chapter2.title)

    slide_index = 0
    check_slide(slides[slide_index], 'Slide 2.1', false, false,
                [Domain::HTML],
                ['<b>Bold</b>'])

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 2.2', false, false,
                [Domain::ButtonLinkPrevious,
                 Domain::ButtonLiveCSS,
                 Domain::ButtonLivePreview,
                 Domain::ButtonLivePreviewFloat,
                 Domain::Button,
                 Domain::ButtonWithLog,
                 Domain::ButtonWithLogPre])

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 2.3', false, false,
                [Domain::Heading, Domain::Heading, Domain::Heading],
                ['Heading 3', 'Heading 4', 'Heading 5']) do |e|
      assert_equal(3, e[0].level)
      assert_equal(4, e[1].level)
      assert_equal(5, e[2].level)
    end

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 2.4', false, false,
                [Domain::Image, Domain::Image, Domain::Image],
                %w[img/file.png img/file.png img/file.png]) do |e|
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

      assert_equal('10%', e[3].width_slide)
      assert_equal('0%', e[3].width_plain)

      assert_equal('10%', e[4].width_slide)
      assert_equal('0', e[4].width_plain)
    end

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 2.5', false, false,
                [Domain::Image, Domain::Image, Domain::Image],
                %w[img/file.png img/file.png img/file.png]) do |e|
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

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 2.6', false, false,
                [Domain::Image, Domain::Image, Domain::Image],
                %w[img/file.png img/file.png img/file.png]) do |e|
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

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 2.6b', false, false,
                [Domain::Image, Domain::Image, Domain::Image],
                %w[img/file.png img/file.png img/file.png]) do |e|
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

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 2.7', false, false,
                [Domain::Image, Domain::Image, Domain::Image],
                %w[img/file.png img/file.png img/file.png]) do |e|
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

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 2.7b', false, false,
                [Domain::Image, Domain::Image, Domain::Image],
                %w[img/file.png img/file.png img/file.png]) do |e|
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

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 2.8', false, false,
                [Domain::UML]) do |e|
      assert_equal('100%', e[0].width_slide)
      assert_equal('70%', e[0].width_plain)
    end

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 2.9', false, false,
                [Domain::Equation],
                ['\sum_{i=0}^N{P(X = i)} = 1'])

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 2.10', true, false,
                [Domain::Source],
                ["  0011      3             1101      -3             0111       7\n" \
                  "+ 0010    + 2           + 1110    + -2           + 1011    + -5\n" \
                  "------    ---           ------    ----           ------    ----\n" \
                  '= 0101    = 5           = 1011    = -5           = 0010    =  2'],
                false)

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 2.11', false, false,
                [Domain::UnorderedList, Domain::Text, Domain::UnorderedList]) do |e|
      assert_equal('Item 1', e[0].entries[0].to_s)
      assert_equal('Item 2', e[0].entries[1].to_s)

      assert_equal('Example', e[1].to_s)

      assert_equal('Item 3', e[2].entries[0].to_s)
      assert_equal('Item 4', e[2].entries[1].to_s)
    end

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 2.12', false, false,
                [Domain::OrderedList, Domain::Text, Domain::OrderedList]) do |e|
      assert_equal('Item 1', e[0].entries[0].to_s)
      assert_equal('Item 2', e[0].entries[1].to_s)

      assert_equal(1, e[0].start_number)
      assert_equal('Item 1', e[0].entries[0].to_s)
      assert_equal('Item 2', e[0].entries[1].to_s)
      assert_equal('Item 3', e[0].entries[2].to_s)

      assert_equal('Text', e[1].to_s)

      assert_equal(4, e[2].start_number)
      assert_equal('Item 4', e[2].entries[0].to_s)
      assert_equal('Item 5', e[2].entries[1].to_s)
      assert_equal('Item 6', e[2].entries[2].to_s)
    end

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 2.13', false, false,
                [Domain::OrderedList]) do |e|

      assert_equal(4, e[0].start_number)
      assert_equal('Item 4', e[0].entries[0].to_s)
      assert_equal('Item 5', e[0].entries[1].to_s)
      assert_equal('Item 6', e[0].entries[2].to_s)
    end

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 2.14', false, false,
                [Domain::OrderedList]) do |e|

      assert_equal(1, e[0].start_number)
      assert_equal('Item 1', e[0].entries[0].to_s)
      assert_equal('Item 2', e[0].entries[1].to_s)
      assert_equal('Item 2.1', e[0].entries[2].entries[0].to_s)
      assert_equal(1, e[0].entries[2].start_number)
      assert_equal('Item 2.2', e[0].entries[2].entries[1].to_s)
      assert_equal('Item 3', e[0].entries[3].to_s)
      assert_equal('Item 4', e[0].entries[4].to_s)
    end

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 3.1', true, false,
                [Domain::Source],
                ["THIS IS SOURCE CODE\nAT LEAST SOME"],
                false) do |e|

      assert_equal("THIS IS SOURCE CODE\nAT LEAST SOME", e[0].to_s)
      assert_equal('AT LEAST SOME', e[1].to_s)
      assert_equal("THIS IS SOURCE CODE\nAT LEAST SOME", e[2].to_s)
      assert_equal('Java', e[2].language)
      assert_equal('AT LEAST SOME', e[3].to_s)
      assert_equal('Java', e[3].language)
    end

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 4.1', false, false,
                [Domain::Text, Domain::MultipleChoiceQuestions],
                [],
                false) do |e|

      assert_equal(false, e[1].inline)

      assert_equal('Some text', e[0].to_s)
      assert_equal('A question', e[1].questions[0].text)
      assert_equal(false, e[1].questions[0].correct)
      assert_equal('A correct question', e[1].questions[1].text)
      assert_equal(true, e[1].questions[1].correct)
      assert_equal('A question', e[1].questions[2].text)
      assert_equal(false, e[1].questions[2].correct)
      assert_equal('Some text at the end', e[2].to_s)
    end

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 4.2', false, false,
                [Domain::Text, Domain::MultipleChoiceQuestions],
                [],
                false) do |e|

      assert_equal(true, e[1].inline)

      assert_equal('Some text', e[0].to_s)
      assert_equal('A question', e[1].questions[0].text)
      assert_equal(false, e[1].questions[0].correct)
      assert_equal('A correct question', e[1].questions[1].text)
      assert_equal(true, e[1].questions[1].correct)
      assert_equal('A question', e[1].questions[2].text)
      assert_equal(false, e[1].questions[2].correct)
      assert_equal('Some text at the end', e[2].to_s)
    end

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 5.1', false, false,
                [Domain::Table],
                [],
                false) do |e|
      assert_equal('Dezimal', e[0].headers[0].to_s)
      assert_equal('Binär', e[0].headers[1].to_s)
      assert_equal('Oktal', e[0].headers[2].to_s)
      assert_equal('Hexadezimal', e[0].headers[3].to_s)

      row = e[0].rows
      assert_nil(row[0])
      assert_equal('521,125', row[1][0].strip)
      assert_equal('', row[1][1].strip)
      assert_equal('', row[1][2].strip)
      assert_equal('', row[1][3].strip)

      assert_equal('', row[2][0].strip)
      assert_equal('1011,11', row[2][1].strip)
      assert_equal('', row[2][2].strip)
      assert_equal('', row[2][3].strip)

      assert_equal('', row[3][0].strip)
      assert_equal('', row[3][1].strip)
      assert_equal('15,7', row[3][2].strip)
      assert_equal('', row[3][3].strip)

      assert_equal('', row[4][0].strip)
      assert_equal('', row[4][1].strip)
      assert_equal('', row[4][2].strip)
      assert_equal('AC,8', row[4][3].strip)
    end

    slide_index += 1
    check_slide(slides[slide_index], 'Slide 5.2', false, false,
                [Domain::Table],
                [],
                false) do |e|
      assert_equal('Dezimal', e[0].headers[0].to_s)
      assert_equal('Binär', e[0].headers[1].to_s)
      assert_equal('Oktal', e[0].headers[2].to_s)
      assert_equal('Hexadezimal', e[0].headers[3].to_s)

      row = e[0].rows
      assert_nil(row[0])
      assert_equal('521,125', row[1][0].strip)
      assert_equal('1000001001,001', row[1][1].strip)
      assert_equal('1011,1', row[1][2].strip)
      assert_equal('209,2', row[1][3].strip)

      assert_equal('11,75', row[2][0].strip)
      assert_equal('1011,11', row[2][1].strip)
      assert_equal('13,6', row[2][2].strip)
      assert_equal('B,C', row[2][3].strip)

      assert_equal('13,875', row[3][0].strip)
      assert_equal('1101,111', row[3][1].strip)
      assert_equal('15,7', row[3][2].strip)
      assert_equal('D,E', row[3][3].strip)

      assert_equal('172,5', row[4][0].strip)
      assert_equal('10101100,1', row[4][1].strip)
      assert_equal('254,4', row[4][2].strip)
      assert_equal('AC,8', row[4][3].strip)
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
  # @param [Boolean] strip strip content before comparison
  def check_slide(slide, title, code, skipped, content_types = [], contents = [], strip = true, &checks)
    assert_equal(title, slide.title)
    assert_equal(code, slide.contains_code?)
    assert_equal(skipped, slide.skip)
    content_types.each_with_index { |e, i| assert_kind_of(e, slide.elements[i]) }
    contents.each_with_index do |e, i|
      if strip
        assert_equal(e, slide.elements[i].to_s.strip)
      else
        assert_equal(e, slide.elements[i].to_s)
      end
    end
    yield(slide.elements) unless checks.nil?
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
