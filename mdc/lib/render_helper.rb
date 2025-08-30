require_relative 'parsing/line_parser'
require_relative 'parsing/parser'
require_relative 'rendering/line_renderer_html'
require_relative 'rendering/line_renderer_latex'
require_relative 'rendering/line_renderer_jekyll'

##
# Helper method to take a line of Markdown and convert it into
# a line of HTML
# @param [String] input String to be parsed
# @param [String] def_prog_lang Programming language for code blocks
def markdown_to_html_line(input, def_prog_lang)
  lp = Parsing::LineParser.new
  nodes = lp.parse(input, [])
  renderer = Rendering::LineRendererHTML.new(def_prog_lang)
  nodes.render(renderer)
end

##
# Helper method to take a line of Markdown and convert it into
# a line of LaTeX
# @param [String] input String to be parsed
# @param [String] def_prog_lang Programming language for code blocks
def markdown_to_latex_line(input, def_prog_lang)
  lp = Parsing::LineParser.new
  nodes = lp.parse(input)
  renderer = Rendering::LineRendererLatex.new(def_prog_lang)
  nodes.render(renderer)
end

##
# Helper method to take a line of Markdown and convert it into
# a line of Jekyll (md+html)
# @param [String] input String to be parsed
# @param [String] def_prog_lang Programming language for code blocks
def markdown_to_jekyll_line(input, def_prog_lang)
  lp = Parsing::LineParser.new
  nodes = lp.parse(input)
  renderer = Rendering::LineRendererJekyll.new(def_prog_lang)
  nodes.render(renderer)
end

##
# Parse a Markdown file and return an object representation.
# @param [String] file to parse
# @param [String] def_prog_lang Programming language for code blocks
# @param [String] slide_language Language of the slides (DE, EN)
# @return [Domain::Document] the parsed content
def parse_file(file, def_prog_lang, slide_language)
  slide_language ||= 'DE'
  set_language(slide_language.downcase)

  parser = Parsing::Parser.new(0)

  document = Domain::Document.new(file)

  parser.parse(file, def_prog_lang, document)
  parser.second_pass(document)

  document
end
