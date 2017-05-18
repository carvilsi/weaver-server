[![Build Status](https://secure.travis-ci.org/weaverplatform/weaver-server.png?branch=master)](http://travis-ci.org/weaverplatform/weaver-server)[![codecov](https://codecov.io/gh/weaverplatform/weaver-server/branch/master/graph/badge.svg)](https://codecov.io/gh/weaverplatform/weaver-server)
# weaver-server
Weaver-compatible API server module for Node/Express


# Weaver SDK payloads

Currently two SDK's can be used to input data to de Weaver Platform:

  * weaver-sdk-js
  * weaver-sdk-java
  
The format the payload these SDK's produce is documented on this page. They directly represent the [operations](https://github.com/weaverplatform/weaver-server/blob/master/src/operations.coffee) in the weaver-server module.

## create

```json
{
  "id" : "",
  "type": "",
  "attributes": {
  }
}
```

## read

```json
{
  "_META": {  },
  "_ATTRIBUTES": {

    "key": "value"

  },
  "_RELATIONS": {

    "1234": {

        "_META": {},
        "_ATTRIBUTES": {},
        "_RELATIONS":{}

    }

   }
}
```

## update

```json
{
  "id": "",
  "attribute": "",
  "value": ""
}
```

## destroyAttribute
```json
{
  "id": "",
  "attribute": ""
}
```

## destroyEntity
```json
{
  "id":""
}
```

## link
```json
{
  "source": {
    "id": "",
    "type": "",
    "fetched": "true",
    "attributes": {},
    "relations": {}
  },
  "key": "",
  "target": {}
}
```

## unlink
```json
{
  "id": "",
  "key": ""
}
```

## populate

## wipe

no payload

## dump

no payload

## bootstrapFromUrl

there are two options
```json
{
  "url": "http://__.json" 
}
```

## bootstrapFromJson

```json
[

  {
    "id": "cuid...",
    "action": "create",
    "payload": "{...}"
  },
  
  etc.
] 

```

# Docker composes

## weaver-server development dependencies
In order to run all dependencies for the default configuration values of
a weaver-server running outside of a container:
```
docker-compose up
```

## usable weaver-server 
For a fully functional weaver-server for non-development purposes, check out
the test-server setup in the weaver-sdk-js repo, which contains a automatically
tested docker composition for client usage.
