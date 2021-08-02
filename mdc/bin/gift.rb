#!/usr/bin/env ruby
require_relative 'custom_handler'
require_relative '../lib/rendering/renderer_gift'
require_relative 'master_file'
require_relative '../lib/domain/matching_questions'
require_relative '../lib/domain/multiple_choice_questions'
require_relative '../lib/domain/input_question'

##
# Parse a Markdown snippet of an exam question and render
# it in the Moodle GIFT format.
# This covers a very special use case. For more generic use cases
# use the fle `main.rb`
class GIFT

  ##
  # Parse a whole directory of files.
  # @param [String] src_dir directory with source files
  # @param [String] dest_dir directory to store results in
  # @param [String] language default programming language
  def self.parse_directory_and_render(src_dir, dest_dir, prog_lang = '')

    # Get all files in the directory
    files = Dir.new(src_dir).entries.select { |f| (/^.*\.md$/ =~ f) }

    files.each do |file|
      target_name = file.gsub('.md', '.txt')
      CustomHandler.convert_file(src_dir, dest_dir, file, target_name, prog_lang,
                                 'Rendering::RendererGIFT')
    end
  end

  ##
  # Parse lines containing a markdown file and return the rendered result.
  # @param [String] src_dir directory with source files
  # @param [String] dest_dir target directory
  # @param [String] prog_language the default programming language
  # @param [String] renderer_class name of class used for rendering
  # @param [Array<String>] lines text to be parsed
  # @param [String] input_file name of the input file
  # @return [String] the rendered contents as string
  def self.parse_file_and_render(src_dir, dest_dir, prog_language, lines, input_file = '')
    CustomHandler.convert_stream(src_dir, dest_dir, prog_language,
                                 'Rendering::RendererGIFT', lines, input_file)  do |presentation|

      # Ensure that every exercise is at least an input question
      exercise = presentation.chapters[0].slides[0]
      question_found = exercise.elements.filter { |e|
        [ Domain::MultipleChoiceQuestions, Domain::InputQuestion, Domain::MatchingQuestions ].include?(e.class)
      }.length > 0

      unless question_found
        exercise << Domain::InputQuestion.new([])
      end
    end
  end

  ##
  # Create a moodle GIFT file from a single master, control file
  # @param [String] input_file the control file
  # @param [String] section_prefix additional hierarchy to separate exercises
  def self.from_master_file(input_file, desired_status = ['+'], section_prefix = '')

    base_dir = File.dirname(input_file) + "/"

    master_file = MasterFile.parse(input_file, desired_status, false)

    master_file.each_section do |section|

      title = section.title.gsub('Themenbereich: ', '')

      if section.has_entries
        puts "$CATEGORY: $course$/#{section_prefix}#{title}\n\n"
      end

      section.each_entry do |e|
        next if e.path.nil?

        filename = e.path
        unless File.exist?(filename)
          filename = filename + ".md"
        end

        lines = File.readlines(filename)
        puts "// GIFT generated from file #{filename.gsub(base_dir, '')}"
        puts GIFT.parse_file_and_render(File.dirname(filename), '', '', lines)
        puts ""
      end
    end
  end
end

if $0 == __FILE__
  file = ARGV[0]

  unless File.exist?(file)
    puts "File #{file} does not exist"
    exit(1)
  end

  prefix = if ARGV.length > 2 then ARGV[2] else '' end
  desired_status = [ ARGV[1] ]
  GIFT.from_master_file(file, desired_status, prefix)
end
