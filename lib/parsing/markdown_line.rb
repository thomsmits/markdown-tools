# -*- coding: utf-8 -*-

module Parsing

  ##
  # Wrapper around a single line to ease matching of special elements that
  # indicate a new parser state or action
  class MarkdownLine

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

    ##
    # Cut away the first characters
    # @param [Fixnum] from number of characters to be removed
    def substr!(from)
      @line = @line[from..-1]
    end

    ##
    # Remove the code prefix (i.e. four blanks) from the line
    def trim_code_prefix!
      if @line.length > 4
        @line = @line[4..-1]
      end
    end

    ## Source code prefixed by four blanks
    def source?; /^ {4}[^\*](.*)/ =~ @line; end

    ## Row of a table
    def table_row?; /^\|(.*)\| *$/ =~ @line; end

    ## A quote
    def quote?; /^> (.*)$/ =~ @line; end

    ## An empty line
    def empty?; /^$/ =~ @line.strip; end

    ## A normal line
    def normal?; /^[^ ].*$/ =~ @line; end

    ## Just text
    def text?; /^[A-Za-z0-9_ÄÖÜäöü`].*$/ =~ @line; end

    ## HTML code
    def html?; /^<.*$/ =~ @line; end

    ## Image
    def image?; /\!\[.*\]\(.*\)/ =~ @line; end

    ## End of a fenced code block
    def fenced_code_end?; /^```$/ =~ @line.strip; end

    ## Slide to be skipped
    def skipped_slide?; /.*--skip--.*/ =~ @line.strip; end

    ## Start of a script
    def script_start?; /^<script>$/ =~ @line.strip; end

    ## End of a script
    def script_end?; /^<\/script>$/ =~ @line.strip; end

    ## Start of an equation
    def equation_start?; /^\\\[$/ =~ @line.strip; end

    ## End of an equation
    def equation_end?; /^\\\]$/ =~ @line.strip; end

    ## Separator of slide and comment
    def separator?; /^---.*/ =~ @line; end

    ## Separator of tables
    def table_separator?; /^\|[-]{2,}\|.*/ =~ @line.strip; end

    ## unordered list, level 1
    def ul1; /^ {2}[\*](.*)/ =~ @line; $1; end

    ## unordered list, level 1
    alias ul1? ul1

    ## unordered list, level 2
    def ul2; /^ {4}[\*](.*)/ =~ @line; $1; end

    ## unordered list, level 1
    alias ul2? ul2

    ## unordered list, level 3
    def ul3; /^ {6}[\*](.*)/ =~ @line; $1; end

    ## unordered list, level 1
    alias ul3? ul3

    ## ordered list, level 1
    def ol1; /^ {2}[0-9]+\.(.*)/ =~ @line; $1; end

    ## ordered list, level 1
    alias ol1? ol1

    ## ordered list, level 1 with number
    def ol1_number; /^ {2}([0-9]+)\..*/ =~ @line; $1; end

    ## ordered list, level 2
    def ol2; /^ {4}[0-9]+\.(.*)/ =~ @line; $1; end

    ## ordered list, level 2
    alias ol2? ol2

    ## ordered list, level 3
    def ol3; /^ {6}[1-9]+\.(.*)/ =~ @line; $1; end

    ## ordered list, level 3
    alias ol3? ol3

    ## Beginning of a fenced code block
    def fenced_code_start; /^```(.*)/ =~ @line.strip; $1; end

    ## Beginning of a fenced code block
    alias fenced_code_start? fenced_code_start

    ## Title of a slide
    def slide_title; /^ *## (.*)#?#?/ =~ @line; $1; end

    ## Title of a slide
    alias slide_title? slide_title

    ## Title of a chapter
    def chapter_title; /^ *# (.*)#?/ =~ @line; $1; end

    ## Title of a chapter
    alias chapter_title? chapter_title

    ## Beginning of UML block
    def uml_start?; /^@startuml.*$/ =~ @line.strip; end
    def uml_start; /^@startuml\[(.*)\]$/ =~ @line; $1; end

    ## Beginning of UML block
    def uml_end?; /^@enduml$/ =~ @line.strip; end

    ## Forwarding of String's sub method
    def sub(pattern, replacement)
      @line.sub(pattern, replacement)
    end

    ## String representation
    def to_s; @line; end
  end
end