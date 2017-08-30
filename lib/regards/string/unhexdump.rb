# coding: utf-8
# frozen-string-literal: true
#
# © Chris Riddoch, 2017
# This software is licensed under the GPLv3 and comes with ABSOLUTELY NO WARRANTY; for details see LICENSE in the project's main directory.

module Regards
  module StringRefinements
    module Unhexdump
      refine String do
        ::REFININGS ||= {}
        ::REFININGS["String#unhexdump"] = true

        def unhexdump
          # Check for non-hex, non-space characters.
          if /[^A-Fa-f0-9\t\n ]/ =~ self 
            nil
          else
            [self.gsub(/\H*/, "")].pack("H*")
          end
        end
      end
    end
  end
end

