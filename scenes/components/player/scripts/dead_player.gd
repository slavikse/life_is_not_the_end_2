extends RigidBody2D

class_name DeadPlayer

const FOR_NORMAL_SHAPE_CENTER_Y_GRAVITY := 4.0 * 8.0
const FOR_SMALL_SHAPE_CENTER_Y_GRAVITY := 2.0 * 8.0

# Нормальная форма 32 по умолчанию.
const FOR_SMALL_SHAPE_POSITION_AND_COLLISION_Y := 16
const DECREASE_ACCELERATION := 0.6

onready var sprite_node := $Sprite as Sprite
onready var collision_node := $Collision as CollisionPolygon2D
onready var death_audio_node := $Death as AudioStreamPlayer2D
onready var delay_reload_node := $DelayReload as Timer
onready var player_node := $'/root/Level/Player' as Player


func _ready() -> void:
    death_audio_node.play()

    if player_node.shape.is_normal_shape:
        position = Vector2(player_node.position.x, player_node.position.y - FOR_NORMAL_SHAPE_CENTER_Y_GRAVITY)

    else:
        position = Vector2(player_node.position.x, player_node.position.y - FOR_SMALL_SHAPE_CENTER_Y_GRAVITY)

        # Сдвиги спрайта и коллайдера, чтобы их корректно центрировать
        # и подстроить под малые размеры.
        sprite_node.position.y = FOR_SMALL_SHAPE_POSITION_AND_COLLISION_Y
        sprite_node.scale = player_node.shape.NORMAL_SHAPE

        collision_node.position.y = FOR_SMALL_SHAPE_POSITION_AND_COLLISION_Y
        collision_node.scale = player_node.shape.SMALL_SHAPE

    set_linear_velocity(player_node.velocity * DECREASE_ACCELERATION)

    delay_reload_node.start(1)
    yield(delay_reload_node, 'timeout')

    GlobalController.external_is_need_reload_level = true
