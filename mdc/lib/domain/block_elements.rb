# -*- coding: utf-8 -*-

require_relative 'element'
require_relative '../constants'

module Domain

  ##
  # Base class for all elements that span more than one line
  class BlockElement < Element

    attr_accessor :content

    ##
    # Create a new element with the given content
    # @param [String] content of the element
    # @param [Fixnum] order the order of displaying the item
    def initialize(content, order = 0)
      super(order)
      @content = content
    end

    ##
    # Append a single line to the element
    # @param [String] line to be appended
    def append(line)
      @content << line
    end

    ##
    # Create a digest of the content
    # @return [String] a digest of the slide
    def digest
      @content
    end

    ##
    # Return a string representation of the object
    # @return [String] a string representation
    def to_s
      @content.strip
    end
  end

  ##
  # Equation
  class Equation < BlockElement

    ##
    # Create a new element with the given content
    # @param [String] content of the element
    def initialize(content = '')
      super(content)
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.equation(@content)
    end
  end

  ##
  # Unordered list
  class UnorderedList < BlockElement

    attr_accessor :entries, :parent

    ##
    # Crate a new list
    def initialize
      super('')
      @parent = nil
      @entries = [ ]
    end

    ##
    # Add an element to the list
    # @param [Domain::BlockElement] element to be added
    def add(element)
      @entries << element
      element.parent = self
    end

    ##
    # Append a line to the list
    # @param [String] line the line to be added
    def append(line)
      self.add(UnorderedListItem.new(line))
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.ul_start
      @entries.each { |e| e.render(renderer) }
      renderer.ul_end
    end

    ##
    # Create a digest of the content
    # @return [String] a digest of the slide
    def digest
      digest = ''
      @entries.each { |entry| digest << entry.digest << ' '}
      digest
    end
  end

  ##
  # Ordered list
  class OrderedList < UnorderedList

    attr_accessor :start_number

    ##
    # Crate a new list with the given start number
    # @param [Fixnum] start_number number of first entry
    def initialize(start_number)
      super()
      @start_number = start_number
    end

    ##
    # Append a line to the list
    # @param [String] line the line to be added
    def append(line)
      self.add(OrderedListItem.new(line))
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.ol_start(@start_number)
      @entries.each { |e| e.render(renderer) }
      renderer.ol_end
    end
  end

  ##
  # Item of an ordered list
  class OrderedListItem < BlockElement

    attr_accessor :parent

    ##
    # Create a new element with the given content
    # @param [String] content content of the item
    def initialize(content)
      super(content)
      @parent = nil
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.ol_item(@content)
    end
  end

  ##
  # Quote
  class Quote < BlockElement

    attr_accessor :source

    ##
    # Create a new quote with the given content
    # @param [String] content content of the quote
    def initialize(content = '')
      super(content)
      @source = nil
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.quote(@content, source)
    end
  end

  ##
  # Important
  class Important < BlockElement

    ##
    # Create a box for important content
    # @param [String] content content of the box
    def initialize(content = '')
      super(content)
      @source = nil
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.important(@content)
    end
  end

  ##
  # Question
  class Question < BlockElement

    ##
    # Create a box for question content
    # @param [String] content content of the box
    def initialize(content = '')
      super(content)
      @source = nil
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.question(@content)
    end
  end

  ##
  # Script
  class Script < BlockElement

    ##
    # Create a new script with the given content
    # @param [String] content content of the script
    def initialize(content = '')
      super(content)
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.script(@content)
    end
  end

  ##
  # Table
  class Table < BlockElement

    ## Header of the tabke
    class TableHeader

      attr_accessor :name, :alignment

      ##
      # Create a new header
      # @param [String] name name of the header
      # @param [Fixnum] alignment alignment of the header cell
      def initialize(name, alignment = Constants::LEFT)
        @name, @alignment = name, alignment
      end
    end

    attr_accessor :headers, :rows

    ##
    # Create a new table
    def initialize
      super('')
      @headers = [ ]
      @rows = [ ]
    end

    ##
    # Add a header to the table
    # @param [String] header_name name of the header
    # @param [Fixnum] alignment alignment of the header
    def add_header(header_name, alignment)
      @headers << TableHeader.new(header_name, alignment)
    end

    ##
    # Add a full row to the table
    # @param [Array] row of the row
    def add_row(row)
      @rows << row
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)

      alignment = [ ]
      titles = [ ]
      @headers.each { |h|
        alignment << h.alignment
        titles    << h.name
      }

      renderer.table_start(titles, alignment)
      @rows.each { |r| renderer.table_row(r, alignment) }
      renderer.table_end
    end
  end

  ##
  # Item of an unordered list
  class UnorderedListItem < BlockElement

    attr_accessor :parent

    ##
    # Create a new list item with the given content
    # @param [String] content content of the item
    def initialize(content)
      super(content)
      @parent = nil
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.ul_item(@content)
    end
  end

  ##
  # Source code
  class Source < BlockElement

    attr_accessor :language, :caption

    ##
    # Create a new source code fragment with the given language
    # @param [String] language the programming language
    # @param [String] caption caption of the source code
    # @param [Fixnum] order the order of displaying the item
    def initialize(language, caption = nil, order = 0)
      super('', order)
      @language = language
      @caption = caption
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.code_start(@language, @caption)
      renderer.code(@content)
      renderer.code_end(@caption)
    end
  end

  ##
  # Text
  class Text < BlockElement

    ##
    # Create a new plain text element with the given text
    # @param [String] content text of the element
    def initialize(content)
      super(content)
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.text(@content)
    end
  end

  ##
  # Inline UML, embedded in the slide and compiled to a graphic
  class UML < BlockElement

    attr_accessor :picture_name, :width_slide, :with_plain

    ##
    # Create a new element
    def initialize(picture_name, width_slide, width_plain)
      super('')
      @picture_name = picture_name
      @width_slide, @width_plain = width_slide, width_plain
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.uml(@picture_name, @content, @width_slide, @width_plain)
    end
  end
end
