Router = require('./router')

# This is the main entry point of any new socket connection.
module.exports =
  wire: (socket) ->

    # Route function taking path, key and operation
    route = Router(socket)

    # Route paths
    core     = route('core')
    app      = route('app')
    dataset  = route('dataset')
    flow     = route('flow')
    email    = route('email')

    # Auth
    core 'auth','signup'
    core 'auth','signinToken'
    core 'auth','signinUsername'

    # Organization
    core 'organization','create'
    core 'organization','update'
    core 'organization','delete'
    core 'organization','add'
    core 'organization','remove'

    # User
    core 'user','create'
    core 'user','update'
    core 'user','delete'
    core 'user','add'
    core 'user','remove'

    # Session
    core 'session','create'
    core 'session','update'
    core 'session','delete'

    # Workspace
    core 'workspace','create'
    core 'workspace','update'
    core 'workspace','delete'
    core 'workspace','add'
    core 'workspace','remove'

    # Project
    core 'project','create'
    core 'project','update'
    core 'project','delete'
    core 'project','add'
    core 'project','remove'

    # Dataset
    dataset 'dataset','create'
    dataset 'dataset','update'
    dataset 'dataset','delete'
    dataset 'dataset','add'
    dataset 'dataset','remove'

    # App
    app 'app','create'
    app 'app','read'
    app 'app','update'
    app 'app','delete'
    app 'app','add'
    app 'app','remove'

    # Model
    dataset 'model','create'
    dataset 'model','read'
    dataset 'model','delete'
    dataset 'model','update'
    dataset 'model','add'
    dataset 'model','remove'

    # Object
    dataset 'object','create'
    dataset 'object','delete'
    dataset 'object','update'
    dataset 'object','add'
    dataset 'object','remove'

    # Attribute
    dataset 'attribute','create'
    dataset 'attribute','delete'
    dataset 'attribute','update'

    # Property
    dataset 'property','create'
    dataset 'property','delete'
    dataset 'property','update'
    dataset 'property','add'
    dataset 'property','remove'

    # View
    app 'view','create'
    app 'view','delete'
    app 'view','update'
    app 'view','add'
    app 'view','remove'

    # Element
    app 'element','create'
    app 'element','delete'
    app 'element','update'
    app 'element','add'
    app 'element','remove'

    # Style
    app 'style','create'
    app 'style','delete'
    app 'style','update'

    # Variable
    app 'variable','create'
    app 'variable','update'
    app 'variable','delete'
    app 'variable','add'
    app 'variable','remove'

    # Behaviour
    flow 'behaviour','create'
    flow 'behaviour','update'
    flow 'behaviour','delete'
    flow 'behaviour','add'
    flow 'behaviour','remove'

    # Flow
    flow 'flow','create'
    flow 'flow','update'
    flow 'flow','delete'
    flow 'flow','add'
    flow 'flow','remove'

    # Function
    flow 'function','create'
    flow 'function','update'
    flow 'function','delete'
    flow 'function','add'
    flow 'function','remove'

    # Component
    flow 'component','create'
    flow 'component','update'
    flow 'component','delete'
    flow 'component','add'
    flow 'component','remove'

    # Argument
    flow 'argument','create'
    flow 'argument','update'
    flow 'argument','delete'

    # Inport
    flow 'inport','create'
    flow 'inport','update'
    flow 'inport','delete'

    # Outport
    flow 'outport','create'
    flow 'outport','update'
    flow 'outport','delete'

    # Trigger
    flow 'trigger','create'
    flow 'trigger','update'
    flow 'trigger','delete'

    # Connection
    flow 'connection','create'
    flow 'connection','update'
    flow 'connection','delete'

    # Environment
    core 'environment','create'
    core 'environment','update'
    core 'environment','delete'
    core 'environment','read'
    core 'environment','add'
    core 'environment','remove'

    # Email
    email 'email','send'