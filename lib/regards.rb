# coding: utf-8
# frozen-string-literal: true
#
# © Chris Riddoch, 2017
# This software is licensed under the GPLv3 and comes with ABSOLUTELY NO WARRANTY; for details see LICENSE in the project's main directory.

::REFININGS ||= {} 

class Object
  # In current versions of ruby (2.3), respond_to? doesn't return true for methods defined using refinements.
  # As a workaround, I'm introducing this refined_with? method to test whether the method is in a list of known refinement methods.
  # Unfortunately, attempting to modify the class with a constant listing methods refining it is currently not possible
  # from within the refine Klass { ... } block, so this adds the class#method to a global ::REFININGS hash for lookup.
  def refined_with?(mth)
    ref = "#{self.class}##{mth}"
    ::REFININGS&.include?(ref)
  end
end

require "regards/string"
require "regards/regexp"

#class Kernel
#  def is_refined_with?(mth)
#    Module.used_modules # ...?
#  end
#end
