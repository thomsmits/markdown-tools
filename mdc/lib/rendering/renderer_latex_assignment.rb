require 'erb'

require_relative 'renderer_latex'
require_relative '../messages'

module Rendering
  ##
  # Render the presentation into a latex file for further processing
  # using LaTeX
  class RendererLatexAssignment < RendererLatex
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
        %q(
        % ----------------------------------------------------------------------------
        \subsection{<%= line_renderer.meta(title) %>}\label{<%= id %>}
        )
      ),

      slide_end: erb(
        ''
      ),

      comment_start: erb(
        %q(\begin{solution}
        )
      ),

      comment_end: erb(
        %q(\end{solution}
        )
      ),

      text: erb(
        '
        <%= content %>
        '
      ),

      code_start: erb(
        %q(
        \vspace{1mm}
        \begin{lstlisting}[language=<%= prog_lang %>,<%= caption_command %>,basicstyle=\small\ttfamily])
      ),

      code: erb(
        '<%= content %>'
      ),

      code_end: erb(
        "\\end{lstlisting}\\vspace{2mm}\n"
      ),

      multiple_choice_start: erb(
        '\begin{itemize}'
      ),

      multiple_choice_end: erb(
        '\end{itemize}'
      ),

      multiple_choice: erb(
        %q(\item <%= if correct then '[X]' else '[ ]' end %> <%= text %>)
      )
    }.freeze

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
      return if /^0$/ === width_plain || /^0%$/ === width_plain

      image_latex(location, title, width, source)
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
