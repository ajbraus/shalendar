module Debugger
  # TODO: remove version from C ext
  send :remove_const, :VERSION if const_defined? :VERSION
  VERSION = '1.1.4'
end
