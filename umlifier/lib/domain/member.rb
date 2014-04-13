# -*- coding: utf-8 -*-

module Domain
  class Member
    attr_accessor :name, :visibility, :static

    def initialize(name, visibility, static = false)
      @name, @visibility, @static = name, visibility, static
    end
  end

  class Field < Member

    def initialize(name, visibility, static = false)
      super(name, visibility, static)
    end

    def render(renderer)
      renderer.field(@visibility, @name, @static)
    end
  end

  class Method < Member
    attr_accessor :abstract

    def initialize(name, visibility, static = false, abstract = false)
      super(name, visibility, static)
      @abstract = abstract
    end

    def render(renderer)
      renderer.method(@visibility, @name, @static, @abstract)
    end
  end

  class Constructor < Member

    def initialize(name, visibility)
      super(name, visibility, true)
    end

    def render(renderer)
      renderer.method(@visibility, @name, @static, false)
    end

  end
end
