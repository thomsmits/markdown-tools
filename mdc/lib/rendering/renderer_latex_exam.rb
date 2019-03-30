require 'erb'

require_relative 'renderer_latex'
require_relative '../messages'

module Rendering
  ##
  # Render the presentation into a latex file for further processing
  # using LaTeX
  class RendererLatexExam < RendererLatex
    ## ERB templates to be used by the renderer
    TEMPLATES = {
      presentation_start: erb(
        ''
      ),

      presentation_end: erb(
        ''
      ),

      chapter_start: erb(
        ''
      ),

      chapter_end: erb(
        ''
      ),

      slide_start: erb(
        ''
      ),

      slide_end: erb(
        ''
      ),

      comment_start: erb(
        %q(
        \begin{solution}[<%= spacing %>mm]
        )
      ),

      comment_end: erb(
        %q(
        \end{solution}
        )
      ),

      text: erb(
        '
        <%= inline_code(content) %>
        '
      ),

      code_start: erb(
        %q(
        \vspace{5mm}
        \begin{lstlisting}[language=<%= language %>,<%= caption_command %><%= column_style %>basicstyle=\small\ttfamily])
      ),

      code: erb(
        '<%= content %>'
      ),

      code_end: erb(
        %q(\end{lstlisting}
        )
      )
    }.freeze

    ##
    # Initialize the renderer
    # @param [IO] io target of output operations
    # @param [String] language the default language for code snippets
    # @param [String] result_dir location for results
    # @param [String] image_dir location for generated images (relative to result_dir)
    # @param [String] temp_dir location for temporary files
    def initialize(io, language, result_dir, image_dir, temp_dir)
      super(io, language, result_dir, image_dir, temp_dir)
    end

    ##
    # Method returning the templates used by the renderer. Should be overwritten by the
    # subclasses.
    # @return [Hash] the templates
    def all_templates
      @templates = super.merge(TEMPLATES)
    end

    ##
    # Indicates whether the renderer handles animations or not. false indicates
    # that slides should not be repeated.
    # @return [Boolean] +true+ if animations are supported, otherwise +false+
    def handles_animation?
      false
    end

    ##
    # Start of slide
    # @param [String] title the title of the slide
    # @param [String] number the number of the slide
    # @param [String] id the unique id of the slide (for references)
    # @param [Boolean] contains_code indicates whether the slide contains code fragments
    def slide_start(title, number, id, contains_code)
      super unless title == @last_title
    end

    ##
    # Render an image
    # @param [String] location path to image
    # @param [Array] _formats available file formats
    # @param [String] _alt alt text
    # @param [String] title title of image
    # @param [String] width_slide width for slide
    # @param [String] source source of the image
    def image(location, _formats, _alt, title, width_slide, width_plain, source = nil)
      width = width_plain || width_slide

      # Skip images with width 0
      unless /^0$/ === width_plain || /^0%$/ === width_plain
        image_latex(location, title, width, source)
      end
    end

    ##
    # Render an UML inline diagram using an external tool
    # @param [String] picture_name name of the picture
    # @param [String] contents the embedded UML
    # @param [String] width_slide width of the diagram on slides
    # @param [String] width_plain width of the diagram on plain documents
    def uml(picture_name, contents, width_slide, width_plain)
      new_width = calculate_width(width_plain)
      formats = %w[pdf eps]
      img_path = super(picture_name, contents, width_slide, width_plain, 'pdf')
      image(img_path, formats, '', '', new_width, new_width)
    end
  end
end
