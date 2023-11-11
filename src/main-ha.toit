import fixed-point show FixedPoint
import gpio
import i2c
import net
import mqtt
import .home-assistant show HomeAssistantClient HomeAssistantDevice
import .secrets show MQTT-PASSWORD
import .sensor show Sensor MoistureSensor

MQTT-CLIENT-ID ::= "moisture01"
MQTT-HOST ::= "localhost"
MQTT-USERNAME ::= "admin"
BROADCAST-INTERVAL ::= Duration --m=1
I2C-DEVICE-ADDRESS ::= 0x36

main:
  mqtt-client ::= create-mqtt-client
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
    sleep BROADCAST-INTERVAL


create-mqtt-client -> mqtt.Client:
  transport ::= mqtt.TcpTransport --net-open=(::net.open) --host=MQTT-HOST
  mqtt-client ::= mqtt.Client --transport=transport
  mqtt-options ::= mqtt.SessionOptions
    --client-id=MQTT-CLIENT-ID
    --username=MQTT-USERNAME
    --password=MQTT-PASSWORD
  mqtt-client.start --options=mqtt-options
  return mqtt-client


create-sensor -> Sensor:
  device := setup-sensor-device
  return MoistureSensor device


setup-sensor-device -> i2c.Device:
  scl ::= gpio.Pin 25
  sda ::= gpio.Pin 26
  frequency ::= 100_000

  bus ::= i2c.Bus --sda=sda --scl=scl --frequency=frequency
  return bus.device I2C-DEVICE-ADDRESS
