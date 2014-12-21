# -*- coding: utf-8 -*-


module Parsing

  ##
  # State of the parser
  class ParserState

    public

    attr_accessor :state, :line_counter, :comment_mode, :slide, \
            :chapter, :language, :current_list, :slide_counter, :presentation, \
            :file_name, :chapter_counter

    ##
    # Create a new object
    # @param [Domain::Presentation] presentation presentation to work on
    # @param [String] file_name name of the file being parsed
    # @param [Fixnum] slide_counter start value of the slide numbers
    # @param [Symbol[]] states all possible states
    def initialize(presentation, file_name, slide_counter, *states)
      @presentation = presentation
      @state = states[0]
      @line_counter = 0
      @slide_counter = slide_counter
      @file_name = file_name
      @comment_mode = false
      @chapter = nil
      @slide = nil
      @chapter_counter = 0
      @possible_states = states
    end

    ##
    # Catch missing methods. Due to the fact that the parser can have a large
    # amount of different states, it is cumbersome to add them all as methods
    # to this class. To avoid this, the methods are created using the +missing_method+
    # method, which allows intercepting calls to non-existing methods.
    # @param [String] name Name of the method
    def method_missing(name, *args, &block)
      state = name.to_s.upcase.gsub(/\?|!/, '')
      symbol = state.to_sym

      raise "Unknown Method #{name}"  unless @possible_states.include?(symbol)

      if name.to_s.end_with?('!')
        @state = symbol
      elsif name.to_s.end_with?('?')
        @state == symbol
      else
        raise "Unknown Method #{name}"
      end
    end

    ##
    # Return an ID for the current line
    # @return [String] ID of the line
    def line_id
      "id_#{@chapter_counter}_#{@line_counter}"
    end

    ##
    # Return the state of the parser as a string
    # @return [String] state of the parser as string
    def to_s
      "state: #{@state}, line: #{@line_counter}, comment: #{@comment_mode}, " \
          "chapter: #{@chapter}, slide: #{@slide}, slide_counter: #{@slide_counter}"
    end
  end
end
