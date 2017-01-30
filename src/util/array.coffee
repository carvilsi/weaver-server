module.exports = 
  
  # Returns the length of the element that has the highest length of all elements
  maxLength: (array) ->
    max = -1
    max = element.length for element in array when element.length > max
    max