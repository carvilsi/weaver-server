class CalculatorPlugin

  constructor: (@bus) ->
    console.log('yeah')

  init: ->
    console.log('All good')

module.exports = CalculatorPlugin
