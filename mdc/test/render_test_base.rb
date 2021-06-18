require 'minitest/autorun'
require 'stringio'
require_relative '../lib/domain/presentation'
require_relative '../lib/parsing/parser'
require_relative '../lib/parsing/parser_handler'

##
# Base class for renderer tests.
class RenderTestBase < Minitest::Test

  ##
  # Determine the base path of this file.
  # @return [String] path pointing to this file
  def base_path
    raise RuntimeError.new("Overwrite this method!")
  end

  ##
  # Execute the test given block for all files with
  # the extension in the given directory.
  # @param [String] dir directory to scan
  # @param [Regexp] extension file extension as regular expression
  # @param [Proc] block test to execute
  def execute_for_all_files(dir, extension = /.*\.md/, &block)
    files = Dir.entries(dir)
    files.filter! { |f| extension =~ f }
    files.sort!

    files.each do |md_name|
      block.call(md_name)
    end
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

  ##
  # Parse the given input and render it.
  # @param [String] input content to be parsed and rendered
  # @param [Rendering::Renderer] renderer renderer to use for the rendering
  # @param [String] prepend a text to place before input, e.g. the '# Chapter'
  def parse_and_render(input, renderer, prepend = '')
    presentation = Domain::Presentation.new('DE', 'Title1', 'Title2', 3, 'Section 3', '(c) 2014',
                                            'Thomas Smits', 'java', 'Test Presentation', 'WS2014',
                                            false, nil)

    parser = Parsing::Parser.new(5, Parsing::ParserHandler.new(true))
    lines = lines(input)
    lines.prepend(prepend)
    parser.parse_lines(lines, 'testfile.md', 'java', presentation)
    parser.second_pass(presentation)

    output = StringIO.new

    renderer.io = output
    presentation >> renderer
    output.string
  end
end