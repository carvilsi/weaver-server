module.exports =
  class Model extends require('./../default.entity')

    getEntityIdentifier: ->
      'model'

    getDependencyIdentifiers: ->
      nameAttributes: require('./../dataset/attribute.entity')
      attributes: require('./../dataset/attribute.entity')
      objects: require('./../dataset/object.entity')
      supertypes: require('./../dataset/model.entity')
      subtypes: require('./../dataset/model.entity')
