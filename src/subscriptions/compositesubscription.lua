local Subscription = require 'subscription'
local util = require 'util'

--- @class CompositeSubscription
-- @description A Subscription that is composed of other subscriptions and can be used to
-- unsubscribe multiple subscriptions at once.
local CompositeSubscription = setmetatable({}, Subscription)
CompositeSubscription.__index = CompositeSubscription
CompositeSubscription.__tostring = util.constant('CompositeSubscription')

--- Creates a new CompositeSubscription. It may be initialized empty or with a set of Subscriptions.
-- @arg {Subscription...} subscriptions - A set of subscriptions to initialize the object with.
-- @returns {CompositeSubscription}
function CompositeSubscription.create(...)
  local self = {
    subscriptions = {...},
    unsubscribed = false,
  }

  return setmetatable(self, CompositeSubscription)
end

--- Unsubscribes all subscriptions that were added to this CompositeSubscription and removes them
-- from this CompositeSubscription.
-- @returns {nil}
function CompositeSubscription:unsubscribe()
  if not self.unsubscribed then
    self.unsubscribed = true
    for _,subscription in ipairs(self.subscriptions) do
      subscription:unsubscribe()
    end
    self.subscriptions = {}
  end
end

--- Adds one or more Subscriptions to this CompositeSubscription. If this subscription has already
-- unsubscribed, then any added subscriptions will be immediately disposed.
-- @arg {Subscription...} subscriptions - The list of Subscriptions to add.
-- @returns {nil}
function CompositeSubscription:add(...)
  for _,subscription in ipairs({...}) do
    if not self.unsubscribed then
      table.insert(self.subscriptions, subscription)
    else
      subscription:unsubscribe()
    end
  end
end

--- Removes all subscriptions from this CompositeSubscription and calls `Subscription:unsubscribe()`
-- on each one. More subscriptions can be added to this CompositeSubscription in the future.
-- @returns {nil}
function CompositeSubscription:clear()
  for _,subscription in ipairs(self.subscriptions) do
    subscription:unsubscribe()
    self.subscriptions = {}
  end
end
