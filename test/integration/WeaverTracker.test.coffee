WeaverTracker    = require('./../../src/tracker/Tracker')


describe 'Weaver Tracker test', ->
  
  it 'should connect to the mysqldb', ->
    tracker = new WeaverTracker()
    tracker.initDb()
    .then((res) ->
      console.log(res)

#    tracker.test()
#    ).then((res) ->
#      console.log(res)
    )
    