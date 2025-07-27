class_name WebSocketClient extends Node

#region Signals
signal connected
signal disconnected
signal packet_received(packet: Packets.Packet)
#endregion

#region Public Variables
var socket: WebSocketPeer
var previous_state: WebSocketPeer.State

var url: String
var client_id: int: set = _set_client_id
var has_connection: bool
#endregion

#region Private Variables
var _paused: bool: set = _set_paused
#endregion

#region Constructor
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	socket = WebSocketPeer.new()
	previous_state = WebSocketPeer.STATE_CLOSED
	_paused = true
#endregion

#region Public Methods
func connect_to_url(
	host: String = "127.0.0.1", port: int = 8080, host_is_ip: bool = true, tls_options: TLSOptions = null,
	) -> Error:
		if has_connection:
			return OK
		
		host = host.strip_edges().strip_escapes()
		url = ""
		
		var host_error_message: String = UtilsNetwork.validate_host(host, host_is_ip)
		
		if not host_error_message.is_empty():
			Log.error(connect_to_url, "Host validation error: %s" % host_error_message)
			return ERR_INVALID_PARAMETER
		
		var port_error_message: String = UtilsNetwork.validate_port(port)
		
		if not port_error_message.is_empty():
			Log.error(connect_to_url, "Port validation error: %s" % port_error_message)
			return ERR_INVALID_PARAMETER
		
		url = "%s://%s:%d/ws" % ["wss" if tls_options else "ws", host, port]
		
		var connection_error: Error = socket.connect_to_url(url, tls_options)
		
		Log.info(connect_to_url, "Connecting to %s..." % url)
		
		if connection_error != OK:
			_paused = true
			return connection_error
		
		_paused = false
		previous_state = socket.get_ready_state()
		
		return OK


func close(code: int = 1000, reason: String = "") -> void:
	socket.close(code, reason)
	previous_state = socket.get_ready_state()


func clear() -> void:
	socket = WebSocketPeer.new()
	previous_state = socket.get_ready_state()


func send_packet(packet: Packets.Packet) -> Error:
	packet.set_sender_id(0)
	
	var data: PackedByteArray = packet.to_bytes()
	
	return socket.send(data)


func poll() -> void:
	var current_state: WebSocketPeer.State = socket.get_ready_state()
	
	if current_state != WebSocketPeer.STATE_CLOSED:
		socket.poll()
	
	if previous_state != current_state:
		previous_state = current_state
		
		match current_state:
			WebSocketPeer.STATE_OPEN:
				connected.emit()
				has_connection = true
				Log.success(poll, "Connected")
			
			WebSocketPeer.STATE_CLOSED:
				disconnected.emit()
				has_connection = false
				Log.success(poll, "Disconnected")
	
	while current_state == WebSocketPeer.STATE_OPEN and socket.get_available_packet_count():
		var packet: Packets.Packet = _retrieve_packet()
		
		if packet != null:
			packet_received.emit(packet)
#endregion

#region Private Methods
func _process(_delta: float) -> void:
	poll()


func _retrieve_packet() -> Packets.Packet:
	if socket.get_available_packet_count() < 1:
		return null
	
	var data: PackedByteArray = socket.get_packet()
	var packet: Packets.Packet = Packets.Packet.new()
	var result: int = packet.from_bytes(data)
	
	if result != OK:
		Log.error(_retrieve_packet, "Error forming packet from data %s" % data.get_string_from_utf8())
	
	return packet
#endregion

#region SubClasses
# Use the Protobuf add-on to parse a "packets.proto" Protocol Buffers file and prepend the resulting file with
# the line "class_name Packets". Alternatively, you can define your own Packets.Packet class structures
# using the following preset:
class Packets:
	class Packet:
		func set_sender_id(_sender_id: int) -> void: pass
		func to_bytes() -> PackedByteArray: return PackedByteArray([])
		func from_bytes(_data: PackedByteArray) -> int: return OK
#endregion

#region Setter Methods
func _set_client_id(arg: int) -> void:
	client_id = arg
	Log.debug(_set_client_id, "Client ID is: %d" % client_id)


func _set_paused(arg: bool) -> void:
	_paused = arg
	set_process(not arg)
#endregion
