module.exports =
  class Dataset extends require('./../default.entity')

    getEntityIdentifier: ->
      'dataset'

    getDependencyIdentifiers: ->
      models: require('./../dataset/model.entity')