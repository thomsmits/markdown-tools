# -*- coding: utf-8 -*-

require_relative 'block_element'

module Domain

  ##
  # Table
  class Table < BlockElement

    ## Header of the table
    class TableHeader

      attr_accessor :name, :alignment, :separator

      ##
      # Create a new header
      # @param [String] name name of the header
      # @param [Fixnum] alignment alignment of the header cell
      def initialize(name, alignment = Constants::LEFT)
        @name, @alignment = name, alignment
      end
    end

    attr_accessor :headers, :rows

    ##
    # Create a new table
    def initialize
      super('')
      @headers = [ ]
      @rows = [ ]
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
    # @param [Array] row of the row
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
    # @param [Rendering::Renderer] renderer to be used
    def >>(renderer)

      alignment = [ ]
      titles = [ ]
      @headers.each do |h|
        alignment << h.alignment
        titles  << h.name
      end

      renderer.table_start(titles, alignment)

      @rows.each do |r|
        if r.nil?
          renderer.table_separator(@headers)
        else
          renderer.table_row(r, alignment)
        end
      end
      renderer.table_end
    end
  end
end
