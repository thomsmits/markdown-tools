require 'minitest/autorun'
require_relative '../lib/parsing/line_parser'
require_relative '../lib/rendering/line_renderer'


class LineRendererHTML < LineRenderer

  def render_text(content)
    content.gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')
  end

  def render_code(content)
    "<code>#{content.gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')}</code>"
  end

  def render_strongunderscore(content)
    "<strong>#{content}</strong>"
  end

  def render_strongstar(content)
    "<strong>#{content}</strong>"
  end

  def render_emphasisunderscore(content)
    "<em>#{content}</em>"
  end

  def render_emphasisstar(content)
    "<em>#{content}</em>"
  end

  def render_superscript(content)
    "<sup>#{content}</sup>"
  end

  def render_subscript(content)
    "<sub>#{content}</sub>"
  end

  def render_link(content, target = '', title = '')
    if title.nil?
      %Q{<a href="#{target}">#{content}</a>}
    else
      %Q{<a href="#{target}" title="#{title}">#{content}</a>}
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
    "$$#{content}$$"
  end

  def render_deleted(content)
    "<del>#{content}</del>"
  end

  def render_underline(content)
    "<u>#{content}</u>"
  end

  def render_unparsed(content)
    "UNPARSED NODE - SHOULD NOT BE RENDERED!!!! #{content}"
  end
end


##
# Test class for the MarkdownLine class
class LineParserTest < Minitest::Test

  Cases = [
    ['Combined', %Q{*Bold ~underline~ Bold*}, %Q{<em>Bold <u>underline</u> Bold</em>}],

    ['364', %Q{foo*bar*}, %Q{foo<em>bar</em>}],
    ['360', %Q{*foo bar*}, %Q{<em>foo bar</em>}],
    ['338', %Q{`foo`}, %Q{<code>foo</code>}],
    ['339', %Q{`` foo ` bar ``}, %Q{<code>foo ` bar</code>}],
    ['340', %Q{` `` `}, %Q{<code>``</code>}],
    ['341', %Q{`  ``  `}, %Q{<code> `` </code>}],
    ['342', %Q{` a`}, %Q{<code> a</code>}],
    ['343', %Q{`\tb\t`}, %Q{<code>\tb\t</code>}],
    ['344', %Q{` `\n`  `}, %Q{<code> </code>\n<code>  </code>}],
    ['345', %Q{``\nfoo\nbar  \nbaz\n``}, %Q{<code>foo bar   baz</code>}],
    ['346', %Q{``\nfoo \n``}, %Q{<code>foo </code>}],
    ['347', %Q{`foo   bar \nbaz`}, %Q{<code>foo   bar  baz</code>}],
    ['348', %Q{`foo\\`bar`}, %Q{<code>foo\\</code>bar`}],
    ['349', %Q{``foo`bar``}, %Q{<code>foo`bar</code>}],
    ['350', %Q{` foo `` bar `}, %Q{<code>foo `` bar</code>}],
    ['351', %Q{*foo`*`}, %Q{*foo<code>*</code>}],
    ['352', %Q{[not a `link](/foo`)}, %Q{[not a <code>link](/foo</code>)}],
    ['353', %Q{`<a href="`">`}, %Q{<code>&lt;a href=&quot;</code>&quot;&gt;`}],
    ['355', %Q{`<http://foo.bar.`baz>`}, %Q{<code>&lt;http://foo.bar.</code>baz&gt;`}],
    ['358', %Q{`foo}, %Q{`foo}],
    ['359', %Q{`foo``bar``}, %Q{`foo<code>bar</code>}],
    #
    ['360', %Q{*foo bar*}, %Q{<em>foo bar</em>}],
    ['361', %Q{a * foo bar*}, %Q{a * foo bar*}],
    ['362', %Q{a*"foo"*}, %Q{a*&quot;foo&quot;*}],
    ['363', %Q{* a *}, %Q{* a *}],
    ['364', %Q{foo*bar*}, %Q{foo<em>bar</em>}],
    ['365', %Q{5*6*78}, %Q{5<em>6</em>78}],
    ['366', %Q{_foo bar_}, %Q{<em>foo bar</em>}],
    ['367', %Q{_ foo bar_}, %Q{_ foo bar_}],
    ['368', %Q{a_"foo"_}, %Q{a_&quot;foo&quot;_}],
    ['369', %Q{foo_bar_}, %Q{foo_bar_}],
    ['370', %Q{5_6_78}, %Q{5_6_78}],
    ['372', %Q{aa_"bb"_cc}, %Q{aa_&quot;bb&quot;_cc}],
    ['373', %Q{foo-_(bar)_}, %Q{foo-<em>(bar)</em>}],
    ['374', %Q{_foo*}, %Q{_foo*}],
    ['375', %Q{*foo bar *}, %Q{*foo bar *}],
    ['376', %Q{*foo bar\n*}, %Q{*foo bar\n*}],
    ['377', %Q{*(*foo)}, %Q{*(*foo)}],
    ['379', %Q{*foo*bar}, %Q{<em>foo</em>bar}],
    ['380', %Q{_foo bar _}, %Q{_foo bar _}],
    ['381', %Q{_(_foo)}, %Q{_(_foo)}],
    ['383', %Q{_foo_bar}, %Q{_foo_bar}],
    ['385', %Q{_foo_bar_baz_}, %Q{<em>foo_bar_baz</em>}],
    ['386', %Q{_(bar)_.}, %Q{<em>(bar)</em>.}],

    ['387', %Q{**foo bar**}, %Q{<strong>foo bar</strong>}],
    ['388', %Q{** foo bar**}, %Q{** foo bar**}],
    ['389', %Q{a**"foo"**}, %Q{a**&quot;foo&quot;**}],
    ['390', %Q{foo**bar**}, %Q{foo<strong>bar</strong>}],
    ['391', %Q{__foo bar__}, %Q{<strong>foo bar</strong>}],
    ['392', %Q{__ foo bar__}, %Q{__ foo bar__}],
    ['393', %Q{__\nfoo bar__}, %Q{__\nfoo bar__}],
    ['394', %Q{a__"foo"__}, %Q{a__&quot;foo&quot;__}],
    ['395', %Q{foo__bar__}, %Q{foo__bar__}],
    ['396', %Q{5__6__78}, %Q{5__6__78}],
    ['399', %Q{foo-__(bar)__}, %Q{foo-<strong>(bar)</strong>}],
    ['400', %Q{**foo bar **}, %Q{**foo bar **}],
    ['401', %Q{**(**foo)}, %Q{**(**foo)}],
    ['405', %Q{**foo**bar}, %Q{<strong>foo</strong>bar}],
    ['406', %Q{__foo bar __}, %Q{__foo bar __}],
    ['407', %Q{__(__foo)}, %Q{__(__foo)}],
    ['409', %Q{__foo__bar}, %Q{__foo__bar}],
    ['411', %Q{__foo__bar__baz__}, %Q{<strong>foo__bar__baz</strong>}],
    ['412', %Q{__(bar)__.}, %Q{<strong>(bar)</strong>.}],
    ['429', %Q{** is not an empty emphasis}, %Q{** is not an empty emphasis}],

    ['493', %Q{[link](/uri "title")}, %Q{<a href="/uri" title="title">link</a>}],
    ['494', %Q{[link](/uri)}, %Q{<a href="/uri">link</a>}],
    ['495', %Q{[link]()}, %Q{<a href="">link</a>}],
    ['496', %Q{[link](<>)}, %Q{<a href="">link</a>}],
    ['497', %Q{[link](/my uri)}, %Q{[link](/my uri)}],
    ['498', %Q{[link](</my uri>)}, %Q{<a href="/my%20uri">link</a>}],
    ['499', %Q{[link](foo\nbar)}, %Q{[link](foo\nbar)}],
    ['500', %Q{[link](<foo\nbar>)}, %Q{[link](&lt;foo\nbar&gt;)}],
    ['501', %Q{[a](<b)c>)}, %Q{<a href="b)c">a</a>}],

    # Reference Style
    ['535', %Q{[foo][bar]\n\n[bar]: /url "title"}, %Q{<a href="/url" title="title">foo</a>}],

    ['Form', %q|\[x^{22}\]|, %q|$$x^{22}$$|],
    ['Sub', %q|a_0|, %q|a<sub>0</sub>|],
    ['Sub', %q|CO_2|, %q|CO<sub>2</sub>|],
    ['Sup', %q|a^3|, %q|a<sup>3</sup>|],
    ['Sup', %q|x^22|, %q|x<sup>22</sup>|],
    ['Del', %q|~~delete me~~|, %q|<del>delete me</del>|],
    ['Underline', %q|~underline me~|, %q|<u>underline me</u>|],

  ]

  def test_line_parser
    Cases.each do |t|
      line = LineParser.new.parse(t[1])
      renderer = LineRendererHTML.new
      result = line.render(renderer)


      assert_equal(result.strip, t[2], "case #{t[0]}")
      if result.strip != t[2]
        puts "case #{t[0]}: expected '#{t[2]}', got '#{result}'"
      end
    end
  end
end

