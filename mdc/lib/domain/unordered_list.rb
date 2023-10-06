require_relative 'block_element'

module Domain
  ##
  # Unordered list
  class UnorderedList < BlockElement
    attr_accessor :entries, :parent

    ##
    # Crate a new list
    def initialize
      super('')
      @parent = nil
      @entries = []
    end

    ##
    # Add an element to the list
    # @param [Domain::BlockElement] element to be added
    def add(element)
      @entries << element
      element.parent = self
    end

    ##
    # Append a line to the list
    # @param [String] line the line to be added
    def <<(line)
      add(UnorderedListItem.new(line))
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] other Renderer to be used..
    def >>(other)
      other.ul_start
      @entries.each { |e| e >> other }
      other.ul_end
    end

    ##
    # Create a digest of the content
    # @return [String] a digest of the slide
    def digest
      digest = ''
      @entries.each { |entry| digest << entry.digest << ' ' }
      digest
    end

    ##
    # Call the provided block on each content element.
    def each_content_element(&block)
      @entries.each { |e| e.each_content_element(&block) }
    end

    ##
    # Return a string representation of this object.
    # @return [String] the content of the object
    def to_s
      result = ''
      @entries.each { |entry| result << entry.to_s << ' ' }
      result
    end
  end
end
