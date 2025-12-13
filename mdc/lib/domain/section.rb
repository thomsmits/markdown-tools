require_relative 'container'

module Domain
  ##
  # A single section of the document, e.g., a single slide in
  # the presentation.
  class Section < Container
    attr_accessor :title, :id, :number, :skip, :footnotes, :suppress_numbering

    ##
    # Create a new instance
    # @param [String] id section id
    # @param [String] title title of the section
    # @param [Fixnum] number number of the section
    # @param [Boolean] skip indicates a hidden section
    def initialize(id, title, number, skip, suppress_numbering = false)
      super()
      @title = title
      @id = id
      @number = number
      @skip = skip
      @footnotes = []
      @suppress_numbering = suppress_numbering
    end

    ##
    # Render the section
    # @param [Rendering::Renderer] other Renderer to be used..
    def >>(other)
      return if @skip

      if other.handles_animation?
        (0...max_order + 1).each do |order|
          other.section_start(@title, @number, @id, contains_code?, @suppress_numbering)
          @elements.each do |e|
            e >> other if !e.order.nil? && e.order <= order
          end
          other.section_end
        end
      else
        other.section_start(@title, @number, @id, contains_code?, @suppress_numbering)
        @elements.each { |e| e >> other }
        @footnotes.each { |e| e >> other }
        other.section_end
      end
    end

    ##
    # Indicate whether the slide contains code
    # @return [Boolean] true if slide contains code, otherwise false
    def contains_code?
      @elements.each { |e| return true if e.instance_of?(Domain::Source) }
      false
    end

    ##
    # Add a footnote to the slide
    # @param [Footnote] footnote the footnote to be added
    def add_footnote(footnote)
      @footnotes << footnote
    end

    ##
    # Return a string representation
    # @return [String] string representation
    def to_s
      @title.to_s
    end

    ##
    # Indicates that the slide contains animated elements, i.e. elements
    # that should be shown one after each other
    def animated?
      max_order.positive?
    end

    ##
    # Determine the maximum ordering number assigned to elements of this slide
    # @return [Fixnum] the maximum number found in the elements
    def max_order
      max = 0
      @elements.each do |e|
        max = !e.order.nil? && e.order > max ? e.order : max
      end
      max
    end
  end
end
