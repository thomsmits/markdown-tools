require 'minitest/autorun'
require_relative '../lib/parsing/line_parser'
require_relative '../lib/rendering/line_renderer'
require_relative '../lib/rendering/line_renderer_html'

##
# Test class for the MarkdownLine class
class LineParserTest < Minitest::Test
  CASES = [
#    ['*("...")* xxx *("...")*', '*("aaa", "bbb")* xxx *("aaa", "bbb")*', %q|<em class="alternate">(&quot;aaa&quot;, &quot;bbb&quot;)</em> xxx <em class="alternate">(&quot;aaa&quot;, &quot;bbb&quot;)</em>|],
#    ['*("...")*', '*("vielleicht", "möglicherweise")*', %q|<em class="alternate">(&quot;vielleicht&quot;, &quot;möglicherweise&quot;)</em>|],
#    ['aaa *("...")* bbb', 'aaa *("vielleicht", "möglicherweise")* bbb', %q|aaa <em class="alternate">(&quot;vielleicht&quot;, &quot;möglicherweise&quot;)</em> bbb|],
    ['* double with <br>', '*T*<br>*Trend* als', '<em class="alternate">T</em><br><em class="alternate">Trend</em> als' ],
    ['_ double with <br>', '_T_<br>_Trend_ als', '<em>T</em><br><em>Trend</em> als' ],
    ['_ double', '_T_: _Trend_ als', '<em>T</em>: <em>Trend</em> als' ],
    ['* double', '*T*: *Trend* als', '<em class="alternate">T</em>: <em class="alternate">Trend</em> als' ],
    ['__ code 1', '__`#define NAME [KONSTANTE]`__', %q|<strong><code>#define NAME [KONSTANTE]</code></strong>|],
    ['__ code 2', '__`codehere`__', %q|<strong><code>codehere</code></strong>|],
    ['__ exclamation 1', 'aaa __Vorsicht!__ bb', %q|aaa <strong>Vorsicht!</strong> bb|],
    ['__ exclamation 2', 'aaa (__Vorsicht!__) bb', %q|aaa (<strong>Vorsicht!</strong>) bb|],
    ['_ exclamation 1', 'aaa _Vorsicht!_ bb', %q|aaa <em>Vorsicht!</em> bb|],
    ['_ exclamation 2', 'aaa (_Vorsicht!_) bb', %q|aaa (<em>Vorsicht!</em>) bb|],
    ['** exclamation 1', 'aaa **Vorsicht!** bb', %q|aaa <strong class="alternate">Vorsicht!</strong> bb|],
    ['** exclamation 2', 'aaa (**Vorsicht!**) bb', %q|aaa (<strong class="alternate">Vorsicht!</strong>) bb|],
    ['* exclamation 1', 'aaa *Vorsicht!* bb', %q|aaa <em class="alternate">Vorsicht!</em> bb|],
    ['* exclamation 2', 'aaa (*Vorsicht!*) bb', %q|aaa (<em class="alternate">Vorsicht!</em>) bb|],
    ['multi `', 'text <br> `code1` <br> `    code2` <br> `code3`', %q|text <br> <code>code1</code> <br> <code>    code2</code> <br> <code>code3</code>|],
    ['it paren', '_Zeichenkodierung (encoding)_ und einem _Zeichensatz (font)_', %q|<em>Zeichenkodierung (encoding)</em> und einem <em>Zeichensatz (font)</em>|],
    ['emph paren', 'Ursachen für Krisen können endogen *(z.B. schlechte Projektplanung)* oder exogen *(z.B. Insolvenz von Partnern)* sein', %q|Ursachen für Krisen können endogen <em class="alternate">(z.&nbsp;B. schlechte Projektplanung)</em> oder exogen <em class="alternate">(z.&nbsp;B. Insolvenz von Partnern)</em> sein|],
    ['emph plus', 'before (__PE__ / __PE32+__)<br>', %q|before (<strong>PE</strong> / <strong>PE32+</strong>)<br>|],
    ['multi emph', '__and__, __or__, __xor__ und __not__', %q|<strong>and</strong>, <strong>or</strong>, <strong>xor</strong> und <strong>not</strong>|],
    ['misc emph', '__Durchsatz (D)__ [**Throughput**]', %q|<strong>Durchsatz (D)</strong> [<strong class="alternate">Throughput</strong>]| ],
    ['emph dash', '__Inter__-Net -- Netz __zwischen__ den Netzen', %q|<strong>Inter</strong>-Net &ndash; Netz <strong>zwischen</strong> den Netzen| ],
    ['html', 'Text <span class="clazZ">In span</span>', %q|Text <span class="clazZ">In span</span>|],
    ['hamlet', %q|aaa<br>*"bbb" [1] ccc.*|, %q|aaa<br><em class="alternate">&quot;bbb&quot; [1] ccc.</em>|],
    ['emp colon', '_P_: xxx', %q|<em>P</em>: xxx|],
    ['strong_quot', %q|__"emphasis"__|, %q|<strong>&quot;emphasis&quot;</strong>|],
    ['361', %Q{a * foo bar*}, %Q{a * foo bar*}],
    ['nested_quote', %q|aaa: *bbb "ccc" ddd "eee" fff*|, %q|aaa: <em class="alternate">bbb &quot;ccc&quot; ddd &quot;eee&quot; fff</em>|],
    ['special_1', %q|Üntergang"|, %q|Üntergang&quot;|],
    ['emph_quot', %q|_"emphasis"_|, %q|<em>&quot;emphasis&quot;</em>|],
    ['em_quote', %q|"_emphasis_"|, %q|&quot;<em>emphasis</em>&quot;|],
    ['quote and emph', 'Text "text _emph_ text" text', %q|Text &quot;text <em>emph</em> text&quot; text|],
    ['emph_bracket', %q|(*emphasis*)|, %q|(<em class="alternate">emphasis</em>)|],
    ['strong_bracket', %q|(**emphasis**)|, %q|(<strong class="alternate">emphasis</strong>)|],
    ['emph_bracket 2', %q|(_emphasis_)|, %q|(<em>emphasis</em>)|],
    ['strong_bracket 2', %q|(__emphasis__)|, %q|(<strong>emphasis</strong>)|],
    ['strong_quote', %q|"__emphasis__"|, %q|&quot;<strong>emphasis</strong>&quot;|],

    ['Combined', %Q{*Bold ~underline~ Bold*}, %Q{<em class="alternate">Bold <u>underline</u> Bold</em>}],
    ['364', %Q{foo*bar*}, %Q{foo<em class="alternate">bar</em>}],
    ['360', %Q{*foo bar*}, %Q{<em class="alternate">foo bar</em>}],
    ['338', %Q{`foo`}, %Q{<code>foo</code>}],
    ['339', %Q{`` foo ` bar ``}, %Q{<code>foo ` bar</code>}],
    ['340', %Q{` `` `}, %Q{<code>``</code>}],
    ['341', %Q{`  ``  `}, %Q{<code> `` </code>}],
    ['342', %Q{` a`}, %Q{<code> a</code>}],
    ['342b', %Q{`  a`}, %Q{<code>  a</code>}],
    ['342c', %Q{`a`x`  b`}, %Q{<code>a</code>x<code>  b</code>}],
    ['343', %Q{`\tb\t`}, %Q{<code>\tb\t</code>}],
    #    ['344', %Q{` `\n`  `}, %Q{<code> </code>\n<code>  </code>}],
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
    ['360', %Q{*foo bar*}, %Q{<em class="alternate">foo bar</em>}],
    ['361', %Q{a * foo bar*}, %Q{a * foo bar*}],
    ['362', %Q{a*"foo"*}, %Q{a*&quot;foo&quot;*}],
    ['363', %Q{* a *}, %Q{* a *}],
    ['364', %Q{foo*bar*}, %Q{foo<em class="alternate">bar</em>}],
    ['365', %Q{5*6*78}, %Q{5<em class="alternate">6</em>78}],
    ['366', %Q{_foo bar_}, %Q{<em>foo bar</em>}],
    ['366', %Q{_f_}, %Q{<em>f</em>}],
    ['366', %Q{_foo_/_bar_}, %Q{<em>foo</em>/<em>bar</em>}],
    ['367', %Q{_ foo bar_}, %Q{_ foo bar_}],
    ['368', %Q{a_"foo"_}, %Q{a_&quot;foo&quot;_}],
    ['369', %Q{foo_bar_}, %Q{foo_bar_}],
    #['370', %Q{5_6_78}, %Q{5_6_78}],
    ['372', %Q{aa_"bb"_cc}, %Q{aa_&quot;bb&quot;_cc}],
    ['373', %Q{foo-_(bar)_}, %Q{foo-<em>(bar)</em>}],
    ['374', %Q{_foo*}, %Q{_foo*}],
    ['375', %Q{*foo bar *}, %Q{*foo bar *}],
    ['376', %Q{*foo bar\n*}, %Q{*foo bar\n*}],
    ['377', %Q{*(*foo)}, %Q{*(*foo)}],
    ['379', %Q{*foo*bar}, %Q{<em class="alternate">foo</em>bar}],
    ['380', %Q{_foo bar _}, %Q{_foo bar _}],
    ['381', %Q{_(_foo)}, %Q{_(_foo)}],
    #['383', %Q{_foo_bar}, %Q{_foo_bar}],
    #['385', %Q{_foo_bar_baz_}, %Q{<em>foo_bar_baz</em>}],
    ['386', %Q{_(bar)_.}, %Q{<em>(bar)</em>.}],

    ['387', %Q{**foo bar**}, %Q{<strong class="alternate">foo bar</strong>}],
    ['388', %Q{** foo bar**}, %Q{** foo bar**}],
    ['389', %Q{a**"foo"**}, %Q{a**&quot;foo&quot;**}],
    ['390', %Q{foo**bar**}, %Q{foo<strong class="alternate">bar</strong>}],
    ['391', %Q{__foo bar__}, %Q{<strong>foo bar</strong>}],
    ['391', %Q{__x__}, %Q{<strong>x</strong>}],
    ['392', %Q{__ foo bar__}, %Q{__ foo bar__}],
    ['393', %Q{__\nfoo bar__}, %Q{__\nfoo bar__}],
    ['394', %Q{a__"foo"__}, %Q{a__&quot;foo&quot;__}],
    ['395', %Q{foo__bar__}, %Q{foo__bar__}],
    ['396', %Q{5__6__78}, %Q{5__6__78}],
    ['399', %Q{foo-__(bar)__}, %Q{foo-<strong>(bar)</strong>}],
    ['400', %Q{**foo bar **}, %Q{**foo bar **}],
    ['401', %Q{**(**foo)}, %Q{**(**foo)}],
    ['405', %Q{**foo**bar}, %Q{<strong class="alternate">foo</strong>bar}],
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
    #    ['535', %Q{[foo][bar]\n\n[bar]: /url "title"}, %Q{<a href="/url" title="title">foo</a>}],

    ['Form', %q|\[x^{22}\]|, %q|$$ x^{22} $$|],
    ['Sub', %q|a_0|, %q|a<sub>0</sub>|],
    ['Sub', %q|CO_2|, %q|CO<sub>2</sub>|],
    ['Sup', %q|a^3|, %q|a<sup>3</sup>|],
    ['Sup', %q|x^22|, %q|x<sup>22</sup>|],
    ['Del', %q|~~delete me~~|, %q|<del>delete me</del>|],
    ['Underline', %q|~underline me~|, %q|<u>underline me</u>|],

    ['Combined', %Q{before *Bold ~underline~ Bold* after}, %Q{before <em class="alternate">Bold <u>underline</u> Bold</em> after}],
    ['364', %Q{before foo*bar* after}, %Q{before foo<em class="alternate">bar</em> after}],
    ['360', %Q{before *foo bar* after}, %Q{before <em class="alternate">foo bar</em> after}],
    ['338', %Q{before `foo` after}, %Q{before <code>foo</code> after}],
    ['339', %Q{before `` foo ` bar `` after}, %Q{before <code>foo ` bar</code> after}],
    ['340', %Q{before ` `` ` after}, %Q{before <code>``</code> after}],
    ['341', %Q{before `  ``  ` after}, %Q{before <code> `` </code> after}],
    #    ['342', %Q{before ` a` after}, %Q{before <code> a</code> after}],
    ['343', %Q{before `\tb\t` after}, %Q{before <code>\tb\t</code> after}],
    #    ['344', %Q{before ` `\n`  ` after}, %Q{before <code> </code>\n<code>  </code> after}],
    ['345', %Q{before ``\nfoo\nbar  \nbaz\n`` after}, %Q{before <code>foo bar   baz</code> after}],
    ['346', %Q{before ``\nfoo \n`` after}, %Q{before <code>foo </code> after}],
    ['347', %Q{before `foo   bar \nbaz` after}, %Q{before <code>foo   bar  baz</code> after}],
    ['348', %Q{before `foo\\`bar` after}, %Q{before <code>foo\\</code>bar` after}],
    ['349', %Q{before ``foo`bar`` after}, %Q{before <code>foo`bar</code> after}],
    ['350', %Q{before ` foo `` bar ` after}, %Q{before <code>foo `` bar</code> after}],
    ['351', %Q{before *foo`*` after}, %Q{before *foo<code>*</code> after}],
    ['352', %Q{before [not a `link](/foo`) after}, %Q{before [not a <code>link](/foo</code>) after}],
    ['353', %Q{before `<a href="`">` after}, %Q{before <code>&lt;a href=&quot;</code>&quot;&gt;` after}],
    ['355', %Q{before `<http://foo.bar.`baz>` after}, %Q{before <code>&lt;http://foo.bar.</code>baz&gt;` after}],
    ['358', %Q{before `foo after}, %Q{before `foo after}],
    ['359', %Q{before `foo``bar`` after}, %Q{before `foo<code>bar</code> after}],
    ['360', %Q{before *foo bar* after}, %Q{before <em class="alternate">foo bar</em> after}],
    ['361', %Q{before a * foo bar* after}, %Q{before a * foo bar* after}],
    ['362', %Q{before a*"foo"* after}, %Q{before a*&quot;foo&quot;* after}],
    ['363', %Q{before * a * after}, %Q{before * a * after}],
    ['364', %Q{before foo*bar* after}, %Q{before foo<em class="alternate">bar</em> after}],
    ['365', %Q{before 5*6*78 after}, %Q{before 5<em class="alternate">6</em>78 after}],
    ['366', %Q{before _foo bar_ after}, %Q{before <em>foo bar</em> after}],
    ['366', %Q{before _f_ after}, %Q{before <em>f</em> after}],
    ['366', %Q{before _foo_/_bar_ after}, %Q{before <em>foo</em>/<em>bar</em> after}],
    ['367', %Q{before _ foo bar_ after}, %Q{before _ foo bar_ after}],
    ['368', %Q{before a_"foo"_ after}, %Q{before a_&quot;foo&quot;_ after}],
    ['369', %Q{before foo_bar_ after}, %Q{before foo_bar_ after}],
    #['370', %Q{before 5_6_78 after}, %Q{before 5_6_78 after}],
    ['372', %Q{before aa_"bb"_cc after}, %Q{before aa_&quot;bb&quot;_cc after}],
    ['373', %Q{before foo-_(bar)_ after}, %Q{before foo-<em>(bar)</em> after}],
    ['374', %Q{before _foo* after}, %Q{before _foo* after}],
    ['375', %Q{before *foo bar * after}, %Q{before *foo bar * after}],
    ['376', %Q{before *foo bar\n* after}, %Q{before *foo bar\n* after}],
    ['377', %Q{before *(*foo) after}, %Q{before *(*foo) after}],
    ['379', %Q{before *foo*bar after}, %Q{before <em class="alternate">foo</em>bar after}],
    ['380', %Q{before _foo bar _ after}, %Q{before _foo bar _ after}],
    ['381', %Q{before _(_foo) after}, %Q{before _(_foo) after}],
    #['383', %Q{before _foo_bar after}, %Q{before _foo_bar after}],
    #['385', %Q{before _foo_bar_baz_ after}, %Q{before <em>foo_bar_baz</em> after}],
    ['386', %Q{before _(bar)_. after}, %Q{before <em>(bar)</em>. after}],
    ['387', %Q{before **foo bar** after}, %Q{before <strong class="alternate">foo bar</strong> after}],
    ['388', %Q{before ** foo bar** after}, %Q{before ** foo bar** after}],
    ['389', %Q{before a**"foo"** after}, %Q{before a**&quot;foo&quot;** after}],
    ['390', %Q{before foo**bar** after}, %Q{before foo<strong class="alternate">bar</strong> after}],
    ['391', %Q{before __foo bar__ after}, %Q{before <strong>foo bar</strong> after}],
    ['391', %Q{before __x__ after}, %Q{before <strong>x</strong> after}],
    ['392', %Q{before __ foo bar__ after}, %Q{before __ foo bar__ after}],
    ['393', %Q{before __\nfoo bar__ after}, %Q{before __\nfoo bar__ after}],
    ['394', %Q{before a__"foo"__ after}, %Q{before a__&quot;foo&quot;__ after}],
    ['395', %Q{before foo__bar__ after}, %Q{before foo__bar__ after}],
    ['396', %Q{before 5__6__78 after}, %Q{before 5__6__78 after}],
    ['399', %Q{before foo-__(bar)__ after}, %Q{before foo-<strong>(bar)</strong> after}],
    ['400', %Q{before **foo bar ** after}, %Q{before **foo bar ** after}],
    ['401', %Q{before **(**foo) after}, %Q{before **(**foo) after}],
    ['405', %Q{before **foo**bar after}, %Q{before <strong class="alternate">foo</strong>bar after}],
    ['406', %Q{before __foo bar __ after}, %Q{before __foo bar __ after}],
    ['407', %Q{before __(__foo) after}, %Q{before __(__foo) after}],
    ['409', %Q{before __foo__bar after}, %Q{before __foo__bar after}],
    ['411', %Q{before __foo__bar__baz__ after}, %Q{before <strong>foo__bar__baz</strong> after}],
    ['412', %Q{before __(bar)__. after}, %Q{before <strong>(bar)</strong>. after}],
    ['429', %Q{before ** is not an empty emphasis after}, %Q{before ** is not an empty emphasis after}],
    ['493', %Q{before [link](/uri "title") after}, %Q{before <a href="/uri" title="title">link</a> after}],
    ['494', %Q{before [link](/uri) after}, %Q{before <a href="/uri">link</a> after}],
    ['495', %Q{before [link]() after}, %Q{before <a href="">link</a> after}],
    ['496', %Q{before [link](<>) after}, %Q{before <a href="">link</a> after}],
    ['497', %Q{before [link](/my uri) after}, %Q{before [link](/my uri) after}],
    ['498', %Q{before [link](</my uri>) after}, %Q{before <a href="/my%20uri">link</a> after}],
    ['499', %Q{before [link](foo\nbar) after}, %Q{before [link](foo\nbar) after}],
    ['500', %Q{before [link](<foo\nbar>) after}, %Q{before [link](&lt;foo\nbar&gt;) after}],
    ['501', %Q{before [a](<b)c>) after}, %Q{before <a href="b)c">a</a> after}],
    ['Form', %q|\[x^{22 after}\]|, %q|$$ x^{22 after} $$|],
    ['Sub', %q|a_0|, %q|a<sub>0</sub>|],
    ['Sub', %q|CO_2|, %q|CO<sub>2</sub>|],
    ['Sup', %q|a^3|, %q|a<sup>3</sup>|],
    ['Sup', %q|x^22|, %q|x<sup>22</sup>|],
    ['Del', %q|~~delete me~~|, %q|<del>delete me</del>|],
    ['Underline', %q|~underline me~|, %q|<u>underline me</u>|],
    ['Emph!', %q|_emphasis_!|, %q|<em>emphasis</em>!|],
    ['Strong"', %q|"__emphasis__"|, %q|&quot;<strong>emphasis</strong>&quot;|],
    ['Emph"', %q|"_emphasis_"|, %q|&quot;<em>emphasis</em>&quot;|],
    ['greedy emph', %q|_aaa_ bbb _ccc_: ddd _eee_ fff.|, %q|<em>aaa</em> bbb <em>ccc</em>: ddd <em>eee</em> fff.|],
    ['greedy string', %q|__aaa__ bbb __ccc__: ddd __eee__ fff.|, %q|<strong>aaa</strong> bbb <strong>ccc</strong>: ddd <strong>eee</strong> fff.|],
    ['quote and emph', 'Text "text _emph_ text" text', %q|Text &quot;text <em>emph</em> text&quot; text|],
    ['br emph', 'xxx<br>*emph*<br>*emph2*end', %q|xxx<br><em class="alternate">emph</em><br><em class="alternate">emph2</em>end|],
  #['br emph quot', 'xxx<br>*"emph"*<br>*"emph2"*end', %q|xxx<br><em>&quot;emph&quot;</em><br><em>&quot;emph2&quot;</em>end|],
  ]

  def test_line_parser
    CASES.each do |t|
      line = Parsing::LineParser.new.parse(t[1], [])
      renderer = Rendering::LineRendererHTML.new('java')
      result = line.render(renderer).gsub('&ldquo;', '&quot;').gsub('&rdquo;', '&quot;')

      assert_equal(t[2], result.strip, "case #{t[0]}")
      puts "case #{t[0]}: expected '#{t[2]}', got '#{result}'" if result.strip != t[2]
    end
  end
end
