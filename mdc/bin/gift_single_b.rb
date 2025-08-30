#!/usr/bin/env ruby
require_relative 'custom_handler'
require_relative '../lib/rendering/renderer_gift'
require_relative 'master_file'
require_relative '../lib/domain/questions/matching_questions'
require_relative '../lib/domain/questions/multiple_choice_questions'
require_relative '../lib/domain/questions/input_question'


##
# Parse a Markdown snippet of an exam question and render
# it in the Moodle GIFT format.
class GiftSingle

  ##
  # Parse lines containing a markdown file and return the rendered result.
  # @param [String] src_dir directory with source files
  # @param [String] dest_dir target directory
  # @param [String] prog_language the default programming language
  # @param [String] renderer_class name of class used for rendering
  # @param [Array<String>] lines text to be parsed
  # @param [String] input_file name of the input file
  # @return [String] the rendered contents as string
  def self.parse_file_and_produce_gift(prog_language = 'java', input_file = '')
    target_name = input_file.gsub('.md', '.txt')
    CustomHandler.convert_file('/', '/', input_file, target_name, prog_language,
                               'Rendering::RendererGIFT')
  end
end

if $PROGRAM_NAME == __FILE__
  file = ARGV[0]

  unless File.exist?(file)
    puts "File #{file} does not exist"
    exit(1)
  end
  GiftSingle.parse_file_and_produce_gift('java', file)
end
