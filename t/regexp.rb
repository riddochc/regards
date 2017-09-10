# coding: utf-8
# frozen-string-literal: true
#
# © Chris Riddoch, 2017
# This software is licensed under the GPLv3 and comes with ABSOLUTELY NO WARRANTY; for details see LICENSE in the project's main directory.

$:.unshift(File.join(File.dirname(File.expand_path(__FILE__)), "../lib/"))

require_relative "../lib/regards"
require_relative "../lib/regards/regexp/unroll"

gem 'minitest'
require 'minitest/autorun'
require 'minitest/hooks/default'

using Regards::RegexpRefinements::Unroll

def numeric_must_be(str, result)
  str.to_numeric.must_equal result
end

describe "Regexp" do
  describe ".unroll" do
    it "Creates a regexp for unpacking quoted strings, by default" do
      rx = Regexp.unroll()
      m = rx.match('"some string"')
      m[:body].must_equal "some string"

      m = rx.match('grab "some string \\" containing a literal doublequote" from it.')
      m[:body].must_equal 'some string \\" containing a literal doublequote'
    end

    it "Creates a regexp that uses an alternate escaping mechanism" do
      rx = Regexp.unroll(normal: /[^"=]/, special: /\=./)
      
      m = rx.match('an equals sign "is the escape =" character here," you see.')
      m[:body].must_equal 'is the escape =" character here,'
    end

    it "Creates a regexp for matching parenthesized portions of a string" do
      rx = Regexp.unroll(opening: /\(/, closing: /\)/, normal: /[^\(\)\\]/)
      m = rx.match("For the (scheme \\( fans \\) out) there")
      m[:body].must_equal "scheme \\( fans \\) out"
    end
  end

  describe ".unroll_and_unescape" do
    it "Performs substitutions on escaped portions" do
      s = %Q{The reporter said, "He said he's an ""engineer"" of some sort."} 
      res = Regexp.unroll_and_unescape(s, normal: /[^"]/, special: /\"\"/) {|c| "`" }
      res.must_equal "He said he's an `engineer` of some sort."
    end

    it "Works on non-default regexes" do
      s = "For the (scheme \\( fans \\) out) there" 
      res = Regexp.unroll_and_unescape(s, opening: /\(/, closing: /\)/, normal: /[^\(\)\\]/) {|ex| ".#{ex[-1]}." }
      res.must_equal "scheme .(. fans .). out"
    end
  end
end


