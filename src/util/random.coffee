# Generate random types
module.exports = 
  
  integer: (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min