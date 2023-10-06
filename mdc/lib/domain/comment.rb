require_relative 'container'

module Domain
  ##
  # Comment area of a slide (used for speaker notes or additional explanations)
  class Comment < Container
    attr_accessor :spacing

    ##
    # Create a new instance
    def initialize
      super()
      @spacing = 0
    end

    ##
    # Render contents
    # @param [Renderer] other renderer used for generation
    def >>(other)
      other.comment_start(spacing)
      elements.each { |e| e >> other }
      other.comment_end
    end
  end
end
