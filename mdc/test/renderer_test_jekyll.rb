require 'minitest/autorun'
require_relative '../lib/rendering/renderer'
require_relative '../lib/rendering/renderer_jekyll'
require_relative '../lib/rendering/line_renderer'
require_relative '../lib/parsing/parser'
require_relative 'renderer_test_base'

##
# Test the parser
#
class RendererTestJekyll < RendererTestBase

  ##
  # Determine the base path of this file.
  # @return [String] path pointing to this file
  def base_path
    "#{File.dirname(__FILE__)}/#{File.basename(__FILE__, '.*')}/"
  end

  ##
  # Perform the test for all the files in our test directory.
  def test_all
    renderer = Rendering::RendererJekyll.new(nil, 'Java', '', '', '/tmp', 0, false)
    execute_all(renderer)
  end
end

