# -*- coding: utf-8 -*-

require 'minitest/autorun'
require_relative '../lib/parsing/markdown_line'

##
# Test class for the MarkdownLine class
class MarkdownLineTest < Minitest::Test

  ##
  # Create a line
  # @param [String] contents The contents of the created line
  # @return [Parsing::MarkdownLine] the created line
  def line(contents)
    Parsing::MarkdownLine.new contents
  end

  ##
  # Test parsing of comments
  def test_comment
    line = line('<!--Hallo-->')
    assert(line.comment?)
    assert_equal('Hallo', line.comment)

    line = line('<!-- <br>Hallo</br> -->')
    assert(line.comment?)
    assert_equal(' <br>Hallo</br> ', line.comment)

    assert(!line('<--Hallo-->').comment?)
    assert(!line('<!-- Hallo ->').comment?)
  end

  ##
  # Test parsing of vertical spaces
  def test_vspace
    assert(line('<br>').vertical_space?)
    assert(line(' <br>').vertical_space?)
    assert(line('<br> ').vertical_space?)
    assert(line('  <br>  ').vertical_space?)

    assert(!line('x<br>').vertical_space?)
    assert(!line('<br> x').vertical_space?)
    assert(!line('x <br>').vertical_space?)
    assert(!line('x  <br>  x').vertical_space?)
  end

  ##
  # Test parsing of sources marked by indentation
  def test_source
    assert(line('    int i = 5;').source?)
    assert(line('      int i = 5;').source?)
    assert(line('        int i = 5;').source?)
    assert(line('          int i = 5;').source?)

    assert(!line('   int i = 5;').source?)
    assert(!line('    * Item').source?)
    assert(!line('    - Item').source?)
  end

  ##
  # Test parsing of a table row
  def test_table
    assert(line('| aaa | bbb | ccc |').table_row?)
    assert(line('| aaa | bbb | ccc |  ').table_row?)
    assert(line('| aaa |').table_row?)

    assert(line('|--|--|').table_separator?)
    assert(line('|--|').table_separator?)

    assert(!line('| aaa ').table_row?)
    assert(!line(' | aaa | bbb | ccc |').table_row?)

    assert(!line('|-|-|').table_separator?)
    assert(!line('|--').table_separator?)
  end

  ##
  # Test parsing of quotes and boxes
  def test_quotes
    assert(line('> Quote').quote?)
    assert(line('>> Quelle').quote_source?)
    assert(line('>? Question').question?)
    assert(line('>! Important').important?)
    assert(line('>: Important').box?)

    assert(!line(' > Zitat').quote?)
    assert(!line(' >> Quote').quote_source?)
    assert(!line('>? Question').quote?)
    assert(!line('>! Important').quote?)
    assert(!line(' >? Question').question?)
    assert(!line(' >! Important').important?)
    assert(!line('x >? Question').question?)
    assert(!line('x >! Important').important?)
  end

  ##
  # Test for empty lines
  def test_empty
    assert(line('').empty?)
    assert(line(' ').empty?)
    assert(line("\t").empty?)
    assert(line('    ').empty?)

    assert(!line('x').empty?)
    assert(!line('  x   ').empty?)
  end

  ##
  # Test for normal lines
  def test_normal
    assert(line('hello').normal?)
    assert(line('hello world').normal?)
    assert(!line(' hello').normal?)
    assert(!line('  hello').normal?)
    assert(!line('   hello').normal?)
    assert(!line('    hello').normal?)
    assert(!line('      hello').normal?)
  end

  ##
  # Test for text lines
  def test_text
    assert(line('Hello World').text?)
    assert(line('Hello World with special characters äöüßÄÖÜ').text?)
    assert(!line('.:!').text?)
  end

  ##
  # Test for HTML tags
  def test_html
    assert(line('<br>').html?)
    assert(line('<br><b>').html?)

    assert(!line(' <br>').html?)
    assert(!line('  <br><b>').html?)
  end

  ##
  # Test for image tags
  def test_image
    assert(line('![](img/royal-baby)').image?)
    assert(line('![Royal Baby](img/royal-baby)').image?)
    assert(line('![Royal Baby](img/royal-baby "The Royal Baby")').image?)

    assert(!line('![]()').image?)
    assert(!line('![Royal Baby]()').image?)
    assert(!line('!(img/royal-baby)').image?)
    assert(!line('![]').image?)
  end

  ##
  # Test for fenced code blocks
  def test_fenced_code
    assert(line('```').fenced_code_end?)
    assert(line(' ```').fenced_code_end?)
    assert(line('``` ').fenced_code_end?)
    assert(line(' ``` ').fenced_code_end?)

    assert(!line('``').fenced_code_end?)
    assert(!line('````').fenced_code_end?)
    assert(!line('`').fenced_code_end?)
    assert(!line('``````').fenced_code_end?)
    assert(!line('x ```').fenced_code_end?)
    assert(!line('x```').fenced_code_end?)
    assert(!line('``` x').fenced_code_end?)
    assert(!line('```x').fenced_code_end?)
    assert(!line('x ``` x').fenced_code_end?)
    assert(!line('x```x').fenced_code_end?)

    assert(line('```java').fenced_code_start?)
    assert(line('```java{Example Program}').fenced_code_start?)
    assert(line('```java[1]{Example Program}').fenced_code_start?)
    assert(line('```java[1]').fenced_code_start?)

    assert_equal('java', line('```java').fenced_code_start)
    assert_equal('java', line('```java ').fenced_code_start)
    assert_equal('java', line('```java[1]').fenced_code_start)
    assert_equal('java', line('```java[1] ').fenced_code_start)

    assert_equal('java', line('```java{Example Program}').fenced_code_start)
    assert_equal('java', line('```java{Example Program} ').fenced_code_start)
    assert_equal('java', line('```java[1]{Example Program}').fenced_code_start)
    assert_equal('java', line('```java[1]{Example Program} ').fenced_code_start)

    assert_nil(line('```java').fenced_code_caption)
    assert_equal('Example Program', line('```java{Example Program}').fenced_code_caption)
    assert_equal('Example Program', line('```java{Example Program} ').fenced_code_caption)
    assert_equal('Example Program', line('```java[1]{Example Program}').fenced_code_caption)
    assert_equal('Example Program', line('```java[1]{Example Program} ').fenced_code_caption)

    assert(line('```java[1]{Example Program}').fenced_code_order?)
    assert_equal('1', line('```java[1]{Example Program}').fenced_code_order)

    assert(line('```java[1]').fenced_code_order?)
    assert_equal('1', line('```java[1]').fenced_code_order)

    assert(!line('```java').fenced_code_order?)
    assert(!line('```java{Example Program}').fenced_code_order?)
  end

  ##
  # Test skip mark for slides
  def test_skipped
    assert(line('--skip--').skipped_slide?)
    assert(line('# Examples --skip--').skipped_slide?)
    assert(line('## Examples --skip--').skipped_slide?)
    assert(line('--skip-- ').skipped_slide?)
    assert(line('# Examples --skip-- ').skipped_slide?)
    assert(line('## Examples --skip-- ').skipped_slide?)

    assert(!line('-- skip--').skipped_slide?)
    assert(!line('--skip --').skipped_slide?)
    assert(!line('-- skip --').skipped_slide?)
    assert(!line('-skip--').skipped_slide?)
    assert(!line('--skip-').skipped_slide?)
  end

  ##
  # Test for HTML script tags
  def test_script
    assert(line('<script>').script_start?)
    assert(line('  <script>').script_start?)
    assert(line('    <script>').script_start?)
    assert(line('<script>  ').script_start?)

    assert(!line('x <script>').script_start?)
    assert(!line('<script>x').script_start?)

    assert(line('</script>').script_end?)
    assert(line('  </script>').script_end?)
    assert(line('    </script>').script_end?)
    assert(line('</script>  ').script_end?)

    assert(!line('x </script>').script_end?)
    assert(!line('</script> x').script_end?)
  end

  ##
  # Test for equation marks
  def test_equation
    assert(line('\[').equation_start?)
    assert(line(' \[').equation_start?)
    assert(line('  \[').equation_start?)
    assert(line('\[ ').equation_start?)
    assert(line('\[  ').equation_start?)
    assert(line('    \[').equation_start?)

    assert(line('\]').equation_end?)
    assert(line(' \]').equation_end?)
    assert(line('  \]').equation_end?)
    assert(line('\] ').equation_end?)
    assert(line('    \]').equation_end?)

    assert(!line('x\[').equation_start?)
    assert(!line('x \[').equation_start?)
    assert(!line('\[ x').equation_start?)

    assert(!line('x\]').equation_end?)
    assert(!line('x \]').equation_end?)
    assert(!line('\] x').equation_end?)
  end

  ##
  # Test for comment separator
  def test_separator
    assert(line('---').separator?)
    assert(line('-----').separator?)

    assert(!line(' ---').separator?)
    assert(!line('  ---').separator?)
  end

  ##
  # Test for lists
  def test_lists
    assert(line('  * Item').ul1?)
    assert(line('  - Item').ul1?)
    assert(line('    * Item').ul2?)
    assert(line('    - Item').ul2?)
    assert(line('      * Item').ul3?)
    assert(line('      - Item').ul3?)

    assert_equal('Item 1', line('  * Item 1').ul1)
    assert_equal('Item 1', line('  - Item 1').ul1)
    assert_equal('Item 2', line('    * Item 2').ul2)
    assert_equal('Item 2', line('    - Item 2').ul2)
    assert_equal('Item 3', line('      * Item 3').ul3)
    assert_equal('Item 3', line('      - Item 3').ul3)

    assert(!line('  * Item').ul2?)
    assert(!line('  - Item').ul2?)
    assert(!line('    * Item').ul3?)
    assert(!line('    - Item').ul3?)
    assert(!line('      * Item').ul1?)
    assert(!line('      - Item').ul1?)

    assert(line('  1. Item').ol1?)
    assert(line('  11. Item').ol1?)
    assert(line('    1. Item').ol2?)
    assert(line('    11. Item').ol2?)
    assert(line('      1. Item').ol3?)
    assert(line('      11. Item').ol3?)

    assert_equal('Item 1', line('  1. Item 1').ol1)
    assert_equal('Item 1', line('  11. Item 1').ol1)
    assert_equal('Item 2', line('    1. Item 2').ol2)
    assert_equal('Item 2', line('    11. Item 2').ol2)
    assert_equal('Item 3', line('      1. Item 3').ol3)
    assert_equal('Item 3', line('      11. Item 3').ol3)

    assert_equal('1', line('  1. Item 1').ol1_number)
    assert_equal('11', line('  11. Item 1').ol1_number)
    assert_equal('1', line('    1. Item 2').ol2_number)
    assert_equal('11', line('    11. Item 2').ol2_number)
    assert_equal('1', line('      1. Item 3').ol3_number)
    assert_equal('11', line('      11. Item 3').ol3_number)
  end

  ##
  # Test titles
  def test_titles
    assert(line('## Slide Title').slide_title?)
    assert(line('  ## Slide Title').slide_title?)
    assert(line('## Slide Title ##').slide_title?)
    assert_equal('Slide Title', line('## Slide Title').slide_title)
    assert_equal('Slide Title', line('## Slide Title  ').slide_title)
    assert_equal('Slide Title', line('  ## Slide Title').slide_title)
    assert_equal('Slide Title', line('## Slide Title ##').slide_title)

    assert(line('# Chapter Title').chapter_title?)
    assert(line('  # Chapter Title').chapter_title)
    assert_equal('Chapter Title', line('# Chapter Title').chapter_title)
    assert_equal('Chapter Title', line('  # Chapter Title').chapter_title)
    assert_equal('Chapter Title', line('# Chapter Title ').chapter_title)
    assert_equal('Chapter Title', line('  # Chapter Title ').chapter_title)
    assert_equal('Chapter Title', line('# Chapter Title #').chapter_title)
    assert_equal('Chapter Title', line(' # Chapter Title # ').chapter_title)
  end

  ##
  # UML blocks
  def test_uml
    assert(line('@startuml').uml_start?)
    assert(line('@startuml[90%][20%]').uml_start?)
    assert(line('@startuml[20%]').uml_start?)

    assert_equal(%w(90% 90%), line('@startuml[90%]').uml_start)
    assert_equal(%w(90% 20%), line('@startuml[90%][20%]').uml_start)

    assert(line('@enduml').uml_end?)
  end

  ##
  # Source includes
  def test_include_src
    assert(line('!INCLUDESRC[4] "path/to/file"').code_include?)
    assert(line('!INCLUDESRC "path/to/file"').code_include?)
    assert(!line('!INCLUDESRC[4] path/to/file').code_include?)
    assert(!line('!INCLUDESRC path/to/file').code_include?)
    assert(line('!INCLUDESRC[4] "path/to/file" Java').code_include?)
    assert(line('!INCLUDESRC "path/to/file" Pascal').code_include?)
    assert(!line('!INCLUDESRC[4] path/to/file').code_include?)
    assert(!line('!INCLUDESRC path/to/file').code_include?)

    assert_equal("path/to/file", line('!INCLUDESRC[4] "path/to/file"').code_include[0])
    assert_equal(4, line('!INCLUDESRC[4] "path/to/file"').code_include[1])
    assert_equal("path/to/file", line('!INCLUDESRC "path/to/file"').code_include[0])
    assert_equal("path/to/file", line('!INCLUDESRC "path/to/file" Java').code_include[0])
    assert_equal(0, line('!INCLUDESRC "path/to/file" Java').code_include[1])
    assert_equal("Java", line('!INCLUDESRC "path/to/file" Java').code_include[2])
    assert_equal("path/to/file", line('!INCLUDESRC[4] "path/to/file" Java').code_include[0])
    assert_equal(4, line('!INCLUDESRC[4] "path/to/file" Java').code_include[1])
    assert_equal("Java", line('!INCLUDESRC[4] "path/to/file" Java').code_include[2])
  end

  ##
  # Multiple choice questions
  def test_multiple_choice
    assert(line("[ ] Frage 1").multiple_choice?)
    assert(line("[X] Frage 1").multiple_choice?)
    assert(line("[x] Frage 1").multiple_choice?)
    assert(line("[*] Frage 1").multiple_choice?)

    assert_equal("Frage 1", line("[ ] Frage 1").multiple_choice[2])
    assert_equal("Frage 1", line("[X] Frage 1").multiple_choice[2])
    assert_equal("Frage 1", line("[x] Frage 1").multiple_choice[2])
    assert_equal("Frage 1", line("[*] Frage 1").multiple_choice[2])

    assert_equal(false, line("[ ] Frage 1").multiple_choice[1])
    assert_equal(false, line("[X] Frage 1").multiple_choice[1])
    assert_equal(false, line("[x] Frage 1").multiple_choice[1])
    assert_equal(false, line("[*] Frage 1").multiple_choice[1])

    assert_equal(true, line("[ ]. Frage 1").multiple_choice[1])
    assert_equal(true, line("[X]. Frage 1").multiple_choice[1])
    assert_equal(true, line("[x]. Frage 1").multiple_choice[1])
    assert_equal(true, line("[*]. Frage 1").multiple_choice[1])

    assert_equal(false, line("[ ] Frage 1").multiple_choice[0])
    assert_equal(true, line("[X] Frage 1").multiple_choice[0])
    assert_equal(true, line("[x] Frage 1").multiple_choice[0])
    assert_equal(true, line("[*] Frage 1").multiple_choice[0])
  end

  ##
  # Test the other methods of the class
  def test_other_methods
    assert_equal('Testline', line('Testline').to_s)
    assert_equal('Testline', line('Testline').string)
    assert_equal('Testline'.length, line('Testline').length)
    assert_equal('tline', line('Testline').substr!(3))
    assert_equal('tline', line('Testline').substr!(3))
    assert_equal('int i = 7;', line('    int i = 7;').trim_code_prefix!)
  end
end
