// Generated by CoffeeScript 1.10.0
(function() {
  module.exports = function(bus) {
    bus["private"]("getBase").on(function(req) {
      return "Base-10";
    });
    bus["private"]('add').require('x', 'y').on(function(req, x, y) {
      return x + y;
    });
    return bus["private"]('subtract').require('x', 'y').on(function(req, x, y) {
      return x - y;
    });
  };

}).call(this);
