#!/usr/bin/env ruby
require 'stringio'
require 'tmpdir'

require_relative '../lib/messages'
require_relative '../lib/parsing/properties_reader'
require_relative '../lib/parsing/parser'
require_relative '../lib/domain/presentation'
require_relative '../lib/rendering/renderer_html_presentation'
require_relative '../lib/rendering/renderer_html_plain'
require_relative '../lib/rendering/renderer_latex_presentation'
require_relative '../lib/rendering/renderer_latex_plain'

$project_path = ''

##
# Main entry point into the markdown compiler.
# The +self.main+ method is called with the command
# line parameters.
class Main

  ##
  # Main entry point.
  # @param [String] directory Directory with the files to be parsed
  # @param [String] type Type of output generated
  # @param [String] output_file File to write results into
  def self.main(directory, type, output_file)
    # Determine my own directory to make invocation of the UML tool
    # more dynamic
    $project_path = File.expand_path($PROGRAM_NAME)
                        .tr('\\', '/')
                        .gsub('/mdc/bin/main.rb', '')

    # Read global properties
    dir = Dir.new(directory)
    prop_file = "#{directory}/metadata.properties"

    # Determine the chapter number from the directory
    chapter_no_from_file = if /([0-9][0-9])_.*/ =~ directory
                             Regexp.last_match(1).to_i
                           else
                             nil
                           end

    defaults_file = "#{directory}/../metadata.properties"

    props = Parsing::PropertiesReader.new(prop_file, '=', defaults_file)

    title1           = props['title_1']
    title2           = props['title_2']
    chapter_no       = props['chapter_no'] || chapter_no_from_file
    chapter_name     = props['chapter_name']
    copyright        = props['copyright']
    author           = props['author']
    default_syntax   = props['default_syntax']
    image_dir        = props['image_dir']
    temp_dir         = props['temp_dir']
    description      = props['description']
    term             = props['term']
    slide_language   = props['language']
    bibliography     = props['bibliography']
    create_index     = (props['create_index'] || 'false') == 'true'

    temp_dir ||= Dir.tmpdir
    slide_language ||= 'DE'

    set_language(slide_language.downcase)

    image_dir = image_dir.sub(%r{/$}, '')  unless image_dir.nil?
    temp_dir  = temp_dir.sub(%r{/$}, '')   unless temp_dir.nil?

    result_dir = File.dirname(output_file)

    # Scan files matching the pattern 01_...
    files = []

    dir.each { |file| files << file if /[0-9][0-9]_.*\.md/ =~ file }

    files = files.sort

    puts "Directory: #{directory}"
    puts "Type: #{type}"

    parser = Parsing::Parser.new(Constants::PAGES_FRONT_MATTER)
    presentation = Domain::Presentation.new(
      slide_language, title1, title2, chapter_no, chapter_name,
      copyright, author, default_syntax, description,
      term, create_index, bibliography
    )

    # Parse files in directory
    files.each do |file|
      puts "Parsing: #{file}"
      parser.parse("#{directory}/#{file}", default_syntax, presentation)
      parser.second_pass(presentation)
    end

    io = StringIO.new
    io.set_encoding('UTF-8')

    renderer = case type
               when 'slide' then
                 Rendering::RendererHTMLPresentation.new(
                   io, default_syntax, result_dir,
                   image_dir, temp_dir
                 )
               when 'plain' then
                 Rendering::RendererHTMLPlain.new(
                   io, default_syntax, result_dir,
                   image_dir, temp_dir
                 )
               when 'tex-slide' then
                 Rendering::RendererLatexPresentation.new(
                   io, default_syntax, result_dir,
                   image_dir, temp_dir
                 )
               when 'tex-plain' then
                 Rendering::RendererLatexPlain.new(
                   io, default_syntax, result_dir,
                   image_dir, temp_dir
                 )
               else
                 puts "Unknown type #{type} for result"
                 exit 5
               end

    puts "Result written to: #{output_file}"

    presentation >> renderer

    File.open(output_file, 'w', encoding: 'UTF-8') { |f| f << io.string }
  end
end

Main.main(ARGV[0], ARGV[1], ARGV[2])

