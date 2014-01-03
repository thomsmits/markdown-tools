# -*- coding: utf-8 -*-

require_relative 'element'

module Domain

  ##
  # Base class for all line elements
  class LineElement < Element
    attr_accessor :type

    ##
    # Create a new instance
    def initialize
      super()
    end
  end

  ##
  # Button to cause some action
  class Button < Element
    attr_accessor :line_id

    ## Create a new button
    # @param [String] line_id id of the source line
    def initialize(line_id)
      super()
      @line_id = line_id
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.button(@line_id)
    end
  end

  ##
  # Button with output
  class ButtonWithLog < Button
    ## Create a new button
    # @param [String] line_id id of the source line
    def initialize(line_id)
      super(line_id)
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.button_with_log(@line_id)
    end
  end

  ##
  # Button with output
  class ButtonWithLogPre < Button
    ##
    # Create a new button
    # @param [String] line_id id of the source line
    def initialize(line_id)
      super(line_id)
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.button_with_log_pre(@line_id)
    end
  end

  ##
  # Heading
  class Heading < Element

    ##
    # Create a new heading
    # @param [Fixnum] level of the heading
    # @param [String] title title of the heading
    def initialize(level, title)
      super()
      @level, @title = level, title
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.heading(@level, @title)
    end
  end

  ##
  # HTML code (can only be used in HTML slides)
  class HTML < Element

    ##
    # Create a new element
    # @param [String] content HTML code
    def initialize(content)
      super()
      @content = content
    end

    def append(content)
      @content << content
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.html(@content)
    end
  end

  ##
  # Image
  class Image < Element

    ##
    # Create a new image
    # @param [String] location path of the image
    # @param [String] alt alternate text
    # @param [String] title title
    # @param [String] width_slide width for slides
    # @param [String] width_plain width for plain text
    def initialize(location, alt, title, width_slide, width_plain)
      super()
      @location, @alt, @title, @width_slide, @width_plain = location, alt, title, width_slide, width_plain
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.image(@location, @alt, @title, @width_slide, @width_plain)
    end
  end

  ##
  # Link output to code on previous slide
  class LinkPrevious < Button
    ## Create a new button
    # @param [String] line_id id of the source line
    def initialize(line_id)
      super(line_id)
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.link_previous(@line_id)
    end
  end

  ##
  # Link CSS to output
  class LiveCSS < Button
    ## Create a new button
    # @param [String] line_id id of the source line
    # @param [String] fragment html code the button refers to
    def initialize(line_id, fragment)
      super(line_id)
      @fragment = fragment
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.live_css(@line_id, @fragment)
    end
  end

  ##
  # Link output to code on same slide
  class LivePreview < Button
    ## Create a new button
    # @param [String] line_id id of the source line
    def initialize(line_id)
      super(line_id)
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.live_preview(@line_id)
    end
  end

  ##
  # Link floating output to code on same slide
  class LivePreviewFloat < Button
    ## Create a new button
    # @param [String] line_id id of the source line
    def initialize(line_id)
      super(line_id)
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.live_preview_float(@line_id)
    end
  end
end