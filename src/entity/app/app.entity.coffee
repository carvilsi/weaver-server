module.exports =
  class App extends require('./../default.entity')

    getEntityIdentifier: ->
      'app'

    getDependencyIdentifiers: ->
      views: require('./../app/view.entity')
      variables: require('./../app/variable.entity')
      behaviours: require('./../flow/behaviour.entity')
      styles: require('./../app/style.entity')
