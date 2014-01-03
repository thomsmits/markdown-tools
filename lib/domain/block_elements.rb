# -*- coding: utf-8 -*-

require_relative 'element'

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
    ##
    # Create a new quote with the given content
    # @param [String] content content of the quote
    def initialize(content = '')
      super(content)
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.quote(@content)
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
    # @param [String] header one header of the table
    def add_header(header)
      @headers << header
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
      renderer.table_start(@headers.size)
      renderer.table_header(@headers)
      @rows.each { |r| renderer.table_row(r) }
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
    attr_accessor :language

    ##
    # Create a new source code fragment with the given language
    # @param [String] language the programming language
    # @param [Fixnum] order the order of displaying the item
    def initialize(language, order = 0)
      super('', order)
      @language = language
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.code_start(@language)
      renderer.code(@content)
      renderer.code_end
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

    attr_accessor :picture_name, :width

    ##
    # Create a new element
    def initialize(picture_name, width)
      super('')
      @picture_name = picture_name
      @width = width
    end

    ##
    # Render the element
    # @param [Rendering::Renderer] renderer to be used
    def render(renderer)
      renderer.uml(@picture_name, @content, @width)
    end
  end
end
