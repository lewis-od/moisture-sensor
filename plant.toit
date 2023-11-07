import gpio
import i2c

main:
  scl := gpio.Pin 25
  sda := gpio.Pin 26
  frequency := 100_000

  print "Setting up bus..."
  bus := i2c.Bus --sda=sda --scl=scl --frequency=frequency

  sensor := MoistureSensor bus

  num-readings := 0
  while num-readings < 20:
    reading := sensor.read-moisture
    print reading

    sleep --ms=500
    num-readings += 1


class MoistureSensor:
  device-address /int := 0x36
  moisture-address /ByteArray := #[0x0F, 0x10]
  device /i2c.Device

  constructor bus / i2c.Bus:
    device = bus.device device-address

  read-moisture -> int:
    reading := device.read-address moisture-address 2
    return (reading[0] << 8) | reading[1]
