require 'minitest/autorun'
require_relative '../lib/domain/presentation'
require_relative '../lib/parsing/parser'
require_relative '../lib/parsing/gift_parser'
require_relative '../lib/rendering/renderer_gift'

require_relative 'renderer_test_base'

class GiftRendererTest < RendererTestBase

  ##
  # Determine the base path of this file.
  # @return [String] path pointing to this file
  def base_path
    File.dirname(__FILE__) + '/' + File.basename(__FILE__, '.*') + '/'
  end

  ##
  # Perform the test for all the files in our test directory.
  def test_all
    return
    renderer = Rendering::RendererGIFT.new(nil, 'DE', '/tmp', '.', '/tmp')

    execute_for_all_files(base_path, /.*\.txt/) do |gift_name|
    input = File.read(base_path + gift_name)
    parser = Parsing::GiftParser.new
    renderer = Rendering::RendererGIFT.new(parser, 'DE', '/tmp', '.', '/tmp')
    presentation = Domain::Presentation.new('DE', 'Title1', 'Title2', 3, 'Section 3', '(c) 2014',
                                            'Thomas Smits', 'java', 'Test Presentation', 'WS2014',
                                            false, nil, nil)

    lines = lines(input)
    parser.parse_lines(lines, 'testfile.md', 'java', presentation)
    parser.second_pass(presentation)

    output = StringIO.new

    renderer.io = output
    presentation >> renderer
    assert_equal(input.strip, output.string.strip, "Error in file #{gift_name}")
    end
  end
end
