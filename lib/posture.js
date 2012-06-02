var Posture, accessors, decorator, filters, isFn, noFuncs, root, signals, toArray, validators, _, _addPreAndPost, _camel, _posture_props, _prePost_default_methods;
var __slice = Array.prototype.slice, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
root = this;
if ((typeof exports !== "undefined" && exports !== null)) {
  Posture = exports;
} else {
  Posture = root.Posture = {};
}
_ = root._;
if (!_ && (typeof require !== "undefined" && require !== null)) {
  _ = require('underscore')._;
}
_posture_props = {
  Collection: {},
  Model: {},
  Router: {},
  View: {}
};
_.extend(Posture, _posture_props);
isFn = _.isFunction;
toArray = _.toArray;
noFuncs = function(options) {
  var name, _i, _len, _ref;
  _ref = ['before', 'after', 'wrap'];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    name = _ref[_i];
    if (options[name] && isFn(options[name] || null)) {
      return false;
    }
  }
  return true;
};
decorator = function(options) {
  var final_func;
  if (!options || !options.func || !isFn(options.func) || noFuncs(options) === true) {
    throw "A function to decorate and one or more of a before, after or wrapping function must be specified.";
  }
  if (options.wrap && isFn(options.wrap)) {
    options.func = (function(opts) {
      return function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        args.unshift(opts.func);
        return opts.wrap.apply(opts.context || this, args);
      };
    })(options);
  }
  final_func = function() {
    var after_return, args, before_return, orig_args, orig_return;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (options.before) {
      before_return = options.before.apply(this, args);
    }
    if (options.chain_returns) {
      orig_args = args;
      args = before_return;
    }
    orig_return = options.func.apply(this, args);
    if (options.chain_returns) {
      args = orig_args.concat([orig_return]);
    }
    after_return = options.after ? options.after.apply(this, args) : orig_return;
    if (options.chain_returns) {
      return after_return;
    } else {
      return orig_return;
    }
  };
  final_func[options.indicator || '_is_decorated_'] = true;
  if (options.context) {
    return _.bind(final_func, options.context);
  } else {
    return final_func;
  }
};
decorator.decorateMethod = function(obj, methodName, options) {
  if (options.assignToProto && obj.prototype) {
    obj = obj.prototype;
  }
  if (!obj || !methodName || !options || noFuncs(options)) {
    throw "decorateMethod requires an object and method name and one or more of before, after and wrap options";
  }
  _.extend(options, {
    func: obj[methodName] || function() {},
    context: (options.addContext === true ? obj : null)
  });
  obj[methodName] = decorator(options);
  return true;
};
Posture.Decorator = decorator;
Posture.Validator = validators;
_camel = function(prefix, suffix) {
  var suffixInitial, suffixRest;
  prefix = prefix.toLowerCase();
  suffixInitial = suffix[0].toUpperCase();
  suffixRest = suffix.substr(1);
  return "" + prefix + suffixInitial + suffixRest;
};
_prePost_default_methods = ['initialize', 'save', 'destroy', 'render', 'navigate'];
_addPreAndPost = function(obj, methodName) {
  var opts;
  if (obj.prototype[methodName].__has_pre_post__) {
    return null;
  }
  opts = {
    before: function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (methodName === 'initialize') {
        this._connectAll();
      }
      return this.signal.apply(this, [_camel('pre', methodName)].concat(__slice.call(args)));
    },
    after: function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.signal.apply(this, [_camel('post', methodName)].concat(__slice.call(args)));
    },
    assignToProto: true,
    indicator: '__has_pre_post__'
  };
  return decorator.decorateMethod(obj, methodName, opts);
};
signals = {
  extend: function(target, source) {
    var output;
    output = {};
    /* Iterate the source callbacks config */
    _.each(source, function(val, name) {
      /* 
      The first member of the is either a positional argument: 
      'before' or 'after' OR a callback. 
      */
      var callbacks, position, source_callbacks;
      position = (target[name] != null) && _.isArray(target[name]) && !isFn(target[name][0]) ? target[name].shift() : 'after';
      callbacks = target[name] || [];
      /* If target has this key in its config, then append or prepend source's callbacks as appropriate */
      if (target[name] != null) {
        source_callbacks = position === 'replace' ? [] : source[name];
        return output[name] = (position === 'after' ? source_callbacks : callbacks).concat(position === 'after' ? callbacks : source_callbacks);
      } else {
        /* If not, just copy source's callbacks */
        return output[name] = [].concat(source[name]);
      }
    });
    _.each(target, function(val, name) {
      if (!isFn(val[0] && _.isArray(val))) {
        val.shift();
      }
      if (!(source[name] != null) && val.length > 0) {
        return output[name] = val;
      }
    });
    return output;
  },
  connect: function(signal, callback, context) {
    if (context == null) {
      context = this;
    }
    /*
        Subscribe to a signal using Backbone.Event's bind
        @param {string} signal      The name of the signal
        @param {function} callback  The callback that we are binding to the signal
        @param {object} context     (optional) The 'this' for the callback
        */
    if (typeof signal === "string" && isFn(callback)) {
      return this.bind("signals:" + signal, callback, context);
    }
    throw "connect takes two arguments:\n1. signal: a string identifying the signal to listen for, and\n2. callback: a function to handle the signal\nArguments were signal: " + signal + " " + (signal.toString()) + " and callback " + callback;
  },
  signal: function() {
    var args, signal;
    signal = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    /**
    Publish a signal and it's arguments via Backbone.Event's trigger
    @param {string} signal  The name of the signal
    @param {array} args     The rest of the arguments
    */
    args.unshift(this);
    return this.trigger.apply(this, ["signals:" + signal].concat(__slice.call(args)));
  },
  connectAll: function() {
    /**
    Iterate the signal callback config (@signals) of this instance and connect callbacks to signals.
    @param: {object} A Backbone.Model, Backbone.Collection, Backbone.View or Backbone.Router instance
    */    if (this.signals) {
      return _.each(this.signals, function(list, signal) {
        var connected;
        connected = {};
        return _.each(list, function(callback) {
          if (isFn(callback)) {
            if (!_.has(connected[signal] || [], callback)) {
              this.connect(signal, callback);
              connected[signal] = connected[signal] || [];
              return connected[signal].push(callback);
            }
          }
        }, this);
      }, this);
    }
  },
  init: function(obj) {
    obj.prototype._connectAll = signals.connectAll;
    obj.prototype.connect = signals.connect;
    obj.prototype.signal = signals.signal;
    obj.prototype._has_signals_ = true;
    return _.each(_prePost_default_methods, function(methodName) {
      if (obj.prototype[methodName] && isFn(obj.prototype[methodName])) {
        return _addPreAndPost(obj, methodName);
      }
    });
  }
};
Posture.Signals = signals;
accessors = {
  init: function(obj) {
    return _.each(obj.prototype.defaults, function(val, name) {
      obj.prototype[name] = function(newVal, options, context) {
        var payload, to_return;
        if (context == null) {
          context = this;
        }
        switch (newVal) {
          case null:
          case void 0:
            to_return = this.get(name);
            break;
          case _:
            to_return = _(this.get(name)).chain();
            break;
          case 'subscribe':
            if (isFn(options)) {
              to_return = this.bind("change:" + name, options, context);
            } else {
              payload = {};
              payload[name] = newVal;
              to_return = this.set(payload, options);
            }
            break;
          case isFn(newVal):
            payload = {};
            payload[name] = !options || !options.func_is_val ? newVal() : newVal;
            to_return = this.set(payload, options);
            break;
          default:
            payload = {};
            payload[name] = newVal;
            to_return = this.set(payload, options);
        }
        return to_return;
      };
      return obj.prototype[name].accessorized = true;
    });
  }
};
Posture.Accessors = accessors;
filters = {
  integer: function(val, clean_first) {
    /**
    Converts a value to an integer. If the value cannot convert, returns 0.
    @param: {variable} val          Value to convert
    @param: {boolean} clean_first   Should we strip out non-numeric characters?
    */    val = !clean_first ? val : filters.regex(val, /[^\d\.]+/g, '');
    return parseInt(val);
  },
  decimal: function(val, clean_first) {
    /**
    Converts a value to an floating point number. If the value cannot convert, returns 0.
    @param: {variable} val          Value to convert
    @param: {boolean} clean_first   Should we strip out non-numeric characters?
    */    val = !clean_first ? val : filters.regex(val, /[^\d\.]+/g, '');
    return parseFloat(val);
  },
  alpha: function(val, allowwhitespace) {
    /**
    Remove any characters that are not a-z, A-Z or (optionally) white space characters.
    @param: {variable} val              Value to clean
    @param: {boolean} allowwhitespace   Should we leave white space characters?
    */
    var reg;
    reg = !allowwhitespace ? /[^a-zA-Z]/g : /[^a-zA-Z\s]/g;
    return filters.regex(val, reg, '');
  },
  alnum: function(val, allowwhitespace) {
    /**
    Remove any characters that are not a-z, A-Z, 0-9 or (optionally) white space characters.
    @param: {variable} val              Value to convert
    @param: {boolean} allowwhitespace   Should we leave white space characters?
    */
    var reg;
    reg = !allowwhitespace ? /[^\da-zA-Z]/g : /[^\da-zA-Z\s]/g;
    return filters.regex(val, reg, '');
  },
  to_json: function(val) {
    /**
    Converts the argument to a JSON representation.
    @param: {variable} val Value (string, number, object, array, etc.) to JSONify
    */    return JSON.stringify(val) || null;
  },
  trim: function(val) {
    /**
    Remove leading and/or trailing white space from a string.
    @param {string} val String to trim
    */    return filters.regex(val, /^\s+|\s+$/g, '');
  },
  regex: function(val, pattern, replacement, regex_args) {
    if (replacement == null) {
      replacement = '';
    }
    if (regex_args == null) {
      regex_args = null;
    }
    /**
    Base regex filter method.
    @param: {string} val                    String to run the regex filter on.
    @param: {string, regex} pattern         Expression to match
    @param: {string, function} replacement  Replacement string or replacer function
    @param: regex_args {string} regex_args  2nd arg for RegExp constructor, if pattern is a string.
    */
    pattern = _.isRegExp(pattern) ? pattern : new RegExp('' + pattern, regex_args);
    return ('' + val).replace(pattern, replacement);
  },
  bool: function(val, extended) {
    /**
    Convert value to boolean in a smarter way than ordinary JavaScript.
    @param: {variable} val Value to convert to a boolean
    */
    var _ref;
    if (_.isObject(val || _.isArray(val))) {
      return !_.isEmpty(val);
    }
    if (extended && ((_ref = ('' + val).toLowerCase()) === 'false' || _ref === 'no' || _ref === 'off' || _ref === 'null' || _ref === '0')) {
      return false;
    }
    return !!val;
  }
};
Posture.Filters = filters;
validators = {
  lessThan: function(val, max, allow_equal) {
    /**
    Tests that value is less than (or optionally equal to) a maximum value
    @param: {number} val            Value to be tested
    @param: {number} max            Maximum value
    @param: {boolean} allow_equal   Should allow val to equal max?
    */    if ((allow_equal && val <= max) || val < max) {
      return true;
    }
    throw new validators.NotLessThan(val, max);
  },
  greaterThan: function(val, min, allow_equal) {
    /**
    Tests that value is greater than (or optionally equal to) a minimum value
    @param: {number} val            Value to be tested
    @param: {number} min            Minimum value
    @param: {boolean} allow_equal   Should allow val to equal min?
    */    if (allow_equal && val >= min || val > min) {
      return true;
    }
    throw new validators.NotGreaterThan(val, min);
  },
  notEmpty: function(val) {
    /**
    Tests that value is not empty.
    @param: {variable} val Value to test for 'emptiness'
    */    if (!(_.isEmpty(val)) && val === !void 0) {
      return true;
    }
    throw new validators.IsEmpty(val);
  },
  decimalPlaces: function(val, places, msg) {
    var arr;
    if (places == null) {
      places = 2;
    }
    arr = Posture.Filter.trim('' + val).split('.');
    if (arr.length === 1) {
      return true;
    }
    if (arr.pop().length <= places) {
      return true;
    }
    throw new validators.Invalid(msg || ("'" + val + "' has too many decimal places! Only " + places + " are allowed."));
  },
  regex: function(val, pattern, msg) {
    var reg;
    reg = pattern instanceof RegExp ? pattern : new RegExp(pattern);
    if (reg.test(val)) {
      return true;
    }
    throw new validators.Invalid(msg || ("'" + val + "' does not fit the required pattern: " + reg));
  }
};
validators.Invalid = (function() {
  __extends(Invalid, Error);
  function Invalid(message) {
    this.message = message;
  }
  Invalid.prototype.toString = function() {
    if (isFn(this.message)) {
      return this.message();
    } else {
      return this.message;
    }
  };
  return Invalid;
})();
validators.NotLessThan = (function() {
  __extends(NotLessThan, validators.Invalid);
  function NotLessThan(val, max, message) {
    this.val = val;
    this.max = max;
    this.message = message != null ? message : null;
    if (!this.message) {
      this.message = "" + this.val + " is greater than the allowed maximum: " + this.max;
    }
  }
  return NotLessThan;
})();
validators.NotGreaterThan = (function() {
  __extends(NotGreaterThan, validators.Invalid);
  function NotGreaterThan(val, min, message) {
    this.val = val;
    this.min = min;
    this.message = message != null ? message : null;
    if (!this.message) {
      this.message = "" + this.val + " is less than the allowed minimum: " + this.max;
    }
  }
  return NotGreaterThan;
})();
validators.IsEmpty = (function() {
  __extends(IsEmpty, validators.Invalid);
  function IsEmpty(val, message) {
    this.val = val;
    this.message = message != null ? message : null;
    if (!this.message) {
      this.message = "'" + val + "' is empty";
    }
  }
  return IsEmpty;
})();
Posture.Validators = validators;
Posture.enhance = {
  _default: function() {
    var classProps, ext_args, ext_obj, new_obj, obj, protoProps;
    obj = arguments[0], ext_args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (ext_args.length === 3) {
      new_obj = ext_args.pop();
    }
    protoProps = ext_args[0], classProps = ext_args[1];
    obj = new_obj || obj;
    if (protoProps.signals && obj.prototype.signals) {
      protoProps.signals = signals.extend(protoProps.signals, obj.prototype.signals);
    }
    ext_obj = obj.extend.apply(obj, ext_args);
    signals.init(ext_obj);
    return ext_obj;
  },
  Model: function() {
    var ext_args, ext_obj, obj, _ref;
    obj = arguments[0], ext_args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    ext_obj = (_ref = Posture.enhance)._default.apply(_ref, [obj].concat(__slice.call(ext_args)));
    accessors.init(ext_obj);
    return ext_obj;
  },
  Collection: function() {
    var ext_args, ext_obj, obj, _ref;
    obj = arguments[0], ext_args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    ext_obj = (_ref = Posture.enhance)._default.apply(_ref, [obj].concat(__slice.call(ext_args)));
    return ext_obj;
  },
  View: function() {
    var ext_args, ext_obj, obj, _ref;
    obj = arguments[0], ext_args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    ext_obj = (_ref = Posture.enhance)._default.apply(_ref, [obj].concat(__slice.call(ext_args)));
    return ext_obj;
  },
  Router: function() {
    var ext_args, ext_obj, obj, _ref;
    obj = arguments[0], ext_args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    ext_obj = (_ref = Posture.enhance)._default.apply(_ref, [obj].concat(__slice.call(ext_args)));
    return ext_obj;
  }
};
Posture.init = function(Backbone) {
  return _.each(Backbone, function(obj, name) {
    if (obj.extend && isFn(obj.extend) && (Posture.enhance[name] != null)) {
      return Posture[name].extend = function() {
        var args, _ref;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return (_ref = Posture.enhance)[name].apply(_ref, [obj].concat(__slice.call(args)));
      };
    }
  });
};