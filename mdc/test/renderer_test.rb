require 'minitest/autorun'
require_relative '../lib/rendering/renderer'
require_relative '../lib/rendering/line_renderer'
require_relative '../lib/parsing/parser'
require_relative 'render_test_base'

##
# Test the parser
#
class RendererTest < RenderTestBase

  ##
  # Determine the base path of this file.
  # @return [String] path pointing to this file
  def base_path
    File.dirname(__FILE__) + "/" + File.basename(__FILE__, ".*") + "/"
  end

  ##
  # Perform the test for all the files in our test directory.
  def test_all
    renderer = Rendering::Renderer.new(nil, Rendering::LineRenderer.new('java'), 'DE', '/tmp', '.', '/tmp')

    execute_for_all_files(base_path) do |md_name|
      md = File.read(base_path + md_name)

      result_file = base_path + File.basename(md_name, ".*") + ".expected"
      result = parse_and_render(md, renderer).gsub("\n", "").gsub(' ', '')

      expected = if File.exist?(result_file)
                   File.read(result_file)
                 else
                   md
                 end

      assert_equal(expected.gsub("\n", "").gsub(' ', ''), result, "Error in file #{md_name}")
    end
  end
end
