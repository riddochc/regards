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

using Regards::StringRefinements

describe "String" do
  it "implements .number?" do
    "3".number?.must_equal true
  end
  it "doesn't respond_to? :number?" do
    "".respond_to?(:number?).must_equal false
  end
  it "is refined_with? :number?" do
    "".refined_with?(:number?).must_equal true
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
end


