"""
# Version 1.0.0 (02-Apr-2025):
	- Reviewed release;
"""


class_name UtilsEase


#region Public Static Methods
static func linear_weight(from: float, to: float, weight: float) -> float:
	return lerpf(from, to, weight)


static func linear_speed(from: float, to: float, speed: float, delta: float) -> float:
	return linear_weight(from, to, _compute_weight(from, to, speed, delta))


static func spring_weight(from: float, to: float, weight: float) -> float:
	weight = clampf(weight, 0.0, 1.0)
	weight = (
		(sin(weight * PI * (0.2 + 2.5 * weight * weight * weight)) * pow(1.0 - weight, 2.2) + weight)
		* (1.0 + (1.2 * (1.0 - weight)))
		)
	
	return from + (to - from) * weight


static func spring_speed(from: float, to: float, speed: float, delta: float) -> float:
	return spring_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_quad_weight(from: float, to: float, weight: float) -> float:
	to -= from
	
	return to * weight * weight + from


static func in_quad_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_quad_weight(from, to, _compute_weight(from, to, speed, delta))


static func out_quad_weight(from: float, to: float, weight: float) -> float:
	to -= from
	
	return -to * weight * (weight - 2.0) + from


static func out_quad_speed(from: float, to: float, speed: float, delta: float) -> float:
	return out_quad_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_out_quad_weight(from: float, to: float, weight: float) -> float:
	weight /= 0.5
	to -= from
	
	if weight < 1.0:
		return to * 0.5 * weight * weight + from
	
	weight -= 1.0
	
	return -to * 0.5 * (weight * (weight - 2.0) - 1.0) + from


static func in_out_quad_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_out_quad_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_cubic_weight(from: float, to: float, weight: float) -> float:
	to -= from
	
	return to * weight * weight * weight + from


static func in_cubic_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_cubic_weight(from, to, _compute_weight(from, to, speed, delta))


static func out_cubic_weight(from: float, to: float, weight: float) -> float:
	weight -= 1.0
	to -= from
	
	return to * (weight * weight * weight + 1.0) + from


static func out_cubic_speed(from: float, to: float, speed: float, delta: float) -> float:
	return out_cubic_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_out_cubic_weight(from: float, to: float, weight: float) -> float:
	weight /= 0.5
	to -= from
	
	if weight < 1.0:
		return to * 0.5 * weight * weight * weight + from
	
	weight -= 2.0
	
	return to * 0.5 * (weight * weight * weight + 2.0) + from


static func in_out_cubic_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_out_cubic_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_quart_weight(from: float, to: float, weight: float) -> float:
	to -= from
	
	return to * weight * weight * weight * weight + from


static func in_quart_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_quart_weight(from, to, _compute_weight(from, to, speed, delta))


static func out_quart_weight(from: float, to: float, weight: float) -> float:
	weight -= 1.0
	to -= from
	
	return -to * (weight * weight * weight * weight - 1.0) + from


static func out_quart_speed(from: float, to: float, speed: float, delta: float) -> float:
	return out_quart_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_out_quart_weight(from: float, to: float, weight: float) -> float:
	weight /= 0.5
	to -= from
	
	if weight < 1.0:
		return to * 0.5 * weight * weight * weight * weight + from
	
	weight -= 2.0
	
	return -to * 0.5 * (weight * weight * weight * weight - 2.0) + from


static func in_out_quart_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_out_quart_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_quint_weight(from: float, to: float, weight: float) -> float:
	to -= from
	
	return to * weight * weight * weight * weight * weight + from


static func in_quint_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_quint_weight(from, to, _compute_weight(from, to, speed, delta))


static func out_quint_weight(from: float, to: float, weight: float) -> float:
	weight -= 1.0
	to -= from
	
	return to * (weight * weight * weight * weight * weight + 1.0) + from


static func out_quint_speed(from: float, to: float, speed: float, delta: float) -> float:
	return out_quint_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_out_quint_weight(from: float, to: float, weight: float) -> float:
	weight /= 0.5
	to -= from
	
	if weight < 1.0:
		return to * 0.5 * weight * weight * weight * weight * weight + from
	
	weight -= 2.0
	
	return to * 0.5 * (weight * weight * weight * weight * weight + 2.0) + from


