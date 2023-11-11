import fixed-point show FixedPoint
import net
import mqtt
import .home-assistant show HomeAssistantClient HomeAssistantDevice
import .sensor show Sensor FakeSensor

CLIENT-ID ::= "moisture01"
HOST ::= "localhost"
USERNAME ::= "admin"
PASSWORD ::= "password"

main:
  transport ::= mqtt.TcpTransport --net-open=(::net.open) --host=HOST
  mqtt-client ::= mqtt.Client --transport=transport
  mqtt-options ::= mqtt.SessionOptions --client-id=CLIENT-ID --username=USERNAME --password=PASSWORD
  mqtt-client.start --options=mqtt-options

  ha-client := HomeAssistantClient mqtt-client
  sensor := create-sensor
  ha-device := HomeAssistantDevice
    --name_="Moisture Sensor"
    --object-id_="moisture"
    --unique-id_="01"
    --identifier_="Plant"
    --sensor_=sensor
    --client_=ha-client
  
  ha-device.start

  while true:
    ha-device.broadcast-state
    sleep --ms=1000

create-sensor -> Sensor:
  values := [
    FixedPoint 620,
    FixedPoint 623,
    FixedPoint 627,
    FixedPoint 622,
    FixedPoint 617,
    FixedPoint 608,
    FixedPoint 612,
    FixedPoint 619,
    FixedPoint 625,
    FixedPoint 622,
  ]
  return FakeSensor values
