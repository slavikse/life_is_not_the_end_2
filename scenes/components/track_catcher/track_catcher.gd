extends Area2D

var max_roads_quantity := -1.0
var hp_node_scale := 2.0
var interpolate_speed := 0.2

onready var tween_node := $Tween as Tween
onready var hp_node := $HP as Sprite
onready var delay_ready_node := $DelayReady as Timer
onready var level_node := $"/root/Level" as Level


func _ready() -> void:
    # Чтобы успели инициализироваться дорожки.
    delay_ready_node.start(0.2)
    yield(delay_ready_node, 'timeout')

    max_roads_quantity = GlobalState.roads_quantity


func _on_TrackCatcher_area_entered(block: BlockTrackCatcher) -> void:
    if block:
        GlobalState.roads_quantity -= 1

        if GlobalState.roads_quantity == 0:
            interpolate(hp_node_scale)
            level_node.external_can_activate_exit("track_catcher")

        else:
            interpolate((max_roads_quantity - GlobalState.roads_quantity) / max_roads_quantity)


func interpolate(size: float) -> void:
    #warning-ignore:RETURN_VALUE_DISCARDED
    tween_node.interpolate_property(hp_node, "scale",
        hp_node.scale, Vector2(size, size), interpolate_speed,
        Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)

    #warning-ignore:RETURN_VALUE_DISCARDED
    tween_node.start()
