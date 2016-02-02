module.exports =
  class Workspace extends require('./../default.entity')

    getEntityIdentifier: ->
      'workspace'

    getDependencyIdentifiers: ->
      projects: require('./../core/project.entity')
