require 'stringio'

require_relative '../../lib/domain/chapter'
require_relative '../../lib/domain/slide'
require_relative '../../lib/domain/comment'
require_relative '../../lib/domain/presentation'
require_relative '../../lib/domain/comment'
require_relative '../../lib/domain/element'
require_relative '../../lib/domain/license'
require_relative '../constants'

require_relative 'markdown_line'
require_relative 'line_matcher'
require_relative 'properties_reader'
require_relative 'parser_state'
require_relative 'parser_handler'
require_relative 'line_parser'

module Parsing
  ##
  # Extend parser state class with a useful method combining two states
  class ParserState
    ## Inside a code section
    #
    # @return [Boolean] if we are in a code or a fenced code section
    def code_or_code_fenced?
      code? || code_fenced?
    end
  end

  ##
  # Parser for markdown presentation files. The files parsed by this
  # class are normal markdown files with special tags possible to use
  # them in presentations.
  class Parser
    ##
    # Create a new parser
    # @param [Fixnum] count_front_matter number of pages of front matter
    # @param [ParserHandler] parser_handler for parser actions
    def initialize(count_front_matter, parser_handler = ParserHandler.new)
      @last_slide_counter = count_front_matter
      @parser_handler = parser_handler
      @chapter_counter = 0
    end

    ##
    # Parse the given string or file into the given presentation.
    # @param [Array<String>] lines input to be parsed
    # @param [String] file_name File to be parsed
    # @param [String] def_prog_lang language for code blocks not tagged
    # @param [Domain::Presentation] presentation Storage of results
    def parse_lines(lines, file_name, def_prog_lang, presentation)
      begin
        ps = ParserState.new(presentation, file_name, @last_slide_counter,
                             :NORMAL,
                             :CODE_FENCED,
                             :CODE,
                             :SCRIPT,
                             :EQUATION,
                             :UL1,
                             :UL2,
                             :UL3,
                             :OL1,
                             :OL2,
                             :OL3,
                             :TABLE,
                             :QUOTE,
                             :UML,
                             :IMPORTANT,
                             :QUESTION,
                             :BOX,
                             :MATCHING_QUESTION)

        ps.prog_lang = def_prog_lang
        ps.comment_mode = false
        ps.chapter_counter = @chapter_counter

        handler = @parser_handler

        lines.each do |raw_line|
          line = MarkdownLine.new(raw_line)
          ps.line_counter = ps.line_counter + 1

          if line.code_include? && !ps.code_or_code_fenced?
            # !INCLUDESRC[x] "path" prog_lang
            handler.code_include(ps, line)

          elsif line.multiple_choice?
            # [ ] Question 1 or [X] Question
            handler.multiple_choice(ps, line)

          elsif line.separator? && !ps.code_or_code_fenced? && !ps.comment_mode
            # ---
            handler.separator(ps, line)

          elsif line.separator? && !ps.code_or_code_fenced? && ps.comment_mode
            # ---
            ps.comment_mode = false

          elsif line.vertical_space? && !ps.code_or_code_fenced?
            # <br>
            handler.vertical_space?(ps, line)

          elsif line.chapter_title? && !ps.code_or_code_fenced?
            # # Chapter Title
            handler.chapter_title(ps, line)

          elsif line.slide_title? && !ps.code_or_code_fenced?
            # ## Slide Title
            handler.slide_title(ps, line)

          elsif line.fenced_code_start? && !ps.code_fenced?
            # ```code
            handler.code_fenced_start(ps, line)

          elsif line.fenced_code_end? && ps.code_fenced?
            # ```
            ps.normal!

          elsif line.script_end? && ps.script?
            # </script>
            ps.normal!

          elsif ps.script?
            # inside <script>...</script>
            handler.script_line(ps, line)

          elsif line.script_start? && !ps.code_or_code_fenced?
            # <script>
            handler.script_start(ps, line)

          elsif line.equation_start? && !ps.equation?
            # \[
            handler.equation_start(ps, line)

          elsif line.equation_end? && ps.equation?
            # \]
            ps.normal!

          elsif ps.equation?
            handler.equation_line(ps, line)

          elsif line.uml_start? && !ps.uml?
            # @startuml
            handler.uml_start(ps, line)

          elsif line.uml_end? && ps.uml?
            # @enduml
            ps.normal!

          elsif ps.uml?
            handler.uml_line(ps, line)

          elsif line.matching_question_start?
            # <!-- SHUFFLE type="questions" -->
            handler.matching_question_start(ps, line)

          elsif ps.matching_question? && !line.matching_question?
            ps.normal!

          elsif ps.matching_question? && line.matching_question?
            handler.matching_question(ps, line)

          elsif line.ol1? && !ps.code_or_code_fenced?
            #   1. item
            handler.ol1(ps, line)

          elsif line.ol2? && !ps.code_or_code_fenced?
            #     1. item
            handler.ol2(ps, line)

          elsif line.ol3? && !ps.code_or_code_fenced?
            #       1. item
            handler.ol3(ps, line)

          elsif line.ul2? && ps.code?
            # special case. Code starts with a * sign
            handler.code_with_stars(ps, line)

          elsif line.ul1? && !ps.code_or_code_fenced?
            #   * Item
            handler.ul1(ps, line)

          elsif line.ul2? && !ps.code_or_code_fenced?
            handler.ul2(ps, line)

          elsif line.ul3? && !ps.code_or_code_fenced?
            handler.ul3(ps, line)

          elsif line.source? && !ps.code_or_code_fenced? && !line.empty?
            handler.source_start(ps, line)

          elsif line.source? && ps.code? && !line.empty?
            handler.source_line(ps, line)

          elsif ps.code? && line.empty?
            handler.source_lookahead(ps, lines)

          elsif ps.code_fenced?
            handler.fenced_code_line(ps, line)

          elsif line.quote? || line.quote_source?
            # > Quote
            handler.quote(ps, line)

          elsif line.important?
            # >! Important text
            handler.important(ps, line)

          elsif line.question?
            # >? Question text
            handler.question(ps, line)

          elsif line.box?
            # >: Generic box
            handler.box(ps, line)

          elsif line.table_row?
            # | Table | Table |
            handler.table(ps, line)

          elsif line.space_comment?
            # <!-- Spacing: xx -->
            handler.space_comment(ps, line)

          elsif line.comment? && !line.image? && !line.input_question?
            # <!-- --> but not after an image, to allow image dimensions
            # in comments.
            handler.comment(ps, line)

          else
            # Other cases (simple inline matches)
            handler.inline(ps, line)

          end
        rescue StandardError => e
          warn "#####################################"
          warn "An error occured"
          warn "File: #{file_name}"
          warn "Line: #{ps.line_counter}"
          warn "Code: #{e.backtrace_locations[0]}"
          warn "#####################################"
          exit(-1)
        end
      end

      # As chapters may be parsed separately, with new invocations of the
      # parse method, the counter of the last slide of the previous chapter
      # needs to be saved to ensure correct slide numbering
      @last_slide_counter = ps.slide_counter
      @chapter_counter = ps.chapter_counter
    end

    ##
    # Parse the given file
    # @param [String] file_name File to be parsed
    # @param [String] def_prog_lang language for code blocks not tagged
    # @param [Domain::Presentation] presentation Storage of results
    def parse(file_name, def_prog_lang, presentation)
      # Read whole file into an array to allow looking ahead
      lines = File.readlines(file_name, "\n", encoding: 'UTF-8')
      parse_lines(lines, file_name, def_prog_lang, presentation)
    end

    ##
    # Perform a second pass to replace links and footnotes in the reference.
    # Split up the text of the elements into node lists.
    # Format (i.e. [...] and [^...]) with inline versions.
    # @param [Domain::Presentation] presentation Storage of results
    def second_pass(presentation)
      line_parser = Parsing::LineParser.new

      presentation.each do |chapter|
        links = chapter.links
        chapter.each do |slide|
          footnotes = slide.footnotes

          footnotes.each do |footnote|
            footnote.nodes  = line_parser.parse(footnote.content, footnotes)
          end

          slide.each_content_element do |element, type, content|

            # Types of content to do the inline replacement with
            if [Domain::Text,
                Domain::OrderedListItem,
                Domain::UnorderedListItem,
                Domain::Quote,
                Domain::Question,
                Domain::Box,
                Domain::Important,
                Domain::MultipleChoice].include? type

              links.each do |link|
                ref, inline = MarkdownLine.link_ref_to_inline(link)
                content.gsub!(ref, inline)
              end

              # Parse the contents of the elements into nodes
              element.nodes = line_parser.parse(element.content, footnotes)

              # A quote may have an additional source field
              element.source_nodes = line_parser.parse(element.source, footnotes) if type == Domain::Quote && !element.source.nil?
            end

            if [Domain::Table].include? type
              # Parse table contents
              element.headers.each do |header|
                header.nodes = line_parser.parse(header.content, footnotes)
              end

              element.rows.each do |row|
                # Separator?
                next if row.nil?

                row.each do |cell|
                  cell.nodes = line_parser.parse(cell.content, footnotes)
                end
              end
            end
          end
        end
      end
    end
  end
end
