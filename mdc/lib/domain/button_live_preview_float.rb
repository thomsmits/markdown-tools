# -*- coding: utf-8 -*-

require_relative 'element'
require_relative 'button'

module Domain

  ##
  # Link floating output to code on same slide
  class ButtonLivePreviewFloat < Button
    render_method :live_preview_float
  end
end
