require 'date'
require 'fileutils'

require_relative '../lib/parsing/properties_reader'
require_relative '../lib/parsing/parser'
require_relative '../lib/domain/presentation'
require_relative '../lib/rendering/renderer_html_note'
require_relative '../lib/domain/notes'

##
# Generate a set of html files from a set of markdown notes
class NotesHandling
  ##
  # Parse the given directory and generate html structure
  # @param [String] source the source directory
  # @param [String] target the target directory
  def self.main(source, target)
    handler = NotesHandling.new
    root_folder = Notes::Folder.new(source, '', '', '')
    handler.parse_folder(source, root_folder, true)
    handler.read_files_and_convert(root_folder, target)
  end

  ##
  # Convert an array in the form 'name: value', ... to a hash 'name' => 'value'
  # @param [String[]] comments array with strings
  # @return [Hash] a hash
  def strings_to_hash(comments)
    hash = {}
    comments.each do |c|
      next unless /(.*):(.*)/ =~ c

      name = Regexp.last_match(1).strip
      value = Regexp.last_match(2).strip
      hash[name] = value
    end
    hash
  end

  ##
  # @param [Folder] folder
  # @param [String] target directory for the result files
  def read_files_and_convert(folder, target)
    parser = Parsing::Parser.new(0)

    folder.files.each do |file|
      src_path = folder.path + '/' + file.name
      dest_dir = target + '/' + folder.name

      FileUtils.mkdir_p(dest_dir)  unless Dir.exist?(dest_dir)

      dest_path = dest_dir + '/' + file.name + '.html'

      puts "Compiling #{src_path}"

      presentation = Domain::Presentation.new('', '', '',
                                              '', '',
                                              '', '', '',
                                              '', '', false, nil)
      parser.parse(src_path, '', presentation)
      presentation.title1 = presentation.chapters[0].title
      file.title = presentation.title1
      file.digest = presentation.digest(180) + '...'
      file.date = File.mtime(src_path)

      metadata = strings_to_hash(presentation.comments)

      file.date = Date.parse(metadata['date']) unless metadata['date'].nil?
      file.tags = metadata['tags'].split(/, ?/) unless metadata['tags'].nil?

      io = File.new(dest_path, 'w', encoding: 'UTF-8')
      renderer = Rendering::RendererHTMLNote.new(
	      io, '', '', '',
        '', file.tags, file.date, folder.title
      )
      presentation >> renderer
      io.close
    end

    folder.folders.each { |dir| read_files_and_convert(dir, target + '/' + folder.name) }

    dest_dir = target + '/' + folder.name
    make_index(dest_dir, folder)
  end

  def make_index(dest_dir, folder)
    return if folder.folders.count.zero? && folder.files.count.zero?

    Dir.mkdir(dest_dir) unless Dir.exist?(dest_dir)
    io = File.new(dest_dir + '/' + 'index.html', 'w')
    renderer = Rendering::RendererHTMLNote.new(io, '', '', '',
                                               '', [], [], folder.title)
    folder >> renderer
    io.close
  end

  ##
  # Recursively parse the given folder and return a
  # tree containing all found data
  # @param [String] directory of the root folder of the notes storage
  # @param [String] folder the folder to add data to
  # @return [Folder] root folder
  def parse_folder(directory, folder, first = false)
    # Unify to Unix file separators
    directory.tr!('\\', '/')

    # Get last part of the path
    directory =~ %r{.*/(.*?)$}
    folder.name = first ? '' : Regexp.last_match(1)

    # Check for properties
    if File.exist?("#{directory}/folder.properties")
      props = Parsing::PropertiesReader.new("#{directory}/folder.properties")
      folder.title = props['title']
      folder.description = props['description']
    else
      folder.title = folder.name
      folder.description = ''
    end

    # Search for files in folder
    Dir.foreach(directory) do |d|
      next if d.end_with?('.')

      path = "#{directory}/#{d}"

      if File.file?(path) && d.end_with?('.txt', '.md')
        entry = Notes::FolderEntry.new(d)
        folder << entry
      elsif File.directory?(path)
        sub_folder = Notes::Folder.new(path, '', '', '')
        parse_folder(path, sub_folder)
        folder.add_folder(sub_folder)
      end
    end
  end
end

NotesHandling.main(ARGV[0].dup, ARGV[1].dup)
# NotesHandling::main('/Users/thomas/Dropbox/Notes/',
# '/Users/thomas/Dropbox/Notes_Html/')
