# -*- coding: utf-8 -*-

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
    # @param [Renderer] renderer Rendering class used for generation
    def render(renderer)
      renderer.comment_start(spacing)
      elements.each { |e| e.render(renderer) }
      renderer.comment_end
    end
  end
end