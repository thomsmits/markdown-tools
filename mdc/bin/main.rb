# -*- coding: utf-8 -*-

require_relative '../lib/parsing/properties_reader'
require_relative '../lib/parsing/parser'
require_relative '../lib/domain/presentation'
require_relative '../lib/rendering/renderer_html_presentation'
require_relative '../lib/rendering/renderer_html_plain'
require_relative '../lib/rendering/renderer_latex_presentation'
require_relative '../lib/rendering/renderer_latex_plain'
require 'stringio'

class Main

  def self.main(directory, type, output_file)

    # Read global properties
    dir = Dir.new(directory)
    prop_file = directory + '/metadata.properties'

    defaults_file = directory + '/..' + '/metadata.properties'

    props = Parsing::PropertiesReader.new(prop_file, '=', defaults_file)

    title1 = props.get('title_1')
    title2 = props.get('title_2')
    chapter_no = props.get('chapter_no')
    chapter_name = props.get('chapter_name')
    copyright = props.get('copyright')
    author = props.get('author')
    default_language = props.get('default_language')
    image_dir = props.get('image_dir')
    temp_dir = props.get('temp_dir')
    description = props.get('description')
    term = props.get('term')

    image_dir = image_dir.sub(/\/$/, '')  unless image_dir.nil?
    temp_dir  = temp_dir.sub(/\/$/, '')   unless image_dir.nil?

    result_dir = File.dirname(output_file)

    # Scan files matching the pattern 01_...
    files = [ ]

    dir.each { |file| files << file  if /[0-9][0-9]_.*\.md/ === file }

    files.sort

    puts "Directory: #{directory}"
    puts "Type: #{type}"

    p = Parsing::Parser.new(Constants::PAGES_FRONT_MATTER)
    pres = Domain::Presentation.new(title1, title2, chapter_no, chapter_name,
        copyright, author, default_language, description, term)

    # Parse files in directory
    files.each { |file|
      puts "Parsing: #{file}"
      p.parse(directory + '/' + file, default_language, pres)
    }

    io = StringIO.new
    io.set_encoding('UTF-8')

    r = case type
      when 'slide' then Rendering::RendererHTMLPresentation.new(io, default_language, result_dir, image_dir, temp_dir)
      when 'plain' then Rendering::RendererHTMLPlain.new(io, default_language, result_dir, image_dir, temp_dir)
      when 'tex-slide' then Rendering::RendererLatexPresentation.new(io, default_language, result_dir, image_dir, temp_dir)
      when 'tex-plain' then Rendering::RendererLatexPlain.new(io, default_language, result_dir, image_dir, temp_dir)
      else
        puts "Unknown type #{type} for result"
        exit 5
    end

    puts "Result written to: #{output_file}"

    pres.render(r)

    File.open(output_file, 'w', :encoding => 'UTF-8') { |f| f << io.string }
  end
end

Main::main(ARGV[0], ARGV[1], ARGV[2])

#Main::main('/Users/thomas/Documents/Work/Vorlesungen/GDI/03_Folien/src/06_oo', 'tex-plain', '/Users/thomas/Temp/06_oo/06_oo.tex')
