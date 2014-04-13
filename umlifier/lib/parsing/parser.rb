# -*- coding: utf-8 -*-

require_relative '../domain/diagram'
require_relative '../domain/types'
require_relative '../domain/connectors'
require_relative '../domain/visibility'
require_relative '../domain/member'
require_relative '../domain/term'
require_relative 'uml_line'

require 'stringio'

require_relative '../rendering/renderer_dot'

module Parsing
  class Parser

    ##
    # State of the parser
    class ParserState

      private

      STATE_CLASS          = 1
      STATE_INTERFACE      = 2
      STATE_INSTANCE       = 4
      STATE_NORMAL         = 8

      public

      attr_accessor :state, :line_counter, :diagram, :file_name, :current_type

      ##
      # Create a new object
      # @param [Domain::Diagram] diagram presentation to work on
      # @param [String] file_name name of the file being parsed
      def initialize(diagram, file_name)
        @diagram = diagram
        @state = STATE_NORMAL
        @line_counter = 0
        @file_name = file_name
        @current_type = nil
      end

      def instance?;   @state == STATE_INSTANCE; end
      def instance!;   @state = STATE_INSTANCE; end
      def clazz?;      @state == STATE_CLASS; end
      def clazz!;      @state = STATE_CLASS; end
      def interface?;  @state == STATE_INTERFACE; end
      def interface!;  @state = STATE_INTERFACE; end
      def normal?;     @state == STATE_NORMAL; end
      def normal!;     @state = STATE_NORMAL; end

      ##
      # Return the state of the parser as a string
      # @return [String] state of the parser as string
      def to_s
        "state: #{@state}, line: #{@line_counter}, file: #{@file_name}"
      end
    end

    ##
    # Parse a file
    # @param [Domain::Diagram] diagram presentation to work on
    # @param [String] file_name name of the file being parsed
    def parse(file_name, diagram)

      # Read whole file into an array to allow looking ahead
      lines = File.readlines(file_name, "\n", :encoding => 'UTF-8')
      parse_string(lines, file_name, diagram)
    end

    ##
    # Parse lines
    # @param [Domain::Diagram] diagram presentation to work on
    # @param [String] file_name name of the file being parsed
    # @param [Array] lines the contents to be parsed
    # @param [Fixnum] line_number the number of the first line in the file (for error output)
    def parse_string(lines, file_name, diagram, line_number = 0)

      ps = ParserState.new(diagram, file_name)
      ps.line_counter = line_number

      types = { }

      lines.each { |raw_line|

        line = UMLLine.new(raw_line)
        ps.line_counter = ps.line_counter + 1

        if line.comment_line?
          next

        elsif line.clazz? && ps.normal?
          handle_class_start(ps, line, types)

        elsif line.instance? && ps.normal?
          handle_instance_start(ps, line, types)

        elsif line.interface? && ps.normal?
          handle_interface_start(ps, line, types)

        elsif line.term? && ps.normal?
          handle_term(ps, line, types)

        elsif line.end_line? && (ps.clazz? || ps.interface? || ps.term?)
          ps.normal!

        elsif ps.clazz? || ps.interface?
          handle_type(ps, line, types)

        elsif line.link?
          handle_link(ps, line, types)

        elsif line.empty?
          next

        else
          raise Exception, "#{ps.file_name} [#{ps.line_counter}], #{ps}, #{line}"
        end
      }
    end

    ##
    # Handle class
    # @param [ParserState] ps
    # @param [UMLLine] line
    # @param [Hash] types
    def handle_class_start(ps, line, types)
      ps.clazz!

      if line.abstract_clazz?
        name = line.abstract_clazz.strip
        type = Domain::Clazz.new(name, true)
      else
        name = line.clazz.strip
        type = Domain::Clazz.new(name, false)
      end

      types[ name ] = type
      ps.current_type = type
      ps.diagram << type
    end

    ##
    # Handle instance
    # @param [ParserState] ps
    # @param [UMLLine] line
    # @param [Hash] types
    def handle_instance_start(ps, line, types)
      ps.clazz!

      name = line.instance.strip
      type = Domain::Instance.new(name)

      types[ name ] = type
      ps.current_type = type
      ps.diagram << type
    end

    ##
    # Handle type
    # @param [ParserState] ps
    # @param [UMLLine] line
    # @param [Hash] types
    def handle_type(ps, line, types)

      content = line.to_s.strip
      abstract = ps.current_type.instance_of?(Domain::Interface)
      static = false
      visibility = Domain::Visibility.parse(content)
      content = content[1..content.length]  if visibility
      member = nil

      if /\{abstract\}/ =~ content
        abstract = true
        content.gsub!(/\{abstract\}/, '')
      end

      if /\{static\}/ =~ content
        static = true
        content.gsub!(/\{static\}/, '')
      end

      if /\(.*\)/ =~ content

        if content.strip.start_with?(ps.current_type.name)
          member = Domain::Constructor.new(content.strip, visibility)
        else
          member = Domain::Method.new(content.strip, visibility, static, abstract)
        end

      else
        puts line
        member = Domain::Field.new(content.strip, visibility, static || ps.current_type.instance_of?(Domain::Interface))
      end

      ps.current_type << member
    end

    ##
    # Handle interface
    # @param [ParserState] ps
    # @param [UMLLine] line
    # @param [Hash] types
    def handle_interface_start(ps, line, types)
      ps.interface!
      name = line.interface.strip
      type = Domain::Interface.new(name)
      types[ name ] = type
      ps.current_type = type
      ps.diagram << type
    end

    ##
    # Handle term
    # @param [ParserState] ps
    # @param [UMLLine] line
    # @param [Hash] types
    def handle_term(ps, line, types)
      name = line.term.strip
      type = Domain::Term.new(name)
      types[ name ] = type
      ps.current_type = type
      ps.diagram << type
    end

    ##
    # Handle link between types
    # @param [ParserState] ps
    # @param [UMLLine] line
    # @param [Hash] types
    def handle_link(ps, line, types)

      content = line.to_s.strip
      connector = nil
      card_from, card_to, label = '', '', ''

      # Get cardinality
      # [card]--???--[card]
      if /.*?\[(.*?)\][-]{2,}.*?\[(.*?)\].*/ =~ content
        card_from = $1.strip
        card_to   = $2.strip
        content.gsub!(/\[.*?\]/, '')

      # --???--[card]
      elsif /.*?[-]{2,}.*?\[(.*?)\].*/ =~ content
        card_from = ''
        card_to   = $1.strip
        content.gsub!(/\[.*?\]/, '')

      # [card]--???--
      elsif /.*?\[(.*?)\][-]{2,}.*?.*/ =~ content
        card_from = $1.strip
        card_to   = ''
        content.gsub!(/\[.*?\]/, '')
      end

      # Get label
      # ???--<<label>>--???
      if /.*?[-]{2,}<<(.*?)>>[-]{2,}.*?/ =~ content
        label = "&laquo;#{$1.strip}&raquo;"
        content.gsub!(/<<.*?>>/, '')

      # ???--<<label>>--???
      elsif /.*?[-]{2,}<(.*?)>[-]{2,}.*?/ =~ content
        label = $1.strip
        content.gsub!(/<.*?>/, '')
      end

      ## Get arrow type
      # -!>
      if /(.*?)[-]{2,}!>(.*)/ =~ content
        from = type($1, types, ps)
        to = type($2, types, ps)

        if from.instance_of?(Domain::Clazz) && to.instance_of?(Domain::Interface)
          connector = Domain::Implementation.new(from, to)
        else
          connector = Domain::Inheritance.new(from, to)
        end

      # -<>
      elsif /(.*?)[-]{2,}<>(.*)/ =~ content
        connector = Domain::Aggregation.new(type($1, types, ps), type($2, types, ps),
                label, card_from, card_to)

      # -<#>
      elsif /(.*?)[-]{2,}<#>(.*)/ =~ content
        connector = Domain::Composition.new(type($1, types, ps), type($2, types, ps),
                                            label, card_from, card_to)

      # -.>
      elsif /(.*?)[-]{2,}\.>(.*)/ =~ content
        connector = Domain::Relation.new(type($1, types, ps), type($2, types, ps),
                                            label, card_from, card_to)

      # ->
      elsif /(.*?)[-]{2,}>(.*)/ =~ content
        connector = Domain::DirectedAssociation.new(type($1, types, ps), type($2, types, ps),
                                            label, card_from, card_to)

      # --
      elsif /(.*?)[-]{2,}(.*)/ =~ content
        connector = Domain::Association.new(type($1, types, ps), type($2, types, ps),
                                            label, card_from, card_to)
      end

      ps.diagram << connector
    end

    def type(name, types, ps)
      type = types[ name.strip ]

      if type.nil?
        type = Domain::Term.new(name.strip)
        ps.diagram << type
      end

      type
    end
  end
end
