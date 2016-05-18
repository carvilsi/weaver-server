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
  id : "",
  type: "";
  data: {

    key: value,
    key: "value"

  }
}
```

## read

```json
{
  _META: {  }
  _ATTRIBUTES: {

    key: value

  }
  _RELATIONS: {

    1234: {

        _META: {}
        _ATTRIBUTES {}
        _RELATIONS{}

    }

   }
}
```

## update

```json
{
  id: "",
  attribute: "",
  value: ""
}
```

## destroyAttribute 

## destroyEntity

## link

## unlink

## populate

## wipe

no payload

## dump

no payload

## bootstrap

there are two options
```json
{
  "fromUrl": "http://__.json" 
}
```

or

```json
{
  "fromLog": [
  
    {
      "id": "cuid...",
      "action": "create",
      "payload": "{...}"
    },
    
    etc.
  ] 
}
```
