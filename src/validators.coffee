validators =

  lessThan: (val, max, allow_equal) ->
    ###*
    Tests that value is less than (or optionally equal to) a maximum value
    @param: {number} val            Value to be tested
    @param: {number} max            Maximum value
    @param: {boolean} allow_equal   Should allow val to equal max?
    ###
    if (allow_equal and val <= max) or val < max
      return true

    throw new validators.NotLessThan(val, max)

  greaterThan: (val, min, allow_equal) ->
    ###*
    Tests that value is greater than (or optionally equal to) a minimum value
    @param: {number} val            Value to be tested
    @param: {number} min            Minimum value
    @param: {boolean} allow_equal   Should allow val to equal min?
    ###
    if allow_equal and val >= min or val > min
      return true

    throw new validators.NotGreaterThan(val, min)

  notEmpty: (val) ->
    ###*
    Tests that value is not empty.
    @param: {variable} val Value to test for 'emptiness'
    ###
    if (_.isNumber(val) and not _.isNaN(val)) or (not _.isEmpty(val) and val is not undefined)
      return true

    throw new validators.IsEmpty(val)

  decimalPlaces: (val, places=2, msg) ->
    arr = Posture.Filter.trim(''+val).split('.')
    return true if arr.length is 1
    return true if arr.pop().length <= places
    throw new validators.Invalid(msg or "'#{val}' has too many decimal places! Only #{places} are allowed.")

  regex: (val, pattern, msg) ->
    reg = if pattern instanceof RegExp then pattern else new RegExp(pattern)
    return true if reg.test(val)
    throw new validators.Invalid(msg or "'#{val}' does not fit the required pattern: #{reg}")


class validators.Invalid extends Error
  constructor: (@message) ->

  toString: ->
    if isFn @message then @message() else @message

class validators.NotLessThan extends validators.Invalid
  constructor: (@val, @max, @message=null) ->
    unless @message
      @message = "#{@val} is greater than the allowed maximum: #{@max}"

class validators.NotGreaterThan extends validators.Invalid
  constructor: (@val, @min, @message=null) ->
    unless @message 
      @message = "#{@val} is less than the allowed minimum: #{@max}"

    

class validators.IsEmpty extends validators.Invalid

  constructor: (@val, @message=null) ->
    unless @message
      @message = "'#{val}' is empty"
