# -*- coding: utf-8 -*-

require_relative '../../lib/domain/line_element'
require_relative '../../lib/domain/button'
require_relative '../../lib/domain/button_with_log'
require_relative '../../lib/domain/button_with_log_pre'
require_relative '../../lib/domain/heading'
require_relative '../../lib/domain/image'
require_relative '../../lib/domain/button_link_previous'
require_relative '../../lib/domain/button_live_css'
require_relative '../../lib/domain/button_live_preview'
require_relative '../../lib/domain/button_live_preview_float'
require_relative '../../lib/domain/multiple_choice'
require_relative '../../lib/domain/vertical_space'

module Parsing

  ##
  # Helper class for simple line based matches that do not require a stateful
  # parser
  class LineMatcher

    ##
    # Create a new matcher
    # @param [Regexp] pattern pattern
    # @param [Proc] function function to be called if pattern matches
    def initialize(pattern,  &function)
      @pattern, @function = pattern, function
    end

    ## Predefined matchers
    MATCHERS = [
        LineMatcher.new(/^<(.*)/) \
            { |line, line_id| Domain::HTML.new(line) },

        LineMatcher.new(/\(\(Link-Previous\)\)/) \
            { |line, line_id| Domain::ButtonLinkPrevious.new(line_id) },

        LineMatcher.new(/\(\(Live-CSS (.*)\)\)/) \
            { |line, line_id, fragment| Domain::ButtonLiveCSS.new(line_id, fragment) },

        LineMatcher.new(/\(\(Live-Preview\)\)/)  \
            { |line, line_id| Domain::ButtonLivePreview.new(line_id) },

        LineMatcher.new(/\(\(Live-Preview-Float\)\)/)  \
            { |line, line_id| Domain::ButtonLivePreviewFloat.new(line_id) },

        LineMatcher.new(/\(\(Button\)\)/) \
            { |line, line_id| Domain::Button.new(line_id) },

        LineMatcher.new(/\(\(Button-With-Log\)\)/) \
            { |line, line_id| Domain::ButtonWithLog.new(line_id) },

        LineMatcher.new(/\(\(Button-With-Log-Pre\)\)/) \
            { |line, line_id| Domain::ButtonWithLogPre.new(line_id) },

        LineMatcher.new(/##### (.*)/) \
            { |line, line_id, title| Domain::Heading.new(5, title.gsub('#', '')) },

        LineMatcher.new(/#### (.*)/) \
            { |line, line_id, title| Domain::Heading.new(4, title.gsub('#', '')) },

        LineMatcher.new(/### (.*)/) \
            { |line, line_id, title| Domain::Heading.new(3, title.gsub('#', '')) },

        LineMatcher.new(/!\[(.*)\]\((.*) "(.*)"\)\/(.*)\/\/(.*)\//) \
            { |line, line_id, alt, location, title, width_slide, width_plain| Domain::Image.new(location, alt, title, width_slide, width_plain) },

        LineMatcher.new(/!\[(.*)\]\((.*) "(.*)"\)\/(.*)\//) \
            { |line, line_id, alt, location, title, width_slide| Domain::Image.new(location, alt, title, width_slide, nil) },

        LineMatcher.new(/!\[(.*)\]\((.*)\)\/(.*)\/\/(.*)\//) \
            { |line, line_id, alt, location, width_slide, width_plain| Domain::Image.new(location, alt, alt, width_slide, width_plain) },

        LineMatcher.new(/!\[(.*)\]\((.*?)\)\/(.*?)\//) \
            { |line, line_id, alt, location, width_slide| Domain::Image.new(location, alt, alt, width_slide, nil) },

        LineMatcher.new(/!\[(.*)\]\((.*) "(.*)"\)/) \
            { |line, line_id, alt, location, title| Domain::Image.new(location, alt, title, nil, nil) },

        LineMatcher.new(/!\[(.*)\]\((.*)\)/) \
            { |line, line_id, alt, location| Domain::Image.new(location, alt, alt, nil, nil) },
    ]

    ##
    # Match and call function if match succeed
    # @param [String] line input to match against
    # @param [String] line_id id of the current line
    # @return [Domain::Element] the matching element or nil
    def match_single(line, line_id)
      if @pattern =~ line
        @function.call(line, line_id, $1, $2, $3, $4, $5)
      else
        nil
      end
    end

    ##
    # Match against all matchers
    # @param [String] line input to match against
    # @param [String] line_id id of the current line
    # @return [Domain::Element] the matching element or nil
    def LineMatcher.match(line, line_id)
      MATCHERS.each { |m|
        r = m.match_single(line, line_id)
        return r  if r != nil
      }
      nil
    end
  end
end
