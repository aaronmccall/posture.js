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

  # calling new Dinner() should log 'Dinner is ready!'

  # Now let's make a new kind of dinner with a different ready message.
  var Zuppe = Posture.Model.extend({
    defaults: {
      ready: "Soup's on!"
    }
  }, null, Dinner);
  ```