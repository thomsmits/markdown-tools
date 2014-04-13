# -*- coding: utf-8 -*-

require_relative 'member'
module Domain

  class Type
    attr_accessor :name, :fields, :methods

    def initialize(name, fields = [ ], methods = [ ])
      @name, @fields, @methods = name, fields, methods
    end

    def <<(type)
      if type.instance_of?(Field)
        fields << type
      else
        methods << type
      end
    end

    def to_s
      @name
    end

    def render_member(renderer)
      if @fields.size > 0

        renderer.fields_start

        @fields.each { |f|
          f.render(renderer)
        }

        renderer.fields_end

      end

      if @methods.size > 0

        renderer.methods_start

        @methods.each { |f|
          f.render(renderer)
        }

        renderer.methods_end
      end
    end
  end

  class Clazz < Type

    attr_accessor :abstract

    def initialize(name, abstract = false, fields = [ ], methods = [ ])
      super(name, fields, methods)
      @abstract = abstract
    end

    def render(renderer)
      renderer.class_start(name, abstract)
      render_member(renderer)
      renderer.class_end
    end
  end

  class Interface < Type
    def initialize(name, fields = [ ], methods = [ ])
      super(name, fields, methods)
      @abstract = true
    end

    def render(renderer)
      renderer.interface_start(@name)
      render_member(renderer)
      renderer.interface_end
    end
  end

  class Instance < Clazz
    def initialize(name, fields = [ ], methods = [ ])
      super(name, fields, methods)
      @abstract = true
    end

    def render(renderer)
      renderer.instance_start(@name)
      render_member(renderer)
      renderer.instance_end
    end
  end

end
