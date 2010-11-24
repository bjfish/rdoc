require 'rubygems'
require 'minitest/autorun'
require 'rdoc/parser'
require 'rdoc/parser/ruby'
require 'tmpdir'

class TestRDocParser < MiniTest::Unit::TestCase

  def setup
    @RP = RDoc::Parser
    @binary_dat = File.expand_path '../binary.dat', __FILE__
  end

  def test_class_binary_eh_marshal
    marshal = File.join Dir.tmpdir, "test_rdoc_parser_#{$$}.marshal"
    open marshal, 'wb' do |io|
      io.write Marshal.dump('')
      io.write 'lots of text ' * 500
    end

    assert @RP.binary?(marshal)
  ensure
    File.unlink marshal
  end

  def test_class_binary_japanese_text
    file_name = File.expand_path '../test.ja.txt', __FILE__
    refute @RP.binary?(file_name)
  end

  def test_class_binary_japanese_rdoc
    skip "Encoding not implemented" unless Object.const_defined? :Encoding

    file_name = File.expand_path '../test.ja.rdoc', __FILE__
    refute @RP.binary?(file_name)
  end

  def test_class_can_parse
    assert_equal @RP.can_parse(__FILE__), @RP::Ruby

    readme_file_name = File.expand_path '../test.txt', __FILE__

    assert_equal @RP::Simple, @RP.can_parse(readme_file_name)

    assert_nil @RP.can_parse(@binary_dat)

    jtest_file_name = File.expand_path '../test.ja.txt', __FILE__
    assert_equal @RP::Simple, @RP.can_parse(jtest_file_name)

    jtest_rdoc_file_name = File.expand_path '../test.ja.rdoc', __FILE__
    assert_equal @RP::Simple, @RP.can_parse(jtest_rdoc_file_name)

    readme_file_name = File.expand_path '../README', __FILE__
    assert_equal @RP::Simple, @RP.can_parse(readme_file_name)
  end

  ##
  # Selenium hides a .jar file using a .txt extension.

  def test_class_can_parse_zip
    hidden_zip = File.expand_path '../hidden.zip.txt', __FILE__
    assert_nil @RP.can_parse(hidden_zip)
  end

  def test_class_for_binary
    rp = @RP.dup

    class << rp
      alias old_can_parse can_parse
    end

    def rp.can_parse(*args) nil end

    assert_nil @RP.for(nil, @binary_dat, nil, nil, nil)
  end

  def test_class_set_encoding
    skip "Encoding not implemented" unless Object.const_defined? :Encoding

    s = "# coding: UTF-8\n"
    RDoc::Parser.set_encoding s

    assert_equal Encoding::UTF_8, s.encoding

    s = "#!/bin/ruby\n# coding: UTF-8\n"
    RDoc::Parser.set_encoding s

    assert_equal Encoding::UTF_8, s.encoding

    s = "<?xml version='1.0' encoding='UTF-8'?>\n"
    expected = s.encoding
    RDoc::Parser.set_encoding s

    assert_equal Encoding::UTF_8, s.encoding

    s = "<?xml version='1.0' encoding=\"UTF-8\"?>\n"
    expected = s.encoding
    RDoc::Parser.set_encoding s

    assert_equal Encoding::UTF_8, s.encoding
  end

  def test_class_set_encoding_bad
    skip "Encoding not implemented" unless Object.const_defined? :Encoding

    s = ""
    expected = s.encoding
    RDoc::Parser.set_encoding s

    assert_equal expected, s.encoding

    s = "# vim:set fileencoding=utf-8:\n"
    expected = s.encoding
    RDoc::Parser.set_encoding s

    assert_equal expected, s.encoding

    s = "# vim:set fileencoding=utf-8:\n"
    expected = s.encoding
    RDoc::Parser.set_encoding s

    assert_equal expected, s.encoding

    assert_raises ArgumentError do
      RDoc::Parser.set_encoding "# -*- encoding: undecided -*-\n"
    end
  end

end

