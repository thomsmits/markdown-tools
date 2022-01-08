require_relative 'line_renderer'

module Rendering
  class LineRendererLatex < LineRenderer

    META_REPLACEMENTS = [
      ['\\',                  '\textbackslash '],
      ['#',                   '\#'],
      ['&',                   '\\\\&'],
      ['_',                   '\_'],
      ['{',                   '\{'],
      ['}',                   '\}'],
      ['$',                   '\$'],
      ['%',                   '\%'],
    ]

    REPLACEMENTS = [
      # Greek characters
      ['α',                   '\textalpha{}'],
      ['β',                   '\textbeta{}'],
      ['Γ',                   '\textGamma{}'],
      ['γ',                   '\textgamma{}'],
      ['Δ',                   '\textDelta{}'],
      ['δ',                   '\textdelta{}'],
      ['ϵ',                   '\textepsilon{}'],
      ['ζ',                   '\textzeta{}'],
      ['η',                   '\texteta{}'],
      ['Θ',                   '\textTheta{}'],
      ['θ',                   '\texttheta{}'],
      ['ι',                   '\textiota{}'],
      ['κ',                   '\textkappa{}'],
      ['Λ',                   '\textLambda{}'],
      ['λ',                   '\textlambda{}'],
      ['μ',                   '\textmu{}'],
      ['ν',                   '\textnu{}'],
      ['Ξ',                   '\textXi{}'],
      ['ξ',                   '\textxi{}'],
      ['Π',                   '\textPi{}'],
      ['π',                   '\textpi{}'],
      ['ρ',                   '\textrho{}'],
      ['∑',                   '\textSigma{}'],
      ['σ^2',                 '\begin{math}\sigma\textsuperscript{2}\end{math}'],
      ['σ',                   '\textsigma{}'],
      ['τ',                   '\texttau{}'],
      ['Υ',                   '\textUpsilon{}'],
      ['υ',                   '\textupsilon{}'],
      ['Φ',                   '\textPhi{}'],
      ['ϕ',                   '\textphi{}'],
      ['φ',                   '\textvarphi{}'],
      ['χ',                   '\textchi{}'],
      ['Ψ',                   '\textPsi{}'],
      ['ψ',                   '\textpsi{}'],
      ['Ω',                   '\textOmega{}'],
      ['ω',                   '\textomega{}'],
      ['≤',                   '\begin{math}\le\end{math}'],
      ['≥',                   '\begin{math}\ge\end{math}'],

      # Quotes
      [/"(.*?)"/,             '\enquote{\1}'],

      # Abbreviations
      ['Z.B.',                'Z.\,B.'],
      ['z.B.',                'z.\,B.'],
      ['D.h.',                'D.\,h.'],
      ['d.h.',                'd.\,h.'],
      ['u.a.',                'u.\,a.'],
      ['s.u.',                's.\,u.'],
      ['s.o.',                's.\,o.'],
      ['u.U.',                'u.\,U.'],
      ['i.e.',                'i.\,e.'],
      ['e.g.',                'e.\,g.'],
      ['o.O.',                'o.\,O.'],
      ['o.J.',                'o.\,J.'],

      # Arrows
      [/([^<]|^)<->(\s|\))/,  '\1$\leftrightarrow$\2' ],
      [/([^<]|^)<=>(\s|\))/,  '\1$\Leftrightarrow$\2' ],
      [/([^<]|^)->(\s|\))/,   '\1$\rightarrow$\2' ],
      [/([^<]|^)=>(\s|\))/,   '\1$\Rightarrow$\2' ],
      [/([^<]|^)<-(\s|\))/,   '\1$\leftarrow$\2' ],
      [/([^<]|^)<=(\s|\))/,   '\1$\Leftarrow$\2' ],

      # Dots
      ['...',                 '\dots{}'],

      ## Other special characters
      ['<<',                  '{\flqq}'],
      ['>>',                  '{\frqq}'],
      ['<',                   '{\textless}'],
      ['>',                   '{\textgreater}'],
      ['~',                   '{\textasciitilde}'],
      ['^',                   '{\textasciicircum}'],
    ].freeze

    FORMULA_REPLACEMENTS = [
      ['α',                   '\alpha{}'],
      ['β',                   '\beta{}'],
      ['Γ',                   '\Gamma{}'],
      ['γ',                   '\gamma{}'],
      ['Δ',                   '\Delta{}'],
      ['δ',                   '\delta{}'],
      ['ϵ',                   '\epsilon{}'],
      ['ζ',                   '\zeta{}'],
      ['η',                   '\eta{}'],
      ['Θ',                   '\Theta{}'],
      ['θ',                   '\theta{}'],
      ['ι',                   '\iota{}'],
      ['κ',                   '\kappa{}'],
      ['Λ',                   '\Lambda{}'],
      ['λ',                   '\lambda{}'],
      ['μ',                   '\mu{}'],
      ['ν',                   '\nu{}'],
      ['Ξ',                   '\Xi{}'],
      ['ξ',                   '\xi{}'],
      ['Π',                   '\Pi{}'],
      ['π',                   '\pi{}'],
      ['ρ',                   '\rho{}'],
      ['∑',                   '\Sigma{}'],
      ['σ',                   '\sigma{}'],
      ['τ',                   '\tau{}'],
      ['Υ',                   '\Upsilon{}'],
      ['υ',                   '\upsilon{}'],
      ['Φ',                   '\Phi{}'],
      ['ϕ',                   '\phi{}'],
      ['φ',                   '\varphi{}'],
      ['χ',                   '\chi{}'],
      ['Ψ',                   '\Psi{}'],
      ['ψ',                   '\psi{}'],
      ['Ω',                   '\Omega{}'],
      ['ω',                   '\omega{}'],
    ].freeze

    def all_inline_replacements
      META_REPLACEMENTS + REPLACEMENTS
    end

    def meta_replacements
      META_REPLACEMENTS
    end

    def formula_replacements
      FORMULA_REPLACEMENTS
    end

    def render_code(content)

      options = 'literate={-}{{\textminus}}1 {-\ }{{\textminus}\ }2,'
      #size = table ? ',basicstyle=\scriptsize' : ',style=inline' # TODO: Table management
      size = ',style=inline'

      delimiters = %w{+ ! & _ - = $ : ~ . ; ?}
      if content.include?('|')
        # search for a delimiter not used
        delimiters.filter! { |d| !content.include?(d) }
        delimiter = delimiters.pop
        "\\lstinline[#{options}language=#{@prog_lang}#{size}]#{delimiter}#{content}#{delimiter}"
      else
        "\\lstinline[#{options}language=#{@prog_lang}#{size}]|#{content}|"
      end
    end

    def render_strongunderscore(content)
      "\\term{#{content}}\\index{#{content}}"
    end

    def render_strongstar(content)
      "\\termenglish{#{content}}"
    end

    def render_emphasisunderscore(content)
      "\\strong{#{content}}"
    end

    def render_emphasisstar(content)
      "\\strongenglish{#{content}}"
    end

    def render_superscript(content)
      "\\begin{math}\\textsuperscript{#{content}}\\end{math}"
    end

    def render_subscript(content)
      "\\begin{math}\\textsubscript{#{content}}\\end{math}"
    end

    def render_citation(content)
      "[\\cite{#{content}}]"
    end

    def render_link(content, target = '', title = '')
      if title.nil?
        %Q|\\href{#{meta(target)}}{#{meta(content)}}|
      else
        %Q|\\href{#{meta(target)}}{#{meta(content)}}|
      end
    end

    def render_formula(content)
      "\\begin{math}#{formula(content)}\\end{math}"
    end

    def render_deleted(content)
      "\\sout{#{content}}"
    end

    def render_underline(content)
      "\\underline{#{content}}"
    end

    def render_newline(content)
      "\\newline\n"
    end
  end
end
