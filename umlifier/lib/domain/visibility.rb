# -*- coding: utf-8 -*-

module Domain
  class Visibility
    attr_accessor :name, :sign

    def initialize(name, sign)
      @name, @sign = name, sign
    end

    PRIVATE   = Visibility.new('Private', '-')
    DEFAULT   = Visibility.new('Default', '~')
    PROTECTED = Visibility.new('Protected', '#')
    NONE      = Visibility.new('None', '')
    PUBLIC    = Visibility.new('Public', '+')

    ##
    # Return the object corresponding to the sign
    # @param [String] input
    def self.parse(input)
      if input.start_with?('-')
        PRIVATE
      elsif input.start_with?('~')
        DEFAULT
      elsif input.start_with?('#')
        PROTECTED
      elsif input.start_with?('+')
        PUBLIC
      else
        nil
      end
    end

    def to_s
      @name
    end
  end
end