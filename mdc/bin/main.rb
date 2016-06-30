# -*- coding: utf-8 -*-

require_relative '../lib/parsing/properties_reader'
require_relative '../lib/parsing/parser'
require_relative '../lib/domain/presentation'
require_relative '../lib/rendering/renderer_html_presentation'
require_relative '../lib/rendering/renderer_html_plain'
require_relative '../lib/rendering/renderer_latex_presentation'
require_relative '../lib/rendering/renderer_latex_plain'
require 'stringio'

$project_path = ''

class Main

  def self.main(directory, type, output_file)

    # Determine my own directory to make invocation of the UML tool
    # more dynamic
    $project_path = File.expand_path($0).gsub('\\', '/').gsub('/mdc/bin/main.rb', '')

    # Read global properties
    dir = Dir.new(directory)
    prop_file = directory + '/metadata.properties'

    defaults_file = directory + '/..' + '/metadata.properties'

    props = Parsing::PropertiesReader.new(prop_file, '=', defaults_file)

    title1           = props.title_1
    title2           = props.title_2
    chapter_no       = props.chapter_no
    chapter_name     = props.chapter_name
    copyright        = props.copyright
    author           = props.author
    default_syntax   = props.default_syntax
    image_dir        = props.image_dir
    temp_dir         = props.temp_dir
    description      = props.description
    term             = props.term
    slide_language   = props.language

    if slide_language == 'DE'
      $messages = LOCALIZED_MESSAGES_DE
    elsif slide_language == 'EN'
      $messages = LOCALIZED_MESSAGES_EN
    end

    image_dir = image_dir.sub(/\/$/, '')  unless image_dir.nil?
    temp_dir  = temp_dir.sub(/\/$/, '')   unless temp_dir.nil?

    result_dir = File.dirname(output_file)

    # Scan files matching the pattern 01_...
    files = [ ]

    dir.each { |file| files << file  if /[0-9][0-9]_.*\.md/ === file }

    files = files.sort

    puts "Directory: #{directory}"
    puts "Type: #{type}"

    p = Parsing::Parser.new(Constants::PAGES_FRONT_MATTER)
    pres = Domain::Presentation.new(title1, title2, chapter_no, chapter_name,
        copyright, author, default_syntax, description, term)

    # Parse files in directory
    files.each { |file|
      puts "Parsing: #{file}"
      p.parse(directory + '/' + file, default_syntax, pres)
    }

    io = StringIO.new
    io.set_encoding('UTF-8')

    r = case type
      when 'slide' then Rendering::RendererHTMLPresentation.new(io, default_syntax, result_dir, image_dir, temp_dir)
      when 'plain' then Rendering::RendererHTMLPlain.new(io, default_syntax, result_dir, image_dir, temp_dir)
      when 'tex-slide' then Rendering::RendererLatexPresentation.new(io, default_syntax, result_dir, image_dir, temp_dir)
      when 'tex-plain' then Rendering::RendererLatexPlain.new(io, default_syntax, result_dir, image_dir, temp_dir)
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
