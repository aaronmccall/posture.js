filters =
  integer: (val, clean_first) ->
    ###*
    Converts a value to an integer. If the value cannot convert, returns 0.
    @param: {variable} val          Value to convert
    @param: {boolean} clean_first   Should we strip out non-numeric characters?
    ###
    val = if not clean_first then val else filters.regex(val, /[^\d\.]+/g, '')
    parseInt(val) or 0

  decimal: (val, clean_first) ->
    ###*
    Converts a value to an floating point number. If the value cannot convert, returns 0.
    @param: {variable} val          Value to convert
    @param: {boolean} clean_first   Should we strip out non-numeric characters?
    ###
    val = if not clean_first then val else filters.regex(val, /[^\d\.]+/g, '')
    parseFloat(val) or 0

  alpha: (val, allowwhitespace) ->
    ###*
    Remove any characters that are not a-z, A-Z or (optionally) white space characters.
    @param: {variable} val              Value to clean
    @param: {boolean} allowwhitespace   Should we leave white space characters?
    ###
    reg = if not allowwhitespace then /[^a-zA-Z]/g else /[^\sa-zA-Z]/g
    filters.regex(val, reg, '')

  alnum: (val, allowwhitespace) ->
    ###*
    Remove any characters that are not a-z, A-Z, 0-9 or (optionally) white space characters.
    @param: {variable} val              Value to convert
    @param: {boolean} allowwhitespace   Should we leave white space characters?
    ###
    reg = if not allowwhitespace then /^\da-zA-Z/g else /^\da-zA-Z\s/g
    filters.regex(val, reg, '')

  to_json: (val) ->
    ###*
    Converts the argument to a JSON representation.
    @param: {variable} val Value (string, number, object, array, etc.) to JSONify
    ###
    JSON.stringify(val) or null

  trim: (val) ->
    ###*
    Remove leading and/or trailing white space from a string.
    @param {string} val String to trim
    ###
    filters.regex(val, /^\s+|\s+$/g, '')

  regex: (val, pattern, replacement, regex_args) ->
    ###*
    Base regex filter method.
    @param: {string} val                    String to run the regex filter on.
    @param: {string, regex} pattern         Expression to match
    @param: {string, function} replacement  Replacement string or replacer function
    @param: regex_args {string} regex_args  2nd arg for RegExp constructor, if pattern is a string.
    ###
    pattern = if _.isRegExp pattern then pattern else new RegExp(''+pattern, regex_args)
    ('' + val).replace(pattern, replacement)

  bool: (val) ->
    ###*
    Convert value to boolean in a smarter way than ordinary JavaScript.
    @param: {variable} val Value to convert to a boolean
    ###
    return !_.isEmpty(val) if _.isObject val or _.isArray val
    return false if (''+val).toLowerCase() in ['false', 'no', 'off', 'null', '0']
    !!val
