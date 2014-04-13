module Domain
  class Term
    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def render(renderer)
      renderer.term(@name)
    end

    def to_s; @name;  end
  end
end