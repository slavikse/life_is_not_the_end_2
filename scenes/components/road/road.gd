extends Area2D

class_name Road

export(PackedScene) var BlockScene: PackedScene
export(PackedScene) var SpawnScene: PackedScene
export(String, "idle", "top", "right", "bottom", "left") var road_direction := "idle"

var self_road_direction := "idle"
var self_spawn_position := Vector2.ZERO
var external_road_id := get_instance_id()

onready var wireframe_node := $Wireframe as Sprite
onready var blocks_node := $"/root/Level/Blocks" as Node2D


func _ready() -> void:
    self_road_direction = road_direction

    if not Engine.editor_hint:
        wireframe_node.hide()


func _on_Road_body_entered(_block_blocker: Block) -> void:
    road_direction = "idle"


func _on_Road_body_exited(block_blocker: Block) -> void:
    # null - Spawn не появлялся на дорожке | false - Spawn нет на дорожке | true - Spawn на дорожке.
    var is_added = GlobalState.roads_ids.get(external_road_id)

    if is_added:
        road_direction = self_road_direction

    # Возобновление роста после остановки.
    elif block_blocker or is_added == null:
        road_direction = self_road_direction
        external_add_spawn(self_spawn_position)


func external_set_spawn_position(new_position: Vector2) -> void:
    self_spawn_position = new_position


func external_add_block(spawn_position: Vector2) -> void:
    var block_node := BlockScene.instance() as Block

    block_node.position = spawn_position
    block_node.health = int(round(rand_range(1.0, 3.0)))
    block_node.external_is_adding_block = true

    blocks_node.call_deferred("add_child", block_node)


func external_add_spawn(spawn_position: Vector2) -> void:
    if road_direction == "idle":
        return

    var spawn_node := SpawnScene.instance() as Area2D # Spawn

    if road_direction == "top":
        #warning-ignore:UNSAFE_PROPERTY_ACCESS
        spawn_position.y -= spawn_node.EXTERNAL_SPAWN_SIZE

    elif road_direction == "right":
        #warning-ignore:UNSAFE_PROPERTY_ACCESS
        spawn_position.x += spawn_node.EXTERNAL_SPAWN_SIZE

    elif road_direction == "bottom":
        #warning-ignore:UNSAFE_PROPERTY_ACCESS
        spawn_position.y += spawn_node.EXTERNAL_SPAWN_SIZE

    elif road_direction == "left":
        #warning-ignore:UNSAFE_PROPERTY_ACCESS
        spawn_position.x -= spawn_node.EXTERNAL_SPAWN_SIZE

    spawn_node.position = spawn_position
    get_parent().call_deferred("add_child", spawn_node)
