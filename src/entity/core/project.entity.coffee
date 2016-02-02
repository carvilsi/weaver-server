redis = new require('ioredis')()

module.exports =
  class Project extends require('./../default.entity')

    getEntityIdentifier: ->
      'project'

    getDependencyIdentifiers: ->
      datasets: require('./../dataset/dataset.entity')
      apps: require('./../app/app.entity')