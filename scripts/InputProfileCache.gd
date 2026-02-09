extends Node

var _profiles := {}

func set_profile(device_id: String, mapping: Dictionary) -> void:
    _profiles[device_id] = mapping

func get_profile(device_id: String) -> Dictionary:
    return _profiles.get(device_id, {})

func clear() -> void:
    _profiles.clear()
