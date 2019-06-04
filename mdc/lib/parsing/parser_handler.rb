require_relative '../../lib/domain/chapter'
require_relative '../../lib/domain/slide'
require_relative '../../lib/domain/comment'
require_relative '../../lib/domain/presentation'
require_relative '../../lib/domain/comment'

require_relative '../../lib/domain/line_element'
require_relative '../../lib/domain/button'
require_relative '../../lib/domain/button_with_log'
require_relative '../../lib/domain/button_with_log_pre'
require_relative '../../lib/domain/heading'
require_relative '../../lib/domain/image'
require_relative '../../lib/domain/button_link_previous'
require_relative '../../lib/domain/button_live_css'
require_relative '../../lib/domain/button_live_preview'
require_relative '../../lib/domain/button_live_preview_float'
require_relative '../../lib/domain/multiple_choice'
require_relative '../../lib/domain/vertical_space'

require_relative '../../lib/domain/block_element'
require_relative '../../lib/domain/box'
require_relative '../../lib/domain/equation'
require_relative '../../lib/domain/important'
require_relative '../../lib/domain/html'
require_relative '../../lib/domain/multiple_choice_question'
require_relative '../../lib/domain/ordered_list'
require_relative '../../lib/domain/ordered_list_item'
require_relative '../../lib/domain/question'
require_relative '../../lib/domain/quote'
require_relative '../../lib/domain/script'
require_relative '../../lib/domain/source'
require_relative '../../lib/domain/table'
require_relative '../../lib/domain/text'
require_relative '../../lib/domain/uml'
require_relative '../../lib/domain/unordered_list'
require_relative '../../lib/domain/unordered_list_item'
require_relative '../../lib/domain/license'
require_relative '../constants'

require_relative 'line_matcher'

