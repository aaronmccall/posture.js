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

_posture_props =
  Collection: {}
  Model: {}
  Router: {}
  View: {}

_.extend(Posture, _posture_props)

# Make a short alias to _'s function detector
isFn = _.isFunction 

# Make a short alias to _'s array maker
toArray = _.toArray 

# import sub-modules

###import "decorator.coffee" ###

Posture.Decorator = decorator

###import "signals.coffee" ###

Posture.Signals = signals

###import "accessors.coffee" ###

Posture.Accessors = accessors

###import "filters.coffee" ###

Posture.Filters = filters

###import "validators.coffee" ###

Posture.Validators = validators

Posture.enhance = 
  _default: (obj, ext_args...) ->
    if ext_args.length is 3
      new_obj = ext_args.pop()

    [protoProps, classProps] = ext_args
    obj = new_obj or obj
    if protoProps.signals and obj::signals
      protoProps.signals = signals.extend(protoProps.signals, obj::signals)
    ext_obj = obj.extend(ext_args...)
    signals.init(ext_obj)
    ext_obj

  Model: (obj, ext_args...) ->
    ext_obj = Posture.enhance._default(obj, ext_args...)
    accessors.init(ext_obj)
    ext_obj

  Collection: (obj, ext_args...) ->
    # Apply our collection enhancements 
    ext_obj = Posture.enhance._default(obj, ext_args...)
    ext_obj

  View: (obj, ext_args...) ->
    # Apply our view enhancements 
    ext_obj = Posture.enhance._default(obj, ext_args...)
    ext_obj

  Router: (obj, ext_args...) ->
    # Apply our router enhancements 
    ext_obj = Posture.enhance._default(obj, ext_args...)
    ext_obj

Posture.init = (Backbone) ->

  _.each Backbone, (obj, name) ->
    # Add Posture magic to Model.extend, Collection.extend, etc.
    if obj.extend and isFn(obj.extend) and Posture.enhance[name]?
      Posture[name].extend = (args...) -> 
        Posture.enhance[name](obj, args...)
            