# coding: utf-8
# frozen-string-literal: true
#
# © Chris Riddoch, 2017
# This software is licensed under the GPLv3 and comes with ABSOLUTELY NO WARRANTY; for details see LICENSE in the project's main directory.

module Regards
  module StringRefinements
    refine String do
      ::REFININGS ||= {}
      ::REFININGS["String#number?"] = true
      ::REFININGS["String#to_numeric"] = true

      def number?
        begin
          !self.to_numeric.nil?
        rescue
          false
        end
      end

      def to_numeric
        begin
          Integer(self)
        rescue ArgumentError
          begin
            Rational(self)
          rescue ZeroDivisionError
            nil
          rescue ArgumentError
            begin
              Float(self)
            rescue ArgumentError
              begin
                case self
                when "Infinity"
                  Float::INFINITY
                when "-Infinity"
                  -Float::INFINITY
                when "NaN" # sort of?
                  Float::NAN
                else
                  Complex(self)
                end
              rescue ArgumentError
                nil
              end
            end
          end
        end
      end
    end
  end
end

