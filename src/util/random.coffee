# Generate random types
module.exports =

  # Returns a random integer between min (inclusive) and max (inclusive)
  # Using Math.round() will give you a non-uniform distribution!
  integer: (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min