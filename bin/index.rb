# -*- coding: utf-8 -*-

require_relative '../lib/parsing/properties_reader'
require_relative '../lib/rendering/renderer_html'
require_relative '../lib/messages'
require 'stringio'

##
# Generate an overview file for the generated files
class Index

  ##
  # One entry for a generated file
  class Entry

    attr_accessor :chapter_number, :chapter_name, :slide_file, :plain_file

    ##
    # Create new a new instance
    # @param [String] chapter_number Number of chapter
    # @param [String] chapter_name Name of chapter
    # @param [String] slide_file file containing the slides
    # @param [String] plain_file file containing the plain data
    def initialize(chapter_number, chapter_name, slide_file, plain_file)
      @chapter_number, @chapter_name, @slide_file, @plain_file =
          chapter_number, chapter_name, slide_file, plain_file
    end

    ##
    # Render the entry
    # @param [Rendering::Renderer] renderer renderer to be used
    def render(renderer)
      renderer.index_entry(@chapter_number, @chapter_name, @slide_file, @plain_file)
    end

    ##
    # Return string representation
    # @return string representation
    def puts
      "#{chapter_number} - #{chapter_name}"
    end
  end

  ##
  # Main method
  # @param [String] directory directory containing the source files
  def self.main(directory)

    directory = '.'  if directory.nil?

    dir = Dir.new(directory)
    main_prop_file = directory + '/metadata.properties'
    main_props = Parsing::PropertiesReader.new(main_prop_file)

    postfix_slide = '.html'
    postfix_plain = '_plain.html'

    title1           = main_props.get('title_1')
    title2           = main_props.get('title_2')
    copyright        = main_props.get('copyright')
    description      = main_props.get('description')

    dirs = [ ]

    dir.each { |f| dirs << f  if /[0-9][0-9]_.*/ =~ f }

    entries = [ ]

    dirs.each { |f|
      chapter_props      = Parsing::PropertiesReader.new(
          "#{directory}/#{f}/metadata.properties")

      chapter_make_file  = Parsing::PropertiesReader.new(
          "#{directory}/#{f}/Makefile")

      chapter_file = chapter_make_file.get('CHAPTER')
      slide_file   = chapter_file + postfix_slide
      plain_file   = chapter_file + postfix_plain

      entries << Entry.new(chapter_props.get('chapter_no'),
                             chapter_props.get('chapter_name'),
                             slide_file,
                             plain_file)
    }

    io = StringIO.new

    renderer = Rendering::RendererHTML.new(io, '', '', '', '')
    renderer.index_start(title1, title2, copyright, description)

    entries.each { |e|
      renderer.index_entry(e.chapter_number, e.chapter_name,
                           e.slide_file, LOCALIZED_MESSAGES[:presentation],
                           e.plain_file, LOCALIZED_MESSAGES[:plain])
    }

    renderer.index_end

    puts io.string
  end
end

Index::main(ARGV[0])
