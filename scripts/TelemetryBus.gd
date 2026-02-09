extends Node

signal event_logged(name, payload)

var _queue: Array = []

func log_event(name: String, payload: Dictionary = {}) -> void:
    _queue.append({"name": name, "payload": payload})
    emit_signal("event_logged", name, payload)

func drain() -> Array:
    var out := _queue.duplicate()
    _queue.clear()
    return out
