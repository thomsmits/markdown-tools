# -*- coding: utf-8 -*-

require_relative 'connectors'
require_relative 'types'

module DomainUML

  class Diagram

    def initialize
      @classes = [ ]
      @interfaces = [ ]
      @connectors = [ ]
    end

    def <<(element)
      @connectors << element
    end

    def render(renderer)
      renderer.diagram_start
      @classes.each { |c| c.render(renderer) }
      @interfaces.each { |c| c.render(renderer) }
      @connectors.each { |c| c.render(renderer) }
      renderer.diagram_end
    end
  end
end