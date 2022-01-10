extends Area2D

const FILL_INIT_SCALE := 0.4
const FILL_MAX_SCALE := 2.3
const INTERPOLATE_SPEED := 0.2

var max_roads_quantity := -1.0

onready var delay_ready_node := $DelayReady as Timer
onready var tween_node := $Tween as Tween
onready var cannon_node := $Cannon as Node2D
onready var fill_node := $Cannon/Fill as Sprite
onready var level_node := $"/root/Level" as Level


func _ready() -> void:
    # Чтобы успели инициализироваться дорожки.
    delay_ready_node.start(0.2)
    yield(delay_ready_node, 'timeout')

    max_roads_quantity = GlobalState.roads_quantity


func _physics_process(delta: float) -> void:
    cannon_node.rotate(delta * (6 - GlobalState.roads_quantity))


func _on_TrackCatcher_area_entered(block: BlockTrackCatcher) -> void:
    if block:
        GlobalState.roads_quantity -= 1

        if GlobalState.roads_quantity == 0:
            interpolate_mass(FILL_MAX_SCALE)
            level_node.external_can_activate_exit("track_catcher")

        else:
            interpolate_mass(
                FILL_INIT_SCALE
                + (max_roads_quantity - GlobalState.roads_quantity)
                / max_roads_quantity)


func interpolate_mass(size: float) -> void:
    #warning-ignore:RETURN_VALUE_DISCARDED
    tween_node.interpolate_property(fill_node, "scale",
        fill_node.scale, Vector2(size, size), INTERPOLATE_SPEED,
        Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)

    #warning-ignore:RETURN_VALUE_DISCARDED
    tween_node.start()
