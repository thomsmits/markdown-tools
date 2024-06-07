##
# One section in the master file, controlling an exam.
class MasterFileSection
  attr_reader :entries
  attr_accessor :title

  ##
  # Create a new instance.
  # @param [String] title Title of the exam.
  def initialize(title = '')
    @title = title
    # @type [MasterFileEntry]
    @entries = []
  end

  ##
  # Add a new entry to the section.
  # @param [MasterFileEntry] entry the entry to be added.
  def <<(entry)
    @entries << entry
  end

  ##
  # Sum of the element's points.
  # @return [Integer|BigDecimal] sum of the points
  def sum_points(status = '+')
    @entries.reduce(0) { |s, e| s + e.sum_points(status) }
  end

  ##
  # Return a string representation.
  # @return [String] the entry as a string.
  def to_s
    "\n## #{@title}\n\n#{@entries.join("\n")}\n"
  end

  ##
  # Iterate over all entries and apply the given block to them.
  def each_entry(&block)
    @entries.each(&block)
  end

  ##
  # Provide the information, if the section has any entries.
  # @return [Boolean] true, if entries are present, otherwise false.
  def entries?
    @entries.filter { |e| !e.path.nil? }.length.positive?
  end
end

##
# Class representing one entry in the exam's master file.
class MasterFileEntry
  attr_reader :path, :points, :status

  ##
  # Create a new entry.
  # @param [String|nil] path Path to entry
  # @param [Integer] points Points for the entry
  # @param [String] status status of the entry
  def initialize(path, points, status)
    @path = path
    @points = points
    @status = status
  end

  ##
  # Return a string representation.
  # @return [String] the entry as a string.
  def to_s
    if path.nil?
      "#{status}:---"
    else
      "#{status}:[#{points}](#{path})" unless path.nil?
    end
  end

  ##
  # Sum of the element's points.
  # @return [Integer|BigDecimal] sum of the points
  def sum_points(status = '+')
    if @status == status
      points
    else
      0
    end
  end
end

##
# Class representing the master file, which controls the exam's questions.
class MasterFile
  attr_accessor :title, :front_matter, :sections, :path

  ##
  # Create a new instance.
  # @param [String] title The title of the exam.
  # @param [String] front_matter The front_matter.
  # @para [Array<MasterFileSection>] sections Sections.
  # @param [String] path Path to the master file itself.
  def initialize(title = '', front_matter = '', sections = [], path = '')
    @title = title
    @front_matter = front_matter
    @sections = sections || []
    @path = path
  end

  ##
  # Sum of the element's points.
  # @return [Integer|BigDecimal] sum of the points
  def sum_points(status = '+')
    @sections.reduce(0) { |s, e| s + e.sum_points(status) }
  end

  ##
  # Return a string representation.
  # @return [String] the entry as a string.
  def to_s
    "# #{@title}\n\n#{@front_matter}\n" + @sections.join("\n")
  end

  ##
  # Iterate over all sections and apply the given block to them.
  def each_section(&block)
    @sections.each(&block)
  end

  ##
  # Add a section.
  # @param [MasterFileSection] section the section to be added.
  def <<(section)
    @sections << section
  end

  ##
  # Parse the given file and extract the elements with the given status.
  # If requested, the solution is added.
  # @param [String] input_file File with the exam's configuration.
  # @param [Array<String>] desired_status Status of the entries to be extracted.
  # @param [Boolean] solution Configures if the solution should be added.
  # @return [MasterFile] the parsed file
  def self.parse(input_file, desired_status = ['+'], solution = false)
    path = File.dirname(input_file)
    master_file = MasterFile.new

    # Start with an empty section, in case none is defined
    section = MasterFileSection.new
    master_file << section

    File.open(input_file, 'r:UTF-8').each do |line|
      case line
      when /^# (.*)/
        # Title of the file
        master_file.title = Regexp.last_match(1)
        master_file.title += ' (Musterlösung)' if solution
      when /^## (.*)/
        if section.title == ''
          # First, anonymous section
          section.title = Regexp.last_match(1)
        else
          # A new section starts
          section = MasterFileSection.new(Regexp.last_match(1))
          master_file << section
        end
      when /([+KU-]):\[([0-9]*)\]\((.*)\)/, / {2}\* \[([+KU-])\] \|([0-9]*)\| \[.*\]\((.*)\)/
        # File reference
        file_path = Regexp.last_match(3).gsub(/\.md$/, '')
        points = Integer(Regexp.last_match(2) || 0)
        status = Regexp.last_match(1)

        section << MasterFileEntry.new("#{path}/#{file_path}", points, status) if desired_status.include?(status)
      when /([+KU-]):---/, / {2}\* \[([+KU-])\] ---/
        # Separator
        status = Regexp.last_match(1)
        section << MasterFileEntry.new(nil, 0, status)
      else
        master_file.front_matter += line
      end
    end

    master_file.front_matter.strip!

    master_file
  end
end
