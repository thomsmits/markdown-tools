# -*- coding: utf-8 -*-

require_relative '../lib/parsing/properties_reader'
require_relative '../lib/parsing/parser'
require_relative '../lib/domain/presentation'
require_relative '../lib/rendering/renderer_html_note'
require 'date'
require_relative '../lib/domain/notes'
require 'fileutils'

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
      if /(.*):(.*)/ === c
        name = $1.strip
        value = $2.strip
        hash[name] = value
      end
    end
    hash
  end

  ##
  # @param [Folder] folder
  # @param [String] target directory for the result files
  def read_files_and_convert(folder, target)

    p = Parsing::Parser.new(0)

    folder.files.each do |file|
      src_path = folder.path + '/' + file.name;
      dest_dir = target + '/' + folder.name;

      FileUtils.mkdir_p(dest_dir)  unless Dir.exist?(dest_dir)

      dest_path = dest_dir + '/' + file.name + '.html'

      puts "Compiling #{src_path}"

      pres = Domain::Presentation.new('', '', '', '', '', '', '', '', '')
      p.parse(src_path, '', pres)
      pres.title1 = pres.chapters[0].title
      file.title = pres.title1
      file.digest = pres.digest(180) + '...'
      file.date = File.mtime(src_path)

      metadata = strings_to_hash(pres.comments)

      file.date = Date.parse(metadata['date'])  unless metadata['date'].nil?
      file.tags = metadata['tags'].split(/, ?/)  unless metadata['tags'].nil?

      io = File.new(dest_path, 'w', :encoding => 'UTF-8')
      renderer = Rendering::RendererHTMLNote.new(io, '', '', '', '', file.tags, file.date, folder.title)
      pres.render(renderer)
      io.close
    end

    folder.folders.each { |dir| read_files_and_convert(dir, target + '/' + folder.name) }

    dest_dir = target + '/' + folder.name;
    make_index(dest_dir, folder)
  end


  def make_index(dest_dir, folder)

    return  if folder.folders.count == 0 && folder.files.count == 0

    Dir.mkdir(dest_dir)  unless Dir.exist?(dest_dir)
    io = File.new(dest_dir + '/' + 'index.html', 'w')
    renderer = Rendering::RendererHTMLNote.new(io, '', '', '', '', [], [], folder.title)
    folder.render(renderer)
    io.close
  end

  ##
  # Recursively parse the given folder and return a tree containing all found data
  # @param [String] directory of the root folder of the notes storage
  # @param [String] folder the folder to add data to
  # @return [Folder] root folder
  def parse_folder(directory, folder, first = false)

    # Unify to Unix file separators
    directory.gsub!('\\', '/')

    # Get last part of the path
    directory =~ %r!.*/(.*?)$!
    folder.name = first ? '' : $1


    # Check for properties
    if File.exist?("#{directory}/folder.properties")
      props = Parsing::PropertiesReader.new("#{directory}/folder.properties")
      folder.title = props.get('title')
      folder.description = props.get('description')
    else
      folder.title = folder.name
      folder.description = ''
    end

    # Search for files in folder
    Dir.foreach(directory) do |d|

      next if d.end_with?('.')

      path = "#{directory}/#{d}"

      if File.file?(path) && (d.end_with?('.txt') || d.end_with?('.md'))
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

NotesHandling::main(ARGV[0].dup, ARGV[1].dup)
#NotesHandling::main('/Users/thomas/Dropbox/Notes/', '/Users/thomas/Dropbox/Notes_Html/')
