module.exports =
  class Object extends require('./../default.entity')

    getEntityIdentifier: ->
      'object'

    getDependencyIdentifiers: ->
      properties: require('./../dataset/property.entity')

      # TODO
      #relations: require('./../relation.entity')
      #supertypes: require('./../supertype.entity')
      #subtypes: require('./../subtype.entity')


# How will lazy loading work? -> no lazy loading? large dataset in memory?
#
# - A dataset will load its models, all the models
# - Upon opening a model, the model loads all the objects?