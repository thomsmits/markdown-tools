require_relative 'renderer'
require_relative 'line_renderer_typst'
require_relative '../messages'
require_relative '../constants'

module Rendering

  class RendererTypst < Renderer

    PREFERRED_IMAGE_FORMATS = %w[pdf png jpg jpeg gif].freeze

    ## ERB templates to be used by the renderer
    TEMPLATES = {
      chapter_start: erb(
        '
        = <%= line_renderer.render_text(title) %>
        '
      ),

      chapter_end: erb(
        '
        '),

      section_start: erb(
        '
        == <%= line_renderer.render_text(title) %>
        '
      ),

      section_end: erb(
        '
             '),

      heading_3: erb(
        '
        === <%= line_renderer.render_text(title) %>
        '
      ),

      heading_4: erb(
        '
        ==== <%= line_renderer.render_text(title) %>
        '
      ),

      vertical_space: erb(
        '
        #v(4mm)
        '
      ),

      equation: erb(
        '
        $ <%= line_renderer.formula(contents) %> $
        '
      ),

      ol_start: erb('
      '),

      ol_item: erb(
        '<%= "  "*(@ul_level + @ol_level - 1) %><%= @ol_counter %>. <%= content %>
        '
      ),

      ol_end: erb(''),

      ul_start: erb('
      '),

      ul_item: erb(
        '<%= "  "*(@ul_level + @ol_level - 1) %>- <%= content %>
        '
      ),

      ul_end: erb(''),

      quote: erb(
        '<%- if with_source -%>
          #quote(attribution: [<%= source.strip %>])[<%= content %>]
        <%- else -%>
          #quote[<%= content %>]
        <%- end -%>'
      ),

      important: erb(
        '
        #important[<%= content %>]
        '
      ),

      question: erb(
        '
        #question[<%= content %>]
        '
      ),

      box: erb(
        '
        #block[<%= content %>]
        '
      ),

      script: erb(
        ''
      ),

      code_start: erb(
        '
        ```<%= prog_lang %>
        '
      ),

      code: erb(
        '<%= content %>'
      ),

      code_end: erb('
        ```'),

      table_start: erb(
        '
        #align(center)[
        #table(
          columns: (<%= column_line %>),
          align: (<%= alignment_line %>),
          table.header(<%= header_line %>),'
      ),

      table_separator: erb(
        ''
      ),

      table_end: erb(
        "\n)\n]\n"
      ),

      text: erb('<%= content %>'),

      image: erb(
        '
         <%- if full_title.length > 0 then -%>
        #figure(
          image("<%= chosen_image %>", width: <%= width %>),
          caption: [<%= line_renderer.meta(full_title) %>],)
        <%- else %>
          #align(center,
          image("<%= chosen_image %>", width: <%= width %>))
        <%- end -%>
      '),

      multiple_choice_start: erb(''),

      multiple_choice_end: erb(''),

      multiple_choice: erb(
        "- <%= if correct then '[X]' else '[ ]' end %> <%= text %>"
      ),

      input_question: erb('<%= translate(:answer) %>: ..........
      '),

      footnote: erb(''),

      comment_start: erb(''),

      comment_end: erb(''),
    }.freeze

    ##
    # Initialize the renderer
    # @param [IO] io target of output operations
    # @param [String] prog_lang the default language for code snippets
    # @param [String] result_dir location for results
    # @param [String] image_dir location for generated images (relative to result_dir)
    # @param [String] temp_dir location for temporary files
    def initialize(io, prog_lang, result_dir, image_dir, temp_dir)
      super(io, LineRendererTypst.new(prog_lang), prog_lang, result_dir, image_dir, temp_dir)
    end

    ##
    # Method returning the templates used by the renderer. Should be overwritten by the
    # subclasses.
    # @return [Hash] the templates
    def all_templates
      @templates = super.merge(TEMPLATES)
    end

    ##
    # Start of a code fragment
    # @param [String] prog_lang language of the code fragment
    # @param [String] caption caption of the sourcecode
    def code_start(prog_lang, caption)
      if caption.nil?
        caption_command = ''
      else
        replaced_caption = line_renderer.meta(caption)
      end

      @io << @templates[:code_start].result(binding)
    end

    ##
    # Start of an ordered list
    # @param [Fixnum] number start number of list
    def ol_start(number = 1)
      @ol_level += 1
      @ol_counter = number.to_i - 1
      @io << @templates[:ol_start].result(binding)
    end

    ##
    # Item of an ordered list
    # @param [String] content content
    def ol_item(content)
      @ol_counter += 1
      @io << @templates[:ol_item].result(binding)
    end

    ##
    # Heading of a given level
    # @param [Fixnum] level heading level
    # @param [String] title title of the heading
    def heading(level, title)
      @io << @templates[:heading_3].result(binding)  if level == 3
      @io << @templates[:heading_4].result(binding)  if level == 4
    end

    ##
    # Header of table
    # @param [Array] headers the headers
    # @param [Array] alignment alignments of the cells
    def table_start(headers, alignment)
      alignment_line = ''
      column_line = ''

      alignment.each do |a|
        alignment_line << 'left, '    if a == Constants::LEFT
        alignment_line << 'right,'    if a == Constants::RIGHT
        alignment_line << 'center, '  if a == Constants::CENTER
        alignment_line << '| '        if a == Constants::SEPARATOR
        column_line << 'auto, '
      end

      header_line = headers.map { |e| "[*#{e}*]" }.join(", ")
      @io << @templates[:table_start].result(binding)
    end

    ##
    # Row of the table
    # @param [Array] row row of the table
    # @param [Array] alignment alignments of the cells
    def table_row(row, alignment)
      result = '  '
      i = 0

      row.each_with_index do |e, k|
        next if alignment[k] == Constants::SEPARATOR

        result << "[ #{e} ],"
        i += 1
      end

      @io << "#{result}" << nl
    end

    def preferred_image_formats
      PREFERRED_IMAGE_FORMATS
    end

    ##
    # Render an image
    # @param [String] location path to image
    # @param [Array] formats available file formats
    # @param [String] alt alt text
    # @param [String] title title of image
    # @param [String] width_slide width for slide
    # @param [String] width_plain width for plain text
    # @param [String, nil] source source of the image
    def image(location, formats, alt, title, width_slide,
              width_plain, source = nil)
      image_typst(location, formats, title, width_slide, source)
    end

    ##
    # Render an image
    # @param [String] location path to image
    # @param [String] title title of image
    # @param [String] width width for slide
    # @param [String|nil] source source of the image
    def image_typst(location, formats, title, width, source = nil)

      stripped_location = location.gsub(/\.\.\//, '')

      chosen_image = choose_image(location, formats)
      full_title = title

      unless source.nil?
        full_title << ', ' if !full_title.nil? && !full_title.empty?
        full_title = "#{full_title}#{translate(:source)}#{source}"
      end

      @io << @templates[:image].result(binding)
    end
  end
end
