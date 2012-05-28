accessors =
  init:  (obj)->
    # Creates a Posture.Accessor function for each member of the Backbone Model's defaults object
    # @param {object} obj the Backbone Model object to apply the accessor function
    _.each obj::defaults, (val, name) ->
      obj::[name] = (newVal, options, context=@) ->
        # @param {variable} newVal            optional argument that drives the branching logic
        # @param {object, function} options   May be an options object or a callback function
        # @param {object} context             An object context to be the 'this' for a callback function
        switch newVal
          when null, undefined
            # If no arguments are defined, return the attribute of the same name
            to_return = @get(name)
          when _
            # If the first argument is Underscore, wrap the attribute of the same name
            # in the _.chain wrapper
            to_return = _(@get(name)).chain()
          when 'subscribe'
            if isFn options
              # If the 1st arg is 'subscribe' AND the 2nd arg is a function then we are registering a
              # change callback (optionally in the context of the 3rd arg)
              to_return = @bind("change:#{name}", options, context)
            else
              # Otherwise, we are doing an ordinary set to the attribute of the same name
              payload = {}
              payload[name] = newVal
              to_return = @set(payload, options)
          when isFn newVal
            # If the 1st arg is a function AND options.func_is_val is truthy, then set the value of
            # attribute of the to be the function. Otherwise, set it to the return value of the function.
            payload = {}
            payload[name] = if (not options or not options.func_is_val) then newVal() else newVal
            to_return = @set(payload, options)
          else
            payload = {}
            payload[name] = newVal
            to_return = @set(payload, options)

        to_return

      obj::[name].accessorized = true