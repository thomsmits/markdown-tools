require_relative 'block_element'

module Domain

  ##
  # Table
  class Table < BlockElement

    ##
    # A cell of the table outside of the header
    class TableCell
      attr_accessor :content, :nodes

      ##
      # Create a new cell
      # @param [String] content the content of the cell
      def initialize(content)
        @content = content
        # @type [LineNodes]
        @nodes = nil
      end
    end

    ##
    # Header of the table
    class TableHeader
      attr_accessor :content, :nodes
      attr_accessor :alignment, :separator

      ##
      # Create a new header
      # @param [String] content name of the header
      # @param [Fixnum] alignment alignment of the header cell
      def initialize(content, alignment = Constants::LEFT)
        @content = content
        @alignment = alignment
        # @type [LineNodes]
        @nodes = nil
      end

      ##
      # Return the header's name
      # @return String the name of the header
      def to_s
        @content
      end
    end

    attr_accessor :headers, :rows

    ##
    # Create a new table
    # @param [Array<TableHeader>] headers headers of the table
    # @param [Array<Array<TableCell>>] rows rows of the table
    def initialize(headers = [], rows = [])
      super('')
      @headers = headers
      @rows = rows
    end

    ##
    # Add a header to the table
    # @param [String] header_name name of the header
    # @param [Fixnum] alignment alignment of the header
    def add_header(header_name, alignment)
      @headers << TableHeader.new(header_name, alignment)
    end

    ##
    # Add a full row to the table
    # @param [Array<TableCell>] row of the row
    def add_row(row)
      @rows << row
    end

    ##
    # Add a separator line to the table
    def add_separator
      @rows << nil
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer renderer to be used
    def >>(renderer)
      alignment = []
      titles = []
      @headers.each do |h|
        alignment << h.alignment
        titles << h.nodes.render(renderer.line_renderer)
      end

      renderer.table_start(titles, alignment)

      @rows.each do |r|
        if r.nil?
          renderer.table_separator(@headers)
        else
          c = r.map { |e| e.nodes.render(renderer.line_renderer) }
          renderer.table_row(c, alignment)
        end
      end
      renderer.table_end
    end
  end
end
