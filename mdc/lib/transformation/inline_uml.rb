require_relative '../domain/element'

module Transformer
  ##
  # Class representing inline UML diagrams.
  class InlineUML
    def initialize(temp_dir)
      @temp_dir = temp_dir
    end

    ##
    # Transform the element
    # @param [Domain::UML] element element to be transformed
    def self.transform(element)
      uml = element.content
    end

    def execute_plant_uml(file); end
  end
end
