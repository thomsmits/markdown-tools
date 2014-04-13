# -*- coding: utf-8 -*-

require_relative '../../lib/domain/chapter'
require_relative '../../lib/domain/slide'
require_relative '../../lib/domain/comment'
require_relative '../../lib/domain/presentation'
require_relative '../../lib/domain/comment'
require_relative '../../lib/domain/line_elements'
require_relative '../../lib/domain/block_elements'
require_relative '../../lib/domain/license'
require_relative '../constants'

require_relative 'markdown_line'
require_relative 'line_matcher'
require_relative 'properties_reader'

require 'stringio'

module Parsing

  ##
  # Parser for markdown presentation files. The files parsed by this
  # class are normal markdown files with special tags possible to use
  # them in presentations.
  class Parser

    public

    ##
    # Create a new parser
    def initialize
      @chapter_counter = 0
      @page_counter = 3
    end

    ##
    # Generate the id for a slide
    # @param [Fixnum] slide_counter slide counter
    # @return [String] an id for the slide
    def slide_id(slide_counter)
      "slide_id_#{@chapter_counter}_#{slide_counter}"
    end

    ##
    # Parse the given file
    # @param [String] file_name File to be parsed
    # @param [String] default_language language for code blocks not tagged
    # @param [Domain::Presentation] presentation Storage of results

    def parse(file_name, default_language, presentation)

      begin
        ps = ParserState.new(presentation, file_name)

        ps.language = default_language

        # Read whole file into an array to allow looking ahead
        lines = File.readlines(file_name, "\n", :encoding => 'UTF-8')

        ps.comment_mode = false

        lines.each { |raw_line|

          line = MarkdownLine.new(raw_line)
          ps.line_counter = ps.line_counter + 1
          ps.line_id = "id_#{@chapter_counter}_#{ps.line_counter}"

          if line.separator? && !ps.code_or_code_fenced?
            # ---
            handle_separator(ps)

          elsif line.vspace? && !ps.code_or_code_fenced?
            # <br>
            add_to_slide(ps.slide, Domain::VerticalSpace.new, ps.comment_mode)

          elsif line.chapter_title? && !ps.code_or_code_fenced?
            # # Chapter Title
            handle_chapter_title(ps, line)

          elsif line.slide_title? && !ps.code_or_code_fenced?
            # ## Slide Title
            handle_slide_title(ps, line)

          elsif line.fenced_code_start? && !ps.code_fenced?
            # ```code
            handle_code_fenced_start(ps, line)

          elsif line.fenced_code_end? && ps.code_fenced?
            # ```
            ps.normal!

          elsif line.script_end? && ps.script?
            # </script>
            ps.normal!

          elsif ps.script?
            # inside <script>...</script>
            append(ps.slide, line, ps.comment_mode)

          elsif line.script_start? && !ps.code_or_code_fenced?
            # <script>
            add_to_slide(ps.slide, Domain::Script.new, ps.comment_mode)
            ps.script!

          elsif line.equation_start? && !ps.equation?
            # \[
            handle_equation_start(ps)

          elsif line.equation_end? && ps.equation?
            # \]
            ps.normal!

          elsif ps.equation?
            append(ps.slide, line, ps.comment_mode)

          elsif line.uml_start? && !ps.uml?
            # @startuml
            handle_uml_start(ps, line)

          elsif line.uml_end? && ps.uml?
            # @enduml
            ps.normal!

          elsif ps.uml?
            append(ps.slide, line, ps.comment_mode)

          elsif line.ol1? && !ps.code_or_code_fenced?
            #   1. item
            handle_ol1(ps, line)

          elsif line.ol2? && !ps.code_or_code_fenced?
            #     1. item
            handle_ol2(ps, line)

          elsif line.ol3? && !ps.code_or_code_fenced?
            #       1. item
            handle_ol3(ps, line)

          elsif line.ul2? && ps.code?
            # special case. Code starts with a * sign
            handle_code_with_stars(ps, line)

          elsif line.ul1? && !ps.code_or_code_fenced?
            #   * Item
            handle_ul1(ps, line)

          elsif line.ul2? && !ps.code_or_code_fenced?
            handle_ul2(ps, line)

          elsif line.ul3? && !ps.code_or_code_fenced?
            handle_ul3(ps, line)

          elsif line.source? && !ps.code_or_code_fenced? && !line.empty?
            handle_source_start(ps, line)

          elsif line.source? && ps.code? && !line.empty?
            handle_source(ps, line)

          elsif ps.code? && line.empty?
            handle_source_lookahead(ps, lines)

          elsif ps.code_fenced?
            append(ps.slide, line, ps.comment_mode)

          elsif line.quote? || line.quote_source?
            # > Quote
            handle_quote(ps, line)

          elsif line.important?
            # >! Important text
            handle_important(ps, line)

          elsif line.table_row?
            # | Table | Table |
            handle_table(ps, line)

          else
            # Other cases (simple inline matches)
            handle_inline(ps, line)

          end
        }
      rescue Exception => e
        puts e
        puts ps
        exit(-1)
      end
    end

    private

    ##
    # State of the parser
    class ParserState

      private

      STATE_NORMAL      = 1
      STATE_CODE        = 2
      STATE_CODE_FENCED = 3
      STATE_UL1         = 4
      STATE_UL2         = 5
      STATE_UL3         = 6
      STATE_OL1         = 7
      STATE_OL2         = 8
      STATE_OL3         = 9
      STATE_SCRIPT      = 10
      STATE_TABLE       = 11
      STATE_QUOTE       = 12
      STATE_EQUATION    = 13
      STATE_UML         = 14

      public

      attr_accessor :state, :line_counter, :line_id, :comment_mode, :slide, \
          :chapter, :language, :current_list, :slide_counter, :presentation, \
          :file_name

      ##
      # Create a new object
      # @param [Domain::Presentation] presentation presentation to work on
      # @param [String] file_name name of the file being parsed
      def initialize(presentation, file_name)
        @presentation = presentation
        @state = STATE_NORMAL
        @line_counter = 0
        @slide_counter = 0
        @file_name = file_name
        @comment_mode = false
        @chapter = nil
        @slide = nil
      end

      ## inside a code section
      def code_or_code_fenced?; @state == STATE_CODE || @state == STATE_CODE_FENCED; end

      ## normal/default state?
      def normal?;      @state == STATE_NORMAL; end

      ## switch to normal/default state
      def normal!;      @state =  STATE_NORMAL; end

      ## inside a fenced code block?
      def code_fenced?; @state == STATE_CODE_FENCED; end

      ## switch to inside a fenced code block
      def code_fenced!; @state =  STATE_CODE_FENCED; end

      ## inside a normal code block?
      def code?;        @state == STATE_CODE; end

      ## switch to normal code block
      def code!;        @state =  STATE_CODE; end

      ## inside a script?
      def script?;      @state == STATE_SCRIPT; end

      ## switch to inside a script
      def script!;      @state =  STATE_SCRIPT; end

      ## inside an equation
      def equation?;    @state == STATE_EQUATION; end

      ## switch to inside an equation
      def equation!;    @state =  STATE_EQUATION; end

      ## inside a unordered list level 1?
      def ul1?;         @state == STATE_UL1; end

      ## switch to inside a unordered list level 1
      def ul1!;         @state =  STATE_UL1; end

      ## inside a unordered list level 2?
      def ul2?;         @state == STATE_UL2; end

      ## switch to inside a unordered list level 2
      def ul2!;         @state =  STATE_UL2; end

      ## inside a unordered list level 3?
      def ul3?;         @state == STATE_UL3; end

      ## switch to inside a unordered list level 3
      def ul3!;         @state =  STATE_UL3; end

      ## inside a ordered list level 1?
      def ol1?;         @state == STATE_OL1; end

      ## switch to inside a ordered list level 1
      def ol1!;         @state =  STATE_OL1; end

      ## inside a ordered list level 2?
      def ol2?;         @state == STATE_OL2; end

      ## switch to inside a ordered list level 2
      def ol2!;         @state =  STATE_OL2; end

      ## inside a ordered list level 3?
      def ol3?;         @state == STATE_OL3; end

      ## switch to inside a ordered list level 3
      def ol3!;         @state =  STATE_OL3; end

      ## inside a table?
      def table?;       @state == STATE_TABLE; end

      ## switch to inside a table
      def table!;       @state =  STATE_TABLE; end

      ## inside a quote?
      def quote?;       @state == STATE_QUOTE; end

      ## switch to inside a quote
      def quote!;       @state =  STATE_QUOTE; end

      ## inside a UML block?
      def uml?;         @state == STATE_UML; end

      ## switch to inside a UML block
      def uml!;         @state =  STATE_UML; end

      ##
      # Return the state of the parser as a string
      # @return [String] state of the parser as string
      def to_s
        "state: #{@state}, line: #{@line_counter}, comment: #{@comment_mode}, " \
        "chapter: #{@chapter}, slide: #{@slide}, slide_counter: #{@slide_counter}"
      end
    end


    ##
    # Adds an element to the given slide.
    # @param [Domain::Slide] slide the slide to be used
    # @param [Domain::Element] element element to be added to slide
    # @param [Boolean] comment_mode indicator for comment mode
    def add_to_slide(slide, element, comment_mode)
      if comment_mode
        slide.current_element.add(element)
      else
        slide.add(element)
      end
    end

    ##
    # Adds a text line to the given slide.
    # @param [Domain::Slide] slide the slide to be used
    # @param [Parser::MarkdownLine] line to be added
    # @param [Boolean] comment_mode indicator for comment mode
    def append(slide, line, comment_mode)
      current_element(slide, comment_mode).append(line.string)
    end

    ##
    # Returns the active element of the slide.
    # @param [Domain::Slide] slide the slide to be used
    # @param [Boolean] comment_mode indicator for comment mode
    # @return [Domain::Element] the active element
    def current_element(slide, comment_mode)
      if comment_mode
          slide.current_element.current_element
      else
          slide.current_element
      end
    end

    ##
    # Handle the separator string "---" which indicates the beginning
    # of the comment section of the slide
    # @param [ParserState] ps State of the parser
    def handle_separator(ps)
      ps.comment_mode = true
      ps.slide.add(Domain::Comment.new)
    end

    ##
    # Chapter title "# title"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def handle_chapter_title(ps, line)
      @chapter_counter += 1
      @page_counter += 1
      id = "chap_#{@chapter_counter}"
      ps.chapter = Domain::Chapter.new(line.chapter_title, id)
      ps.presentation.add(ps.chapter)
      ps.normal!
      ps.comment_mode = false
    end

    ##
    # Slide title "## title"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def handle_slide_title(ps, line)
      skip = line.skipped_slide?
      ps.slide_counter += 1
      ps.slide = Domain::Slide.new(slide_id(ps.slide_counter),
          line.slide_title, @page_counter, skip)
      ps.chapter.add_slide(ps.slide)
      ps.normal!
      ps.comment_mode = false
      @page_counter += 1  unless skip
    end

    ##
    # Beginning of a fenced (GitHub style) code block "```language"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def handle_code_fenced_start(ps, line)
      language_hint = line.fenced_code_start
      caption = line.fenced_code_caption
      order = 0

      if line.fenced_code_order?
        order = line.fenced_code_order.to_i
      end

      add_to_slide(ps.slide, Domain::Source.new(language_hint, caption, order), ps.comment_mode)
      ps.code_fenced!
    end

    ##
    # Ordered list on level 1
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def handle_ol1(ps, line)
      start_number = line.ol1_number

      if ps.ol2? || ps.ul2? || ps.ol3? || ps.ul3?
        ps.current_list = ps.current_list.parent
      elsif !ps.ol1?
        ps.current_list = Domain::OrderedList.new(start_number)
        add_to_slide(ps.slide, ps.current_list, ps.comment_mode)
      end

      ps.current_list.append(line.ol1)
      ps.ol1!
    end

    ##
    # Ordered list on level 2
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def handle_ol2(ps, line)

      start_number = line.ol2_number

      if ps.ol3? || ps.ul3?
        ps.current_list = ps.current_list.parent
      elsif !ps.ol2?
        list = Domain::OrderedList.new(start_number)
        ps.current_list.add(list)
        ps.current_list = list
      end

      ps.current_list.append(line.ol2)
      ps.ol2!
    end

    ##
    # Ordered list on level 3
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def handle_ol3(ps, line)
      if !ps.ol3?
        list = Domain::OrderedList.new(start_number)
        ps.current_list.add(list)
        ps.current_list = list
      end

      ps.current_list.append(line.ol3)
      ps.ol3!
    end

    ##
    # Unordered list on level 1
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def handle_ul1(ps, line)
      if ps.ol2? || ps.ul2? || ps.ol3? || ps.ul3?
        ps.current_list = ps.current_list.parent
      elsif !ps.ul1?
        ps.current_list = Domain::UnorderedList.new
        add_to_slide(ps.slide, ps.current_list, ps.comment_mode)
      end

      ps.current_list.append(line.ul1)
      ps.ul1!
    end

    ##
    # Unordered list on level 2
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def handle_ul2(ps, line)
      if ps.ol3? || ps.ul3?
        ps.current_list = ps.current_list.parent
      elsif !ps.ul2?
        list = Domain::UnorderedList.new
        ps.current_list.add(list)
        ps.current_list = list
      end

      ps.current_list.append(line.ul2)
      ps.ul2!
    end

    ##
    # Unordered list on level 3
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def handle_ul3(ps, line)
      if !ps.ul3?
        list = Domain::UnorderedList.new
        ps.current_list.add(list)
        ps.current_list = list
      end

      ps.current_list.append(line.ul3)
      ps.ul3!
    end

    ##
    # Quotes "> Quote"
    # @param [ParserState] ps State of the parser
    def handle_quote(ps, line)
      if !ps.quote?
        quote = Domain::Quote.new
        quote.append(line.sub(/> /, ''))
        add_to_slide(ps.slide, quote, ps.comment_mode)
        ps.quote!
      elsif ps.quote?

        quote = current_element(ps.slide, ps.comment_mode)

        if line.quote_source?
          quote.source = line.sub(/>> /, '')
        else
          quote.append(line.sub(/> /, ''))
        end
      end
    end

    ##
    # Important section ">! Text"
    # @param [ParserState] ps State of the parser
    def handle_important(ps, line)
      if !ps.quote?
        element = Domain::Important.new
        element.append(line.sub(/>! /, ''))
        add_to_slide(ps.slide, element, ps.comment_mode)
        ps.quote!
      elsif ps.quote?
        element = current_element(ps.slide, ps.comment_mode)
        element.append(line.sub(/>! /, ''))
      end
    end

    ##
    # Table "| a | b | c |"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def handle_table(ps, line)

      # remove quoted table separators
      cleaned_line = line.string.gsub('\|', '~~pipe~~')

      if !ps.table?
        table = Domain::Table.new

        columns = cleaned_line.split('|')

        columns.each { |e|
          if /^[ ]{2,}.*[ ]{2,}$/ =~ e
            alignment = Constants::CENTER
          elsif /^[ ]{2,}.*[ ]{1}$/ =~ e
            alignment = Constants::RIGHT
          elsif /^[ ]{1}.*[ ]{1,}$/ =~ e
            alignment = Constants::LEFT
          elsif /^!$/ =~ e
            alignment = Constants::SEPARATOR
          else
            alignment = Constants::LEFT
          end

          table.add_header(e.strip.gsub('~~pipe~~', '|') , alignment)  if e.strip.length > 0
        }

        add_to_slide(ps.slide, table, ps.comment_mode)
        ps.table!

      elsif ps.table?
        # skip separator line
        return  if line.table_separator?

        # Split columns and add them to the table
        columns = cleaned_line.split('|')
        row = [ ]
        columns.each { |e| row << e.gsub('~~pipe~~', '|')  if e.strip.length > 0 }
        current_element(ps.slide, ps.comment_mode).add_row(row)
      end
    end

    ##
    # Beginning of an equation "\["
    # @param [ParserState] ps State of the parser
    def handle_equation_start(ps)
      add_to_slide(ps.slide, Domain::Equation.new(), ps.comment_mode)
      ps.equation!
    end

    ##
    # Beginning of an uml section
    # @param [ParserState] ps State of the parser
    def handle_uml_start(ps, line)
      picture_name = "uml_#{ps.line_id}"

      width = line.uml_start
      add_to_slide(ps.slide, Domain::UML.new(picture_name, width), ps.comment_mode)
      ps.uml!
    end

    ##
    # Beginning of a source code section "     int i = 5"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def handle_source_start(ps, line)
      add_to_slide(ps.slide, Domain::Source.new(ps.language), ps.comment_mode)
      line.trim_code_prefix!
      append(ps.slide, line, ps.comment_mode)
      ps.code!
    end

    ##
    # Source line
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def handle_source(ps, line)
      line.trim_code_prefix!
      append(ps.slide, line, ps.comment_mode)
    end

    ##
    # Lookahead for the special case of empty lines inside a source
    # section (goes beyond Markdown standard)
    # @param [ParserState] ps State of the parser
    # @param [Array] lines Lines of input
    def handle_source_lookahead(ps, lines)
      no_more_source = true
      i = ps.line_counter

      while i < lines.length
        peek_line = MarkdownLine.new(lines[i])

        if peek_line.source?
          no_more_source = false
          break
        elsif peek_line.normal?
          break
        end

        i += 1
      end

      if no_more_source
        ps.normal!
      else
        append(ps.slide, MarkdownLine.new("\n"), ps.comment_mode)
      end
    end

    ##
    # Handling of line elements, i.e. elements that occupy only a single
    # line in the markdown file
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def handle_inline(ps, line)
      e = LineMatcher.match(line.string, ps.line_id)

      if !e.nil?
        add_to_slide(ps.slide, e, ps.comment_mode)

        if e.instance_of?(Domain::Image)
          # for image, read available extensions
          e.formats = get_extensions(e.location)
          e.license = get_license(e.location)
        end
      else
        if line.normal?

          if line.text?
            add_to_slide(ps.slide, Domain::Text.new(line.string), ps.comment_mode)
          end
          ps.normal!
        elsif line.empty?
          if ps.ul1? || ps.ul2?
            return
          end
          ps.normal!
        else
          raise Exception, "#{ps.file_name} [#{ps.line_counter}], #{ps}, #{line}"
        end
      end
    end

    ##
    # Special case when a code fragment starts with a single star (can happen
    # with css). In this case we need to avoid the detection of the code
    # as a ul2
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def handle_code_with_stars(ps, line)
      str_line = line.string
      str_line = str_line[4..-1]  if str_line.length > 4
      append(ps.slide, MarkdownLine.new(str_line), ps.comment_mode)
    end

    ##
    # Return a filename without extension
    def get_path_and_name(file)

      basename = File.basename(file)

      if /.*?(\.[a-zA-Z]{3,4})/ =~ basename
        basename.gsub!($1, '')
      end

      dirname = File.dirname(file)

      return dirname, basename

    end

    ##
    # Returns all available extensions (file formats) for a given file
    # @param [String] file the name of the file (with or without extensions)
    # @return [Array] all found extensions for the name
    def get_extensions(file)

      extensions = [ ]

      dirname, basename = get_path_and_name(file)
      dir = Dir.new(dirname)

      dir.each { |f|
        if f.start_with?(basename)
          /.*?\.([a-zA-Z]{3,4})/ =~f
          extensions << $1
        end
      }

      extensions
    end

    ##
    # Returns the license information for the image.
    # @param [String] file the name of the file (with or without extensions)
    # @return [Domain::License] license of the image
    def get_license(file)

      dirname, basename = get_path_and_name(file)
      license_file = "#{dirname}/#{basename}.txt"

      if File.exist?(license_file)
        license = Domain::License.create_from_props(PropertiesReader.new(license_file, ':'))
      else
        license = nil
      end

      license
    end
  end
end
