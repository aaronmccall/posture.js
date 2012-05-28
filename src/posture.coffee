root = this

# Are we in a CommonJS or other module-based environment?
if (exports?)
  # exports FTW!
  Posture = exports
else
  # Attach Posture to the global object
  Posture = root.Posture = {}

# If underscore is already defined let's give it a short handle locally
_ = root._

# If it wasn't try to `require` it if `require` is a thing.
_ = require('underscore')._ if not _ and require?

# Make a short alias to _'s function detector
isFn = _.isFunction 

# Make a short alias to _'s array maker
toArray = _.toArray 

# import sub-modules

###import "decorator.coffee" ###

Posture.Decorator = decorator

###import "signals.coffee" ###

Posture.Signal = signals

###import "accessors.coffee" ###

Posture.Accessors = accessors

###import "filters.coffee" ###

Posture.Filter = filters

###import "validators.coffee" ###

Posture.Validator = validators

_sig_defaults = ['pre', 'post']
Posture.default_signals = 
  Model: 
    initialize: _sig_defaults
    save: _sig_defaults
    destroy: _sig_defaults
  View:
    initialize: _sig_defaults
    render: _sig_defaults


Posture.enhance = 
  Model: (obj, options) ->
    # Apply our model enhancements 
    proto = obj::
    Posture.Accessors.init(obj)



  Collection: (obj, options) ->
    # Apply our collection enhancements 

  View: (obj, options) ->
    # Apply our view enhancements 

  Router: (obj, options) ->
    # Apply our router enhancements 

Posture.init = _.bind( (Backbone) ->
  defaults =
    extend:
      wrap: (func, protoProps, staticProps) ->
        console.log('extend wrapper firing')
        # Extend signals if needed
        if @signals and protoProps.signals
          new_signals = protoProps.signals
          protoProps.signals = Posture.Signal.extend(new_signals, @signals)

        # Setup pre and post initialization signals
        init = (protoProps.initialize or ->)
        init_opts = 
          func: init
          before: (args...) -> 
            console.log('running initialize before decorator')
            signals.init(@)
            if @signal
              args.unshift 'preInit'
              @signal.apply(@, args)
          after: (args...) ->
            if @signal
              args.unshift 'postInit'
              @signal.apply(@, args)
        protoProps.initialize = decorator(init_opts)
        protoProps.connect = signals.connect
        protoProps.signal = signals.signal

        obj = func(protoProps, staticProps)

        Posture.Accessors.init(obj)


  _.each Backbone, (obj, name) ->
    # Add Posture magic to Model.extend, Collection.extend, etc.
    if obj.extend and isFn(obj.extend) and Posture.enhance[name]?
      @[name].extend = (args...) -> 
        ext_obj = obj.extend.apply(obj, args)
        Posture.enhance.Model(ext_obj)
  , Posture)
            