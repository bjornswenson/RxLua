local Observable = require 'rx.observable'
local util = require 'rx.util'

--- Returns an Observable that produces the values of the original inside tables.
-- @returns {Observable}
function Observable:pack()
  return self:map(util.pack)
end
