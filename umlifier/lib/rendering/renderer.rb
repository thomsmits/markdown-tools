# -*- coding: utf-8 -*-

module Rendering

  class Renderer
    ##
    # Initialize the renderer
    # @param [IO] io target of output operations
    def initialize(io)
      @io = io
    end

    ##
    # Return a newline character
    # @return [String] newline character
    def nl
      "\n"
    end

    def diagram_start; end
    def diagram_end; end
    def term(name); end
    def class_start(name, abstract); end
    def class_end; end
    def interface_start(name); end

    def interface_end; end

    def instance_start(name); end

    def instance_end; end

    def field(visibility, name, static); end

    def method(visibility, name, static, abstract); end

    def fields_start; end

    def fields_end; end

    def methods_start; end

    def methods_end; end


    def relation(from, to, label, card_from, card_to); end

    def composition(from, to, label, card_from, card_to); end

    def aggregation(from, to,label, card_from, card_to); end

    def implementation(from, to); end

    def inheritance(from, to); end

    def association(from, to, label, card_from, card_to); end

    def directed_association(from, to, label, card_from, card_to); end
  end
end
