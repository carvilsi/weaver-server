# Its better if this goes into a separate class
require('app-module-path').addPath("src/#{path}") for path in [
  '.'
  'admin'
  'application'
  'auth'
  'auth/schemas'
  'cli'
  'core'
  'database'
  'project'
  'util'
]

chai   = require('chai')
bus    = require('EventBus').get("testBus")
expect = require('util/bus').getExpect(bus)


describe "Bus Test", ->

  it 'should expect a given payload using the bus util', (done) ->

    expect('name').bus('person.create').do((req, res, name) ->
      chai.expect(name).to.equal('John')
      done()
    )

    bus.emit('person.create', {payload: name: 'John'})
    return


  it 'should raise an error with invalid payload using the bus util', (done) ->
    expect('name').bus('person.create').do((req, res, name) ->
    )

    bus.emit('person.create', {payload: age: 22}).catch((error) ->
      chai.expect(error.code).to.equal(-1)
      done()
    )
    return
