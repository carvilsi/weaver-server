test = require('./test-suite')()
ClientVersionChecker = require('../src/core/SDKVersionChecker')

describe 'The version checker', ->
  it 'should instantiate', ->
    expect(new ClientVersionChecker('1.1.1')).to.be.defined

  it 'should reject invalid version on creation', ->
    try
      new ClientVersionChecker('1.asd1.1')
      assert.fail()
    catch err
  
  it 'should use the defined version to compare against if none is provided', ->
    checker = new ClientVersionChecker()
    expect(checker.serverVersion).to.be.defined

  describe 'given an instance', ->
    before ->
      @checker = new ClientVersionChecker('2.2.2')

    it 'should accept lower SDK versions', ->
      expect(@checker.isValidSDKVersion('1.0.0')).to.be.true
      expect(@checker.isValidSDKVersion('2.1.0')).to.be.true
      expect(@checker.isValidSDKVersion('2.2.0')).to.be.true
    
    it 'should accept equal SDK versions', ->
      expect(@checker.isValidSDKVersion('1.0.0')).to.be.true

    it 'should accept higher SDK versions', ->
      expect(@checker.isValidSDKVersion('3.0.0')).to.be.true
      expect(@checker.isValidSDKVersion('2.3.0')).to.be.true
      expect(@checker.isValidSDKVersion('2.2.3')).to.be.true
    
    it 'should return false when checking undefined', ->
      expect(@checker.isValidSDKVersion(undefined)).to.be.false

    it 'should work for rc versions', ->
      expect(@checker.isValidSDKVersion('2.2.5-rc.1')).to.be.true


