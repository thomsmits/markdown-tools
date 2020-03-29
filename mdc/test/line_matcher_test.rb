require 'minitest/autorun'
require_relative '../lib/parsing/line_matcher'
require_relative '../lib/domain/footnote'
require_relative '../lib/domain/html'
require_relative '../lib/domain/heading'
require_relative '../lib/domain/image'

include Domain

##
# Test class for the MarkdownLine class
class LineMatcherTest < Minitest::Test

  ##
  # Test the detection of footnotes
  def test_footnote
    assert_instance_of(Footnote, Parsing::LineMatcher.match('[^1]: Footnote text', ''))
    assert_instance_of(Footnote, Parsing::LineMatcher.match('[^bla]: Footnote text', ''))
    assert_nil(Parsing::LineMatcher.match('[1]: Footnote text', ''))
    assert_nil(Parsing::LineMatcher.match('[bla]: Footnote text', ''))
  end

  ##
  # Test detection of HTML inserts
  def test_html
    assert_instance_of(HTML, Parsing::LineMatcher.match('<a>', ''))
    assert_instance_of(HTML, Parsing::LineMatcher.match('<a href="bla">', ''))
    assert_instance_of(HTML, Parsing::LineMatcher.match('<br>', ''))
    assert_instance_of(HTML, Parsing::LineMatcher.match('<br/>', ''))
  end

  ##
  # Test detection of headings
  def test_heading
    assert_instance_of(Heading, Parsing::LineMatcher.match('##### Heading 5', ''))
    assert_instance_of(Heading, Parsing::LineMatcher.match('#### Heading 4', ''))
    assert_instance_of(Heading, Parsing::LineMatcher.match('### Heading 3', ''))

    assert_equal(5, Parsing::LineMatcher.match('##### Heading 5', '').level)
    assert_equal(4, Parsing::LineMatcher.match('#### Heading 4', '').level)
    assert_equal(3, Parsing::LineMatcher.match('### Heading 3', '').level)

    assert_equal('Heading 5', Parsing::LineMatcher.match('##### Heading 5', '').title)
    assert_equal('Heading 4', Parsing::LineMatcher.match('#### Heading 4', '').title)
    assert_equal('Heading 3', Parsing::LineMatcher.match('### Heading 3', '').title)
  end

  ##
  # Helper function for test of images
  def img(text, alt, location, title, width1, width2)
    # @type [Domsin::Image]
    img = Parsing::LineMatcher.match(text, '')
    assert_instance_of(Image, img)
    assert_equal(alt, img.alt) if alt
    assert_equal(location, img.location)
    assert_equal(title, img.title) if title
    assert_equal(width1, img.width_slide) if width1
    assert_equal(width2, img.width_plain) if width2
  end

  ##
  # Test images
  def test_img
    img('![](img/file.png)/10%//30%/', nil, 'img/file.png', nil, '10%', '30%')
    img('![](img/file.png)/10%/', nil, 'img/file.png', nil, '10%', nil)
    img('![](img/file.png)', nil, 'img/file.png', nil, nil, nil)
    img('![](img/file.png)/10%//0%/', nil, 'img/file.png', nil, '10%', '0%')
    img('![](img/file.png)/10%//0/', nil, 'img/file.png', nil, '10%', '0')
    img('![](img/file.png "Title of image")/10%//30%/', nil, 'img/file.png', 'Title of image', '10%', '30%')
    img('![](img/file.png "Title of image")/10%/', nil, 'img/file.png', 'Title of image', '10%', nil)
    img('![](img/file.png "Title of image")', nil, 'img/file.png', 'Title of image', nil, nil)
    img('![Alt title of image](img/file.png)/10%//30%/', 'Alt title of image', 'img/file.png', nil, '10%', '30%')
    img('![Alt title of image](img/file.png)/10%/', 'Alt title of image', 'img/file.png', nil, '10%', nil)
    img('![Alt title of image](img/file.png)', 'Alt title of image', 'img/file.png', nil, nil, nil)
    img('![Alt title of image](img/file.png)<!-- /10%//30%/ -->', 'Alt title of image', 'img/file.png', nil, '10%', '30%')
    img('![Alt title of image](img/file.png)<!-- /10%/ -->', 'Alt title of image', 'img/file.png', nil, '10%', nil)
    img('![Alt title of image](img/file.png)', 'Alt title of image', 'img/file.png', nil, nil, nil)
    img('![Alt title of image](img/file.png "Title of image")/10%//30%/', 'Alt title of image', 'img/file.png', 'Title of image', '10%', '30%')
    img('![Alt title of image](img/file.png "Title of image")/10%/', 'Alt title of image', 'img/file.png', 'Title of image', '10%', nil)
    img('![Alt title of image](img/file.png "Title of image")', 'Alt title of image', 'img/file.png', 'Title of image', nil, nil)
    img('![Alt title of image](img/file.png "Title of image")<!-- /10%//30%/ -->', 'Alt title of image', 'img/file.png', 'Title of image', '10%', '30%')
    img('![Alt title of image](img/file.png "Title of image")<!-- /10%/ -->', 'Alt title of image', 'img/file.png', 'Title of image', '10%', nil)
    img('![Alt title of image](img/file.png "Title of image")', 'Alt title of image', 'img/file.png', 'Title of image', nil, nil)
  end
end