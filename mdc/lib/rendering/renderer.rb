module Rendering
  ##
  # Base class for all renderer used by the markdown compiler
  class Renderer
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
      ERB.new(clean(input), nil, '-')
    end

    ## ERB templates to be used by the renderer
    TEMPLATES = {
      vertical_space: erb(
        '<br>
          '
      ),

      equation: erb(
        %q(
        \[
        <%= contents %>
        \]
        )
      ),

      ol_start: erb(
        '<%= number %> '
      ),

      ol_item: erb(
        '<%= inline_code(content) %>'
      ),

      ol_end: erb(
        '
        '
      ),

      ul_start: erb(
        '  * '
      ),

      ul_item: erb(
        '<%= inline_code(content) %>'
      ),

      ul_end: erb(
        '
        '
      ),

      quote: erb(
        '> <%= inline_code(content) %>
        <% if !source.nil? %>
        >> <%= source %>
        <% end %>
        '
      ),

      important: erb(
        '>!<%= inline_code(content) %>
        '
      ),

      question: erb(
        '>? <%= inline_code(content) %>
        '
      ),

      box: erb(
        '>: <%= inline_code(content) %>
        '
      ),

      script: erb(
        '<script><%= content %></script>'
      ),

      code_start: erb(
        '```<%= language %>'
      ),

      code: erb(
        '<%= content %>'
      ),

      code_end: erb(
        '```
        '
      ),

      table_start: erb(
        ''
      ),

      table_end: erb(
        ''
      ),

      heading: erb(
        '# <%= title %>
        '
      ),

      toc_start: erb(
        ''
      ),

      toc_entry: erb(
        ''
      ),

      toc_end: erb(
        ''
      ),

      toc_sub_entries_start: erb(
        ''
      ),

      toc_sub_entry: erb(
        ''
      ),

      toc_sub_entries_end: erb(
        ''
      ),

      index_start: erb(
        ''
      ),

      index_entry: erb(
        '<%= chapter_name %>
        '
      ),

      index_end: erb(
        ''
      ),

      html: erb(
        '<%= content %>'
      ),

      css: erb(
        '<%= css %>'
      ),

      js: erb(
        '<%= js %>'
      ),

      button: erb(
        '((Button))
        '
      ),

      button_with_log: erb(
        '((Button-With-Log))
        '
      ),

      button_with_log_pre: erb(
        '((Button-With-Log-Pre))
        '
      ),

      link_previous: erb(
        '((Link-Previous))
        '
      ),

      live_css: erb(
        '((Live-CSS))
        '
      ),

      live_preview: erb(
        '((Live-Preview))
        '
      ),

      live_preview_float: erb(
        '((Live-Preview-Float))
        '
      ),

      comment_start: erb(
        ''
      ),

      comment_end: erb(
        ''
      ),

      image: erb(
        '<%= chosen_image %>'
      ),

      slide_start: erb(
        ''
      ),

      slide_end: erb(
        ''
      ),

      presentation_start: erb(
        ''
      ),

      presentation_end: erb(
        '
        '
      ),

      text: erb(
        '<%= inline_code(content) %>'
      ),

      table_row: erb(
        '<%= inline_code(content) %>'
      ),

      multiple_choice_start: erb(
        ''
      ),

      multiple_choice_end: erb(
        ''
      ),

      multiple_choice: erb(
        "[<%= if correct then 'X' else ' ' end %>] <%= text %>"
      )
    }.freeze

    ## Inline replacements
    INLINE = [].freeze

    ##
    # Class representing the parts of a line
    class LinePart
      attr_accessor :matched, :content

      ##
      # Create a new instance
      # @param [String] content content of the part
      # @param [Boolean] matched indicates whether we have a match
      #                  or normal text
      def initialize(content, matched)
        @matched = matched
        @content = content
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
    # @param [String] image_dir location for generated images
    #                 (relative to result_dir)
    # @param [String] temp_dir location for temporary files
    def initialize(io, language, result_dir, image_dir, temp_dir)
      @io = io
      @language = language
      @result_dir = result_dir
      @image_dir = image_dir
      @temp_dir = temp_dir

      @templates = all_templates
      @dialog_counter = 0
      @ol_level = 0
      @ul_level = 0
      @last_title = nil
    end

    ##
    # Method returning the templates used by the renderer.
    # Should be overwritten by the subclasses to provide
    # the correct templates for the type of renderer.
    # @return [Hash] the templates
    def all_templates
      TEMPLATES
    end

    ##
    # Method returning the inline replacements.Should be overwritten by the
    # subclasses.
    # @param [Boolean] _alternate should alternate replacements be used
    # @return [String[]] the templates
    def all_inline_replacements(_alternate = false)
      INLINE
    end

    ##
    # Indicates whether the renderer handles animations or not. false indicates
    # that slides should not be repeated.
    # @return [Boolean] +true+ if animations are supported, otherwise +false+
    def handles_animation?
      false
    end

    ##
    # Replace `inline code` in input
    # @param [String] input the input
    # @param [boolean] _table code used in a table
    # @param [Boolean] _alternate should alternate replacements be used
    # @return the input with replaced code fragments
    def inline_code(input, _table = false, _alternate = false)
      input
    end

    ##
    # Apply regular expressions to replace inline content
    # @param [String] input Text to be replaced
    # @param [Boolean] alternate should alternate replacements be used
    # @return [String] Text with replacements performed
    def replace_inline_content(input, alternate = false)
      return '' if input.nil?

      result = input

      all_inline_replacements(alternate).each { |e| result.gsub!(e[0], e[1]) }

      result
    end

    ##
    # Split the line into tokens. One token for each code / non-code fragment
    # is created
    # @param [String] input the input
    # @param [Pattern] expression regex used for tokenizing
    # @return [Renderer::LinePart[]] the input tokenized
    def tokenize_line(input, expression)
      parts = []
      remainder = input

      while expression =~ remainder
        parts << LinePart.new($`, false)
        parts << LinePart.new(Regexp.last_match(1), true)
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
    def vertical_space
      @io << @templates[:vertical_space].result(binding)
    end

    ##
    # Equation
    # @param [String] contents LaTeX source of equation
    def equation(contents)
      @io << @templates[:equation].result(binding)
    end

    ##
    # Start of an ordered list
    # @param [Fixnum] number start number of list
    def ol_start(number = 1)
      @ol_level += 1
      @io << @templates[:ol_start].result(binding)
    end

    ##
    # End of ordered list
    def ol_end
      @io << @templates[:ol_end].result(binding)
      @ol_level -= 1
    end

    ##
    # Item of an ordered list
    # @param [String] content content
    def ol_item(content)
      @io << @templates[:ol_item].result(binding)
    end

    ##
    # Indent output
    # @param [Fixnum] level the indentation
    def indent(level)
      [0..level].each { @io << ' ' }
    end

    ##
    # Start of an unordered list
    def ul_start
      @ul_level += 1
      @io << @templates[:ul_start].result(binding)
    end

    ##
    # End of an unordered list
    def ul_end
      @io << @templates[:ul_end].result(binding)
      @ul_level -= 1
    end

    ##
    # Item of an unordered list
    # @param [String] content content
    def ul_item(content)
      @io << @templates[:ul_item].result(binding)
    end

    ##
    # Quote
    # @param [String] content the content
    # @param [String] source the source of the quote
    def quote(content, source)
      with_source = !source.nil? && !source.empty?
      @io << @templates[:quote].result(binding)
    end

    ##
    # Important
    # @param [String] content the box
    def important(content)
      @io << @templates[:important].result(binding)
    end

    ##
    # Question
    # @param [String] content the box
    def question(content)
      @io << @templates[:question].result(binding)
    end

    ##
    # Box
    # @param [String] content the box
    def box(content)
      @io << @templates[:box].result(binding)
    end

    ##
    # Script
    # @param [String] content the script to be included
    def script(content)
      @io << @templates[:script].result(binding)
    end

    ##
    # Start of a code fragment
    # @param [String] language language of the code fragment
    # @param [String] caption caption of the sourcecode
    def code_start(language, caption)
      @io << @templates[:code_start].result(binding).strip
    end

    ##
    # End of a code fragment
    # @param [String] caption caption of the sourcecode
    def code_end(caption)
      @io << @templates[:code_end].result(binding)
    end

    ##
    # Output code
    # @param [String] content the code content
    def code(content)
      @io << @templates[:code].result(binding).chomp
    end

    ##
    # Start of a table
    # @param [Array] headers the headers
    # @param [Array] alignment alignments of the cells
    def table_start(headers, alignment)
      @io << @templates[:table_start].result(binding)
    end

    ##
    # Row of the table
    # @param [Array] row row of the table
    # @param [Array] alignment alignments of the cells
    def table_row(row, alignment)
      @io << @templates[:table_row].result(binding)
    end

    ##
    # Separator in the table
    # @param [Array] headers the headers
    def table_separator(headers)
      @io << @templates[:table_separator].result(binding)
    end

    ##
    # End of the table
    def table_end
      @io << @templates[:table_end].result(binding)
    end

    ##
    # Simple text
    # @param [String] content the text
    def text(content)
      @io << @templates[:text].result(binding)
    end

    ##
    # Heading of a given level
    # @param [Fixnum] level heading level
    # @param [String] title title of the heading
    def heading(level, title)
      @io << @templates[:heading].result(binding)
    end

    ##
    # Start of the TOC
    def toc_start
      @io << @templates[:toc_start].result(binding)
    end

    ##
    # Start of sub entries in toc
    def toc_sub_entries_start
      @io << @templates[:toc_sub_entries_start].result(binding)
    end

    ##
    # End of sub entries
    def toc_sub_entries_end
      @io << @templates[:toc_sub_entries_end].result(binding)
    end

    ##
    # Output a toc sub entry
    # @param [String] name name of the entry
    # @param [String] anchor anchor of the entry
    def toc_sub_entry(name, anchor)
      return if name == @last_toc_name

      @last_toc_name = name
      @io << @templates[:toc_sub_entry].result(binding)
    end

    ##
    # Output a toc entry
    # @param [String] name name of the entry
    # @param [String] anchor anchor of the entry
    def toc_entry(name, anchor)
      @io << @templates[:toc_entry].result(binding)
    end

    ##
    # End of toc
    def toc_end
      @io << @templates[:toc_end].result(binding)
    end

    ##
    # Start of index file
    # @param [String] title1 title 1 of lecture
    # @param [String] title2 title 2 of lecture
    # @param [String] copyright copyright info
    # @param [String] description description
    def index_start(title1, title2, copyright, description)
      @io << @templates[:index_start].result(binding)
    end

    ##
    # End of index
    def index_end
      @io << @templates[:index_end].result(binding)
    end

    ##
    # Single index entry
    # @param [Fixnum] chapter_number number of chapter
    # @param [String] chapter_name name of chapter
    # @param [String] slide_file file containing the slides
    # @param [String] plain_file file containing the plain version
    def index_entry(chapter_number, chapter_name, slide_file,
                    slide_name, plain_file, plain_name)
      @io << @templates[:index_entry].result(binding)
    end

    ##
    # HTML output
    # @param [String] content html
    def html(content)
      @io << @templates[:html].result(binding)
    end

    ##
    # Start a chapter
    # @param [String] title the title of the chapter
    # @param [String] number the number of the chapter
    # @param [String] id the unique id of the chapter (for references)
    def chapter_start(title, number, id)
      @io << @templates[:chapter_start].result(binding)
    end

    ## End of a chapter
    def chapter_end
      @io << @templates[:chapter_end].result(binding)
    end

    ##
    # Render a button
    # @param [String] line_id internal ID of the line
    def button(line_id)
      @io << @templates[:button].result(binding)
    end

    ##
    # Render a button with log area
    # @param [String] line_id internal ID of the line
    def button_with_log(line_id)
      @io << @templates[:button_with_log].result(binding)
    end

    ##
    # Render a button with output
    # @param [String] line_id internal ID of the line
    def button_with_log_pre(line_id)
      @io << @templates[:button_with_log_pre].result(binding)
    end

    ##
    # Link to previous slide (for active HTML)
    # @param [String] line_id internal ID of the line
    def link_previous(line_id)
      @io << @templates[:link_previous].result(binding)
    end

    ##
    # Link to previous slide (for active CSS)
    # @param [String] line_id internal ID of the line
    # @param [String] fragment HTML fragment used for CSS styling
    def live_css(line_id, fragment)
      @io << @templates[:live_css].result(binding)
    end

    ##
    # Link to previous slide (for active CSS)
    # @param [String] line_id internal ID of the line
    def live_preview(line_id)
      @io << @templates[:live_preview].result(binding)
    end

    ##
    # Perform a live preview
    # @param [String] line_id internal ID of the line
    def live_preview_float(line_id)
      @io << @templates[:live_preview_float].result(binding)
    end

    ##
    # Beginning of a comment section, i.e. explanations to the current slide
    def comment_start(spacing = 0)
      @io << @templates[:comment_start].result(binding)
    end

    ##
    # End of comment section
    def comment_end
      @io << @templates[:comment_end].result(binding)
      @dialog_counter += 1
    end

    ##
    # Render an image
    # @param [String] location path to image
    # @param [Array] formats available file formats
    # @param [String] alt alt text
    # @param [String] title title of image
    # @param [String] width_slide width for slide
    # @param [String] width_plain width for plain text
    # @param [String] source source of the image
    def image(location, formats, alt, title, width_slide,
              width_plain, source = nil)
      @io << @templates[:image].result(binding)
    end

    ##
    # Render start of multiple choice questions
    # @param [bool] inline should we use inline checkboxes
    def multiple_choice_start(inline = false)
      @io << @templates[:multiple_choice_start].result(binding)
    end

    ##
    # Render end of multiple choice questions
    # @param [bool] inline should we use inline checkboxes
    def multiple_choice_end(inline = false)
      @io << @templates[:multiple_choice_end].result(binding)
    end

    ##
    # Render multiple choice question
    # @param [Domain::MultipleChoice] question the question
    def multiple_choice(question)
      correct = question.correct
      text = inline_code(question.text)

      @io << @templates[:multiple_choice].result(binding)
    end

    ##
    # Start of presentation
    # @param [String] slide_language the language
    # @param [String] title1 first title
    # @param [String] title2 second title
    # @param [String] section_number number of the section
    # @param [String] section_name name of the section
    # @param [String] copyright copyright information
    # @param [String] author author of the presentation
    # @param [String] description additional description
    # @param [String] term of the lecture
    # @param [String] bibliography File with bibliography
    def presentation_start(slide_language, title1, title2,
                           section_number, section_name,
                           copyright, author, description,
                           term = '', bibliography = nil)
      @io << @templates[:presentation_start].result(binding)
    end

    ##
    # End of presentation
    # @param [String] slide_language the language
    # @param [String] title1 first title
    # @param [String] title2 second title
    # @param [String] section_number number of the section
    # @param [String] section_name name of the section
    # @param [String] copyright copyright information
    # @param [String] author author of the presentation
    # @param [Boolean] create_index create an Index at the end of slides?
    # @param [String] bibliography File with bibliography
    def presentation_end(slide_language, title1, title2,
                         section_number, section_name,
                         copyright, author, create_index,
                         bibliography = nil)
      @io << @templates[:presentation_end].result(binding)
    end

    ##
    # Small TOC menu for presentation slides for quick navigation
    def toc_menu; end

    ##
    # Start of slide
    # @param [String] title the title of the slide
    # @param [String] number the number of the slide
    # @param [String] id the unique id of the slide (for references)
    # @param [Boolean] contains_code indicates whether the slide contains code fragments
    def slide_start(title, number, id, contains_code)
      @io << @templates[:slide_start].result(binding)
      @last_title = title
    end

    ##
    # End of slide
    def slide_end
      @io << @templates[:slide_end].result(binding)
    end

    ##
    # Render an UML inline diagram using an external tool
    # @param [String] picture_name name of the picture
    # @param [String] contents the embedded UML
    # @param [String] type the generated file type (svg, pdf, png)
    # @param [String] _width_slide width of the diagram on slides
    # @param [String] _width_plain width of the diagram on plain documents
    def uml(picture_name, contents, _width_slide, _width_plain, type = 'pdf')
      begin
        Dir.mkdir(@temp_dir)
      rescue StandardError
        # ignored
      end

      base_name = picture_name.tr(' ', '_').downcase

      img_file    = "#{@image_dir}/#{base_name}.#{type}"
      uml_file    = "#{@temp_dir}/#{base_name}.uml"
      dot_file    = "#{@temp_dir}/#{base_name}.dot"
      result_file = "#{@result_dir}/#{img_file}"

      # write uml to file
      File.write(uml_file, contents)

      # generate image
      puts "#{$project_path}/umlifier/bin/main.rb #{uml_file} #{dot_file} #{result_file} #{type}"

      `ruby #{$project_path}/umlifier/bin/main.rb #{uml_file} #{dot_file} #{result_file} #{type}`

      img_file
    end
  end
end
