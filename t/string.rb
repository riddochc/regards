# coding: utf-8
# frozen-string-literal: true
#
# © Chris Riddoch, 2017
# This software is licensed under the GPLv3 and comes with ABSOLUTELY NO WARRANTY; for details see LICENSE in the project's main directory.

$:.unshift(File.join(File.dirname(File.expand_path(__FILE__)), "../lib/"))

require_relative "../lib/regards"
require_relative "../lib/regards/string/to_numeric"

gem 'minitest'
require 'minitest/autorun'
require 'minitest/hooks/default'

using Regards::StringRefinements::Numeric

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
  end
  end
end


