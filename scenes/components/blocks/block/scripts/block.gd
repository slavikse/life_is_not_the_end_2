extends StaticBody2D

class_name Block

export(int, 4) var health := 0
export(PackedScene) var BlockDestroyScene: PackedScene

const MAX_HEALTH := 5
var road: Area2D # Road
var external_is_adding_block := false

onready var blocks_node := get_parent() as Node2D
onready var blocker_node := $Blocker as Sprite
onready var collision_node := $Collision as CollisionShape2D
onready var rise_animation_node := $Rise as AnimationPlayer
onready var increase_health_audio_node := $IncreseHealth as AudioStreamPlayer2D
onready var health_animation_node := $Health as AnimationPlayer
onready var swap_blocks_audio_node := $SwapBlocks as AudioStreamPlayer2D
onready var danger_aim_node := $DangerAim as Sprite
onready var danger_animation_node := $Danger as AnimationPlayer


func _ready() -> void:
    update_health_display()
    has_block_blocked()
    for_adding_block()


func update_health_display() -> void:
    if health > 0 and health < MAX_HEALTH:
        health_animation_node.play("hp%s" % health)


func has_block_blocked() -> void:
    road = get_parent() as Area2D # Road

    if road:
        collision_layer = 4096 # BlockBlocker
        blocker_node.show()


func external_increse_health() -> void:
    health += 1
    update_health_display()
    increase_health_audio_node.play()

    if health == MAX_HEALTH:
        swap_blocks()


func for_adding_block() -> void:
    if external_is_adding_block:
        scale = Vector2(0.0, 0.0)
        rise_animation_node.play("rise")


func swap_blocks() -> void:
    hide()
    collision_node.queue_free()

    var block_destroy_node := BlockDestroyScene.instance() as Node2D
    block_destroy_node.position = position

    if collision_layer == 4096: # BlockBlocker
        block_destroy_node.scale.x /= road.scale.x
        block_destroy_node.scale.y /= road.scale.y

    blocks_node.call_deferred("add_child", block_destroy_node)

    var destroy_animation_node := block_destroy_node.get_node("Destroy") as AnimationPlayer
    destroy_animation_node.play("destroy")
    swap_blocks_audio_node.play()
    yield(destroy_animation_node, "animation_finished")

    block_destroy_node.queue_free()
    queue_free()


func _on_BlockDestruction_body_entered(player: KinematicBody2D) -> void:
    if player:
        player_body_entered()


func _on_BlockDestruction_body_exited(player: KinematicBody2D) -> void:
    if player:
        player_body_exited()


func _on_BlockTrackCatcher_body_entered(player: KinematicBody2D) -> void:
    if player:
        player_body_entered()


func _on_BlockTrackCatcher_body_exited(player: KinematicBody2D) -> void:
    if player:
        player_body_exited()


func player_body_entered() -> void:
    danger_aim_node.show()
    danger_animation_node.play("danger")


func player_body_exited() -> void:
    danger_aim_node.hide()
    danger_animation_node.stop()
