# -*- coding: utf-8 -*-

module Notes

  ##
  # Class representing a folder containing notes
  class Folder
    attr_accessor :path, :name, :title, :description, :files, :folders

    ##
    # Create a new folder
    # @param [String] path fully qualified path to the folder
    # @param [String] name name of the folder
    # @param [String] title title of the folder
    # @param [String] description description of the
    def initialize(path, name, title, description)
      @path, @name, @title, @description, @files, @folders = path, name, title, description, [], []
    end

    ##
    # Add a new entry to the folder
    # @param [FolderEntry] entry entry to be added
    def <<(entry)
      @files << entry
    end

    ##
    # Add sub folder to the folder
    # @param [Folder] folder sub folder to be added
    def add_folder(folder)
      @folders << folder
    end

    ##
    # Return a string representation
    # @return [String] string representation
    def to_s
      result = ''
      result << "#{@title} '#{@description}' -> #{@path}\n"

      @files.each { |e| result << '    ' << e.to_s << "\n" }

      result
    end

    ##
    # Render contents
    # @param [Rendering::RendererHTMLNote] renderer Rendering class used for generation
    def render(renderer)
      renderer.index_start(@title, @description)
      @folders.each { |f| renderer.index_folder_entry(f.name, f.title, f.description, f.count, f.all_tags) }
      @files.each { |f| f.render(renderer) }
      renderer.index_end
    end

    ##
    # Return the number of files in the folder
    # @param [Fixnum] num already counted files for recursive calls
    # @return [Fixnum] total number of files found
    def count(num = 0)
      num = @files.count
      @folders.each { |f| num += f.count }
      num
    end

    ##
    # Return all tags (i.e. short terms describing the file's content)
    # @return [String[]] found tags alphabetically sorted
    def all_tags
      tags = {}
      @files.each do |f|
        f.tags.each { |t| tags[t] = :present }
      end

      @folders.each do |f|
        f.all_tags.each { |t| tags[t] = :present }
      end

      result = []
      tags.each_key { |k| result << k }

      result.sort!
    end
  end

  ##
  # Entry for a file of a folder
  class FolderEntry
    attr_accessor :name, :title, :digest, :date, :tags

    ##
    # Create a new instance
    # @param [String] name name of the file
    def initialize(name)
      @name, @title, @digest, @tags = name, '', '', []
    end

    ##
    # Return a string representation
    # @return [String] string representation
    def to_s
      "#{@name} -> #{@title}"
    end

    ##
    # Render contents
    # @param [Rendering::RendererHTMLNote] renderer Rendering class used for generation
    def render(renderer)
      renderer.index_file_entry(@name, @title, @date, @tags, @digest)
    end
  end
end