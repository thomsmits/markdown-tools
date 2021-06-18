require 'minitest/autorun'
require_relative '../lib/render_helper'

class LineParsingAndRenderingTest < Minitest::Test
  def test_plain
    s = "A line with _em_ and *em* and __strong__ and **strong** plus `code`"
    result = markdown_to_html_line(s, 'java')
  end
end
