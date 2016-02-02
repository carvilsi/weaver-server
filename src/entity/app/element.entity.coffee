module.exports =
  class Element extends require('./../default.entity')

    getEntityIdentifier: ->
      'element'

    getDependencyIdentifiers: ->
      styles: require('./../app/style.entity')
      conditionalStyles: require('./../app/style.entity')
      elements: require('./../app/element.entity')