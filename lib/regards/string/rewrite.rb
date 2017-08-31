# coding: utf-8
# frozen-string-literal: true
#
# © Chris Riddoch, 2017
# This software is licensed under the GPLv3 and comes with ABSOLUTELY NO WARRANTY; for details see LICENSE in the project's main directory.

module Regards
  module StringRefinements
    module Rewrite
      refine String do
        ::REFININGS ||= {}
        ::REFININGS["String#rewrite"] = true

        def rewrite(subs)
          subs.inject(self) {|str, curr|
            rx, fn = *curr
            m = rx.match(str)
            if m.nil?
              str
            else
              fn.call(m)
            end
          }
        end

        def rewrite_all(subs)
          text = self
          loop do
            prev_text = text
            text = text.rewrite(subs)
            break if text == prev_text
          end
          text
        end
      end
    end
  end
end

