require_relative 'line_renderer'

module Rendering
  ##
  # Line renderer implementation for the
  # Typst type setting system.
  class LineRendererTypst < LineRenderer

    META_REPLACEMENTS = [
      ['#', '\#'],
      ['@', '\@'],
      ['$', '\$'],
      ['*', '\*'],
      ['_', '\_'],
      ['<', '\<'],
      ['>', '\>'],
      [/([0-9]+)\./, '\1\\.'],
    ].freeze

    REPLACEMENTS = [
      ['Z.B.',                "Z.\u2009B."],
      ['z.B.',                "z.\u2009B."],
      ['D.h.',                "D.\u2009h."],
      ['d.h.',                "d.\u2009h."],
      ['u.a.',                "u.\u2009a."],
      ['u.ä.',                "u.\u2009ä."],
      ['s.u.',                "s.\u2009u."],
      ['s.o.',                "s.\u2009o."],
      ['u.U.',                "u.\u2009U."],
      ['i.e.',                "i.\u2009e."],
      ['e.g.',                "e.\u2009g."],
      ['o.O.',                "o.\u2009O."],
      ['o.ä.',                "o.\u2009ä."],
      ['o.J.',                "o.\u2009J."],
      [/([^<]|^)\\<-\\>(\s|\))/,  '\1⟷\2'],
      [/([^<]|^)\\<=\\>(\s|\))/,  '\1⇔\2'],
      [/([^<]|^)-\\>(\s|\))/,   '\1➛\2'],
      [/([^<]|^)=\\>(\s|\))/,   '\1⇒\2'],
      [/([^<]|^)\\<-(\s|\))/,   '\1←\2'],
      [/([^<]|^)\\<=(\s|\))/,   '\1⇐\2'],
    ].freeze

    FORMULA_REPLACEMENTS = [
      ['\alpha', 'alpha'],
      ['\beta', 'beta'],
      ['\gamma', 'gamma'],
      ['\delta', 'delta'],
      ['\epsilon', 'epsilon.alt'],
      ['\zeta', 'zeta'],
      ['\eta', 'eta'],
      ['\theta', 'theta'],
      ['\iota', 'iota'],
      ['\kappa', 'kappa'],
      ['\lambda', 'lambda'],
      ['\mu', 'mu'],
      ['\nu', 'nu'],
      ['\xi', 'xi'],
      ['\omicron', 'omicron'],
      ['\pi', 'pi'],
      ['\rho', 'rho'],
      ['\sigma', 'sigma'],
      ['\tau', 'tau'],
      ['\upsilon', 'upsilon'],
      ['\phi', 'phi.alt'],
      ['\chi', 'chi'],
      ['\psi', 'psi'],
      ['\omega', 'omega'],
      ['\varepsilon', 'epsilon'],
      ['\vartheta', 'theta.alt'],
      ['\varpi', 'pi.alt'],
      ['\varrho', 'rho.alt'],
      ['\varsigma', 'sigma.alt'],
      ['\varphi', 'phi'],
      ['\Gamma', 'Gamma'],
      ['\Delta', 'Delta'],
      ['\Theta', 'Theta'],
      ['\Lambda', 'Lambda'],
      ['\Xi', 'Xi'],
      ['\Pi', 'Pi'],
      ['\Sigma', 'Sigma'],
      ['\Upsilon', 'Upsilon'],
      ['\Phi', 'Phi'],
      ['\Psi', 'Psi'],
      ['\Omega', 'Omega'],
      ['\int', 'integral'],
      ['\int', 'integral'],
      ['\oint', 'integral.cont'],
      ['\iint', 'integral.double'],
      ['\oiint', 'integral.surf'],
      ['\iiint', 'integral.triple'],
      ['\oiiint', 'integral.vol'],
      ['\leftarrow', 'arrow.l'],
      ['\gets', 'arrow.l'],
      ['\rightarrow', 'arrow.r'],
      ['\to', 'arrow.r'],
      ['\leftrightarrow', 'arrow.l.r'],
      ['\Leftarrow', 'arrow.l.double'],
      ['\Rightarrow', 'arrow.r.double'],
      ['\Leftrightarrow', 'arrow.l.r.double'],
      ['\mapsto', 'arrow.r.bar'],
      ['\hookleftarrow', 'arrow.l.hook'],
      ['\leftharpoonup', 'harpoon.lt'],
      ['\leftharpoondown', 'harpoon.lb'],
      ['\rightleftharpoons', 'harpoons.rtlb'],
      ['\longleftarrow', 'arrow.l.long'],
      ['\longrightarrow', 'arrow.r.long'],
      ['\longleftrightarrow', 'arrow.l.r.long'],
      ['\Longleftarrow', 'arrow.l.double.long'],
      ['\Longrightarrow', 'arrow.r.double.long'],
      ['\Longleftrightarrow', 'arrow.l.r.double.long'],
      ['\longmapsto', 'arrow.r.long.bar'],
      ['\hookrightarrow', 'arrow.r.hook'],
      ['\rightharpoonup', 'harpoon.rt'],
      ['\rightharpoondown', 'harpoon.rb'],
      ['\iff', 'arrow.l.r.double.long'],
      ['\implies', 'arrow.r.double.long'],
      ['\uparrow', 'arrow.t'],
      ['\downarrow', 'arrow.b'],
      ['\updownarrow', 'arrow.t.b'],
      ['\Uparrow', 'arrow.t.double'],
      ['\Downarrow', 'arrow.b.double'],
      ['\Updownarrow', 'arrow.t.b.double'],
      ['\nearrow', 'arrow.tr'],
      ['\searrow', 'arrow.br'],
      ['\swarrow', 'arrow.bl'],
      ['\nwarrow', 'arrow.tl'],
      ['\leadsto', 'arrow.r.squiggly'],
      ['\leftleftarrows', 'arrows.ll'],
      ['\rightrightarrows', 'arrows.rr'],
      ['\in', 'in'],
      ['\subseteq', 'subset.eq'],
      ['\subset', 'subset'],
      ['\supset', 'supset'],
      ['\supseteq', 'supset.eq'],
      ['\varnothing', 'diameter'],
      ['\pounds', 'pound'],
      ['\yen', 'yen'],
      ['\copyright', 'copyright'],
      ['\S', 'section'],
      ['\P', 'pilcrow'],
      ['\Cap', 'inter.double'],
      ['\Cup', 'union.double'],
      ['\Join', 'join'],
      ['\aleph', 'alef'],
      ['\angle', 'angle'],
      ['\approx', 'approx'],
      ['\approxeq', 'approx.eq'],
      ['\ast', 'ast'],
      ['\bigcap', 'inter.big'],
      ['\bigcirc', 'circle.big'],
      ['\bigcup', 'union.big'],
      ['\bigodot', 'dot.circle.big'],
      ['\bigoplus', 'xor.big'],
      ['\bigotimes', 'times.circle.big'],
      ['\bigsqcup', 'union.sq.big'],
      ['\bigtriangledown', 'triangle.b'],
      ['\bigtriangleup', 'triangle.t'],
      ['\biguplus', 'union.plus.big'],
      ['\bigvee', 'or.big'],
      ['\bigwedge', 'and.big'],
      ['\bullet', 'bullet'],
      ['\cap', 'inter'],
      ['\cdot', 'dot.op'],
      ['\cdots', 'dots.c'],
      ['\checkmark', 'checkmark'],
      ['\circ', 'circle.small'],
      ['\colon', 'colon'],
      ['\cong', 'tilde.equiv'],
      ['\coprod', 'product.co'],
      ['\cup', 'union'],
      ['\curlyvee', 'or.curly'],
      ['\curlywedge', 'and.curly'],
      ['\dagger', 'dagger'],
      ['\dashv', 'tack.l'],
      ['\ddagger', 'dagger.double'],
      ['\ddots', 'dots.down'],
      ['\diamond', 'diamond'],
      ['\displaystyle', ''],
      ['\div', 'div'],
      ['\divideontimes', 'times.div'],
      ['\dotplus', 'plus.dot'],
      ['\dotsb', 'dots.c'],
      ['\ell', 'ell'],
      ['\emptyset', 'nothing'],
      ['\equiv', 'equiv'],
      ['\exists', 'exists'],
      ['\forall', 'forall'],
      ['\geq', 'gt.eq'],
      ['\ge', 'gt.eq'],
      ['\geqslant', 'gt.eq.slant'],
      ['\gg', 'gt.double'],
      ['\hbar', 'planck.reduce'],
      ['\imath', 'dotless.i'],
      ['\infty', 'infinity'],
      ['\intercal', 'top'],
      ['\jmath', 'dotless.j'],
      ['\land', 'and'],
      ['\langle', 'angle.l'],
      ['\lbrace', 'brace.l'],
      ['\lbrack', 'bracket.l'],
      ['\ldots', 'dots.l'],
      ['\leq', 'lt.eq'],
      ['\le', 'lt.eq'],
      ['\leftthreetimes', 'times.three.l'],
      ['\leqslant', 'lt.eq.slant'],
      ['\lhd', 'triangle.l'],
      ['\ll', 'lt.double'],
      ['\log{}', 'log'],
      ['\log', 'log'],
      [/\\log\{(.*?)}/, 'log(\1)'],
      [/\\log_(.)\{(.*?)}/, 'log_\1 (\2)'],
      ['\ltimes', 'times.l'],
      ['\measuredangle', 'angle.arc'],
      ['\mid', 'divides'],
      ['\models', 'models'],
      ['\mp', 'minus.plus'],
      ['\nRightarrow', 'arrow.double.not'],
      ['\nabla', 'nabla'],
      ['\ncong', 'tilde.nequiv'],
      ['\ne{}', 'eq.not'],
      ['\ne', 'eq.not'],
      ['\neg{}', 'not'],
      ['\neg', 'not'],
      ['\neq{}', 'eq.not'],
      ['\neq', 'eq.not'],
      ['\nexists{}', 'exists.not'],
      ['\nexists', 'exists.not'],
      ['\ngeq', 'gt.eq.not'],
      ['\ni', 'in.rev'],
      ['\nleftarrow', 'arrow.l.not'],
      ['\nleq', 'lt.eq.not'],
      ['\nparallel', 'parallel.not'],
      ['\nmid', 'divides.not'],
      ['\notin', 'in.not'],
      ['\nrightarrow', 'arrow.not'],
      ['\nsim', 'tilde.not'],
      ['\nsubseteq', 'subset.eq.not'],
      ['\ntriangleleft', 'lt.tri.not'],
      ['\ntriangleright', 'gt.tri.not'],
      ['\odot', 'dot.circle'],
      ['\ominus', 'minus.circle'],
      ['\oplus', 'xor'],
      ['\otimes', 'times.circle'],
      ['\parallel', 'parallel'],
      ['\partial', 'diff'],
      ['\perp', 'perp'],
      ['\pm', 'plus.minus'],
      ['\prec', 'prec'],
      ['\preceq', 'prec.eq'],
      ['\prime', 'prime'],
      ['\prod', 'product'],
      ['\propto', 'prop'],
      ['\rangle', 'angle.r'],
      ['\rbrace', 'brace.r'],
      ['\rbrack', 'bracket.r'],
      ['\rhd', 'triangle'],
      ['\rightthreetimes', 'times.three.r'],
      ['\rtimes', 'times.r'],
      ['\setminus', 'without'],
      ['\sim', 'tilde'],
      ['\simeq', 'tilde.eq'],
      ['\smallsetminus', 'without'],
      ['\spadesuit', 'suit.spade'],
      ['\sqcap', 'inter.sq'],
      ['\sqcup', 'union.sq'],
      ['\sqsubseteq', 'subset.eq.sq'],
      ['\sqsupseteq', 'supset.eq.sq'],
      ['\star', 'star'],
      ['\subsetneq', 'subset.neq'],
      ['\succ', 'succ'],
      ['\succeq', 'succ.eq'],
      [/\\sum_\{(.*?)}\^\{(.*?)}/, 'sum###\1###\2###'],
      ['\sum', 'sum'],
      [/(\S)\^\{(.*?)}/, 'attach(\1, t:"\2")'],
      [/(\S)_{(.*?)}/, 'attach(\1, b:"\2")'],
      ['\supsetneq', 'supset.neq'],
      ['\times', 'times'],
      ['\top', 'top'],
      ['\triangle', 'triangle.t'],
      ['\triangledown', 'triangle.b.small'],
      ['\triangleleft', 'triangle.l.small'],
      ['\triangleright', 'triangle.r.small'],
      ['\twoheadrightarrow', 'arrow.r.twohead'],
      ['\upharpoonright', 'harpoon.tr'],
      ['\uplus', 'union.plus'],
      ['\vdash', 'tack.r'],
      ['\vdots', 'dots.v'],
      ['\vee', 'or'],
      ['\wedge', 'and'],
      ['\wr', 'wreath'],
      [/\\boldsymbol\{(.*?)}/, 'bold(\\1)'],
      [/\\mathbb\{(.*?)}/, '\\1\\1'],
      [/\\mathbf\{(.*?)}/, 'upright(bold(\\1))'],
      [/\\mathcal\{(.*?)}/, 'cal(\\1)'],
      [/\\mathit\{(.*?)}/, 'italic(\\1)'],
      [/\\frac\{(.*?)}\{(.*?)}/, 'frac(\\1, \\2)'],
      [/\\mathfrak\{(.*?)}/, 'frak(\\1)'],
      [/\\mathrm\{(.*?)}/, 'upright(\\1)'],
      [/\\mathsf\{(.*?)}/, 'sans(\\1)'],
      [/\\mathtt\{(.*?)}/, 'mono(\\1)'],
      [/\\mathbb \{(.*?)}/, '\\1\\1'],
      [/\\mathbf \{(.*?)}/, 'upright(bold(\\1))'],
      [/\\mathcal \{(.*?)}/, 'cal(\\1)'],
      [/\\mathit \{(.*?)}/, 'italic(\\1)'],
      [/\\mathfrak \{(.*?)}/, 'frak(\\1)'],
      [/\\mathrm \{(.*?)}/, 'upright(\\1)'],
      [/\\mathsf \{(.*?)}/, 'sans(\\1)'],
      [/\\mathtt \{(.*?)}/, 'mono(\\1)'],
      [/\\sqrt\{(.*?)}/, 'sqrt(\\1)'],
      [/\\sqrt \{(.*?)}/, 'sqrt(\\1)'],
      [/\\text\{(.*?)}/, '"\\1"'],
      [/\\begin\{cases}(.*?)\\\\(.*?)\\end\{cases}/m, 'cases(\1, \2)'],
      [/\\begin\{cases}(.*?)\\end\{cases}/m, 'cases(\1)'],
      [/\\begin\{pmatrix}(.*?)\\end\{pmatrix}/m, 'mat(\1)'],
      [/\\begin\{bmatrix}(.*?)\\end\{bmatrix}/m, 'mat(\1)'],
      [/(\S)\\ /, '\1 '],
      ['\\\\', '\\'],
      [/sum###(.*?)###(.*?)###/, 'sum_(\1)^(\2)'],
    ].freeze

    ##
    # Method returning the inline replacements. Should be overwritten by the
    # subclasses.
    # @return [Array<Array<String, String>>] the templates
    def all_inline_replacements
      META_REPLACEMENTS + REPLACEMENTS
    end

    ##
    # Method returning the meta replacements. Should be overwritten by the
    # subclasses.
    # @return [Array<Array<String, String>>] the templates
    def meta_replacements
      META_REPLACEMENTS
    end

    ##
    # Method returning the replacements used inside a formula.
    # Should be overwritten by the subclasses.
    # @return [Array<Array<String, String>>] the templates
    def formula_replacements
      FORMULA_REPLACEMENTS
    end

    ##
    # Render a `code` node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_code(content)
      "`#{content}`"
    end

    ##
    # Render a HTML node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_html(content)
      content.to_s
    end

    ##
    # Render a __strong__ node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_strongunderscore(content)
      "#strong([#{content}])#marginale([#{content}])#index[#{content}]"
    end

    ##
    # Render a __`code`__ node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_strongunderscorecode(content)
      "#strong([`#{content}`])#marginale([`#{content}`])#index([`#{content}`])"
    end

    ##
    # Render a **strong** node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_strongstar(content)
      "#strong_alt([#{content}])"
    end

    ##
    # Render a _em_ node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_emphasisunderscore(content)
      "#emph([#{content}])"
    end

    ##
    # Render a *em* node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_emphasisstar(content)
      "#emph_alt([#{content}])"
    end

    ##
    # Render a ^superscript node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_superscript(content)
      "#super[#{content}]"
    end

    ##
    # Render a ^subscript node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_subscript(content)
      "#sub[#{content}]"
    end

    ##
    # Render a [[citation]] node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_citation(content)
      "#cite(<#{content}>)"
    end

    ##
    # Render a [](link) node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_link(content, target, title)
      if title.nil?
        %{#link("#{meta(target)}")[#{content}]}
      else
        # TODO: #{title} is missing
        %{#link("#{meta(target)}")[#{content}]}
      end
    end

    ##
    # Replace characters inside math formula
    # @param [String] input Input string
    # @return [String] result with replaced meta characters
    def formula(input)
      result = super(input)
      if result =~ /mat\(/
        result.gsub(/\\$/, ';')
              .gsub(' & ', ', ')
      else
        result
      end
    end

    ##
    # Render a \[ formula \] node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_formula(content)
      "$#{formula(content).lstrip.rstrip}$"
    end

    ##
    # Render a ~~deleted~~ node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_deleted(content)
      "#strike[#{content}]"
    end

    ##
    # Render a ~underlined~ node.
    # @param [String] content contents of the node
    # @return [String] rendered version of the content
    def render_underline(content)
      "#underline[#{content}]"
    end

    ##
    # Render a newline
    def render_newline(_content)
      ' \\ '
    end

    ##
    # Render a quote
    def render_quoted(content)
      "„#{content}“"
    end

    def render_footnote(content, _)
      "#footnote[#{meta(content)}]"
    end
  end
end