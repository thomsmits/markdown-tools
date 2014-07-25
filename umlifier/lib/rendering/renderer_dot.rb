# -*- coding: utf-8 -*-

require_relative 'Renderer'

module Rendering
  class RendererDOT < Renderer

    ##
    # Initialize the renderer
    # @param [IO] io target of output operations
    def initialize(io)
      super(io)
    end

    def diagram_start
      @io << <<-ENDTEXT
      digraph G {
         fontname = "Helvetica"
         fontsize = 8
         rankdir = BT
         ranksep = 0.35
         size = "25.7,8.3!"

        node [
          fontname  = "Helvetica"
          fontsize  = 8
          height = 0.4
          labelloc = "c"
          len = 100
        ]

        edge [
          fontname  = "Helvetica"
          fontsize  = 7
          penwidth  = 0.75
        ]
      ENDTEXT
    end

    def diagram_end
      @io << '}' << nl
    end

    def normalize_name(name)
      name.gsub(/-/, '').gsub(/_/, '').gsub(/ /, '').gsub(/[^A-Za-z]/, '').downcase
    end

    def term(name)
      @io << "#{normalize_name(name)} ["
      @io << simple_node
      @io << " label=\"#{name}\""
      @io << ']' << nl
    end

    def class_start(name, abstract)

      type_node

      if abstract
        name_formatted = "<b><i>#{name}</i></b><br/>\\{abstract\\}"
      else
        name_formatted = "<b>#{name}</b>"
      end

      @io << "  #{normalize_name(name)} [" << nl
      @io << type_node
      @io << " label=<{#{name_formatted}"
    end

    def class_end
      @io << '}>' << nl
      @io << ']' << nl
    end

    def interface_start(name)

      @io << " #{normalize_name(name)} [" << nl
      @io << type_node
      @io << ' label=<{'
      @io << "&laquo;interface&raquo;<br/><b><i>#{name}</i></b><br/>"
    end

    def interface_end
      @io << '}>' << nl
      @io << ']' << nl
    end

    def instance_start(name)
      @io << " #{normalize_name(name)} [" << nl
      @io << type_node
      @io << ' label=<{'
      @io << "<u><b><i>#{name}</i></b></u><br align='left'/>"
    end

    def instance_end
      @io << '}>' << nl
      @io << ']' << nl
    end


    def field(visibility, name, static)

      sign = visibility.nil? ? '' : visibility.sign

      if static
        @io << "<u>#{sign}#{name}</u><br align='left'/>"
      else
        @io << "#{sign}#{name}<br align='left'/>"
      end
    end

    def method(visibility, name, static, abstract)

      sign = visibility.nil? ? '' : visibility.sign

      if static && !abstract
        @io << "<u>#{sign}#{name}</u><br align='left'/>"
      elsif !static && abstract
        @io << "<i>#{sign}#{name}</i><br align='left'/>"
      elsif !static && !abstract
        @io << "#{sign}#{name}<br align='left'/>"
      else
        raise Exception, "Static and Abstract cannot be combined"
      end
    end

    def fields_start
      @io << '|'
    end

    def fields_end
    end

    def methods_start
      @io << '|'
    end

    def methods_end
    end


    def relation(from, to, label, card_from, card_to)
      edge('open', 'dashed', from, to, label, card_from, card_to, '0.6', true)
    end

    def composition(from, to, label, card_from, card_to)
      edge('diamond', 'solid', from, to, label, card_from, card_to, '1.2')
    end

    def aggregation(from, to,label, card_from, card_to)
      edge('ediamond', 'solid',  from, to, label, card_from, card_to, '1.2')
    end

    def implementation(from, to)
      edge('empty', 'dashed', from, to, '', '', '',  '1.4')
    end

    def inheritance(from, to)
      edge('empty', 'solid', from, to, '', '', '', '1.4')
    end

    def association(from, to, label, card_from, card_to)
      edge('none', 'solid', from, to, label, card_from, card_to)
    end

    def directed_association(from, to, label, card_from, card_to)
      edge('open', 'solid', from, to, label, card_from, card_to, '0.6')
    end

    def edge(arrowhead, style, from, to, label = '', tail_label = '',  head_label = '', size = '1.0', no_rank = false)
      @io << "#{normalize_name(from.to_s)} -> #{normalize_name(to.to_s)}"
      @io << ' ['
      @io << "arrowhead = \"#{arrowhead}\", "
      @io << "style     = \"#{style}\", "
      @io << "label     = \" #{label} \", "
      @io << "headlabel = \" #{head_label}  \", "
      @io << "taillabel = \" #{tail_label}  \", "
      @io << "arrowsize = #{size},  "
      @io << 'constraint = false, '  if no_rank
      @io << ']' << nl
    end

    def type_node
      'shape = "record",  '
    end

    def simple_node
      'shape = "rect", height = 0.1, fontname = "Helvetica-bold", '
    end

  end
end
