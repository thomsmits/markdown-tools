module Domain
  ##
  # Table of contents
  class TOC
    attr_accessor :entries

    ##
    # An entry of the toc
    class TOCEntry < TOC
      attr_accessor :id, :name

      ##
      # Create a new instance
      # @param [String] id id of the entry
      # @param [String] name name of the entry
      def initialize(id, name)
        super()
        @id = id
        @name = name
      end
    end

    ##
    # @return [Boolean] true if element has children
    def children?
      @entries.empty?
    end

    ##
    # Create a new instance
    def initialize
      @entries = []
    end

    ##
    # Add an entry to the TOC
    # @param [String] id id of the entry
    # @param [String] name name of the entry
    def add(id, name)
      @entries << TOCEntry.new(id, name)
    end

    ## Add an entry on the second level
    # @param [String] parent_id id of the parent entry
    # @param [String] id id of the entry
    # @param [String] name name of the entry
    def add_sub_entry(parent_id, id, name)
      parent = find_entry_by_id(parent_id, @entries)
      raise Exception, "Parent must exist #{parent_id}" if parent.nil?

      parent.add(id, name)
    end

    ##
    # Find an entry by its id
    # @param [String] id the id to search for
    # @param [Array] entries array to search in
    def find_entry_by_id(id, entries)
      entries.each { |e| return e if e.id == id }
    end

    ##
    # Iterate over the entries
    def each
      @entries.each { |e| yield e }
    end
  end
end
