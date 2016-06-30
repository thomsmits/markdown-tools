# -*- coding: utf-8 -*-

require 'minitest/autorun'
require_relative '../lib/parsing/properties_reader'

##
# Tests for the class Parsing::PropertiesReader
class PropertiesReaderTest  < Minitest::Test

  ##
  # Test properties without a defaults file
  def test_without_defaults
    contents = StringIO.new(%q{
      # comment 1
      namea=valuea
      nameb = valueb

      name.with.dot = value with blank
      # comment 2
      # ignore = invisible
      special = äöüß:;!!!@@
      name_with_underscore=value_with_underscore
    })

    props = Parsing::PropertiesReader.new(contents, '=')

    assert_equal('valuea',                props.get('namea'))
    assert_equal('valueb',                props.get('nameb'))
    assert_equal('value with blank',      props.get('name.with.dot'))
    assert_equal('äöüß:;!!!@@',           props.get('special'))
    assert_equal('value_with_underscore', props.get('name_with_underscore'))

    assert_equal('valuea',                props.namea)
    assert_equal('valueb',                props.nameb)
    assert_equal('äöüß:;!!!@@',           props.special)
    assert_equal('value_with_underscore', props.name_with_underscore)

    assert_nil(props.get('ignore'))
  end

  ##
  # Test properties without a defaults file
  def test_with_different_separator
    contents = StringIO.new(%q{
      # comment 1
      namea:valuea
      nameb : valueb

      name.with.dot : value with blank
      # comment 2
      # ignore : invisible
      special : äöüß:;!!!@@
      name_with_underscore:value_with_underscore
    })

    props = Parsing::PropertiesReader.new(contents, ':')

    assert_equal('valuea',                props.get('namea'))
    assert_equal('valueb',                props.get('nameb'))
    assert_equal('value with blank',      props.get('name.with.dot'))
    assert_equal('äöüß:;!!!@@',           props.get('special'))
    assert_equal('value_with_underscore', props.get('name_with_underscore'))

    assert_equal('valuea',                props.namea)
    assert_equal('valueb',                props.nameb)
    assert_equal('äöüß:;!!!@@',           props.special)
    assert_equal('value_with_underscore', props.name_with_underscore)

    assert_nil(props.get('ignore'))
  end

  ##
  # Test properties with a defaults file
  def test_with_defaults
    contents = StringIO.new(%q{
      # comment 1
      namea = valuea
      nameb = valueb

    })

    defaults = StringIO.new(%q{
      # comment 1
      namea = valuea_default
      namec = valuec_default
    })

    props = Parsing::PropertiesReader.new(contents, '=', defaults)

    assert_equal('valuea',                props.get('namea'))
    assert_equal('valueb',                props.get('nameb'))
    assert_equal('valuec_default',        props.get('namec'))

    assert_equal('valuea',                props.namea)
    assert_equal('valueb',                props.nameb)
    assert_equal('valuec_default',        props.namec)
  end
end
