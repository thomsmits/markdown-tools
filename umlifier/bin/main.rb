#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require_relative '../lib/parsing/parser'
require_relative '../lib/rendering/renderer_dot'
require_relative '../lib/domain/diagram'

require 'stringio'
require 'fileutils'

class Main

  def self.main(input_file, dot_file, output_file, type = 'pdf')

    if !input_file || !dot_file || !output_file
      puts "Usage: inputfile dotfile outputfile"
      exit 2
    end

    if !type || type == ''
      type = 'pdf'
    end

    diagram = Domain::Diagram.new
    p = Parsing::Parser.new

    puts "Parsing: #{input_file}"
    p.parse(input_file, diagram)

    io = StringIO.new
    r = Rendering::RendererDOT.new(io)

    diagram.render(r)

    File.write(dot_file, io.string)

    puts ".dot file written to: #{dot_file}"

    # Create path to output file to avoid errors
    FileUtils::mkdir_p(File.dirname(output_file))

    # Compile file with graphviz
    puts "Compiling with graphviz to: #{output_file}"
    %x(dot -T#{type} #{dot_file} > #{output_file})
    puts "dot -T#{type} #{dot_file} > #{output_file}"
  end
end

Main::main(ARGV[0], ARGV[1], ARGV[2], ARGV[3])
