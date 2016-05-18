require("../test-suite")()
fs = require('fs')
WeaverServer = require('../../src/index')
VirtuosoConnector  = require('weaver-connector-virtuoso')
Promise = require('bluebird')

describe 'Create an object using Virtuoso connector', ->

  server = null

  json = null


  before ->


    json = fs.readFileSync('./test/virtuoso/bas.json', 'utf8')          # todo make more dymamically powerful


    server = new WeaverServer("localhost:6379", {
      wipeEnabled: true
    })


    virtuosoConnector = new VirtuosoConnector({
      host:'192.168.99.100'
      port:'1111'
      user:'dba'
      password:'myDbaPassword'
      graph:'http://weaver-connector-virtuoso/test#'
      wipeEnabled: true
    })
    server.setConnector(virtuosoConnector)







  # for a description of the payload see
  # https://github.com/weaverplatform/weaverplatform/blob/master/weaver-sdk-payloads.md


  it 'Wipe', ->

    server.operations.wipe().should.be.fulfilled





  it 'Bootstrap', ->


    server.operations.bootstrapFromJson(json).should.be.fulfilled


  it 'Create', ->

    payload = {"type":"$INDIVIDUAL","id":"cimm01hj800043k5bz527ys3x","data":{"name":"mo"}}

    server.operations.create(payload).then(

      # resolved
      ->
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )



  it 'Read', ->

    payload = {"id":"cimm01hj800043k5bz527ys3x", "opts": { "eagerness": "-1" }}

    object = server.operations.read(payload).then(

      # resolved
      (result) ->
        console.log(result)
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )




  it 'Update', ->

    payload = {"id":"cimm01hj800043k5bz527ys3x","attribute":"name", "value":"bosss"}

    server.operations.update(payload).then(

      # resolved
      ->
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )




  it 'Set new value', ->

    payload = {"id":"cimm01hj800043k5bz527ys3x","attribute":"language", "value":"spanish"}

    server.operations.update(payload).then(

      # resolved
      ->
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )

  it 'Read', ->

    payload = {"id":"cimm01hj800043k5bz527ys3x", "opts": { "eagerness": "-1" }}

    server.operations.read(payload).then(

      # resolved
      (result) ->
        console.log(result)
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )




  it 'Destroy Attribute', ->

    payload = {"id":"cimm01hj800043k5bz527ys3x","attribute":"language"}

    server.operations.destroyAttribute(payload).then(

      # resolved
      ->
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )

  it 'Read', ->

    payload = {"id":"cimm01hj800043k5bz527ys3x", "opts": { "eagerness": "-1" }}

    server.operations.read(payload).then(

      # resolved
      (result) ->
        console.log(result)
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )




  it 'Link', ->

    payload = {"source":{"id":"ciocv9q0w00023k6mf1tloaof"},"key":"hasfriend","target":{"id":"cimm01hj800043k5bz527ys3x"}}      # todo: wrong, should be member of collection properties

    server.operations.link(payload).then(

      # resolved
      ->
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )

  it 'Read', ->

    payload = {"id":"ciocv9q0w00023k6mf1tloaof", "opts": { "eagerness": "-1" }}

    server.operations.read(payload).then(

      # resolved
      (result) ->
        console.log(result)
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )




  it 'Unlink', ->

    payload = {"id":"ciocv9q0w00023k6mf1tloaof","key":"hasfriend"}

    server.operations.unlink(payload).then(

      # resolved
      ->
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )

  it 'Read', ->

    payload = {"id":"ciocv9q0w00023k6mf1tloaof", "opts": { "eagerness": "-1" }}

    server.operations.read(payload).then(

      # resolved
      (result) ->
        console.log(result)
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )




  it 'Destroy', ->

    payload = {"id":"cimm01hj800043k5bz527ys3x"}

    server.operations.destroyEntity(payload).then(

      # resolved
      ->
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )





  it 'Dump', ->


    server.operations.dump().then(

      # resolved
      (result)->
        console.log(result)



      # rejected
      (error) ->
        console.log(error)
    )



