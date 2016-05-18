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
  "data": {
  }
}
```

## read

```json
{
  "_META": {  },
  "_ATTRIBUTES": {

    "key": "value"

  }
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
