module.exports =
  class View extends require('./../default.entity')

    getEntityIdentifier: ->
      'view'

    getDependencyIdentifiers: ->
      elements: require('./../app/element.entity')
      styles: require('./../app/style.entity')