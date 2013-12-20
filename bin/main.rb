# -*- coding: utf-8 -*-

require_relative '../lib/parsing/properties_reader'
require_relative '../lib/parsing/parser'
require_relative '../lib/domain/presentation'
require_relative '../lib/rendering/renderer_html_presentation'
require_relative '../lib/rendering/renderer_html_plain'
require_relative '../lib/rendering/renderer_latex'
require 'stringio'

class Main

  def self.main(directory, type, output)

    dir = Dir.new(directory)
    prop_file = directory + '/metadata.properties'
    props = Parsing::PropertiesReader.new(prop_file)

    title1 = props.get('title_1')
    title2 = props.get('title_2')
    chapter_no = props.get('chapter_no')
    chapter_name = props.get('chapter_name')
    copyright = props.get('copyright')
    author = props.get('author')
    default_language = props.get('default_language')

    files = [ ]

    dir.each { |file|
      files << file  if /[0-9][0-9]_.*\.md/ =~ file
    }

    files.sort

    puts "Directory: #{directory}"
    puts "Type: #{type}"

    p = Parsing::Parser.new
    pres = Domain::Presentation.new(title1, title2, chapter_no, chapter_name,
        copyright, author, default_language)

    files.each { |file|

      puts "Parsing: #{file}"
      p.parse(directory + '/' + file, default_language, pres)
    }

    puts "Result written to: #{output}"

    io = StringIO.new

    if type == 'slide'
      r = Rendering::RendererHTMLPresentation.new(io, default_language)
    elsif type == 'plain'
      r = Rendering::RendererHTMLPlain.new(io, default_language)
    elsif type == 'tex'
      r = Rendering::RendererLatex.new(io, default_language)
    end

    pres.render(r)

    File.open(output, 'w') { |f|
      f << io.string
    }
  end
end

Main::main(ARGV[0], ARGV[1], ARGV[2])