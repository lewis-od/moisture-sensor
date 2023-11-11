import i2c
import fixed-point show FixedPoint


interface Sensor:
  read -> FixedPoint


class MoistureSensor implements Sensor:
  moisture-address_ /ByteArray ::= #[0x0F, 0x10]
  device_ /i2c.Device := ?

  constructor .device_:

  read -> FixedPoint:
    bytes := device_.read-address moisture-address_ 2
    return FixedPoint ((bytes[0] << 8) | bytes[1])


class TemperatureSensor implements Sensor:
  temperature-address_ /ByteArray ::= #[0x00, 0x04]
  device_ /i2c.Device := ?

  constructor .device_:

  read -> FixedPoint:
    bytes := device_.read-address temperature-address_ 4
    value := (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3]
    temp := (1.0 / (1 << 16)) * value
    return FixedPoint temp


class FakeSensor implements Sensor:
  values_ /List := ?
  index_ /int := 0

  constructor .values_:

  read -> FixedPoint:
    reading := values_[index_]
    index_ = (index_ + 1) % values_.size
    return reading
