# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `after_party` gem.
# Please instead update this file by running `bin/tapioca gem after_party`.

# AfterParty is a moduke defined by gem after_party
#
# source://after_party//lib/after_party.rb#2
module AfterParty
  class << self
    # @yield [_self]
    # @yieldparam _self [AfterParty] the object that the method was called on
    #
    # source://after_party//lib/after_party.rb#5
    def setup; end
  end
end

# railtie is loaded from lib/after_party.rb.  So all load paths need to be relative to /lib
#
# source://after_party//lib/after_party/railtie.rb#5
class AfterParty::Railtie < ::Rails::Railtie; end