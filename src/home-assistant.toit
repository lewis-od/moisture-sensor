import mqtt
import encoding.json
import .sensor show Sensor

class HomeAssistantClient:
  mqtt-client_ /mqtt.Client := ?

  constructor .mqtt-client_:

  register-device name/string object-id/string unique-id/string identifier/string:
    state-topic ::= state-topic_ object-id
    message ::= {
      "name": name,
      "device_class": "moisture",
      "unique_id": "$object-id$unique-id",
      "state_topic": state-topic,
      "device": {
        "identifiers": [unique-id],
        "name": identifier
      }
    }
    payload ::= json.encode message

    config-topic ::= config-topic_ object-id
    mqtt-client_.publish config-topic payload
  
  config-topic_ object-id/string -> string:
    return "homeassistant/sensor/$object-id/config"
  
  broadcast-state object-id/string value/int:
    payload ::= json.encode value
    topic ::= state-topic_ object-id
    mqtt-client_.publish topic payload
  
  state-topic_ object-id/string -> string:
    return "homeassistant/sensor/$object-id/state"


class HomeAssistantDevice:
  name_ /string := ?
  object-id_ /string := ?
  unique-id_ /string := ?
  identifier_ /string := ?
  client_ /HomeAssistantClient := ?
  sensor_ /Sensor := ?

  constructor --.name_ --.object-id_ --.unique-id_ --.identifier_ --.client_ --.sensor_:

  start:
    client_.register-device name_ object-id_ unique-id_ identifier_
  
  broadcast-state:
    reading ::= sensor_.read
    value ::= reading.to-int
    client_.broadcast-state object-id_ value
