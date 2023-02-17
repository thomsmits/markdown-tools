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
require_relative '../lib/rendering/renderer_jekyll'

$project_path = ''

##
# Main entry point into the markdown compiler.
# The +self.main+ method is called with the command
# line parameters.
class Main

  def self.check_element(container)
    result = false
    container.each do |element|
      if element.is_a?(Domain::Comment)
        result |= check_element(element)
      end
      if element.is_a?(Domain::Equation)
        return true
      end
      if element.to_s =~ /\\\[(.*?)\\\]/
        return true
      end
    end
    result
  end

  def self.has_equation(chapters)
    chapters.each do |chapter|
      chapter.each do |slides|
        slides.each do |slide|
          return true if check_element(slide)
        end
      end
    end
    false
  end

  def self.main(directory, result_dir)

    # Determine my own directory to make invocation of the UML tool
    # more dynamic
    $project_path = File.expand_path($PROGRAM_NAME)
                        .tr('\\', '/')
                        .gsub('/mdc/bin/jekyll.rb', '')

    # Read global properties
    dir = Dir.new(directory)
    prop_file = directory + '/metadata.properties'

    # Determine the chapter number from the directory
    if /([0-9][0-9])_.*/ =~ File.basename(File.expand_path(directory))
      chapter_no_from_file = $1.to_i
    else
      chapter_no_from_file = nil
    end

    defaults_file = directory + '/..' + '/metadata.properties'

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

    # Scan files matching the pattern 01_...
    files = []

    dir.each { |file| files << file if /[0-9][0-9]_.*\.md/ =~ file }

    files = files.sort

    puts "Directory: #{directory}"

    chapters = []

    # Parse files in directory and render result
    files.each_with_index do |file, nav_order|
      parser = Parsing::Parser.new(Constants::PAGES_FRONT_MATTER)
      presentation = Domain::Presentation.new(
        slide_language, title1, title2, chapter_no, chapter_name,
        copyright, author, default_syntax, description,
        term, create_index, bibliography
      )

      chapters << presentation.chapters
      puts "Parsing: #{file}"
      parser.parse(directory + '/' + file, default_syntax, presentation)
      parser.second_pass(presentation)

      has_equation = has_equation(chapters)

      io = StringIO.new
      io.set_encoding('UTF-8')

      output_file = result_dir + "/" + File.basename(file, ".md") +  ".markdown"

      renderer = Rendering::RendererJekyll.new(
                     io, default_syntax, result_dir,
                     image_dir, temp_dir, nav_order + 1, has_equation)

      puts "Result written to: #{output_file}"

      presentation >> renderer

      File.open(output_file, 'w', encoding: 'UTF-8') { |f| f << io.string }
    end

    # Write index file
    File.open(result_dir + "/" + "index.markdown", 'w', encoding: 'UTF-8') do |f|
      f << "---\n"
      f << "title: \"#{chapter_name}\"\n"
      f << "layout: default\n"
      f << "has_children: true\n"
      f << "has_toc: true\n"
      f << "nav_order: #{chapter_no}\n"
      f << "---\n"
      f << "\n"
      f << "# #{chapter_name}\n"
    end

    # Write welcome file
    File.open(result_dir + "/../" + "index.markdown", 'w', encoding: 'UTF-8') do |f|
      nl = "\n"
      f << %Q|---| << nl
      f << %Q|layout: home| << nl
      f << %Q|---| << nl
      f << %Q|| << nl
      f << %Q|<div class="text-purple-200 fs-6 fw-700">#{title1}</div>| << nl
      f << %Q|<div class="fs-4 fw-700">#{title2}</div>| << nl
      f << %Q|<div>#{term}</div>| << nl
      f << %Q|<div class="fs-3 fw-300">Stand: #{Time.new.strftime("%d.%m.%Y")}</div>| << nl
      #f << %Q|<br>| << nl
      #f << %Q|<div class="fs-4 fw-500">#{copyright}</div>| << nl
      f << %Q|<br>| << nl
      f << %Q|<div class="text-grey-dk-000 fs-2 fw-300">#{description}</div>| << nl
    end
  end
end

Main.main(ARGV[0], ARGV[1])

# Main::main('/Users/thomas/Documents/Work/Vorlesungen/GDI/03_Folien/src/06_oo',
# 'tex-plain', '/Users/thomas/Temp/06_oo/06_oo.tex')
