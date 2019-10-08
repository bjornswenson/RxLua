local Observable = require 'rx.observable'

Observable.wrap = Observable.buffer
Observable['repeat'] = Observable.replicate
