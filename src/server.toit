import http
import net
import net.tcp
import encoding.json
import .sensor show Sensor


class SensorServer:
  socket_ /tcp.ServerSocket := ?
  server_ /http.Server := ?
  moisture-sensor_ /Sensor := ?
  temperature-sensor_ /Sensor := ?

  constructor .socket_ .moisture-sensor_ .temperature-sensor_:
    server_ = http.Server --max-tasks=5

  listen:
    server_.listen socket_:: | request/http.RequestIncoming response-writer/http.ResponseWriter |
      if request.path == "/api/moisture":
        handle-moisture_ request response-writer
      else if request.path == "/api/temperature":
        handle-temperature_ request response-writer
      else:
        response-writer.write-headers http.STATUS-NOT-FOUND --message="Not Found"

  handle-moisture_ request/http.RequestIncoming response-writer/http.ResponseWriter:
    respond_ response-writer moisture-sensor_
  
  handle-temperature_ request/http.RequestIncoming response-writer/http.ResponseWriter:
    respond_ response-writer temperature-sensor_

  respond_ response-writer/http.ResponseWriter sensor/Sensor:
    reading := sensor.read
    response-writer.headers.add "Content-Type" "application/json"
    response-writer.write (json.encode { "reading": reading.to-int })
