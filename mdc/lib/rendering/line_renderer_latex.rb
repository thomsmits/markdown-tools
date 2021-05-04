require_relative 'line_renderer'

module Rendering
  class LineRendererLatex < LineRenderer

    REPLACEMENTS = [
      ['\\',                  '\textbackslash '],
      ['{',                   '\{'],
      ['}',                   '\}'],
      ['α',                   '\begin{math}\alpha\end{math}'],
      ['β',                   '\begin{math}\beta\end{math}'],
      ['Γ',                   '\begin{math}\Gamma\end{math}'],
      ['γ',                   '\begin{math}\gamma\end{math}'],
      ['Δ',                   '\begin{math}\Delta\end{math}'],
      ['δ',                   '\begin{math}\delta\end{math}'],
      ['ϵ',                   '\begin{math}\epsilon\end{math}'],
      ['ζ',                   '\begin{math}\zeta\end{math}'],
      ['η',                   '\begin{math}\eta\end{math}'],
      ['Θ',                   '\begin{math}\Theta\end{math}'],
      ['θ',                   '\begin{math}\theta\end{math}'],
      ['ι',                   '\begin{math}\iota\end{math}'],
      ['κ',                   '\begin{math}\kappa\end{math}'],
      ['Λ',                   '\begin{math}\Lambda\end{math}'],
      ['λ',                   '\begin{math}\lambda\end{math}'],
      ['μ',                   '\begin{math}\mu\end{math}'],
      ['ν',                   '\begin{math}\nu\end{math}'],
      ['Ξ',                   '\begin{math}\Xi\end{math}'],
      ['ξ',                   '\begin{math}\xi\end{math}'],
      ['Π',                   '\begin{math}\Pi\end{math}'],
      ['π',                   '\begin{math}\pi\end{math}'],
      ['ρ',                   '\begin{math}\rho\end{math}'],
      ['∑',                   '\begin{math}\Sigma\end{math}'],
      ['σ^2',                 '\begin{math}\sigma\textsuperscript{2}\end{math}'],
      ['σ',                   '\begin{math}\sigma\end{math}'],
      ['τ',                   '\begin{math}\tau\end{math}'],
      ['Υ',                   '\begin{math}\Upsilon\end{math}'],
      ['υ',                   '\begin{math}\upsilon\end{math}'],
      ['Φ',                   '\begin{math}\Phi\end{math}'],
      ['ϕ',                   '\begin{math}\phi\end{math}'],
      ['φ',                   '\begin{math}\varphi\end{math}'],
      ['χ',                   '\begin{math}\chi\end{math}'],
      ['Ψ',                   '\begin{math}\Psi\end{math}'],
      ['ψ',                   '\begin{math}\psi\end{math}'],
      ['Ω',                   '\begin{math}\Omega\end{math}'],
      ['ω',                   '\begin{math}\omega\end{math}'],
      ['≤',                   '\begin{math}\le\end{math}'],
      ['≥',                   '\begin{math}\ge\end{math}'],
      [/"(.*?)"/,             '\enquote{\1}'],
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
      ['$',                   '\$'],
      ['%',                   '\%'],
      [/^-> /,                '$\rightarrow$ '],
      ['(-> ',                '($\rightarrow$ '],
      ['(->)',                '($\rightarrow$)'],
      ['{-> ',                '{$\rightarrow$ '],
      [' -> ',                ' $\rightarrow$ '],
      ['<br>-> ',             '<br>$\rightarrow$ '],
      [/^=> /,                '$\Rightarrow$ '],
      ['(=> ',                '($\Rightarrow$ '],
      ['(=>)',                '($\Rightarrow$)'],
      ['{=> ',                '{$\Rightarrow$ '],
      [' => ',                ' $\Rightarrow$ '],
      ['<br>=> ',             '<br>$\Rightarrow$ '],
      [/^<- /,                '$\leftarrow$ '],
      ['(<- ',                '($\leftarrow$ '],
      ['(<-)',                '($\leftarrow$)'],
      [' <- ',                ' $\leftarrow$ '],
      ['{<- ',                '{$\leftarrow$ '],
      ['<br><- ',             '<br>$\leftarrow$ '],
      [/^<= /,                '$\Leftarrow$ '],
      ['(<= ',                '($\Leftarrow$ '],
      ['(<=)',                '($\Leftarrow$)'],
      ['{<= ',                '{$\Leftarrow$ '],
      [' <= ',                ' $\Leftarrow$ '],
      ['<br><= ',             '<br>$\Leftarrow$ '],
      [/^<=> /,               '$\Leftrightarrow$ '],
      ['(<=> ',               '($\Leftrightarrow$ '],
      ['(<=>)',               '($\Leftrightarrow$)'],
      ['{<=> ',               '{$\Leftrightarrow$ '],
      [' <=> ',               ' $\Leftrightarrow$ '],
      ['<br><=> ',            '<br>$\Leftrightarrow$ '],
      [/^<-> /,               '$\leftrightarrow$ '],
      ['(<-> ',               '($\leftrightarrow$ '],
      ['(<->)',               '($\leftrightarrow$)'],
      ['{<-> ',               '{$\leftrightarrow$ '],
      [' <-> ',               ' $\leftrightarrow$ '],
      ['<br><-> ',            '<br>$\leftrightarrow$ '],
      [/^<br>/,               "\\ \\newline\n"],
      [/<br>/,                "\\newline\n"],
      ['#',                   '\#'],
      ['&',                   '\\\\&'],
      ['_',                   '\_'],
      ['<<',                  '{\flqq}'],
      ['>>',                  '{\frqq}'],
      ['<',                   '{\textless}'],
      ['>',                   '{\textgreater}'],
      ['~',                   '{\textasciitilde}'],
      ['^',                   '{\textasciicircum}'],
      ['\textsubscript',      '_'],
      ['\textsuperscript',    '^']].freeze

    def all_inline_replacements
      REPLACEMENTS
    end

    def render_code(content)

      options = 'literate={-}{{\textminus}}1 {-\ }{{\textminus}\ }2,'
      #size = table ? ',basicstyle=\scriptsize' : ',style=inline' # TODO: Table management
      size = ',style=inline'

      if content.include?('|')
        "\\lstinline[#{options}language=#{@language}#{size}]+#{content}+"
      else
        "\\lstinline[#{options}language=#{@language}#{size}]|#{content}|"
      end
    end

    def render_strongunderscore(content)
      "\\term{#{content}}"
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
      "<sup>#{content}</sup>"
    end

    def render_subscript(content)
      "<sub>#{content}</sub>"
    end

    def render_citation(content)
      "[\\cite{#{content}}]"
    end

    def render_link(content, target = '', title = '')

      _target = target.gsub('_', '\_')   # TODO: General replacement
      _content = content.gsub('_', '\_')

      if title.nil?
        %Q|\href{#{_target}}{#{content}}|
      else
        %Q|\href{#{target}}{#{content}}|
      end
    end

    def render_reflink(content, ref = '')
      if ref == "bar" # TODO: Hack!
        %Q{<a href="/url" title="title">#{content}</a>}
      elsif ref == "ref"
        %Q{<a href="/uri">#{content}</a>}
      else
        ''
      end
    end

    def render_formula(content)
      "\\begin{math}#{content}\\end{math}"
    end

    def render_deleted(content)
      "\\sout{#{content}}"
    end

    def render_underline(content)
      "\\underline{#{content}}"
    end

    def render_unparsed(content)
      "UNPARSED NODE - SHOULD NOT BE RENDERED!!!! #{content}"
    end
  end
end
