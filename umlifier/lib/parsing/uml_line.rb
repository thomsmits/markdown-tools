# -*- coding: utf-8 -*-

module ParsingUML

  ##
  # Wrapper around a single line to ease matching of special elements that
  # indicate a new parser state or action
  class UMLLine

    ## Create a new class wrapped around a single line
    # @param [String] line line to wrap around
    def initialize(line)
      @line = line
    end

    ##
    # Return the wrapped string
    # @return [String] the wrapped string
    def string
      @line
    end

    ##
    # Return the length in character of the line
    # @return [Fixnum] length of the line
    def length
      @line.length
    end


    def clazz; /Class \{ (.*)$/ =~ @line.strip; $1; end
    alias clazz? clazz

    def instance; /Instance \{ (.*)$/ =~ @line.strip; $1; end
    alias instance? instance

    def term; /Term \{ (.*) }$/ =~ @line.strip; $1; end
    alias term? term

    def abstract_clazz; /Class \{ (.*)\{abstract\}$/ =~ @line.strip; $1; end
    alias abstract_clazz? abstract_clazz

    def interface; /Interface \{ (.*)$/ =~ @line.strip; $1; end
    alias interface? interface

    def comment_line?; /^%.*$/ =~ @line.strip; end

    def end_line?; /^\}$/ =~ @line.strip; end

    def link?; /.*[-]{2,}.*/ =~ @line; end

    def empty?; /^$/ =~ @line.strip; end


    ## String representation
    def to_s; @line; end
  end
end
