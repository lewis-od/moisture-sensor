import gpio
import net
import i2c
import .sensor show Sensor MoistureSensor TemperatureSensor
import .server show SensorServer


I2C-DEVICE-ADDRESS ::= 0x36


main:
  sensor-device ::= setup-sensor-device
  moisture-sensor ::= MoistureSensor sensor-device
  temperature-sensor ::= TemperatureSensor sensor-device

  network := net.open
  server-socket := network.tcp-listen 8080
  port := server-socket.local-address.port
  server := SensorServer server-socket moisture-sensor temperature-sensor
  print "Listening on http://$network.address:$port/"
  server.listen


setup-sensor-device -> i2c.Device:
  scl ::= gpio.Pin 25
  sda ::= gpio.Pin 26
  frequency ::= 100_000

  bus ::= i2c.Bus --sda=sda --scl=scl --frequency=frequency
  return bus.device I2C-DEVICE-ADDRESS
