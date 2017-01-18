module.exports =
  newUserCredentials:
    type: 'object'
    required: ['userEmail','userPassword','userName','directoryName']
    properties:
      directoryName:
        type: 'string'
        description: 'Directory name.'
      userName:
        type: 'string'
        description: 'User name.'
      userEmail:
        type: 'string'
        description: 'User email address'
      userPassword:
        type: 'string'
        description: 'User password.'
  userCredentials:
    type: 'object'
    required: ['user','password']
    properties:
      user:
        type: 'string'
        description: 'The name for the user'
      password:
        type: 'string'
        description: 'The secret phrase for the user'
  newApplication:
    type: 'object'
    required: ['applicationName','projectName','accessToken']
    properties:
      applicationName:
        type: 'string'
        description: 'Name for the application'
      projectName:
        type: 'string'
        description: 'Name for the project'
      accessToken:
        type: 'string'
        description: 'jwt kind'