require_relative 'unordered_list'

module Domain
  ##
  # Ordered list
  class OrderedList < UnorderedList
    attr_accessor :start_number

    ##
    # Crate a new list with the given start number
    # @param [Fixnum] start_number number of first entry
    def initialize(start_number)
      super()
      @start_number = start_number
    end

    ##
    # Append a line to the list
    # @param [String] line the line to be added
    def <<(line)
      add(OrderedListItem.new(line))
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def >>(renderer)
      renderer.ol_start(@start_number)
      @entries.each { |e| e >> renderer }
      renderer.ol_end
    end
  end
end
