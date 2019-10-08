local Observable = require 'rx.observable'
local util = require 'rx.util'

--- Returns an Observable that unpacks the tables produced by the original.
-- @returns {Observable}
function Observable:unpack()
  return self:map(util.unpack)
end
