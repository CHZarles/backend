# API

## uav_telemetry

### POST /telemetry/upload
- HTTP status: always 200
- Body (JSON)
  - Required: `droneId` (string), `timestamp` (int, milliseconds, must be an integer), `location` (object: `longitude`/`latitude`/`altitude` numbers), `attitude` (object: `pitch`/`roll`/`yaw` numbers)
  - Optional: `deviceType` (string), `seqid` (number)
- Response (JSON)
  - Success: `{"code":200,"msg":"ok"}`
  - Validation error: `{"code":400,"msg":<reason>}`
  - Server error: `{"code":500,"msg":"Internal Server Error"}`

### GET /api/online/list
- HTTP status: always 200
- Response (JSON)
  - Success: `{"code":200,"data":[{"droneId":string,"clientIp":string,"lastHeartbeat":int(ms)}]}`
  - Not ready: `{"code":500,"msg":"Server not ready"}`

### GET /api/history/list
- HTTP status: always 200
- Query
  - `droneId` (string, optional)
  - `startTime` (int ms, optional; filter is `start_time >= startTime`)
- Response (JSON)
  - Success: `{"code":200,"data":[{"recordId":int,"startTime":int,"droneId":string}]}`
  - Error: `{"code":500,"msg":"Query failed: ..."}`

### POST /api/session/start
- HTTP status: always 200
- Body (JSON)
  - `mode` (string, optional, default `realtime`; allowed: `realtime`, `playback`)
  - When `mode=realtime`: required `droneId` (string), drone must be online
  - When `mode=playback`: required `recordId` (int)
- Response (JSON)
  - Success: `{"code":200,"data":{"sessionId":string}}`
  - Errors: `{"code":400|404|500,"msg":...}`

### POST /api/session/control
- HTTP status: always 200
- Body (JSON)
  - Required: `sessionId` (string), `action` (string: `pause` | `resume` | `set_speed`)
  - When `action=set_speed`: required `value` (number)
- Response (JSON)
  - Success: `{"code":200,"msg":"ok"}`
  - Errors: `{"code":400|404|500,"msg":...}`

### WebSocket /telemetry?sessionId=<sessionId>
- If `sessionId` missing/unknown: connection closed with close code `1008`
- Realtime message (JSON)
  - `{"type":"telemetry","mode":"realtime","timestamp":int,"seqid":int,"status":"playing","payload":{"droneId":string,"device_type":string,"pos":{"x":number,"y":number,"z":number},"rot":{"x":number,"y":number,"z":number,"w":number},"euler":{"x":number,"y":number,"z":number}}}`
- Playback message (JSON)
  - Frame: `{"type":"telemetry","mode":"playback","timestamp":int,"seqid":-1,"status":"playing","payload":{"droneId":string,"device_type":string,"pos":[number,number,number],"rot":[number,number,number,number],"euler":[number,number,number]}}`
  - Finished event: `{"type":"event","mode":"playback","status":"finished","payload":{}}`

## uav-media-info

### GET /
- Response (JSON): `{"message":"Drone Stream Server is running"}`

### POST /api/stream/register
- Body (JSON): `{"drone_id":string,"stream_id":string}`
- Response (JSON): `{"success":true,"message":"Registered successfully"}`

### GET /api/streams/online
- Response (JSON)
  - `[{"stream_id":string,"drone_id":string,"status":string,"app":string,"play_url":string|null,"resolution":string|null,"fps":number|null}]`
  - Only returns streams whose `status` is `Online`

### GET /api/recordings
- Query: `drone_id` (string, optional)
- Response (JSON)
  - `[{"record_id":int,"drone_id":string,"stream_id":string,"file_path":string,"created_at":string(datetime)}]`

### POST /hook/on_publish
- Body (JSON)
  - Required: `mediaServerId` (string), `app` (string), `stream` (string), `params` (string), `ip` (string), `port` (int), `vhost` (string)
- Response (JSON)
  - Allow: `{"code":0,"msg":"success"}`
  - Reject: `{"code":-1,"msg":"auth failed"}`

### POST /hook/on_stream_changed
- Body (JSON)
  - `mediaServerId` (string), `app` (string), `stream` (string), `regist` (bool), `schema` (string), `vhost` (string)
- Response (JSON): `{"code":0,"msg":"success"}`

### POST /hook/on_record_mp4
- Body (JSON)
  - `mediaServerId` (string), `app` (string), `stream` (string), `file_path` (string), `file_size` (int), `folder` (string), `start_time` (int), `time_len` (number), `url` (string), `vhost` (string)
- Response (JSON): `{"code":0,"msg":"success"}`

### GET /api/stream/play-url
- Response: HTTP 404, `{"detail":"Not Found"}`
