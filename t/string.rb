# coding: utf-8
# frozen-string-literal: true
#
# © Chris Riddoch, 2017
# This software is licensed under the GPLv3 and comes with ABSOLUTELY NO WARRANTY; for details see LICENSE in the project's main directory.

$:.unshift(File.join(File.dirname(File.expand_path(__FILE__)), "../lib/"))

require_relative "../lib/regards"
require_relative "../lib/regards/string/to_numeric"
require_relative "../lib/regards/string/unhexdump"
require_relative "../lib/regards/string/rewrite"

gem 'minitest'
require 'minitest/autorun'
require 'minitest/hooks/default'

using Regards::StringRefinements::Numeric
using Regards::StringRefinements::Unhexdump
using Regards::StringRefinements::Rewrite

def numeric_must_be(str, result)
  str.to_numeric.must_equal result
end

describe "String" do
  describe ".number? and .to_numeric" do
    it "isn't found by respond_to? because it's a refinement" do
      "".respond_to?(:number?).must_equal false
      "".respond_to?(:to_numeric).must_equal false
    end
    it "is refined_with? :number?" do
      "".refined_with?(:number?).must_equal true
      "".refined_with?(:to_numeric).must_equal true
    end
    it "returns false for a non-number, 'x'" do
      "x".number?.must_equal false
    end
    it "returns true for a number" do
      "25".number?.must_equal true
    end
    it "implements .to_numeric" do
      "25".to_numeric.must_equal 25
    end
    it "returns integers correctly" do
      {"0" => 0,
       "-0" => 0,
       "1" => 1,
       "36893488147419103232" => 36893488147419103232, # 2**65
       "-50" => -50,
       "0x00" => 0,
       "0xf" => 15,
       "0b0" => 0,
       "0b1" => 1,
       "07" => 7,
       "09" => 9,
      }.each_pair {|str, result| numeric_must_be(str, result) }
    end

    it "returns rationals correctly" do
      {
       "1.25" => Rational(5,4),
       "-1.15" => Rational(-23,20),
      }.each_pair {|str, result| numeric_must_be(str, result) }
    end

    it "handles NaN correctly" do
      "NaN".to_numeric.respond_to?(:nan?)
      "NaN".to_numeric.nan?.must_equal true
    end

    it "returns complex numbers" do
      "3+3i".to_numeric.must_equal Complex(3,3)
      "5i".to_numeric.must_equal Complex(0,5)
    end
  end

  describe ".unhexdump" do
    it "isn't found by respond_to?, because it's a refinement" do
      "".respond_to?(:number?).must_equal false
    end

    it "is found by refined_with?" do
      "".refined_with?(:unhexdump).must_equal true
    end

    it "returns nil on strings containing non-hexadecimal, non-space characters" do
      assert_nil "f0z1".unhexdump
    end

    it 'returns a null byte for "00"' do
      "00".unhexdump.must_equal "\x00"
    end

    it "returns an empty string when called on an empty string" do
      "".unhexdump.must_equal ""
    end

    it %Q{returns "\\x01\\x02\\x03" when given "01 02 03"} do
      "01 02 03".unhexdump.must_equal "\x01\x02\x03"
    end
  end

  describe ".rewrite" do
    it "should replace the string with result of lambda if pattern is found" do
      subs = { /foo/ => ->(m) { "replaced" } }
      "one two".rewrite(subs).must_equal "one two"
      "one foo".rewrite(subs).must_equal "replaced"
    end

    it "should only apply the substitution once" do
      subs = { /[aoeui]+/ => ->(m) { m.pre_match + m[0].upcase + m.post_match } }
      "a test string".rewrite(subs).must_equal "A test string"
    end

    it "should make multiple changes: foo changed to blah, bar changed to baz" do
      subs= { /foo/ => ->(m) { m.pre_match + "blah" + m.post_match },
              /bar/ => ->(m) { m.pre_match + "baz" + m.post_match }
      }

      "one foo for a bar plz".rewrite(subs).must_equal "one blah for a baz plz"
    end
  end

  describe ".rewrite_all" do
    it "should apply the substitution on every match of a pattern" do
      subs = { /[aoeui]+/ => ->(m) { m.pre_match + m[0].upcase + m.post_match } }
      "a test string".rewrite_all(subs).must_equal "A tEst strIng"
    end

    it "should apply multiple changes to the string" do
      subs = { /[aoeui]/  => ->(m) { m.pre_match + "(1)" + m.post_match },
               /[tsr]/    => ->(m) { m.pre_match + "[0]" + m.post_match } }
      "a test string".rewrite_all(subs).must_equal  "(1) [0](1)[0][0] [0][0][0](1)ng"
    end

    it "should be able to manipulate the whole string, not just the matched portion." do
      subs = { /[aoeui]/  => ->(m) { m.post_match + "(1)" + m.pre_match },
               /[tsr]/    => ->(m) { m.post_match + "[0]" + m.pre_match } }
      "a test string".rewrite_all(subs).must_equal "[0]ng(1)[0] (1)[0](1)[0] [0][0]"
    end
  end
end


