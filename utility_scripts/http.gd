class_name UtilsHTTP

#region Information Responses
const CONTINUE: int = 100
const SWITCHING_PROTOCOLS: int = 101
const INFORMATION_RESPONSES: Array[int] = [
	CONTINUE, SWITCHING_PROTOCOLS,
	]
#endregion

#region Successfull Responses
const OK: int = 200
const CREATED: int = 201
const ACCEPTED: int = 202
const NON_AUTHORITATIVE_INFORMATION: int = 203
const NO_CONTENT: int = 204
const RESET_CONTENT: int = 205
const PARTIAL_CONTENT: int = 206
const SUCCESSFULL_RESPONSES: Array[int] = [
	OK, CREATED, ACCEPTED, NON_AUTHORITATIVE_INFORMATION, NO_CONTENT, RESET_CONTENT, PARTIAL_CONTENT,
	]
#endregion

#region Redirection Responses
const MULTIPLE_CHOICES: int = 300
const MOVED_PERMANENTLY: int = 301
const FOUND: int = 302
const SEE_OTHER: int = 303
const NOT_MODIFIED: int = 304
const USE_PROXY: int = 305
const TEMPORARY_REDIRECT: int = 307
const PERMANENT_REDIRECT: int = 308
const REDIRECTION_RESPONSES: Array[int] = [
	MULTIPLE_CHOICES, MOVED_PERMANENTLY, FOUND, SEE_OTHER, NOT_MODIFIED, USE_PROXY, TEMPORARY_REDIRECT,
	PERMANENT_REDIRECT,
	]
#endregion

#region Client Error Responses
const BAD_REQUEST: int = 400
const UNAUTHORIZED: int = 401
const PAYMENT_REQUIRED: int = 402
const FORBIDDEN: int = 403
const NOT_FOUND: int = 404
const METHOD_NOT_ALLOWED: int = 405
const NOT_ACCEPTABLE: int = 406
const PROXY_AUTHENTICATION_REQUIRED: int = 407
const REQUEST_TIMEOUT: int = 408
const CONFLICT: int = 409
const GONE: int = 410
const LENGTH_REQUIRED: int = 411
const PRECONDITION_FAILED: int = 412
const PAYLOAD_TOO_LARGE: int = 413
const URI_TOO_LONG: int = 414
const UNSUPPORTED_MEDIA_TYPE: int = 415
const RANGE_NOT_SATISFIABLE: int = 416
const EXPECTATION_FAILED: int = 417
const MISDIRECTED_REQUEST: int = 421
const UNPROCESSABLE_ENTITY: int = 422
const LOCKED: int = 423
const FAILED_DEPENDENCY: int = 424
const UPGRADE_REQUIRED: int = 426
const PRECONDITION_REQUIRED: int = 428
const TOO_MANY_REQUESTS: int = 429
const REQUEST_HEADER_FIELDS_TOO_LARGE: int = 431
const UNAVAILABLE_FOR_LEGAL_REASONS: int = 451
const CLIENT_ERROR_RESPONSES: Array[int] = [
	BAD_REQUEST, UNAUTHORIZED, PAYMENT_REQUIRED, FORBIDDEN, NOT_FOUND, METHOD_NOT_ALLOWED, NOT_ACCEPTABLE,
	PROXY_AUTHENTICATION_REQUIRED, REQUEST_TIMEOUT, CONFLICT, GONE, LENGTH_REQUIRED, PRECONDITION_FAILED,
	PAYLOAD_TOO_LARGE, URI_TOO_LONG, UNSUPPORTED_MEDIA_TYPE, RANGE_NOT_SATISFIABLE, EXPECTATION_FAILED,
	MISDIRECTED_REQUEST, UNPROCESSABLE_ENTITY, LOCKED, FAILED_DEPENDENCY, UPGRADE_REQUIRED, PRECONDITION_REQUIRED,
	TOO_MANY_REQUESTS, REQUEST_HEADER_FIELDS_TOO_LARGE, UNAVAILABLE_FOR_LEGAL_REASONS,
]
#endregion

