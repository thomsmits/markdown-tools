# -*- coding: utf-8 -*-

module Rendering

  ##
  # Base class for all renderer used by the markdown compiler
  class Renderer

    LEFT = 1
    RIGHT = 2
    CENTER = 3

    ##
    # Remove all trailing spaces on all lines of the string
    # @param [String] input the input string
    def self.clean(input)
      result = ''
      input.split(/\n/).each { |line| result.concat(line.strip).concat("\n") }
      result
    end

    ##
    # Create an ERB template from the given string but remove leading
    # and trailing spaces before
    # @param [String] input the input string for the template
    def self.erb(input)
      ERB.new(clean(input))
    end

    ##
    # Class representing the parts of a line
    class LinePart

      attr_accessor :matched, :content

      ##
      # Create a new instance
      # @param [String] content content of the part
      # @param [Boolean] matched indicates whether we have a match or normal text
      def initialize(content, matched)
        @matched, @content = matched, content
      end

      ##
      # @return [String] representation
      def to_s
        @content
      end
    end

    ##
    # Initialize the renderer
    # @param [IO] io target of output operations
    # @param [String] language the default language for code snippets
    # @param [String] result_dir location for results
    # @param [String] image_dir location for generated images (realtive to result_dir)
    # @param [String] temp_dir location for temporary files
    def initialize(io, language, result_dir, image_dir, temp_dir)
      @io, @language = io, language
      @result_dir = result_dir
      @image_dir = image_dir
      @temp_dir = temp_dir
    end

    ##
    # Indicates whether the renderer handles animations or not. false indicates
    # that slides should not be repeated.
    def handles_animation?
      false
    end

    ##
    # Split the line into tokens. One token for each code / non-code fragment
    # is created
    # @param [String] input the input
    # @param [Pattern] expression regex used for tokenizing
    # @return [Renderer::LinePart[]] the input tokenized
    def tokenize_line(input, expression)
      parts = [ ]
      remainder = input

      while expression =~ remainder
        parts << LinePart.new($`, false)
        parts << LinePart.new($1, true)
        remainder = $'
      end

      parts << LinePart.new(remainder, false)

      parts
    end

    ##
    # Return a newline character
    # @return [String] newline character
    def nl
      "\n"
    end

    ##
    # Render the table of contents
    # @param [Domain::TOC] toc to be rendered
    def render_toc(toc)
      @toc = toc
      toc_start
      toc.each { |e| toc_entry(e.name, e.id) }
      toc_end
    end

    ##
    # Vertical space
    def vertical_space; end

    ##
    # Equation
    # @param [String] contents LaTeX source of equation
    def equation(contents); end

    ##
    # Start of an ordered list
    # @param [Fixnum] number start number of list
    def ol_start(number = 1); end

    ##
    # End of ordered list
    def ol_end; end

    ##
    # Item of an ordered list
    # @param [String] content content
    def ol_item(content); end

    ##
    # Indent output
    # @param [Fixnum] level the indentation
    def indent(level)
      [0..level].each { @io << ' '}
    end

    ##
    # Start of an unordered list
    def ul_start; end

    ##
    # End of an unordered list
    def ul_end; end

    ##
    # Item of an unordered list
    # @param [String] content content
    def ul_item(content); end

    ##
    # Quote
    # @param [String] content the content
    # @param [String] source the source of the quote
    def quote(content, source); end

    ##
    # Important
    # @param [String] content the box
    def important(content); end

    ##
    # Question
    # @param [String] content the box
    def question(content); end

    ##
    # Script
    # @param [String] content the script to be included
    def script(content); end

    ##
    # Start of a code fragment
    # @param [String] language language of the code fragment
    # @param [String] caption caption of the sourcecode
    def code_start(language, caption); end

    ##
    # End of a code fragment
    # @param [String] caption caption of the sourcecode
    def code_end(caption); end

    ##
    # Output code
    # @param [String] content the code content
    def code(content); end

    ##
    # Start of a table
    # @param [Array] headers the headers
    # @param [Array] alignment alignments of the cells
    def table_start(headers, alignment); end

    ##
    # Row of the table
    # @param [Array] row row of the table
    # @param [Array] alignment alignments of the cells
    def table_row(row, alignment); end

    ##
    # End of the table
    def table_end; end

    ##
    # Simple text
    # @param [String] content the text
    def text(content); end

    ##
    # Heading of a given level
    # @param [Fixnum] level heading level
    # @param [String] title title of the heading
    def heading(level, title); end

    ##
    # Start of the TOC
    def toc_start; end

    ##
    # Start of sub entries in toc
    def toc_sub_entries_start; end

    ##
    # End of sub entries
    def toc_sub_entries_end; end

    ##
    # Output a toc sub entry
    # @param [String] name name of the entry
    # @param [String] anchor anchor of the entry
    def toc_sub_entry(name, anchor); end

    ##
    # Output a toc entry
    # @param [String] name name of the entry
    # @param [String] anchor anchor of the entry
    def toc_entry(name, anchor); end

    ##
    # End of toc
    def toc_end; end

    ##
    # Start of index file
    # @param [String] title1 title 1 of lecture
    # @param [String] title2 title 2 of lecture
    # @param [String] copyright copyright info
    # @param [String] description description
    def index_start(title1, title2, copyright, description); end

    ##
    # End of index
    def index_end; end

    ##
    # Single index entry
    # @param [Fixnum] chapter_number number of chapter
    # @param [String] chapter_name name of chapter
    # @param [String] slide_file file containing the slides
    # @param [String] slide_name name of the slide file
    # @param [String] plain_file file containing the plain version
    # @param [String] plain_name name of the plain file
    def index_entry(chapter_number, chapter_name, slide_file, slide_name, plain_file, plain_name); end

    ##
    # HTML output
    # @param [String] content html
    def html(content); end

    ##
    # Render a button
    # @param [String] line_id internal ID of the line
    def button(line_id); end

    ##
    # Start a chapter
    # @param [String] title the title of the chapter
    # @param [String] number the number of the chapter
    # @param [String] id the unique id of the chapter (for references)
    def chapter_start(title, number, id); end

    ## End of a chapter
    def chapter_end; end

    ##
    # Render a button with log area
    # @param [String] line_id internal ID of the line
    def button_with_log(line_id); end

    ##
    # Render a button with output
    # @param [String] line_id internal ID of the line
    def button_with_log_pre(line_id); end

    ##
    # Link to previous slide (for active HTML)
    # @param [String] line_id internal ID of the line
    def link_previous(line_id); end

    ##
    # Link to previous slide (for active CSS)
    # @param [String] line_id internal ID of the line
    # @param [String] fragment HTML fragment used for CSS styling
    def live_css(line_id, fragment); end

    ##
    # Link to previous slide (for active CSS)
    # @param [String] line_id internal ID of the line
    def live_preview(line_id); end

    ##
    # Perform a live preview
    # @param [String] line_id internal ID of the line
    def live_preview_float(line_id); end

    ##
    # Beginning of a comment section, i.e. explanations to the current slide
    def comment_start; end

    ##
    # End of comment section
    def comment_end; end

    ##
    # Render an image
    # @param [String] location path to image
    # @param [Array] formats available file formats
    # @param [String] alt alt text
    # @param [String] title title of image
    # @param [String] width_slide width for slide
    # @param [String] width_plain width for plain text
    # @param [String] source source of the image
    def image(location, formats, alt, title, width_slide, width_plain, source = nil); end

    ##
    # Start of presentation
    # @param [String] title1 first title
    # @param [String] title2 second title
    # @param [String] section_number number of the section
    # @param [String] section_name name of the section
    # @param [String] copyright copyright information
    # @param [String] author author of the presentation
    # @param [String] description additional description
    # @param [String] term of the lecture
    def presentation_start(title1, title2, section_number, section_name, copyright, author, description, term = ''); end

    ##
    # End of presentation
    # @param [String] title1 first title
    # @param [String] title2 second title
    # @param [String] section_number number of the section
    # @param [String] section_name name of the section
    # @param [String] copyright copyright information
    # @param [String] author author of the presentation
    def presentation_end(title1, title2, section_number, section_name, copyright, author); end

    ##
    # Small TOC menu for presentation slides for quick navigation
    def toc_menu; end

    ##
    # Start of slide
    # @param [String] title the title of the slide
    # @param [String] number the number of the slide
    # @param [String] id the unique id of the slide (for references)
    # @param [Boolean] contains_code indicates whether the slide contains code fragments
    def slide_start(title, number, id, contains_code); end

    ##
    # End of slide
    def slide_end; end

    ##
    # Render an UML inline diagram using an external tool
    # @param [String] picture_name name of the picture
    # @param [String] contents the embedded UML
    # @param [String] type the generated file type (svg, pdf, png)
    # @param [String] width_slide width of the diagram on slides
    # @param [String] width_plain width of the diagram on plain documents
    def uml(picture_name, contents, width_slide, width_plain, type = 'pdf')

      begin
        Dir.mkdir(@temp_dir)
      rescue
        # ignored
      end

      base_name = picture_name.gsub(/ /, '_').downcase

      img_file    = "#{@image_dir}/#{base_name}.#{type}"
      uml_file    = "#{@temp_dir}/#{base_name}.uml"
      dot_file    = "#{@temp_dir}/#{base_name}.dot"
      result_file = "#{@result_dir}/#{img_file}"

      # write uml to file
      File.write(uml_file, contents)

      # generate image
      %x(ruby ../../../../../Development/markdown-tools/umlifier/bin/main.rb #{uml_file} #{dot_file} #{result_file} #{type})

      puts "../../../../../Development/markdown-tools/umlifier/bin/main.rb #{uml_file} #{dot_file} #{result_file} #{type}"

      img_file
    end
  end
end
