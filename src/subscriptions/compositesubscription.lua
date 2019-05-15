local util = require 'util'

--- @class CompositeSubscription
-- @description A Subscription that is composed of other subscriptions and can be used to
-- unsubscribe multiple subscriptions at once.
local CompositeSubscription = {}
CompositeSubscription.__index = CompositeSubscription
CompositeSubscription.__tostring = util.constant('CompositeSubscription')

--- Creates a new CompositeSubscription. It may be initialized empty or with a set of Subscriptions.
-- @arg {Subscription...} subscriptions - A set of subscriptions to initialize the object with.
-- @returns {CompositeSubscription}
function CompositeSubscription.create(...)
  local self = {
    subscriptions = {...},
  }

  return setmetatable(self, CompositeSubscription)
end

--- Adds one or more Subscriptions to this CompositeSubscription.
-- @arg {Subscription...} subscriptions - The list of Subscriptions to add.
-- @returns {nil}
function CompositeSubscription:add(...)
  for _,subscription in ipairs({...}) do
    table.insert(self.subscriptions, subscription)
  end
end

--- Unsubscribes all subscriptions that were added to this CompositeSubscription and removes them
-- from this CompositeSubscription.
-- @returns {nil}
function CompositeSubscription:unsubscribe()
  for _,subscription in ipairs(self.subscriptions) do
    subscription:unsubscribe()
  end
  self.subscriptions = {}
end