#region Server Error Responses
const INTERNAL_SERVER_ERROR: int = 500
const NOT_IMPLEMENTED: int = 501
const BAD_GATEWAY: int = 502
const SERVICE_UNAVAILABLE: int = 503
const GATEWAY_TIMEOUT: int = 504
const HTTP_VERSION_NOT_SUPPORTED: int = 505
const VARIANT_ALSO_NEGOTIATES: int = 506
const INSUFFICIENT_STORAGE: int = 507
const LOOP_DETECTED: int = 508
const NOT_EXTENDED: int = 510
const NETWORK_AUTHENTICATION_REQUIRED: int = 511
const SERVER_ERROR_RESPONSES: Array[int] = [
	INTERNAL_SERVER_ERROR, NOT_IMPLEMENTED, BAD_GATEWAY, SERVICE_UNAVAILABLE, GATEWAY_TIMEOUT,
	HTTP_VERSION_NOT_SUPPORTED, VARIANT_ALSO_NEGOTIATES, INSUFFICIENT_STORAGE, LOOP_DETECTED, NOT_EXTENDED,
	NETWORK_AUTHENTICATION_REQUIRED,
]
#endregion

#region Public Static Methods
static func parse_body(body: PackedByteArray) -> Variant:
	var body_decoded: String = body.get_string_from_utf8()
	
	if body_decoded.is_empty():
		return null
	
	var body_parsed: Variant = JSON.parse_string(body_decoded)
	
	if body_parsed == null:
		return null
	
	return body_parsed


static func decode_and_parse_body_to_dict(body: PackedByteArray) -> Dictionary:
	var body_parsed: Variant = parse_body(body)
	
	return body_parsed as Dictionary if typeof(body_parsed) == TYPE_DICTIONARY else {}


static func decode_and_parse_body_to_array(body: PackedByteArray) -> Array:
	var body_parsed: Variant = parse_body(body)
	
	return body_parsed as Array if typeof(body_parsed) == TYPE_ARRAY else []


static func decode_and_parse_body_to_string(body: PackedByteArray) -> String:
	var body_decoded: String = body.get_string_from_utf8()
	
	if body_decoded.is_empty():
		return ""
	
	return body_decoded.get_slice("<p>", 1).replace("</p>", "")


static func build_url(
	host: String, port: int, route: String, args: Dictionary[Variant, Variant] = {}, secure: bool = false
	) -> String:
		var sanitized_args: PackedStringArray
		
		for key: Variant in args:
			sanitized_args.append("%s=%s" % [key, args[key]])
		
		return (
			"http%s://%s:%s/%s%s"
			% ["s" if secure else "", host, port, route, "" if args.is_empty() else ("?%s" % "&".join(sanitized_args))]
			)


static func build_urlv(
	host: String, port: int, path_segments: Array, args: Dictionary[Variant, Variant] = {}
	) -> String:
		return build_url(host, port, "/".join(path_segments), args)


static func response_code_is_information(response: int) -> bool:
	return response in INFORMATION_RESPONSES


static func response_code_is_successfull(response: int) -> bool:
	return response in SUCCESSFULL_RESPONSES


static func response_code_is_redirection(response: int) -> bool:
	return response in REDIRECTION_RESPONSES


static func response_code_is_client_error(response: int) -> bool:
	return response in CLIENT_ERROR_RESPONSES


static func response_code_is_server_error(response: int) -> bool:
	return response in SERVER_ERROR_RESPONSES


static func response_code_is_error(response: int) -> bool:
	return response in CLIENT_ERROR_RESPONSES + SERVER_ERROR_RESPONSES


static func response_code_is_ok(response: int) -> bool:
	return not response_code_is_error(response)
#endregion
