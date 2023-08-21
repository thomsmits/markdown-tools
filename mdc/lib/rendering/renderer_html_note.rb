require_relative 'renderer_html_plain'
require_relative '../messages'

module Rendering
  ##
  # Renderer to HTML for plain (book) like output
  class RendererHTMLNote < RendererHTMLPlain
    attr_accessor :tags, :date, :topic

    STYLE = '
        <style>
        body {
            background-color: #ffffff;
            font-size: 12pt;
            font-family: Helvetica, arial, freesans, clean, sans-serif, "Segoe UI", "Helvetica Neue";
            line-height: 150%;
            margin-left: 0em;
            margin-right: 0em;
            margin-top: 0em;
            padding: 10px;
            padding-top: 50px;
            background: #f3f5f7;
        }

        .infoline {
            left: 0;
            top: 0;
            width: 100%;
            height: 3.2ex;
            color: #7a7d81;
            background: #f3f5f7;
            margin-bottom: 1em;
            padding-left: 10px;
            padding-top: 5px;
            position: fixed;
            -webkit-box-shadow: 0px 3px 6px -3px rgba(0,0,0,0.75);
            -moz-box-shadow: 0px 3px 6px -3px rgba(0,0,0,0.75);
            box-shadow: 0px 3px 6px -3px rgba(0,0,0,0.75);
        }

        .infoline .topic {
            font-weight: normal;
            font-size: 100%;
            color: #7a7d81;
        }

        .infoline .date {
            position: absolute;
            right: 1em;
            font-weight: normal;
            font-size: 100%;
        }

        .infoline .tags {
            position: absolute;
            left: 20em;
        }

        body > section {
            background: #FFFFFF;
            padding: 1em;
            border: 1px solid #d1d2d4;
            border-radius: 4px;
        }
        span.tag {
            padding-left: 3px;
            padding-right: 3px;
            border: 1px solid #ced3d8;
            background: #e7ecf0;
            margin-left: 1px;
            margin-right: 1px;
            color: #aaadb0;
            border-radius: 9px;
            font-size: 75%;
        }

        em {
            color: black;
            font-weight: bold;
            font-style: normal;
        }

        em.alternative {
            color: #A0A0A0;
            font-weight: bold;
            font-style: normal;
        }

        strong {
            color: black;
            font-weight: bold;
            font-style: italic;
        }

        strong.alternative {
            color: #A0A0A0;
            font-weight: bold;
            font-style: italic;
        }

        .ui-widget {
            font-size: 70%;
        }

        figcaption {
            margin-bottom: 0;
            padding-bottom: 0;
        }

        figure.picture {
            float: left;
            margin-top: 0;
            margin-left: 1em;
            margin-right: 0;
            page-break-inside: avoid;
            page-break-before: auto;
        }

        figure.picture figcaption {
            clear: both;
            text-align: left;
        }

        .comment > figure.picture {
            float: right;
        }

        figcaption {
            font-size: 90%;
            font-size: 90%;
            text-align: center;
            color: #7d7d7d;
        }

        figure.picture figcaption {
            counter-increment: figno;
        }

        figure.source {
            margin-top: 0;
            margin-left: 1em;
            margin-right: 0;
        }

        figure.source figcaption {
            counter-increment: srcno;
        }

        figure.source figcaption:before {
            content: "Quellcode " counter(honecounter) "." counter(srcno) ": ";
        }

        .title, .folder_title {
            font-size: 105%;
            font-weight: bold;
        }

        .folder_title {

            color: #2A7F00;
        }

        abbr {
            text-decoration: none;
            color: #2a6207;
            border-bottom-style: dotted;
            border-bottom-width: 1px;
        }

        h1 {
            clear: both;
            border-bottom: #A0A0A0 solid 1px;
            font-size: 130%;
            color: #5fb336;
            padding-top: 0;
            margin-top: 0;
        }

        h2, h2.title {
            font-size: 120%;
            color: #2A7F00;
            clear: both;
            font-weight: bold;
        }

        h3 {
            font-size: 110%;
            color: #2A7F00;
            clear: both;
            font-weight: normal;
            font-style: normal;
        }

        h4 {
            font-size: 100%;
            color: #000000;
            clear: both;
            font-weight: normal;
            font-style: italic;
        }

        a, dfn {
            text-decoration: none;
            font-weight: normal;
            color: #4183c4;
            font-style: normal;
        }

        a:active, a:hover, dfn:hover {
            text-decoration: underline;
            cursor: hand;
        }

        code.xml {
            line-height: 105%;
            font-size: 11pt;
            background-color: transparent;
        }

        .box {
            margin-top: 50px;
            background-color: #515151;
            background-image: -moz-linear-gradient(#707070, #515151);
            background-image: -webkit-linear-gradient(#707070, #515151);
            background-image: linear-gradient(#707070, #515151);
            background-repeat: repeat-x;
            border: 1px solid #3a3a3a;
            border-bottom: 1px solid #2d2d2d;
            border-radius: 3px;
            /*text-shadow: 0 1px 0 #383838;*/
            box-shadow: inset 0 1px 0 #2c2c2c, 0 1px 5px #515151;
            width: 90%;
        }

        .box h4 {
            background-size: 32px auto;
            margin: 0;
            padding: 10px;
            border-bottom: 1px solid #646464;
            color: #ffffff;
            box-shadow: 0 1px 0 #2c2c2c;
            font-size: 14px;
            font-weight: bold;
        }

        .box p {
            margin: 0;
            padding: 10px;
            color: #cacaca;
            text-shadow: none;
        }

        .comment {
            font-size: 11pt;
            line-height: 1.2;
        }

        hr {
            clear: both;
        }

        table {
            border: 1px solid black;
            border-collapse: collapse;
        }

        td, th {
            border: 1px solid black;
            padding: 0.2em;
        }

        table.content {
            border-top: 2px solid black;
            border-bottom: 2px solid black;
            border-collapse: collapse;
            border-left: 0;
            border-right: 0;
        }

        table.content thead > tr,
        table.content th {
             border-bottom: 1px solid black;
        }

        table.content th {
            text-align: left;
        }

        table.content td, table.content th {
            padding-left: 0.8em;
            padding-right: 0.8em;
            border: 0;
        }

        pre {
            border-width: 1px;
            border-style: solid;
            border-color: rgb(165, 165, 165);
            border-radius: 3px;
            padding: 1em;
        }
        code {
            font-size: 11pt;
            background: none;
        }

        .title_first {
            font-size: 20pt;
            font-weight: bold;
            line-height: 140%;
        }

        ul.subentry li {
          font-size: 10pt;
          line-height: 120%;
        }

        img {
            max-width: 100%;
            float: left;
        }

        section {
            clear: both;
        }

        .output_small {
            font-family: monospace;
        }

        .output_small p {
            padding: 0;
            margin: 0;
        }

        a.doclink {
            text-decoration: none;
            color: black;
            font-weight: normal;
        }

        .file {
            padding-bottom: 1em;
            padding-top: 1em;
            padding-left: 1em;
            padding-right: 1em;
            border-top: 1px #D0D0D0 solid;
            line-height: 1.4em;
            background: #FFFFFF;
            font-size: 90%;
        }

        .folder {
            padding-bottom: 1em;
            padding-top: 1em;
            padding-left: 1em;
            padding-right: 1em;
            border-top: 1px #D0D0D0 solid;
            line-height: 1.4em;
            background: #FFFFFF;
            font-size: 90%;
        }

        .file:hover {
            background: #ecf0f3;
        }

        .folder:hover {
            background: #ecf0f3;
        }

        .date {
            color: #4a8db8;
            font-weight: bold;
        }

        blockquote {
            border-left: 3px solid #A0A0A0;
            margin-left: 0;
            padding-left: 1em;
        }

        .quote_source {
            color: #D0D0D0;
            font-size: 90%;
            font-style: italic;
        }

        li {
        }

        ul.files {
            list-style-type: none;
            padding-left: 0;
        }

        .folderinfo {
            color: #505050;
            padding-bottom: 1em;
            padding-left: 0;
            font-size: 80%;
        }

        h1.files {
            font-size: 140%;
            padding-left: 0;
            padding-top: 0.5em;
            border: none;
        }

        h1.files:hover {
            text-decoration: underline;
            color: #5fb336;
        }

        body.files {
            padding: 0;
        }

        .filesheader {
            background: #ffffff;
            -webkit-box-shadow: 0px 3px 6px -3px rgba(0,0,0,0.75);
            -moz-box-shadow: 0px 3px 6px -3px rgba(0,0,0,0.75);
            box-shadow: 0px 3px 6px -3px rgba(0,0,0,0.75);
            padding-left: 1em;
        }
              </style>
      </head>
      <body>
      '.freeze

    ## ERB templates to be used by the renderer
    TEMPLATES = {

      chapter_start: erb(
        "
           <section id='<%= id %>' class='chapter'>
           <div class='infoline'>
           <% unless topic.nil? %>
             <a class='topic' href='index.html'><span class='topic'><%= topic %></span></a>
           <% end %>
           <span class='tags'>
           <% for tag in @tags %>
             <span class='tag'><%= tag %></span>
           <% end %>
           </span>
           <% unless date.nil? %>
             <span class='date'><%= @date.strftime('%Y-%m-%d') %></span>
           <% end %>
           </div>
           <h1 class='trenner'><%= title %></h1>
          "
      ),

      chapter_end: erb(
        '
        </section>
        '
      ),

      code_start: erb(
        "<pre><code class='<%= prog_lang %>'>"
      ),

      toc_start: erb(
        ''
      ),

      toc_entry: erb(
        ''
      ),

      toc_end: erb(
        ''
      ),

      toc_sub_entries_start: erb(
        ''
      ),

      toc_sub_entry: erb(
        ''
      ),

      toc_sub_entries_end: erb(
        ''
      ),

      presentation_start: erb(
        "
        <!DOCTYPE html>
        <html lang='de'>
        <head>
          <meta charset='utf-8'>
          <title><%= title1 %>: <%= section_name %></title>
          <meta name='author' content='<%= author %>'>
          " + STYLE + '
        </head>
        <body>
        '
      ),

      presentation_end: erb(
        '
        </div>
        </body>
        </html>
        '
      ),

      index_folder_entry: erb(
        "
         <li>
         <a class='doclink' href='<%= name %>/index.html'>
         <div class='folder'>
         <img src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAVElEQVR42mNgGFRgyZIlWkuBYNmyZf+JwAcwDAAKXl2+fHkgMZYB7XmIzYAP6DahycPFRg0YUgYA04U3kD4DSh9kGYANDw4DgPRGbAY8IcKAz8h6ACMeaV1Br1iuAAAAAElFTkSuQmCC'>
         &nbsp;<span title='<%= description %>' class='folder_title'><%= title %> (<%= count %>)</span>&nbsp;&nbsp;
         <%= print_tags(tags) %>
         </div></li>
        "
      ),

      index_file_entry: erb(
        "
          <li>
          <a class='doclink' href='<%= name %>.html'>
          <div class='file'><span class='title'><%= title %></span>&nbsp;&nbsp;
          <%= print_tags(tags) %>
          <br>
          <span class='date'><%= date.strftime('%d.%m.%Y') %></span>
          <span class='digest'><%= digest %></span></a><br>
          </div></li>
       "
      ),

      index_start: erb(
        "
         <!DOCTYPE html>
         <html>
         <head>
         <meta charset='utf-8'>
         " + STYLE + "
         </head>
         <body class='files'>
         <div class='filesheader'><a href='../index.html'><h1 class='files'><%= title %></h1></a>
         <div class='folderinfo'><%= description %></div>
         </div>
         <ul class='files'>
        "
      ),

      index_end: erb(
        '
         </ul>
        </html>
        '
      )
    }.freeze

    ##
    # Initialize the renderer
    # @param [IO] io target of output operations
    # @param [String] prog_lang the default language for code snippets
    # @param [String] result_dir location for results
    # @param [String] image_dir location for generated images (relative to result_dir)
    # @param [String] temp_dir location for temporary files
    def initialize(io, prog_lang, result_dir, image_dir, temp_dir, tags, date, topic)
      super(io, prog_lang, result_dir, image_dir, temp_dir)
      @dialog_counter = 1   # counter for dialog popups
      @last_title = ''      # last slide title
      @tags = tags
      @date = date
      @topic = topic
    end

    ##
    # Method returning the templates used by the renderer. Should be overwritten by the
    # subclasses.
    # @return [Hash] the templates
    def all_templates
      @templates = super.merge(TEMPLATES)
    end

    ##
    # Indicates whether the renderer handles animations or not. false indicates
    # that slides should not be repeated.
    def handles_animation?
      false
    end

    ##
    # Start of slide
    # @param [String] title the title of the slide
    # @param [String] _number the number of the slide
    # @param [String] id the unique id of the slide (for references)
    # @param [Boolean] _contains_code indicates whether the slide contains code fragments
    def slide_start(title, _number, id, _contains_code)
      escaped_title = line_renderer.meta(title)

      @io << "<section id='#{id}' class='slide'>" << nl

      return if title == @last_title

      @io << "<h2 class='title'>#{escaped_title} <span class='title_number'></span></h2>" << nl
      @last_title = title
    end

    ##
    # Start of an index file
    # @param [String] title title of the folder
    # @param [String] description description of the folder
    def index_start(title, description, root = false)
      @io << @templates[:index_start].result(binding)
    end

    ##
    # Print the first 10 tags.
    # @param [Array<String>] tags the tags
    # @return [String] the tags in HTML form
    def print_tags(tags)
      result = ''

      count = 0
      tags.each do |t|
        result << "<span class='tag'>#{t}</span>"
        count += 1
        break if count > 10
      end

      result
    end

    ##
    # Entry for one file
    # @param [String] name name of the file
    # @param [String] title title of the file
    # @param [Date] date creation data
    # @param [Array<String>] tags tags
    # @param [String] digest digest of file content
    def index_file_entry(name, title, date, tags, digest)
      @io << @templates[:index_file_entry].result(binding)
    end

    ##
    # Entry for one folder
    # @param [String] name name of the folder
    # @param [String] title title of the folder
    # @param [String] description description of folder
    # @param [Fixnum] count number of contained files
    # @param [Array<String>] tags the tags
    def index_folder_entry(name, title, description, count, tags)
      @io << @templates[:index_folder_entry].result(binding)
    end
  end
end
