require 'stringio'

require_relative '../lib/parsing/properties_reader'
require_relative '../lib/parsing/parser'
require_relative '../lib/domain/presentation'

##
# Helper class for the direct parsing of markdown to other formats
# without using the whole logic of the Main class.
class CustomHandler

  ##
  # Normalize all Headings ("#", "###", "####") to "##". This is necessary
  # because the parser only understands # and ##
  # @param [Array<String>] lines input data
  # @return [Array<String>] normalized headings
  def self.normalize_headings!(lines)
    lines.map! { |l| l.gsub('# ', '## ') }
    lines.map! { |l| l.gsub('### ', '## ') }
    lines.map! { |l| l.gsub('#### ', '## ') }
  end

  ##
  # Parse the given lines and render the results using the given renderer.
  # The result is stored inside the renderer.
  #
  # @param [Array<String>] lines lines to be parsed
  # @param [String] location String the location of the lines (for error messages only)
  # @param [String] src_dir String the directory of the sources (required for relative includes)
  # @param [Rendering::Renderer] renderer the renderer to be used
  # @param [String] prog_language String the programming language
  def self.parse_and_render_internal(lines, location, src_dir, renderer, prog_language)

    normalize_headings!(lines)

    parser = Parsing::Parser.new(Constants::PAGES_FRONT_MATTER)

    presentation = Domain::Presentation.new('DE', '', '', '', '',
                                            '', '', prog_language, '', '',
                                            false, nil)

    # The parser expects that all Documents start with a heading on level 1
    # So we simply put a line at the beginning of the file to make the
    # parser happy
    lines.prepend('# Start')

    Dir.chdir(src_dir) do
      # Change working directory during parsing to ensure
      # that relative paths in the document are handled
      # correctly
      parser.parse_lines(lines, location, 'Java', presentation)
      parser.second_pass(presentation)
    end

    # Render the data
    presentation >> renderer
  end

  ##
  # Convert the given file from the source to the target.
  #
  # @param [String] src_dir source directory
  # @param [String] dest_dir target directory
  # @param [String] src_file the file to be converted (ignored if contents is set)
  # @param [String] dest_file the file to write results to (ignored if contents is set)
  # @param [String] prog_language the default programming language
  # @param [String] renderer_class name of class used for rendering
  # @param [String] img_dir directory with images to include
  # @param [String] tmp_dir directory for temporary files
  def self.convert_file(src_dir, dest_dir, src_file, dest_file, prog_language,
                        renderer_class, img_dir = 'img', tmp_dir ='../temp')
    # Read source file
    lines = File.readlines(src_dir + '/' + src_file, "\n", encoding: 'UTF-8')

    # Open output file
    io = File.open("#{dest_dir}/#{dest_file}", 'w')

    # Create the renderer using the given class name
    renderer = Object.const_get(renderer_class).new(io, prog_language, dest_dir,
                                                    img_dir, tmp_dir)

    parse_and_render_internal(lines, src_file, src_dir, renderer, prog_language)
    io.close
  end

  ##
  # Parse the given lines and convert them using the renderer. The output is returned
  # as a string.
  #
  # @param [String] src_dir source directory
  # @param [String] dest_dir target directory
  # @param [String] prog_language the default programming language
  # @param [String] renderer_class name of class used for rendering
  # @param [Array<String>] lines lines to be parsed
  # @param [String] img_dir directory with images to include
  # @param [String] tmp_dir directory for temporary files
  # @return [String] the result of the parsing and rendering as a string
  def self.convert_stream(src_dir, dest_dir, prog_language, renderer_class, lines,
                          img_dir = 'img', tmp_dir ='../temp')
    io = StringIO.new

    renderer = Object.const_get(renderer_class).new(io, prog_language, dest_dir,
                                                    img_dir, tmp_dir)

    parse_and_render_internal(lines, '', src_dir, renderer, prog_language)
    io.string
  end
end
