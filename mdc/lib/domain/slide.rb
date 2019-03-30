require_relative 'container'

module Domain
  ##
  # A single slide of the presentation
  class Slide < Container
    attr_accessor :title, :id, :number, :skip

    ##
    # Create a new instance
    # @param [String] id slide id
    # @param [String] title title of the slide
    # @param [Fixnum] number number of slide
    # @param [Boolean] skip indicates a hidden slide
    def initialize(id, title, number, skip)
      super()
      @title = title
      @id = id
      @number = number
      @skip = skip
    end

    ##
    # Create a digest of the content
    # @return [String] a digest of the slide
    def digest
      digest = ''
      digest << @title << ' '
      digest << super
      digest
    end

    ##
    # Render the Slide
    # @param [Rendering::Renderer] renderer to be used
    def >>(renderer)
      return if @skip

      if renderer.handles_animation?
        (0...max_order + 1).each do |order|
          renderer.slide_start(@title, @number, @id, contains_code?)
          @elements.each do |e|
            e >> renderer if !e.order.nil? && e.order <= order
          end
          renderer.slide_end
        end
      else
        renderer.slide_start(@title, @number, @id, contains_code?)
        @elements.each { |e| e >> renderer }
        renderer.slide_end
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
    # Return a string representation
    # @return [String] string representation
    def to_s
      @title.to_s
    end

    ##
    # Indicates that the slide contains animated elements, i.e. elements
    # that should be shown one after each other
    def animated?
      max_order > 0
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
