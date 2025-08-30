require_relative '../element'

module Domain
  ##
  # Base class for all line elements
  class LineElement < Element
    attr_accessor :type
  end
end
