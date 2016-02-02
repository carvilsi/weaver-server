module.exports =
  class Property extends require('./../default.entity')

    getEntityIdentifier: ->
      'property'

    getDependencyIdentifiers: ->
      # TODO: Move to value as attributeId
      attributes: require('./../dataset/attribute.entity')