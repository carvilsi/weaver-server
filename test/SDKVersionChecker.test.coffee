test = require('./test-suite')()
SDKVersionChecker = require('../src/core/SDKVersionChecker')

describe 'The version checker', ->
  it 'should instantiate', ->
    expect(new SDKVersionChecker('1.1.1')).to.be.defined

  it 'should reject invalid version on creation', ->
    try
      new SDKVersionChecker('1.asd1.1')
      assert.fail()
    catch err

  it 'should reject lower SDK versions', ->
    checker = new SDKVersionChecker('1.0.0')
    expect(checker.isValidSDKVersion('0.9.0')).to.be.false

  it 'should accept equal SDK versions', ->
    checker = new SDKVersionChecker('1.0.0')
    expect(checker.isValidSDKVersion('1.0.0')).to.be.true

  it 'should accept higher SDK versions', ->
    checker = new SDKVersionChecker('1.0.0')
    expect(checker.isValidSDKVersion('1.0.1')).to.be.true
    expect(checker.isValidSDKVersion('2.0.0')).to.be.true
    expect(checker.isValidSDKVersion('1.1.0')).to.be.true

  it 'should use the embedded SDK version to compare against', ->
    checker = new SDKVersionChecker()
    expect(checker.serverVersion).to.be.defined
  
  it 'should return false when checking undefined', ->
    checker = new SDKVersionChecker()
    expect(checker.isValidSDKVersion(undefined)).to.be.false


