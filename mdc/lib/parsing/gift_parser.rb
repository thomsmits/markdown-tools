require_relative '../../lib/domain/questions/matching_question'
require_relative '../../lib/domain/questions/matching_questions'
require_relative '../../lib/domain/questions/multiple_choice'
require_relative '../../lib/domain/questions/multiple_choice_questions'
require_relative '../../lib/domain/questions/input_question'
require_relative '../../lib/domain/presentation'
require_relative '../../lib/domain/section'
require_relative '../../lib/domain/block_elements/text'

module Parsing
  ##
  # Parser for Moodle's GIFT file format
  class GiftParser
    def initialize; end

    def unescape(string)
      string.gsub('\'', '')
    end

    def split_answers(line)

      # Determine the type of question
      question = if /->/ =~ line
                   Domain::MatchingQuestions.new
                 elsif /~/ =~ line
                   Domain::MultipleChoiceQuestions.new
                 else
                   Domain::InputQuestion.new
                 end

      answers = line.strip.split(/([~=])/).select { |e| !e.empty? }

      0.step(answers.length - 1, 2) do |i|
        type = answers[i]
        text = answers[i + 1]

        # get points
        points = if /%(.*?)%/ =~ text
                   ::Regexp.last_match(1).to_f
                 else
                   0.0
                 end

        # Remove percentage tag from text
        text.gsub!(/%.*?%/, '')
        text.strip!
        text.gsub!('\\', '')

        if /(.*)->(.*)/ =~ text
          l = ::Regexp.last_match(1).strip
          r = ::Regexp.last_match(2).strip
          question << Domain::MatchingQuestion.new(l, r)
        elsif type == '~'
          question << Domain::MultipleChoice.new(text, points.positive?)
        elsif type == '='
          question << Domain::MultipleChoice.new(text, true)
        end

      end
      question
    end

    ##
    # Parse the given string or file into the given presentation.
    # @param [Array<String>] lines input to be parsed
    # @param [String] file_name File to be parsed
    # @param [String] def_prog_lang language for code blocks not tagged
    # @param [Domain::Presentation] presentation Storage of results
    def parse_lines(lines, file_name, def_prog_lang, presentation)

      chapter = Domain::Chapter.new('')
      presentation << chapter

      # remove comment lines
      lines.map { |line| line.gsub!(%r{//.*}, '') }

      # GIFT ist not really line oriented, remove all
      # newlines, inside questions
      result = []
      result_line = ''
      lines.each do |line|
        if line.start_with?("::")
          result << result_line
          result_line = line
        else
          result_line << line
        end
      end
      # Capture the last line
      result << result_line

      lines = result

      lines.each do |line|
        if line.start_with?('$CATEGORY:')
          category = line.gsub('$CATEGORY:[ ]*', '')
          next
        end

        if line.strip.empty?
          next
        end

        title = ''
        language = ''
        text = ''

        # get question title
        if line =~ /::(.*)::/
          title = ::Regexp.last_match(1)
          line.gsub!(%r{::.*::}, '')
          # new question
        end

        # get format specification
        if line =~ /\[(.*)\]/
          language = ::Regexp.last_match(1)
          line.gsub!(/\[.*\]/, '')
        end

        questions = Domain::Text.new('')

        if line =~ /(.*)\{(.*)}/
          text = ::Regexp.last_match(1)
          answers = ::Regexp.last_match(2)
          questions = split_answers(answers)
        end

        # Clean up the text
        text = text.gsub(%r{<p>(.*)</p>}, '\1').gsub('\\', '')
        title = title.gsub('\\', '')
        # each line is a new question

        slide = Domain::Section.new('', title, 0, false)
        slide << Domain::Text.new(text)
        slide << questions
        chapter << slide
      end
      puts presentation
    end

    def second_pass(presentation)
      presentation
    end
  end
end