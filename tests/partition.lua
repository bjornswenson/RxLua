describe('partition', function()
  it('errors when its parent errors', function()
    local observable = Rx.Observable.of(''):map(function(x) return x() end)
    expect(observable).to.produce.error()
    expect(observable:partition()).to.produce.error()
  end)

  it('uses the identity function as the predicate if none is specified', function()
    local pass, fail = Rx.Observable.fromTable({true, false, true}):partition()
    expect(pass).to.produce(true, true)
    expect(fail).to.produce(false)
  end)

  it('partitions the elements into two observables based on the predicate', function()
    local function isEven(x) return x % 2 == 0 end
    local pass, fail = Rx.Observable.fromRange(5):partition(isEven)
    expect(pass).to.produce(2, 4)
    expect(fail).to.produce(1, 3, 5)
  end)
end)
