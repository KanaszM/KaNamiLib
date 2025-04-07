"""
# Version 1.0.1 (02-Apr-2025):
	- Using the `UtilsRegex.is_valid` method for host validations;

# Version 1.0.0 (01-Apr-2025):
	- Initial release;
"""


class_name UtilsNetwork


static func validate_host(host: String, is_ip: bool) -> String:
	host = host.strip_edges()
	
	if host.is_empty():
		return "The host cannot be empty."
	
	if is_ip:
		if not UtilsRegex.is_valid(UtilsRegex.MATCH_HOST_IP, host):
			return "Invalid IP format: %s." % host
		
		for octet: String in host.split("."):
			if not octet.is_valid_int():
				return "IP: %s, contains non-numeric characters." % host
			
			if UtilsNumeric.int_is_between(int(octet), 0, 255):
				return "IP: %s, octets must be between 0 and 255." % host
			
			if octet.length() > 1 and octet.begins_with("0"):
				return "IP: %s, octets cannot have leading zeros." % host
	
	else:
		if not UtilsRegex.is_valid(UtilsRegex.MATCH_HOST_DOMAIN, host):
			return "Invalid domain format: %s." % host
	
	return ""


static func validate_port(port: int) -> String:
	if not UtilsNumeric.int_is_between(port, 1, 65535):
		return "Port: %d, must be between 1 and 65535." % port
	
	return ""
