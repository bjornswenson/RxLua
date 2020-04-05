describe('CompositeSubscription', function()
  describe('create', function()
    it('returns a CompositeSubscription', function()
      local compositeSubscription = Rx.CompositeSubscription.create()
      expect(compositeSubscription).to.be.an(Rx.CompositeSubscription)
    end)
  end)

  describe('unsubscribe', function()
    describe('with subscriptions composed at initialization', function()
      it('unsubscribes composed subscriptions', function()
        local subscriptions = {
          Rx.Subscription.create(function() end),
          Rx.Subscription.create(function() end),
        }
        local spies = {
          spy(subscriptions[1], 'unsubscribe'),
          spy(subscriptions[2], 'unsubscribe'),
        }

        local compositeSubscription = Rx.CompositeSubscription.create(unpack(subscriptions))
        compositeSubscription:unsubscribe()

        expect(#spies[1]).to.equal(1)
        expect(#spies[2]).to.equal(1)
      end)

      it('only invokes unsubscribe once', function()
        local subscriptions = {
          Rx.Subscription.create(function() end),
          Rx.Subscription.create(function() end),
        }
        local spies = {
          spy(subscriptions[1], 'unsubscribe'),
          spy(subscriptions[2], 'unsubscribe'),
        }

        local compositeSubscription = Rx.CompositeSubscription.create(unpack(subscriptions))
        compositeSubscription:unsubscribe()
        compositeSubscription:unsubscribe()

        expect(#spies[1]).to.equal(1)
        expect(#spies[2]).to.equal(1)
      end)
    end)

    describe('with subscriptions composed dynamically', function()
      it('unsubscribes composed subscriptions', function()
        local subscriptions = {
          Rx.Subscription.create(function() end),
          Rx.Subscription.create(function() end),
        }
        local spies = {
          spy(subscriptions[1], 'unsubscribe'),
          spy(subscriptions[2], 'unsubscribe'),
        }

        local compositeSubscription = Rx.CompositeSubscription.create()
        compositeSubscription:add(unpack(subscriptions))
        compositeSubscription:unsubscribe()

        expect(#spies[1]).to.equal(1)
        expect(#spies[2]).to.equal(1)
      end)

      it('only invokes unsubscribe once', function()
        local subscriptions = {
          Rx.Subscription.create(function() end),
          Rx.Subscription.create(function() end),
        }
        local spies = {
          spy(subscriptions[1], 'unsubscribe'),
          spy(subscriptions[2], 'unsubscribe'),
        }

        local compositeSubscription = Rx.CompositeSubscription.create()
        compositeSubscription:add(unpack(subscriptions))
        compositeSubscription:unsubscribe()
        compositeSubscription:unsubscribe()

        expect(#spies[1]).to.equal(1)
        expect(#spies[2]).to.equal(1)
      end)
    end)
  end)

  describe('add', function()
    it('does not unsubscribe composed subscriptions', function()
      local subscriptions = {
        Rx.Subscription.create(function() end),
        Rx.Subscription.create(function() end),
      }
      local spies = {
        spy(subscriptions[1], 'unsubscribe'),
        spy(subscriptions[2], 'unsubscribe'),
      }

      local compositeSubscription = Rx.CompositeSubscription.create()
      compositeSubscription:add(unpack(subscriptions))

      expect(#spies[1]).to.equal(0)
      expect(#spies[2]).to.equal(0)
    end)

    describe('if CompositeSubscription is already unsubscribed', function()
      it('immediately unsubscribes subscriptions', function()
        local subscriptions = {
          Rx.Subscription.create(function() end),
          Rx.Subscription.create(function() end),
        }
        local spies = {
          spy(subscriptions[1], 'unsubscribe'),
          spy(subscriptions[2], 'unsubscribe'),
        }

        local compositeSubscription = Rx.CompositeSubscription.create()
        compositeSubscription:unsubscribe()

        compositeSubscription:add(unpack(subscriptions))

        expect(#spies[1]).to.equal(1)
        expect(#spies[2]).to.equal(1)
      end)
    end)

    describe('if CompositeSubscription was cleared', function()
      it('does not unsubscribe composed subscriptions', function()
        local subscriptions = {
          Rx.Subscription.create(function() end),
          Rx.Subscription.create(function() end),
        }
        local spies = {
          spy(subscriptions[1], 'unsubscribe'),
          spy(subscriptions[2], 'unsubscribe'),
        }

        local compositeSubscription = Rx.CompositeSubscription.create(
            Rx.Subscription.create(function() end))
        compositeSubscription:clear()

        compositeSubscription:add(unpack(subscriptions))

        expect(#spies[1]).to.equal(0)
        expect(#spies[2]).to.equal(0)
      end)
    end)
  end)

  describe('clear', function()
    it('unsubscribes composed subscriptions', function()
        local subscriptions = {
          Rx.Subscription.create(function() end),
          Rx.Subscription.create(function() end),
        }
        local spies = {
          spy(subscriptions[1], 'unsubscribe'),
          spy(subscriptions[2], 'unsubscribe'),
        }

        local compositeSubscription = Rx.CompositeSubscription.create(unpack(subscriptions))
        compositeSubscription:clear()

        expect(#spies[1]).to.equal(1)
        expect(#spies[2]).to.equal(1)
    end)
  end)
end)