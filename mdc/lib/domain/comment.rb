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
    # @param [Renderer] renderer renderer used for generation
    def >>(renderer)
      renderer.comment_start(spacing)
      elements.each { |e| e >> renderer }
      renderer.comment_end
    end
  end
end