static func in_out_quint_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_out_quint_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_sine_weight(from: float, to: float, weight: float) -> float:
	to -= from
	
	return -to * cos(weight * (PI * 0.5)) + to + from


static func in_sine_speed(from: float, to: float, speed: float, delta: float) -> float:
	var distance: float = absf(to - from)
	
	if distance <= 0.0:
		return from
	
	return in_sine_weight(from, to, acos(clampf(1.0 - (speed * delta) / distance, -1.0, 1.0)) / (PI * 0.5))


static func out_sine_weight(from: float, to: float, weight: float) -> float:
	to -= from
	
	return to * sin(weight * (PI * 0.5)) + from


static func out_sine_speed(from: float, to: float, speed: float, delta: float) -> float:
	var distance: float = absf(to - from)
	
	if distance <= 0.0:
		return from
	
	return out_sine_weight(from, to, asin(clampf((speed * delta) / distance, -1.0, 1.0)) / (PI * 0.5))


static func in_out_sine_weight(from: float, to: float, weight: float) -> float:
	to -= from
	
	return -to * 0.5 * (cos(PI * weight) - 1.0) + from


static func in_out_sine_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_out_sine_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_expo_weight(from: float, to: float, weight: float) -> float:
	to -= from
	
	return to * pow(2.0, 10.0 * (weight - 1.0)) + from


static func in_expo_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_expo_weight(from, to, _compute_weight(from, to, speed, delta))


static func out_expo_weight(from: float, to: float, weight: float) -> float:
	to -= from
	
	return to * (-pow(2.0, -10.0 * weight) + 1.0) + from


static func out_expo_speed(from: float, to: float, speed: float, delta: float) -> float:
	return out_expo_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_out_expo_weight(from: float, to: float, weight: float) -> float:
	weight /= 0.5
	to -= from
	
	if weight < 1.0:
		return to * 0.5 * pow(2.0, 10.0 * (weight - 1.0)) + from
	
	weight -= 1.0
	
	return to * 0.5 * (-pow(2.0, -10.0 * weight) + 2.0) + from


static func in_out_expo_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_out_expo_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_circ_weight(from: float, to: float, weight: float) -> float:
	to -= from
	
	return -to * (sqrt(1.0 - weight * weight) - 1.0) + from


static func in_circ_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_circ_weight(from, to, _compute_weight(from, to, speed, delta))


static func out_circ_weight(from: float, to: float, weight: float) -> float:
	weight -= 1.0
	to -= from
	
	return to * sqrt(1.0 - weight * weight) + from


static func out_circ_speed(from: float, to: float, speed: float, delta: float) -> float:
	return out_circ_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_out_circ_weight(from: float, to: float, weight: float) -> float:
	weight /= 0.5
	to -= from
	
	if weight < 1.0:
		return -to * 0.5 * (sqrt(1.0 - weight * weight) - 1.0) + from
	
	weight -= 2.0
	
	return to * 0.5 * (sqrt(1.0 - weight * weight) + 1.0) + from


static func in_out_circ_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_out_circ_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_bounce_weight(from: float, to: float, weight: float) -> float:
	to -= from
	
	return to - out_bounce_weight(0.0, to, 1.0 - weight) + from


static func in_bounce_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_bounce_weight(from, to, _compute_weight(from, to, speed, delta))


static func out_bounce_weight(from: float, to: float, weight: float) -> float:
	to -= from

	if weight < 1 / 2.75:
		return to * (7.5625 * weight * weight) + from
	
	elif weight < 2 / 2.75:
		weight -= 1.5 / 2.75
		
		return to * (7.5625 * weight * weight + 0.75) + from
	
	elif weight < 2.5 / 2.75:
		weight -= 2.25 / 2.75
		
		return to * (7.5625 * weight * weight + 0.9375) + from
	
	weight -= 2.625 / 2.75
	
	return to * (7.5625 * weight * weight + 0.984375) + from


