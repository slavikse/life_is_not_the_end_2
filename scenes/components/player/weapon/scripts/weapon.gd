extends Node2D

class_name Weapon

export(PackedScene) var BulletScene: PackedScene

const ACCELERATION_SPEED_NORMAL := 200.0
const ACCELERATION_SPEED_SMALL := 400.0

var current_rotation_degrees := -1

onready var shot_audio_node := $Shot as AudioStreamPlayer2D
onready var bullets_node := $'/root/Level/Bullets' as Node2D


func external_shot(
    move_animation_node: AnimationPlayer,
    sprite_node: Sprite,
    player_center: Vector2,
    is_normal_shape: bool
) -> void:
    var is_idle := move_animation_node.current_animation == 'idle'
    var is_corner := move_animation_node.current_animation == 'corner'
    var is_horizontal := move_animation_node.current_animation == 'horizontal'
    var is_vertical := move_animation_node.current_animation == 'vertical'

    var is_left := sprite_node.flip_h
    var is_bottom := sprite_node.flip_v

    # Стороны в градусах: idle (-1), N (0), NE (45), E (90), SE (135), S (180), SW (225), W (270), NW (315).
    var rotation_degrees := -1
    var acceleration_vector := Vector2()

    if is_idle:
        rotation_degrees = -1

    else:
        if is_corner:
            if is_left and is_bottom:
                rotation_degrees = 225
                acceleration_vector = Vector2(-1, 1)

            elif is_left and not is_bottom:
                rotation_degrees = 315
                acceleration_vector = Vector2(-1, -1)

            elif not is_left and is_bottom:
                rotation_degrees = 135
                acceleration_vector = Vector2(1, 1)

            elif not is_left and not is_bottom:
                rotation_degrees = 45
                acceleration_vector = Vector2(1, -1)

        elif is_horizontal:
            if is_left:
                rotation_degrees = 270
                acceleration_vector = Vector2(-1, 0)

            else:
                rotation_degrees = 90
                acceleration_vector = Vector2(1, 0)

        elif is_vertical:
            if is_bottom:
                rotation_degrees = 180
                acceleration_vector = Vector2(0, 1)

            else:
                rotation_degrees = 0
                acceleration_vector = Vector2(0, -1)

    set_rotation_degrees(rotation_degrees)

    if current_rotation_degrees != rotation_degrees:
        current_rotation_degrees = rotation_degrees

        if can_shoot(rotation_degrees):
            shoot(player_center, is_normal_shape, acceleration_vector)


func can_shoot(rotation_degrees: int) -> bool:
    if rotation_degrees == -1:
        hide()
        return false

    show()
    return true


func shoot(player_center: Vector2, is_normal_shape: bool, acceleration_vector: Vector2) -> void:
    var bullet_node := BulletScene.instance() as Bullet
    bullet_node.position = player_center

    var acceleration := ACCELERATION_SPEED_NORMAL if is_normal_shape else ACCELERATION_SPEED_SMALL
    var acceleration_speed := acceleration * acceleration_vector
    bullet_node.set_linear_velocity(acceleration_speed)

    shot_audio_node.play()
    bullets_node.call_deferred('add_child', bullet_node)
