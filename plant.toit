import gpio
import i2c
import .sensor show TemperatureSensor MoistureSensor

DEVICE-ADDRESS := 0x36

main:
  scl := gpio.Pin 25
  sda := gpio.Pin 26
  frequency := 100_000

  print "Setting up bus..."
  bus := i2c.Bus --sda=sda --scl=scl --frequency=frequency

  device := bus.device DEVICE-ADDRESS

  moisture-sensor := MoistureSensor device
  temp-sensor := TemperatureSensor device

  num-readings := 0
  while num-readings < 20:
    moisture-reading := moisture-sensor.read
    print "Moisture: $(moisture-reading)"

    sleep --ms=500

    temp-reading := temp-sensor.read
    print "Temp: $(temp-reading)"

    sleep --ms=500
    num-readings += 1
