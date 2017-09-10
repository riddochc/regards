# coding: utf-8
# frozen-string-literal: true
#
# © Chris Riddoch, 2017
# This software is licensed under the GPLv3 and comes with ABSOLUTELY NO WARRANTY; for details see LICENSE in the project's main directory.

module Regards
  module RegexpRefinements
    module Unroll
      refine Regexp do
        ::REFININGS ||= {}
        ::REFININGS["Regexp.unroll"] = true
        ::REFININGS["Regexp#unroll_and_unescape"] = true

        def Regexp.unroll(opening: /"/, closing: /"/, normal: /[^"\\]/, special: /\\./)
          %r{ #{opening}
                 (?<body> (?: #{normal})*
                    (?: #{special} (?: #{normal})* )*
                 )
              #{closing}
           }x
        end

        def Regexp.unroll_and_unescape(str, opening: /"/, closing: /"/, normal: /[^"\\]/, special: /\\./, &blk)
          args = {opening: opening, closing: closing, normal: normal, special: special}
          m = Regexp.unroll(**args).match(str)
          if m
            m['body'].gsub(special, &blk)
          end
        end
      end
    end
  end
end

