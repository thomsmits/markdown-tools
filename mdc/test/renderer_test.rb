require 'minitest/autorun'
require_relative '../lib/rendering/renderer'
require_relative '../lib/rendering/line_renderer'
require_relative '../lib/parsing/parser'

##
# Test the parser
#
class RendererTest < Minitest::Test
  def txt
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

## Slide 6.1

Text using a footnote[^1] and another one[^label].

  * In a list[^1]

> Or a quote[^1]

>! Or Important[^1]

>? Or Question[^1]

Text using a footnote[^withquote] with a quote inside.

[^1]: Footnote with number.
[^label]: Footnote with label.
[^withquote]: Footnote containing a "quote"

## Slide 6.2

Text using a footnote[^2] and another one[^label2].

---
[^2]: Footnote with number.
[^label2]: Footnote with label.

## Slide 6.3

Text with a [one][1] and another [two][2]

  * [three][3]
  * [four][4]

> Quote [five][5]

>! Important [six][6]

>? Question [seven][7]

>? Question [eight][8]

[1]: https://en.wikipedia.org/wiki/Hobbit#Lifestyle
[2]: https://en.wikipedia.org/wiki/Hobbit#Lifestyle "Hobbit lifestyles"
[3]: https://en.wikipedia.org/wiki/Hobbit#Lifestyle 'Hobbit lifestyles'
[4]: https://en.wikipedia.org/wiki/Hobbit#Lifestyle (Hobbit lifestyles)
[5]: <https://en.wikipedia.org/wiki/Hobbit#Lifestyle> "Hobbit lifestyles"
[6]: <https://en.wikipedia.org/wiki/Hobbit#Lifestyle> 'Hobbit lifestyles'
[7]: <https://en.wikipedia.org/wiki/Hobbit#Lifestyle> (Hobbit lifestyles)
[8]: <https://en.wikipedia.org/wiki/Hobbit#Lifestyle>

## Slide 6.4 Comment before slide

---
This is a comment before the actual slide

  * BC1
  * BC2
---

Slide Text

  * BS1
  * BS2

---
End Comment

  * BE1
  * BE2

## Slide 6.5 Just a plain slide

With some text


    ENDOFTEXT
  end

  def parse_and_render(input)
    presentation = Domain::Presentation.new('DE', 'Title1', 'Title2', 3, 'Section 3', '(c) 2014',
                                            'Thomas Smits', 'java', 'Test Presentation', 'WS2014',
                                            false, nil)

    parser = Parsing::Parser.new(5, Parsing::ParserHandler.new(true))
    parser.parse_lines(lines(input), 'testfile.md', 'java', presentation)
    parser.second_pass(presentation)

    output = StringIO.new
    renderer = Rendering::Renderer.new(output, Rendering::LineRenderer.new, 'DE', '/tmp', '.', '/tmp')
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
end