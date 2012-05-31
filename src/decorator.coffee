# Tests to see if our options object contains any of the appropriate functions for the decorator
noFuncs = (options) ->
  # If it does, return false
  return false for name in  ['before', 'after', 'wrap'] when options[name] and isFn(options[name] or null)
  # If it doesn't, return true
  return true

# Provides a Decorator pattern implementation for extending and wrapping Backbone objects and methods.

# **@param** _{object}_ options The options to configure the decorator

# Valid options are:

# * func:           the method or constructor that you want to decorate (Required)
# * before:         a function to be called prior to func with the same arguments (Optional)
# * after:          a function to be called after func with the same arguments (Optional)
# * wrap:           a function that accepts func as it first argument, wrapping and manipulating
#                   the return value (Optional) or the constructed object
# * context:        an object context to bind all of the functions above to when calling them
# * chain_returns:  the return value of each function (before, after, wrap) is appended to the
#                   arguments of the next function
decorator = (options) ->
  # If we have not been give a function to decorate or any decorator functions then squawk!
  if not options or not options.func or not isFn(options.func) or noFuncs(options) is true
    throw "A function to decorate and one or more of a before, after or wrapping function must be specified."

  # If we have a wrapper function, wrap our original function (FN) in an outer wrapper that takes the arguments
  # intended for FN and pushes FN onto the front of the arguments array and then calls the inner wrapper (options.wrap)
  if options.wrap and isFn options.wrap
    options.func = ((opts) ->
      (args...) ->
        args.unshift opts.func
        opts.wrap.apply opts.context or @, args
    )(options)


  # Here we build our final function/constructor that will stand in for the original.
  final_func = (args...) ->
    # Apply our before decorator (if it exists)
    before_return = options.before.apply @, args if options.before
    
    # If we are chaining, substitute before's return for the original arguments object
    if options.chain_returns
      orig_args = args
      args = before_return
    # Call the original or wrapped function, capturing it's output
    orig_return = options.func.apply(@, args)
    # If we are chaining returns, append the original or wrapped function's return to the original arguments
    if options.chain_returns
      args = orig_args.concat([orig_return])
    after_return =  if options.after then options.after.apply @, args else orig_return
    # If we are chaining returns, return the last return in the chain
    if options.chain_returns then after_return else orig_return
  final_func[options.indicator or '_is_decorated_'] = true
  # return a bound, decorated function if we have a binding context, else just return the deocorated function ###
  (if (options.context) then _.bind final_func, options.context else final_func)


# Convenience method to allow easy decoration of an object's methods. (Huh?)

# - **@param** _{object}_ obj         The object whose method we are decorating.
# - **@param** _{string}_ methodname  The name of the method that we are decorating.
# - **@param** _{object}_ options     An object containing the decorating configuration
decorator.decorateMethod = (obj, methodName, options) ->
  # If we are supposed to be working with the prototype, set obj to be obj's prototype
  if options.assignToProto and obj.prototype
    obj = obj::

  # If we have not been given an object or a method name or any decorator functions squawk! 
  if not obj or not methodName or not options or noFuncs(options)
    throw "decorateMethod requires an object and method name and one or more of before, after and wrap options"

  # Extend the options array with the additional func and context properties (if appropriate)
  _.extend options,
    func: obj[methodName] or ->
    context: (if (options.addContext is true) then obj else null)

  # decorate the method and return it
  obj[methodName] = decorator options
  return true
