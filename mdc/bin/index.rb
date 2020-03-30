require 'stringio'

require_relative '../lib/parsing/properties_reader'
require_relative '../lib/rendering/renderer_html'
require_relative '../lib/messages'

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
      @chapter_number = chapter_number
      @chapter_name = chapter_name
      @slide_file = slide_file
      @plain_file = plain_file
    end

    ##
    # Return string representation
    # @return string representation
    def puts
      "#{chapter_number} - #{chapter_name}"
    end

    ##
    # Compares this object with the given one
    # @param [Entry] other the object to compare with
    def <=>(other)
      chapter_number <=> other.chapter_number
    end
  end

  ##
  # Main method
  # @param [String] directory directory containing the source files
  def self.main(directory)
    directory = '.' if directory.nil?

    dir = Dir.new(directory)
    main_prop_file = directory + '/metadata.properties'
    main_props = Parsing::PropertiesReader.new(main_prop_file)

    postfix_slide = '-slides.html'
    postfix_plain = '-script.html'

    title1           = main_props['title_1']
    title2           = main_props['title_2']
    copyright        = main_props['copyright']
    description      = main_props['description']

    dirs = []

    dir.each { |f| dirs << f if /[0-9][0-9]_.*/ =~ f }

    entries = []

    dirs.each do |f|
      prop_file = "#{directory}/#{f}/metadata.properties"

      next unless File.exist?(prop_file)

      chapter_props = Parsing::PropertiesReader.new(prop_file)

      chapter_file = chapter_props['resultfile']
      slide_file = chapter_file + postfix_slide
      plain_file = chapter_file + postfix_plain

      entries << Entry.new(chapter_props['chapter_no'],
                           chapter_props['chapter_name'],
                           slide_file,
                           plain_file)
    end

    io = StringIO.new
    io.set_encoding('UTF-8')

    renderer = Rendering::RendererHTML.new(io, '', '', '', '')
    renderer.index_start(title1, title2, copyright, description)

    entries.sort!

    entries.each do |e|
      renderer.index_entry(e.chapter_number, e.chapter_name,
                           e.slide_file, translate(:presentation),
                           e.plain_file, translate(:plain))
    end

    renderer.index_end

    puts io.string
  end
end

Index.main(ARGV[0])
