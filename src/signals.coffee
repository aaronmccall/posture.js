# TODO: package level docs!
Posture.Validator = validators
_camel = (prefix, suffix) ->
  prefix = prefix.toLowerCase()
  suffixInitial = suffix[0].toUpperCase()
  suffixRest = suffix.substr(1)
  "#{prefix}#{suffixInitial}#{suffixRest}"

_prePost_default_methods = ['initialize', 'save', 'destroy', 'render', 'navigate']

_addPreAndPost = (obj, methodName) ->
  opts = 
    before: (args...) ->
      if methodName == 'initialize'
        @_connectAll()
      @signal(_camel('pre', methodName), args...)
    after: (args...) ->
      @signal(_camel('post', methodName), args...)
    assignToProto: yes

  decorator.decorateMethod(obj, methodName, opts)

signals =

# Used when extending the signals config of one object with additional callbacks

# * @param: {object} target A map of signal name: [ array of callbacks ]
# * @param: {object} source A map of signal name: [ array of callbacks ]
# * @example

# ```javascript
#    app.Soup = app.Food.extend({
#        signals: {
#            preInit: [
#                'before',
#                function(attrs){ if (attrs.broth && attrs.broth === 'beef') alert('Tasty!') }
#            ]
#        }
#    });
# ```

# When Posture extends Food's signals with Soup's signals, it will prepend Soup's preInit rather than appending it.
 extend: (target, source) ->

    output = {}

    ### Iterate the source callbacks config ###
    _.each source, (val, name)->
      ### The first member of the is either a positional argument: 'before' or 'after' OR a callback. ###
      position = if target[name]? and _.isArray(target[name]) and not isFn target[name][0] then target[name].shift() else 'after'
      after = position is 'after'
      callbacks = target[name] or []

      ### If target has this key in its config, then append or prepend source's callbacks as appropriate ###
      if target[name]?
        output[name] = (if after then source[name] else callbacks).concat(if after then callbacks else source[name])
      else
        ### If not, just copy source's callbacks ###
        output[name] = [].concat(source[name])

    _.each target, (val, name) ->
      if not isFn val[0] and _.isArray val
        val.shift()
      if not source[name]? and val.length > 0
        output[name] = val

    output

  connect: (signal, callback, context=@) ->
    ###
    Subscribe to a signal using Backbone.Event's bind
    @param {string} signal      The name of the signal
    @param {function} callback  The callback that we are binding to the signal
    @param {object} context     (optional) The 'this' for the callback
    ###
    if typeof signal == "string" and isFn(callback)
      return @bind("signals:#{signal}", callback, context)
    throw """
    connect takes two arguments:
    1. signal: a string identifying the signal to listen for, and
    2. callback: a function to handle the signal
    Arguments were signal: #{signal} #{signal.toString()} and callback #{callback}
    """

  signal: (signal, args...) ->
    ###*
    Publish a signal and it's arguments via Backbone.Event's trigger
    @param {string} signal  The name of the signal
    @param {array} args     The rest of the arguments
    ###
    @trigger("signals:#{signal}", args...)

  connectAll: ->
    ###*
    Iterate the signal callback config (@signals) of this instance and connect callbacks to signals.
    @param: {object} A Backbone.Model, Backbone.Collection, Backbone.View or Backbone.Router instance
    ###
    if @signals
      _.each @signals, (list, signal) ->
        connected = 0
        _.each list, (callback) ->
          if isFn callback
            connected++
            @connect signal, callback
        , @
      , @

  init: (obj) ->
    obj::_connectAll = signals.connectAll
    obj::connect = signals.connect
    obj::signal = signals.signal
    obj::_has_signals_ = true
    _.each _prePost_default_methods, (methodName) ->
      if obj::[methodName] and isFn obj::[methodName]
        _addPreAndPost(obj, methodName)