static func out_bounce_speed(from: float, to: float, speed: float, delta: float) -> float:
	return out_bounce_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_out_bounce_weight(from: float, to: float, weight: float) -> float:
	to -= from
	
	if weight < 0.5:
		return in_bounce_weight(0.0, to, weight * 2.0) * 0.5 + from
	
	return out_bounce_weight(0.0, to, weight * 2.0 - 1.0) * 0.5 + to * 0.5 + from


static func in_out_bounce_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_out_bounce_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_back_weight(from: float, to: float, weight: float) -> float:
	to -= from
	weight /= 1.0
	
	return to * (weight) * weight * ((1.70158 + 1.0) * weight - 1.70158) + from


static func in_back_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_back_weight(from, to, _compute_weight(from, to, speed, delta))


static func out_back_weight(from: float, to: float, weight: float) -> float:
	to -= from
	weight -= 1.0
	
	return to * ((weight) * weight * ((1.70158 + 1.0) * weight + 1.70158) + 1.0) + from


static func out_back_speed(from: float, to: float, speed: float, delta: float) -> float:
	return out_back_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_out_back_weight(from: float, to: float, weight: float) -> float:
	var smoothing: float = 1.70158
	
	to -= from
	weight /= 0.5
	
	if weight < 1.0:
		smoothing *= 1.525
		
		return to * 0.5 * (weight * weight * (((smoothing) + 1.0) * weight - smoothing)) + from
	
	weight -= 2.0
	smoothing *= 1.525
	
	return to * 0.5 * ((weight) * weight * (((smoothing) + 1.0) * weight + smoothing) + 2.0) + from


static func in_out_back_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_out_back_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_elastic_weight(from: float, to: float, weight: float) -> float:
	to -= from
	
	if absf(weight) < 0.00001:
		return from
	
	if absf(weight - 1.0) < 0.00001:
		return from + to
	
	return from + _calculate_elastic_oscillation(weight, to, 0.075, true)


static func in_elastic_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_elastic_weight(from, to, _compute_weight(from, to, speed, delta))


static func out_elastic_weight(from: float, to: float, weight: float) -> float:
	to -= from
	
	if absf(weight) < 0.00001:
		return from
	
	if absf(weight - 1.0) < 0.00001:
		return from + to
	
	return from + to + _calculate_elastic_oscillation(weight, to, 0.075, false)


static func out_elastic_speed(from: float, to: float, speed: float, delta: float) -> float:
	return out_elastic_weight(from, to, _compute_weight(from, to, speed, delta))


static func in_out_elastic_weight(from: float, to: float, weight: float) -> float:
	to -= from
	
	if absf(weight) < 0.00001:
		return from
	
	if absf(weight - 1.0) < 0.00001:
		return from + to
	
	if weight < 0.5:
		return from + 0.5 * _calculate_elastic_oscillation(weight * 2.0, to, 0.075, true)
	
	return from + to * 0.5 + 0.5 * _calculate_elastic_oscillation(weight * 2.0 - 1.0, to, 0.075, false)


static func in_out_elastic_speed(from: float, to: float, speed: float, delta: float) -> float:
	return in_out_elastic_weight(from, to, _compute_weight(from, to, speed, delta))
#endregion

#region Private Static Methods
static func _calculate_bounce_factor(weight: float, to: float, offset: float) -> float:
	weight -= offset
	
	return to * (7.5625 * weight * weight)


static func _calculate_elastic_oscillation(
	weight: float, amplitude: float, smoothing: float, inverse: bool = false
	) -> float:
		if inverse:
			return -(amplitude * pow(2.0, 10.0 * (weight - 1.0)) * sin((weight - smoothing) * (2.0 * PI) / 0.3))
		
		return amplitude * pow(2.0, -10.0 * weight) * sin((weight - smoothing) * (2.0 * PI) / 0.3)


static func _compute_weight(from: float, to: float, speed: float, delta: float) -> float:
	return clampf((speed * delta) / absf(to - from), 0.0, 1.0)
#endregion
