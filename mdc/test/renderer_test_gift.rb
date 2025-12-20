require 'minitest/autorun'
require_relative '../lib/domain/presentation'
require_relative '../lib/parsing/parser'
require_relative '../lib/rendering/renderer_gift'
require_relative 'renderer_test_base'

class GiftRendererTest < RendererTestBase

  ##
  # Determine the base path of this file.
  # @return [String] path pointing to this file
  def base_path
    File.dirname(__FILE__) + "/" + File.basename(__FILE__, ".*") + "/"
  end

  ##
  # Perform the test for all the files in our test directory.
  def test_all
    renderer = Rendering::RendererGIFT.new(nil, 'DE', '/tmp', '.', '/tmp')

    execute_for_all_files(base_path) do |md_name|
      gift_name = md_name.gsub(".md", ".txt")
      md = File.read(base_path + md_name)
      gift = File.read(base_path + gift_name)
      result = parse_and_render(md, renderer, "# Title")
      assert_equal(gift.strip, result.strip, "Error in file #{md_name}")
    end
  end
end
