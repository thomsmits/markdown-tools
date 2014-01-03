# -*- coding: utf-8 -*-

require_relative 'container'

module Domain

  ##
  # Comment area of a slide (used for speaker notes or additional explanations)
  class Comment < Container

    ##
    # Create a new instance
    def initialize
      super()
    end

    ##
    # Render contents
    # @param [Renderer] renderer Rendering class used for generation
    def render(renderer)
      renderer.comment_start
      elements.each { |e| e.render(renderer) }
      renderer.comment_end
    end
  end
end