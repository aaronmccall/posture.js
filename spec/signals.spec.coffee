Backbone = require("backbone")
Posture = require("../lib/posture")
should = require("should")
Posture.init Backbone
Backbone.sync = ->

describe "Signals", ->

  it "Model should fire 'pre' and 'post' signals for initialize, save & destroy", (done) ->
    count = 0
    foo_opts =
      save: ->
      destroy: ->
      signals:
        preInitialize: [ 
          ->
            count++
            count.should.equal 1
        ]
        postInitialize: [ 
          ->
            count++
            count.should.equal 2
        ]
        preSave: [
          ->
            count++
            count.should.equal 3
        ]
        postSave: [
          ->
            count++
            count.should.equal 4
        ]
        preDestroy: [
          ->
            count++
            count.should.equal 5
        ]
        postDestroy: [
          ->
            count++
            count.should.equal 6
            done()
        ]

    Foo = Posture.Model.extend(foo_opts)
    my_foo = new Foo
    my_foo.save()
    my_foo.destroy()

  it "View should fire 'pre' and 'post' signals for initialize & render", (done) ->
    count = 0
    foo_opts =
      signals:
        preInitialize: [ 
          ->
            count++
            count.should.equal 1
        ]
        postInitialize: [ 
          ->
            count++
            count.should.equal 2
        ]
        preRender: [
          ->
            count++
            count.should.equal 3
        ]
        postRender: [
          ->
            count++
            count.should.equal 4
            done()
        ]

    Foo = Posture.View.extend(foo_opts)
    Foo::_ensureElement = ->
    my_foo = new Foo
    my_foo.render()

  it "Collection should fire 'pre' and 'post' signals for initialize", (done) ->
    count = 0
    foo_opts =
      signals:
        preInitialize: [ 
          ->
            count++
            count.should.equal 1
        ]
        postInitialize: [ 
          ->
            count++
            count.should.equal 2
            done()
        ]

    Foo = Posture.Collection.extend(foo_opts)
    my_foo = new Foo

  it "Router should fire 'pre' and 'post' signals for initialize & navigate", (done) ->
    count = 0
    foo_opts =
      navigate: ->
      signals:
        preInitialize: [ 
          ->
            count++
            count.should.equal 1
        ]
        postInitialize: [ 
          ->
            count++
            count.should.equal 2
        ]
        preNavigate: [
          ->
            count++
            count.should.equal 3
        ]
        postNavigate: [
          ->
            count++
            count.should.equal 4
            done()
        ]

    Foo = Posture.Router.extend(foo_opts)
    my_foo = new Foo
    my_foo.navigate('/')
