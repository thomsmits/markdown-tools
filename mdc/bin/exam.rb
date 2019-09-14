require_relative 'custom_handler'
require_relative '../lib/rendering/renderer_latex_exam'

##
# Create TeX snippets to be used in an exam from Markdown files.
# This covers a very special use case. For more generic use cases
# use the fle `main.rb`
class Exam
  ##
  # Main entry point
  # @param src_dir String directory with source files
  # @param dest_dir String directory to store results in
  # @param language String default programming language
  def self.main(src_dir, dest_dir, language = '')

    # Get all files in the directory
    files = Dir.new(src_dir).entries.select { |f| (/^.*\.md$/ =~ f) }

    files.each do |file|
      target_name = file.gsub('.md', '.tex')
      CustomHandler.convert_file(src_dir, dest_dir, file, target_name, language,
                                 'Rendering::RendererLatexExam')
    end
  end
end

Exam.main(ARGV[0], ARGV[1], ARGV[2])
