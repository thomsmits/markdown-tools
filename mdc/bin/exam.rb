require_relative 'custom_handler'
require_relative '../lib/rendering/renderer_latex_exam'

##
# Create TeX snippets to be used in an exam from Markdown files.
# This covers a very special use case. For more generic use cases
# use the fle `main.rb`
class Exam
  ##
  # Main entry point
  # @param [String] src_dir directory with source files
  # @param [String] dest_dir directory to store results in
  # @param [String] prog_lang default programming language
  def self.main(src_dir, dest_dir, prog_lang = '')
    # Get all files in the directory
    files = Dir.new(src_dir).entries.select { |f| (/^.*\.md$/ =~ f) }

    files.each do |file|
      target_name = file.gsub('.md', '.tex')
      CustomHandler.convert_file(src_dir, dest_dir, file, target_name, prog_lang,
                                 'Rendering::RendererLatexExam')
    end
  end

  ##
  # Parse lines containing a markdown file and return the rendered result.
  # @param [String] src_dir directory with source files
  # @param [String] dest_dir target directory
  # @param [String] prog_lang the default programming language
  # @param [String] renderer_class name of class used for rendering
  # @param [Array<String>] lines text to be parsed
  # @return [String] String the rendered contents as
  def self.parse_file_and_render(src_dir, dest_dir, prog_lang, lines)
    CustomHandler.convert_stream(src_dir, dest_dir, prog_lang,
                                 'Rendering::RendererLatexExam', lines)
  end
end

Exam.main(ARGV[0], ARGV[1], ARGV[2]) if $PROGRAM_NAME == __FILE__
