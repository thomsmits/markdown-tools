require_relative 'element'

module Domain
  ##
  # Base class for all line elements
  class LineElement < Element
    attr_accessor :type

    ##
    # Create a digest of the content
    # @return [String] a digest of the slide
    def digest
      ''
    end
  end
end
