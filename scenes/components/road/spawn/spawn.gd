extends Area2D

class_name Spawn

const EXTERNAL_SPAWN_SIZE := 64
var road: Road

onready var wireframe_node := $Wireframe as Sprite
onready var rise_animation_node := $Rise/Animation as AnimationPlayer
onready var delay_ready_node := $DelayReady as Timer


func _ready() -> void:
    if not Engine.editor_hint:
        wireframe_node.hide()

    # При разрушении блокировщика, пока Spawn не остановился - вызывало лишнее создание еще одного Spawn.
    delay_ready_node.start(0.2)
    yield(delay_ready_node, 'timeout')

    # При разрушении блокирующего блока до того, как рост дойдёт до этой дорожки (блокер), то появляется лишний блок.
    if road:
        # null - Spawn не появлялся на дорожке | false - Spawn нет на дорожке | true - Spawn на дорожке.
        var is_added = GlobalState.roads_ids.get(road.external_road_id)

        if is_added:
            queue_free()

        else:
            GlobalState.roads_ids[road.external_road_id] = true

    else:
        queue_free()


func _exit_tree() -> void:
    if road:
        GlobalState.roads_ids[road.external_road_id] = false


func _on_Spawn_area_entered(_road: Road) -> void:
    _road.external_set_spawn_position(position)
    road = _road


func _on_Spawn_body_entered(body: Node2D) -> void:
    if body is Player or body is DeadPlayer:
        rise_animation_node.stop(false)


func _on_Spawn_body_exited(body: Node2D) -> void:
    if body is Player or body is DeadPlayer:
        rise_animation_node.play('Growth')


func on_animation_finished() -> void:
    queue_free()

    road.external_add_block(position)
    road.external_add_spawn(position)
