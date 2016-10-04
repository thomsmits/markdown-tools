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

require_relative 'line_matcher'

module Parsing

  ##
  # Callback handler for the parser
  class ParserHandler

    ##
    # Create a new instance
    # @param [Bool] test_mode indicates that the handler is tested and should not perform
    #    any file access
    def initialize(test_mode = false)
      @test_mode = test_mode
    end

    ##
    # Copy a line to the document
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def copy_line_to_document(ps, line)
      append(ps.slide, line, ps.comment_mode)
    end

    alias script_line copy_line_to_document
    alias uml_line copy_line_to_document
    alias fenced_code_line copy_line_to_document
    alias equation_line copy_line_to_document

    ##
    # Beginning of a script
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def script_start(ps, line)
      add_to_slide(ps.slide, Domain::Script.new, ps.comment_mode)
      ps.script!
    end

    ##
    # Insert a vertical space into the document
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def vspace(ps, line)
      add_to_slide(ps.slide, Domain::VerticalSpace.new, ps.comment_mode)
    end

    ##
    # Handle the separator string "---" which indicates the beginning
    # of the comment section of the slide
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def separator(ps, line)
      ps.comment_mode = true
      ps.slide.add(Domain::Comment.new)
    end

    ##
    # Chapter title "# title"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def chapter_title(ps, line)
      ps.chapter_counter += 1
      id = "chap_#{ps.chapter_counter}"
      ps.slide_counter += 1
      ps.chapter = Domain::Chapter.new(line.chapter_title.gsub('#', ''), id)
      ps.presentation.add(ps.chapter)
      ps.normal!
      ps.comment_mode = false
      # puts line.chapter_title + " #{ps.slide_counter}"
    end

    ##
    # Slide title "## title"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def slide_title(ps, line)
      skip = line.skipped_slide?
      ps.slide_counter += 1 unless skip
      ps.slide = Domain::Slide.new(slide_id(ps.slide_counter),
                                   line.slide_title.gsub('#', '').gsub('--skip--', '').strip,
                                   ps.slide_counter, skip)
      ps.chapter.add_slide(ps.slide)
      ps.normal!
      ps.comment_mode = false
      # puts line.slide_title + " #{ps.slide_counter}"
    end

    ##
    # Beginning of a fenced (GitHub style) code block "```language"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def code_fenced_start(ps, line)
      language_hint = line.fenced_code_start
      caption = line.fenced_code_caption
      order = 0

      if line.fenced_code_order?
        order = line.fenced_code_order.to_i
      end

      add_to_slide(ps.slide, Domain::Source.new(language_hint, caption, order), ps.comment_mode)
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
        add_to_slide(ps.slide, ps.current_list, ps.comment_mode)
      end

      ps.current_list.append(line.ol1)
      ps.ol1!
    end

    ##
    # Ordered list on level 2
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def ol2(ps, line)

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
    def ol3(ps, line)
      unless ps.ol3?
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
    def ul1(ps, line)
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
    def ul2(ps, line)
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
    def ul3(ps, line)
      unless ps.ul3?
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
    # @param [MarkdownLine] line Line of input
    def quote(ps, line)
      if ps.quote?
        quote = current_element(ps.slide, ps.comment_mode)

        if line.quote_source?
          quote.source = line.sub(/>> /, '')
        else
          quote.append(line.sub(/> /, ''))
        end
      else
        quote = Domain::Quote.new
        quote.append(line.sub(/> /, ''))
        add_to_slide(ps.slide, quote, ps.comment_mode)
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
        element.append(line.sub(/>! /, ''))
        add_to_slide(ps.slide, element, ps.comment_mode)
        ps.important!
      elsif ps.important?
        element = current_element(ps.slide, ps.comment_mode)
        element.append(line.sub(/>! /, ''))
      end
    end

    ##
    # Question section ">? Text"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def question(ps, line)
      if !ps.question?
        element = Domain::Question.new
        element.append(line.sub(/>\? /, ''))
        add_to_slide(ps.slide, element, ps.comment_mode)
        ps.question!
      elsif ps.question?
        element = current_element(ps.slide, ps.comment_mode)
        element.append(line.sub(/>\? /, ''))
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

        columns.each { |e|
          if /^[ ]{2,}.*[ ]{2,}$/ === e
            alignment = Constants::CENTER
          elsif /^[ ]{2,}.*[ ]$/ === e
            alignment = Constants::RIGHT
          elsif /^[ ]{1}.*[ ]+$/ === e
            alignment = Constants::LEFT
          elsif /^!$/ === e
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
    # @param [MarkdownLine] line Line of input
    def equation_start(ps, line)
      add_to_slide(ps.slide, Domain::Equation.new, ps.comment_mode)
      ps.equation!
    end

    ##
    # Beginning of an uml section
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def uml_start(ps, line)
      picture_name = "uml_#{ps.line_id}"
      width_slide, width_plain = line.uml_start
      add_to_slide(ps.slide, Domain::UML.new(picture_name, width_slide, width_plain), ps.comment_mode)
      ps.uml!
    end

    ##
    # Beginning of a source code section "     int i = 5"
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def source_start(ps, line)
      add_to_slide(ps.slide, Domain::Source.new(ps.language), ps.comment_mode)
      line.trim_code_prefix!
      append(ps.slide, line, ps.comment_mode)
      ps.code!
    end

    ##
    # Source line
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def source_line(ps, line)
      line.trim_code_prefix!
      append(ps.slide, line, ps.comment_mode)
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
        append(ps.slide, MarkdownLine.new("\n"), ps.comment_mode)
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
      else
        add_to_slide(ps.slide, e, ps.comment_mode)

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
      str_line = str_line[4..-1]  if str_line.length > 4
      append(ps.slide, MarkdownLine.new(str_line), ps.comment_mode)
    end

    ##
    # HTML-Comment in the page
    # @param [ParserState] ps State of the parser
    # @param [MarkdownLine] line Line of input
    def comment(ps, line)
      ps.presentation.comments << line.comment.strip
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

      dir.each do |f|
        if f.start_with?(basename)
          /.*?\.([a-zA-Z]{3,4})/ =~ f
          extensions << $1
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