module Parsing
  ##
  # Callback handler for the parser
  class ParserHandler
    ##
    # Create a new instance
    # @param [Bool] test_mode indicates that the handler is
    #    tested and should not perform any file access
    def initialize(test_mode = false)
      @test_mode = test_mode
    end

    ##
    # Copy a line to the document
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def copy_line_to_document(ps, line)
      element(ps) << line.string
    end

    alias script_line copy_line_to_document
    alias uml_line copy_line_to_document
    alias fenced_code_line copy_line_to_document
    alias equation_line copy_line_to_document

    ##
    # Beginning of a script
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] _line Line of input
    def script_start(ps, _line)
      slide(ps) << Domain::Script.new
      ps.script!
    end

    ##
    # Insert a vertical space into the document
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] _line Line of input
    def vertical_space?(ps, _line)
      slide(ps) << Domain::VerticalSpace.new
    end

    ##
    # Handle the separator string "---" which indicates the beginning
    # of the comment section of the slide
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] _line Line of input
    def separator(ps, _line)
      slide(ps) << Domain::Comment.new
      ps.comment_mode = true
    end

    ##
    # Chapter title "# title"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def chapter_title(ps, line)
      ps.chapter_counter += 1
      id = "chap_#{ps.chapter_counter}"
      ps.slide_counter += 1
      ps.chapter = Domain::Chapter.new(line.chapter_title.delete('#'), id)
      ps.presentation << ps.chapter
      ps.normal!
      ps.comment_mode = false
    end

    ##
    # Slide title "## title"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def slide_title(ps, line)
      skip = line.skipped_slide?
      ps.slide_counter += 1 unless skip
      title = line.slide_title.delete('#').gsub('--skip--', '').strip
      ps.slide = Domain::Slide.new(slide_id(ps.slide_counter),
                                   title, ps.slide_counter, skip)

      unless ps.chapter
        raise "No chapter here to add '#{title}'. Maybe the " +
              "#-Heading is missing at beginning of file '#{ps.file_name}'."
      end

      ps.chapter << ps.slide
      ps.normal!
      ps.comment_mode = false
    end

    ##
    # Include code from an external file and transform
    # it to a fenced code block
    #
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def code_include(ps, line)
      path, first_line, language_hint = line.code_include

      source = File.readlines(path, "\n", encoding: 'UTF-8')
      caption = ''
      order = 0

      slide(ps) << Domain::Source.new(language_hint, caption, order)

      ## Add the included source to the slide
      source.each_with_index do |src_line, i|
        element(ps) << src_line if i + 1 >= first_line
      end
    end

    ##
    # Beginning of a fenced (GitHub style) code block "```language"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def code_fenced_start(ps, line)
      language_hint = line.fenced_code_start
      caption = line.fenced_code_caption
      order = 0

      order = line.fenced_code_order.to_i if line.fenced_code_order?

      slide(ps) << Domain::Source.new(language_hint, caption, order)

      ps.code_fenced!

      # increase slide counter to account for additional slide numbers generated
      # through the animations
      ps.slide_counter += order
    end

    ##
    # Ordered list on level 1
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def ol1(ps, line)
      start_number = line.ol1_number.to_i

      if ps.ol2? || ps.ul2? || ps.ol3? || ps.ul3?
        ps.current_list = ps.current_list.parent
      elsif !ps.ol1?
        ps.current_list = Domain::OrderedList.new(start_number)
        slide(ps) << ps.current_list
      end

      ps.current_list << line.ol1
      ps.ol1!
    end

    ##
    # Ordered list on level 2
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def ol2(ps, line)
      start_number = line.ol2_number.to_i

      if ps.ol3? || ps.ul3?
        ps.current_list = ps.current_list.parent
      elsif !ps.ol2?
        list = Domain::OrderedList.new(start_number)
        ps.current_list.add(list)
        ps.current_list = list
      end

      ps.current_list << line.ol2
      ps.ol2!
    end

    ##
    # Ordered list on level 3
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def ol3(ps, line)
      unless ps.ol3?
        list = Domain::OrderedList.new(start_number)
        ps.current_list.add(list)
        ps.current_list = list
      end

      ps.current_list << line.ol3
      ps.ol3!
    end

    ##
    # Unordered list on level 1
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def ul1(ps, line)
      if ps.ol2? || ps.ul2? || ps.ol3? || ps.ul3?
        ps.current_list = ps.current_list.parent
      elsif !ps.ul1?
        ps.current_list = Domain::UnorderedList.new
        slide(ps) << ps.current_list
      end

      ps.current_list << line.ul1
      ps.ul1!
    end

    ##
    # Unordered list on level 2
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def ul2(ps, line)
      if ps.ol3? || ps.ul3?
        ps.current_list = ps.current_list.parent
      elsif !ps.ul2?
        list = Domain::UnorderedList.new
        ps.current_list.add(list)
        ps.current_list = list
      end

      ps.current_list << line.ul2
      ps.ul2!
    end

    ##
    # Unordered list on level 3
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def ul3(ps, line)
      unless ps.ul3?
        list = Domain::UnorderedList.new
        ps.current_list.add(list)
        ps.current_list = list
      end

      ps.current_list << line.ul3
      ps.ul3!
    end

    ##
    # Quotes "> Quote"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def quote(ps, line)
      if ps.quote?
        quote = element(ps)

        if line.quote_source?
          quote.source = line.sub(/>> /, '')
        else
          quote << line.sub(/> /, '')
        end
      else
        quote = Domain::Quote.new
        quote << line.sub(/> /, '')
        slide(ps) << quote
        ps.quote!
      end
    end

    ##
    # Important section ">! Text"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def important(ps, line)
      if !ps.important?
        element = Domain::Important.new
        element << line.sub(/>! /, '')
        slide(ps) << element
        ps.important!
      elsif ps.important?
        element(ps) << line.sub(/>! /, '')
      end
    end

    ##
    # Question section ">? Text"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def question(ps, line)
      if !ps.question?
        element = Domain::Question.new
        element << line.sub(/>\? /, '')
        slide(ps) << element
        ps.question!
      elsif ps.question?
        element(ps) << line.sub(/>\? /, '')
      end
    end

    ##
    # Question section ">| Text"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def box(ps, line)
      if !ps.box?
        element = Domain::Box.new
        element << line.sub(/>: /, '')
        slide(ps) << element
        ps.box!
      elsif ps.box?
        element(ps) << line.sub(/>: /, '')
      end
    end

    ##
    # Table "| a | b | c |"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def table(ps, line)
      # remove quoted table separators
      cleaned_line = line.string.gsub('\|', '~~pipe~~')

      if !ps.table?
        table = Domain::Table.new

        columns = cleaned_line.split('|')

        columns.each do |e|
          alignment =
            case e
            when /^[ ]{2,}.*[ ]{2,}$/
              Constants::CENTER
            when /^[ ]{2,}.*[ ]$/
              Constants::RIGHT
            when /^[ ]{1}.*[ ]+$/
              Constants::LEFT
            when /^!$/
              Constants::SEPARATOR
            else
              Constants::LEFT
              end

          table.add_header(e.strip.gsub('~~pipe~~', '|'), alignment) unless e.strip.empty?
        end

        slide(ps) << table
        ps.table!

      elsif ps.table?

        if line.table_separator?
          element(ps).add_separator
          return
        end

        # Split columns and add them to the table
        columns = cleaned_line.split('|')
        row = []
        columns.each { |e| row << e.gsub('~~pipe~~', '|') unless e.strip.empty? }
        element(ps).add_row(row)
      end
    end

    ##
    # Beginning of an equation "\["
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] _line Line of input
    def equation_start(ps, _line)
      slide(ps) << Domain::Equation.new
      ps.equation!
    end

    ##
    # Beginning of an uml section
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def uml_start(ps, line)
      picture_name = "uml_#{ps.line_id}"
      width_slide, width_plain = line.uml_start
      slide(ps) << Domain::UML.new(picture_name, width_slide, width_plain)
      ps.uml!
    end

    ##
    # Beginning of a source code section "     int i = 5"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def source_start(ps, line)
      slide(ps) << Domain::Source.new(ps.language)
      line.trim_code_prefix!
      element(ps) << line.string
      ps.code!
    end

    ##
    # Source line
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def source_line(ps, line)
      line.trim_code_prefix!
      element(ps) << line.string
    end

    ##
    # Lookahead for the special case of empty lines inside a source
    # section (goes beyond Markdown standard)
    # @param [ParserState] ps State of the parser
    # @param [Array] lines Lines of input
    def source_lookahead(ps, lines)
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
        element(ps) << "\n"
      end
    end

    ##
    # Handling of line elements, i.e. elements that occupy only a single
    # line in the markdown file
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def inline(ps, line)
      e = LineMatcher.match(line.string, ps.line_id)

      if e.nil?
        if line.normal?
          slide(ps) << Domain::Text.new(line.string) if line.text?
          ps.normal!
        elsif line.empty?
          return if ps.ul1? || ps.ul2?

          ps.normal!
        else
          raise Exception, "Line #{ps.line_counter} of file '#{ps.file_name}' has a syntax error - " +
                           "#{ps}, '#{line}'"
        end
      else
        slide(ps) << e

        if e.instance_of?(Domain::Image) && !@test_mode
          # for image, read available extensions
          e.formats = get_extensions(e.location)
          e.license = get_license(e.location)
        end
      end
    end

    ##
    # Special case when a code fragment starts with a single star (can happen
    # with css). In this case we need to avoid the detection of the code
    # as a ul2
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def code_with_stars(ps, line)
      str_line = line.string
      str_line = str_line[4..-1] if str_line.length > 4
      element(ps) << str_line
    end

    ##
    # HTML-Comment in the page
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def comment(ps, line)
      ps.presentation.comments << line.comment.strip
    end

    ##
    # Multiple choice question
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def multiple_choice(ps, line)
      correct, inline, text = line.multiple_choice
      element = element(ps)
      question = Domain::MultipleChoice.new(text, correct)

      if element.is_a?(Domain::MultipleChoiceQuestions)
        # We are already in a question section
        element << question
      else
        # We are the first question, start a new section
        element = Domain::MultipleChoiceQuestions.new(inline)
        element << question
        slide(ps) << element
      end
    end

    ##
    # HTML-Comment in the page
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def space_comment(ps, line)
      ps.slide.current_element.spacing = line.space_comment.to_i
    end

    private

    ##
    # Generate the id for a slide
    # @param [Fixnum] slide_counter slide counter
    # @return [String] an id for the slide
    def slide_id(slide_counter)
      "slide_id_#{@chapter_counter}_#{slide_counter}"
    end

    ##
    # Returns the current slide.
    # @param [Parsing::ParserState] ps state of the parser
    # @return [Domain:Slide] the slide
    def slide(ps)
      if ps.comment_mode
        ps.slide.current_element
      else
        ps.slide
      end
    end

    ##
    # Returns the active element of the slide.
    # @param [Parsing::ParserState] ps state of the parser
    # @return [Domain::Element] the active element
    def element(ps)
      if ps.comment_mode
        ps.slide.current_element.current_element
      else
        ps.slide.current_element
      end
    end

    ##
    # Return a filename without extension
    def get_path_and_name(file)
      basename = File.basename(file)

      if /.*?(\.[a-zA-Z]{3,4})/ =~ basename
        basename.gsub!(Regexp.last_match(1), '')
      end

      dirname = File.dirname(file)

      [dirname, basename]
    end

    ##
    # Returns all available extensions (file formats) for a given file
    # @param [String] file the name of the file (with or without extensions)
    # @return [Array] all found extensions for the name
    def get_extensions(file)
      extensions = []

      dirname, basename = get_path_and_name(file)

      throw "File #{file} does not exist" unless Dir.exist?(dirname)

      dir = Dir.new(dirname)

      dir.each do |f|
        if f.start_with?(basename)
          /.*?\.([a-zA-Z]{3,4})/ =~ f
          extensions << Regexp.last_match(1)
        end
      end

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
