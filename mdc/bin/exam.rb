# -*- coding: utf-8 -*-

require_relative '../lib/parsing/properties_reader'
require_relative '../lib/parsing/parser'
require_relative '../lib/domain/presentation'
require_relative '../lib/rendering/renderer_latex_exam'
require 'stringio'

##
# Create TeX snippets to be used in an exam from Markdown files
class Exam

  ##
  # Convert the given file from the source to the target directory
  #
  # @param src String source directory
  # @param dest String target directory
  # @param file_name String the file to be converted
  def self.convert(src, dest, file_name)

    p = Parsing::Parser.new(Constants::PAGES_FRONT_MATTER)

    pres = Domain::Presentation.new('DE', '', '', '', '',
                                    '', '', 'Java', '', '', false, nil)


    lines = File.readlines(src + '/' + file_name, "\n", encoding: 'UTF-8')
    lines.map! { |l| l.gsub('# ', '## ') }
    lines.map! { |l| l.gsub('### ', '## ') }
    lines.map! { |l| l.gsub('#### ', '## ') }

    lines = ['# Start'] + lines


    Dir.chdir(src) do
      # Change working directory during parsing to ensure
      # that relative paths in the document are handled
      # correctly
      p.parse_lines(lines, file_name, 'Java', pres)
    end

    target_name = file_name.gsub('.md', '.tex')
    io = File.open("#{dest}/#{target_name}", 'w')
    renderer = Rendering::RendererLatexExam.new(io, 'console', dest, 'img', '../temp')
    pres.render(renderer)
    io.close
  end

  ##
  # Main entry point
  # @param src String directory with source files
  # @param dest String directory to store results in
  def self.main(src, dest)
    files = Dir.new(src).entries.reject { |f| !(/^.*\.md$/ =~ f) }

    files.each do |file|
      convert(src, dest, file)
    end
  end
end

Exam::main(ARGV[0], ARGV[1])
