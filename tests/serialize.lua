describe('serialize', function()
  it('returns a Subject', function()
    local subject = Rx.Subject.create():serialize()
    expect(subject).to.be.an(Rx.Subject)
  end)

  it('pushes values to observers in order', function()
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

  it('pushes errors to observers in order', function()
    local subject = Rx.Subject.create():serialize()

    local function createNaughtyObserver()
      return Rx.Observer.create(nil, function()
        subject:onNext('test value')
      end, nil)
    end

    local observers = {
      createNaughtyObserver(),
      createNaughtyObserver(),
    }
    local spies = {
      onNext = {
        spy(observers[1], '_onNext'),
        spy(observers[2], '_onNext'),
      },
      onError = {
        spy(observers[1], '_onError'),
        spy(observers[2], '_onError'),
      },
    }
    subject:subscribe(observers[1])
    subject:subscribe(observers[2])

    subject:onError('ohno')

    expect(#spies.onNext[1]).to.equal(0)
    expect(#spies.onNext[2]).to.equal(0)
    expect(spies.onError[1]).to.equal({{'ohno'}})
    expect(spies.onError[2]).to.equal({{'ohno'}})
  end)

  it('notifies observers of completion in order', function()
    local subject = Rx.Subject.create():serialize()

    local function createNaughtyObserver()
      return Rx.Observer.create(nil, nil, function()
        subject:onNext('test value')
      end)
    end

    local observers = {
      createNaughtyObserver(),
      createNaughtyObserver(),
    }
    local spies = {
      onNext = {
        spy(observers[1], '_onNext'),
        spy(observers[2], '_onNext'),
      },
      onCompleted = {
        spy(observers[1], '_onCompleted'),
        spy(observers[2], '_onCompleted'),
      },
    }
    subject:subscribe(observers[1])
    subject:subscribe(observers[2])

    subject:onCompleted()

    expect(#spies.onNext[1]).to.equal(0)
    expect(#spies.onNext[2]).to.equal(0)
    expect(#spies.onCompleted[1]).to.equal(1)
    expect(#spies.onCompleted[2]).to.equal(1)
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
      return Rx.Observer.create(function()
        for _,subscription in ipairs(subscriptions) do
          subscription:unsubscribe()
        end
      end, nil, nil)
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