require 'stringio'

require_relative 'custom_handler'
require_relative '../lib/parsing/properties_reader'
require_relative '../lib/parsing/parser'
require_relative '../lib/domain/presentation'
require_relative '../lib/rendering/renderer_latex_assignment'

##
# Create TeX snippets form Markdown files for assignments.
# This covers a very special use case. For more generic use cases
# use the fle `main.rb`
class Assignment
  ##
  # Parse lines containing a markdown file and return the rendered result.
  # @param [String] src_dir directory with source files
  # @param [String] dest_dir target directory
  # @param [String] prog_language the default programming language
  # @param [String] renderer_class name of class used for rendering
  # @param [Array<String>] lines text to be parsed
  # @return [String] the rendered contents as string
  def self.parse_file_and_render(src_dir, dest_dir, prog_language, lines)
    CustomHandler.convert_stream(src_dir, dest_dir, prog_language,
                                 'Rendering::RendererLatexAssignment', lines)
  end

  ##
  # Parse a whole directory of files.
  # @param [String] src_dir directory with source files
  # @param [String] dest_dir directory to store results in
  # @param [String] language default programming language
  def self.parse_directory_and_render(src_dir, dest_dir, language = '')

    # Get all files in the directory
    files = Dir.new(src_dir).entries.select { |f| (/^.*\.md$/ =~ f) }

    files.each do |file|
      target_name = file.gsub('.md', '.tex')
      CustomHandler.convert_file(src_dir, dest_dir, file, target_name, language,
                                 'Rendering::RendererLatexAssignment')
    end
  end
end

if $0 == __FILE__
  # Get and remove command line arguments
  src_dir = ARGV.shift
  dest_dir = ARGV.shift

  if ARGV.size.zero?
    # Only directories given. Compile whole directory
    puts Assignment.parse_directory_and_render(src_dir, dest_dir)
  else
    # More data given, compile single file
    prog_language = ARGV.shift

    # With an empty ARGV, ARGF will read from STDIN
    # otherwise it will open all files ARGV is containing anc
    #  concatenate them
    lines = ARGF.readlines

    puts Assignment.parse_file_and_render(src_dir, dest_dir, prog_language, lines)
  end
end
