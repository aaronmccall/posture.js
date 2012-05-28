Backbone = require 'backbone'
Posture = require '../lib/posture'
should = require 'should'
Posture.init(Backbone)

console.log 'Running tests'

describe 'Posture', ->
  it 'should fire pre and post init signals', (done) ->
    count = 0
    foo_opts =
      signals:
        preInit: [-> count++],
        postInit: [
          ->
            count++
            count.should.equal(2)
            done()
        ]
    Foo = Backbone.Model.extend(foo_opts)
    console.log Backbone.Model.extend.toString()
    my_foo = new Foo