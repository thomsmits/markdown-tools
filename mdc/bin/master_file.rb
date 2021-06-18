class MasterFileSection
  attr_reader :entries
  attr_accessor :title

  def initialize(title = '')
    @title = title
    @entries = []
  end

  def <<(entry)
    @entries << entry
  end

  def sum_points(status = '+')
    @entries.reduce(0) { |s, e| s + e.sum_points(status)}
  end

  def to_s
    "\n## #{@title}\n\n" + @entries.join("\n") + "\n"
  end

  def each_entry
    @entries.each { |e| yield e }
  end

  def has_entries
    @entries.filter { |e| !e.path.nil?}.length > 0
  end
end

class MasterFileEntry

  attr_reader :path, :points, :status

  def initialize(path, points, status)
    @path = path
    @points = points
    @status = status
  end

  def to_s
    if path.nil?
      "#{status}:---"
    else
      "#{status}:[#{points}](#{path})" unless path.nil?
    end
  end

  def sum_points(status = '+')
    if @status == status
      points
    else
      0
    end
  end
end

class MasterFile
  attr_accessor :title, :frontmatter, :sections, :path

  def initialize(title = '', frontmatter = '', sections = [], path = '')
    @title = title
    @frontmatter = frontmatter
    @sections = sections || []
    @path = path
  end

  def sum_points(status = '+')
    @sections.reduce(0) { |s, e| s + e.sum_points(status)}
  end

  def to_s
    "# #{@title}\n\n#{@frontmatter}\n" + @sections.join("\n")
  end

  def each_section
    sections.each do |e|
      yield e
    end
  end

  def <<(section)
    @sections << section
  end

  def self.parse(input_file, desired_status = ['+'], solution = false)

    path = File.dirname(input_file)
    master_file = MasterFile.new

    # Start with an empty section, in case none is defined
    section = MasterFileSection.new
    master_file << section

    File.open(input_file, "r:UTF-8").each do |line|
      if /^# (.*)/ =~ line
        # Title of the file
        master_file.title = Regexp.last_match(1)
        master_file.title += ' (Musterlösung)' if solution
      elsif /^## (.*)/ =~ line
        if section.title == ''
          # First, anonymous section
          section.title = Regexp.last_match(1)
        else
          # A new section starts
          section = MasterFileSection.new(Regexp.last_match(1))
          master_file << section
        end
      elsif /([+KU-]):\[([0-9]*)\]\((.*)\)/ =~ line
        # File reference
        file_path = Regexp.last_match(3)
        points = Integer(Regexp.last_match(2))
        status = Regexp.last_match(1)

        if desired_status.include?(status)
          section << MasterFileEntry.new(path + '/' + file_path, points, status)
        end
      elsif /([+KU-]):---/ =~ line
        # Separator
        status = Regexp.last_match(1)
        section << MasterFileEntry.new(nil, 0, status)
      else
        master_file.frontmatter += line
      end
    end

    master_file.frontmatter.strip!

    master_file
  end
end
