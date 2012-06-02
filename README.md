# What is posture.js?

It is a set of conventions and helpers to make data-driven Backbone apps to stand tall and run strong!

# How does it support Backbone?

By providing:

* __Signals__: 
  A concept borrowed from Python's Django framework, signals are pre-determined events related to the object's lifecycle. For instance, a Model has three important events in its lifecycle: initialize, save, and destroy. With signals, we can hook other logic into the lifecycle immediately before or after any of these events.

  An example:
  ```javascript
    var Dinner = Posture.Model.extend({
        defaults: {
            ready: 'Dinner is ready!',
        },
        signals: {
              postInitialize: [
                  function () { this.trigger('ready', this.get('ready')) }
              ]
        },
        initialize: function () {
            this.bind('ready', function (msg) { console.log(msg) });
        }
    });

  // calling `new Dinner` should log "Dinner is ready!"

  # Now let's make a new kind of dinner with a different ready message.
    var Zuppe = Posture.Model.extend({
        defaults: {
            ready: "Soup's on!"
        },
        initialize: function () {
            this.bind('ready', function (msg) { console.log(msg + " Come and get it!") });
        }
    }, null, Dinner);

  // calling `new Zuppe` should log "Soup's on! Come and get it!"
  ```

  This is a very simple (and not terribly useful) example, but it does illustrate that you can create modular functionality that is extendable and flexible. 

  If you extend a constructor that already has signals defined (as Zuppe did), you can pass a positional directive as the first member of the callback list for any given signal.

  For example, we could have defined Zuppe like so:
  ```javascript
    var Zuppe = Posture.Model.extend({
        defaults: {
            ready: "Soup's on!"
        },
        signals: {
              postInitialize: [
                  'replace',
                  function () { this.trigger('ready', this.get('ready') + " Come and get it!") }
              ]
        },
    }, null, Dinner);
    ```