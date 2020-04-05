describe('serialize', function()
  it('returns a Subject', function()
    local subject = Rx.Subject.create():serialize()
    expect(subject).to.be.an(Rx.Subject)
  end)

  it('emits in order', function()
    local subject = Rx.Subject.create():serialize()

    local function createReentrantObserver(trigger)
      return Rx.Observer.create(function(value)
        if value == trigger then
          subject:onNext(trigger + 1)
          subject:onNext(trigger + 2)
        end
      end, nil, nil)
    end

    local observers = {
      createReentrantObserver(1), -- emits 2 & 3
      createReentrantObserver(3), -- emits 4 & 5
    }
    local spies = {
      spy(observers[1], '_onNext'),
      spy(observers[2], '_onNext'),
    }
    subject:subscribe(observers[1])
    subject:subscribe(observers[2])

    subject:onNext(1)

    expect(#spies[1]).to.equal(5)
    expect(#spies[2]).to.equal(5)
    expect(spies[1]).to.equal({{1}, {2}, {3}, {4}, {5}})
    expect(spies[2]).to.equal({{1}, {2}, {3}, {4}, {5}})
  end)

  it('processes subscriptions in order', function()
    local subject = Rx.Subject.create():serialize()
    local spies = {}

    local function createCreativeObserver()
      return Rx.Observer.create(function()
        for i = 1,2 do
          local observer = Rx.Observer.create()
          spies[i] = spy(observer, '_onNext')
          subject:subscribe(observer)
        end
      end, nil, nil)
    end

    subject:subscribe(createCreativeObserver())

    subject:onNext()

    expect(#spies).to.equal(2)
    expect(#spies[1]).to.equal(0)
    expect(#spies[2]).to.equal(0)
  end)

  it('processes unsubscriptions in order', function()
    local subject = Rx.Subject.create():serialize()
    local subscriptions = {}

    local function createDestructiveObserver()
      return Rx.Observer.create(nil, function()
        for _,subscription in ipairs(subscriptions) do
          subscription:unsubscribe()
        end
      end, nil)
    end

    local observers = {
      createDestructiveObserver(),
      createDestructiveObserver(),
    }
    local spies = {
      spy(observers[1], '_onNext'),
      spy(observers[2], '_onNext'),
    }
    subject:subscribe(observers[1])
    subject:subscribe(observers[2])

    subject:onNext()

    expect(#spies[1]).to.equal(1)
    expect(#spies[2]).to.equal(1)
  end)
end)