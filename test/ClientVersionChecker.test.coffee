test = require('./test-suite')()
ClientVersionChecker = require('../src/core/ClientVersionChecker')

describe 'The version checker', ->
  it 'should instantiate', ->
    expect(new ClientVersionChecker('1.1.1')).to.be.defined

  it 'should reject invalid version on creation', ->
    try
      new ClientVersionChecker('1.asd1.1')
      assert.fail()
    catch err
  
  it 'should use the defined sensor version to compare against if none is provided', ->
    checker = new ClientVersionChecker()
    expect(checker.serverVersion).to.be.defined
  
  it 'should use the defined connector version to compare against if none is provided', ->
    checker = new ClientVersionChecker()
    checker.getVersion()
    .then( (version)->
      expect(version).to.not.be.undefined
    )

  describe 'given an instance', ->
    before ->
      @checker = new ClientVersionChecker('2.2.2', '3.2.1')

    describe 'should check sdk versions for', ->
      it 'defined', ->
        expect(@checker.isValidSDKVersion('1.0.0')).to.be.true
        expect(@checker.isValidSDKVersion('2.2.0')).to.be.true
        expect(@checker.isValidSDKVersion('3.2.0')).to.be.true
        expect(@checker.isValidSDKVersion('3.2.0-rc.1')).to.be.true

      it 'undefined', ->
        expect(@checker.isValidSDKVersion(undefined)).to.be.false

    describe 'should check weaver-server-requirement', ->
      it 'should accept undefined server versions', ->
        expect(@checker.serverSatisfies(undefined)).to.be.true

      it 'should accept server version requirements it satisfies', ->
        expect(@checker.serverSatisfies('2.2.2')).to.be.true

      it 'should deny server version requirements it doesnt satisfy', ->
        expect(@checker.serverSatisfies('1.2.3')).to.be.false

    describe 'should check weaver-connector-version', ->
      it 'should accept undefined connector versions', ->
        expect(@checker.connectorSatisfies(undefined)).to.be.true

      it 'should accept connector version requirements it satisfies', ->
        expect(@checker.connectorSatisfies('3.2.1')).to.be.true

      it 'should deny connector version requirements it doesnt satisfy', ->
        expect(@checker.connectorSatisfies('3.2.0')).to.be.false
