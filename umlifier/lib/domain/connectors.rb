# -*- coding: utf-8 -*-

module Domain

  ##
  # Base class for all elements connecting two entities in the diagram
  class Connector

    attr_accessor :from, :to, :card_from, :card_to, :label

    ##
    # Create a new connector
    # @param [Type] from starting point of the connector
    # @param [Type] to end point of the connector
    # @param [String] label of the connector
    # @param [String] card_from cardinality on the from side
    # @param [String] card_to cardinality on the to side
    def initialize(from = nil, to = nil, label = '', card_from = '', card_to = '')
      @from, @to, @card_from, @card_to, @label = from, to, card_from, card_to, label
    end
  end

  ##
  # Composition
  class Composition  < Connector

    ##
    # Create a new instance
    # @param [Type] from starting point of the connector
    # @param [Type] to end point of the connector
    # @param [String] label of the connector
    # @param [String] card_from cardinality on the from side
    # @param [String] card_to cardinality on the to side
    def initialize(from, to, label, card_from, card_to)
      super(from, to, label, card_from, card_to)
    end

    ##
    # Render the element using the given renderer
    # @param [Renderer] renderer renderer to be used for rendering
    def render(renderer)
      renderer.composition(@from, @to, @label, @card_to, @card_from)
    end
  end

  ##
  # Association (not directed)
  class Association < Connector

    ##
    # Create a new instance
    # @param [Type] from starting point of the connector
    # @param [Type] to end point of the connector
    # @param [String] label of the connector
    # @param [String] card_from cardinality on the from side
    # @param [String] card_to cardinality on the to side
    def initialize(from, to, label, card_from, card_to)
      super(from, to, label, card_from, card_to)
    end

    ##
    # Render the element using the given renderer
    # @param [Renderer] renderer renderer to be used for rendering
    def render(renderer)
      renderer.association(@from, @to, @label, @card_to, @card_from)
    end

  end

  ##
  # Association (directed)
  class DirectedAssociation < Connector

    ##
    # Create a new instance
    # @param [Type] from starting point of the connector
    # @param [Type] to end point of the connector
    # @param [String] label of the connector
    # @param [String] card_from cardinality on the from side
    # @param [String] card_to cardinality on the to side
    def initialize(from, to, label, card_from, card_to)
      super(from, to, label, card_from, card_to)
    end

    ##
    # Render the element using the given renderer
    # @param [Renderer] renderer renderer to be used for rendering
    def render(renderer)
      renderer.directed_association(@from, @to, @label, @card_to, @card_from)
    end

  end

  ##
  # Aggregation
  class Aggregation  < Connector

    ##
    # Create a new instance
    # @param [Type] from starting point of the connector
    # @param [Type] to end point of the connector
    # @param [String] label of the connector
    # @param [String] card_from cardinality on the from side
    # @param [String] card_to cardinality on the to side
    def initialize(from, to, label, card_from, card_to)
      super(from, to, label, card_from, card_to)
    end

    ##
    # Render the element using the given renderer
    # @param [Renderer] renderer renderer to be used for rendering
    def render(renderer)
      renderer.aggregation(@from, @to, @label, @card_to, @card_from)
    end

  end

  ##
  # Implements relationship
  class Implementation < Connector

    ##
    # Create a new instance
    # @param [Type] from starting point of the connector
    # @param [Type] to end point of the connector
    def initialize(from, to)
      super(from, to)
    end

    ##
    # Render the element using the given renderer
    # @param [Renderer] renderer renderer to be used for rendering
    def render(renderer)
      renderer.implementation(@from, @to)
    end
  end

  ##
  # Inheritance relationship
  class Inheritance < Connector

    ##
    # Create a new instance
    # @param [Type] from starting point of the connector
    # @param [Type] to end point of the connector
    def initialize(from, to)
      super(from, to)
    end

    ##
    # Render the element using the given renderer
    # @param [Renderer] renderer renderer to be used for rendering
    def render(renderer)
      renderer.inheritance(@from, @to)
    end

  end

  ##
  # General relation (uses, creates, etc.)
  class Relation < Connector

    ##
    # Create a new instance
    # @param [Type] from starting point of the connector
    # @param [Type] to end point of the connector
    # @param [String] label of the connector
    # @param [String] card_from cardinality on the from side
    # @param [String] card_to cardinality on the to side
    def initialize(from, to, label, card_from, card_to)
      super(from, to, label, card_from, card_to)
    end

    ##
    # Render the element using the given renderer
    # @param [Renderer] renderer renderer to be used for rendering
    def render(renderer)
      renderer.relation(@from, @to, @label, @card_to, @card_from)
    end
  end
end