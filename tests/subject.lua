describe('Subject', function()
  describe('create', function()
    it('returns a Subject', function()
      expect(Rx.Subject.create()).to.be.an(Rx.Subject)
    end)
  end)

  describe('subscribe', function()
    it('returns a Subscription', function()
      local subject = Rx.Subject.create()
      local observer = Rx.Observer.create()
      expect(subject:subscribe(observer)).to.be.an(Rx.Subscription)
    end)

    it('accepts 3 functions as arguments', function()
      local onNext, onCompleted = spy(), spy()
      local subject = Rx.Subject.create()
      subject:subscribe(onNext, nil, onCompleted)
      subject:onNext(5)
      subject:onCompleted()
      expect(onNext).to.equal({{5}})
      expect(#onCompleted).to.equal(1)
    end)

    describe('if the subject has already received an error', function()
      it('immediately emits an error', function()
        local onNext, onError, onCompleted = spy(), spy(), spy()
        local subject = Rx.Subject.create()
        subject:onNext(5)
        subject:onError('ohno')
        subject:subscribe(onNext, onError, onCompleted)
        expect(#onNext).to.equal(0)
        expect(onError).to.equal({{'ohno'}})
        expect(#onCompleted).to.equal(0)
      end)
    end)

    describe('if the subject has already completed', function()
      it('immediately completes', function()
        local onNext, onError, onCompleted = spy(), spy(), spy()
        local subject = Rx.Subject.create()
        subject:onNext(5)
        subject:onCompleted()
        subject:subscribe(onNext, onError, onCompleted)
        expect(#onNext).to.equal(0)
        expect(#onError).to.equal(0)
        expect(#onCompleted).to.equal(1)
      end)
    end)
  end)

  describe('onNext', function()
    it('pushes values to all subscribers', function()
      local observers = {}
      local spies = {}
      for i = 1, 2 do
        observers[i] = Rx.Observer.create()
        spies[i] = spy(observers[i], '_onNext')
      end

      local subject = Rx.Subject.create()
      subject:subscribe(observers[1])
      subject:subscribe(observers[2])
      subject:onNext(1)
      subject:onNext(2)
      subject:onNext(3)
      expect(spies[1]).to.equal({{1}, {2}, {3}})
      expect(spies[2]).to.equal({{1}, {2}, {3}})
    end)

    it('can be called using function syntax', function()
      local observer = Rx.Observer.create()
      local subject = Rx.Subject.create()
      local onNext = spy(observer, 'onNext')
      subject:subscribe(observer)
      subject(4)
      expect(#onNext).to.equal(1)
    end)

    describe('if the subject has already received an error', function()
      it('does not push values to subscribers', function()
        local observers = {}
        local spies = {}
        for i = 1, 2 do
          observers[i] = Rx.Observer.create(nil, function() end, nil)
          spies[i] = spy(observers[i], '_onNext')
        end

        local subject = Rx.Subject.create()
        subject:onError('ohno')
        subject:subscribe(observers[1])
        subject:subscribe(observers[2])
        subject:onNext(1)
        subject:onNext(2)
        subject:onNext(3)
        expect(#spies[1]).to.equal(0)
        expect(#spies[2]).to.equal(0)
      end)
    end)

    describe('if the subject has already completed', function()
      it('does not push values to subscribers', function()
        local observers = {}
        local spies = {}
        for i = 1, 2 do
          observers[i] = Rx.Observer.create()
          spies[i] = spy(observers[i], '_onNext')
        end

        local subject = Rx.Subject.create()
        subject:onCompleted()
        subject:subscribe(observers[1])
        subject:subscribe(observers[2])
        subject:onNext(1)
        subject:onNext(2)
        subject:onNext(3)
        expect(#spies[1]).to.equal(0)
        expect(#spies[2]).to.equal(0)
      end)
    end)
  end)

  describe('onError', function()
    it('pushes errors to all subscribers', function()
      local observers = {}
      local spies = {}
      for i = 1, 2 do
        observers[i] = Rx.Observer.create(nil, function() end, nil)
        spies[i] = spy(observers[i], '_onError')
      end

      local subject = Rx.Subject.create()
      subject:subscribe(observers[1])
      subject:subscribe(observers[2])
      subject:onError('ohno')
      expect(spies[1]).to.equal({{'ohno'}})
      expect(spies[2]).to.equal({{'ohno'}})
    end)

    describe('if the subject has already completed', function()
      it('does not push errors to subscribers', function()
        local observers = {}
        local spies = {}
        for i = 1, 2 do
          observers[i] = Rx.Observer.create(nil, function() end, nil)
          spies[i] = spy(observers[i], '_onError')
        end

        local subject = Rx.Subject.create()
        subject:onCompleted()
        subject:onError('ohno')
        subject:subscribe(observers[1])
        subject:subscribe(observers[2])
        subject:onError('ohno')
        expect(#spies[1]).to.equal(0)
        expect(#spies[2]).to.equal(0)
      end)
    end)
  end)

  describe('onCompleted', function()
    it('notifies all subscribers of completion', function()
      local observers = {}
      local spies = {}
      for i = 1, 2 do
        observers[i] = Rx.Observer.create(nil, function() end, nil)
        spies[i] = spy(observers[i], '_onCompleted')
      end

      local subject = Rx.Subject.create()
      subject:subscribe(observers[1])
      subject:subscribe(observers[2])
      subject:onCompleted()
      expect(#spies[1]).to.equal(1)
      expect(#spies[2]).to.equal(1)
    end)

    describe('if the subject has already received an error', function()
      it('does not notify all subscribers of completion', function()
        local observers = {}
        local spies = {}
        for i = 1, 2 do
          observers[i] = Rx.Observer.create(nil, function() end, nil)
          spies[i] = spy(observers[i], '_onCompleted')
        end

        local subject = Rx.Subject.create()
        subject:onError('ohno')
        subject:onCompleted()
        subject:subscribe(observers[1])
        subject:subscribe(observers[2])
        subject:onCompleted()
        expect(#spies[1]).to.equal(0)
        expect(#spies[2]).to.equal(0)
      end)
    end)
  end)
end)
