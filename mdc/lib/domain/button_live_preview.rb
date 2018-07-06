# -*- coding: utf-8 -*-

require_relative 'element'
require_relative 'button'

module Domain

  ##
  # Link output to code on same slide
  class ButtonLivePreview < Button
    render_method :live_preview
  end
end
