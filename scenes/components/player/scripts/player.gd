extends KinematicBody2D

class_name Player

const FLOOR := Vector2.UP
const OFFSET_NORMAL_SHAPE := 4 * 8
const OFFSET_SMALL_SHAPE := 2 * 8
const ADDITIONAL_JUMP_QUANTITY := 1

var move := preload('./movement/move.gd').new()
var jump := preload('./movement/jump.gd').new()
var shape := preload('./transform/shape.gd').new()
var animations := preload('./transform/animations.gd').new()

var is_first_entered := false
var velocity := Vector2.ZERO;
# Больше 1, когда стоит на поверхности. Когда в воздухе =0. Когда только что приземлился =1.
var landed_counter := 0
var jump_quantity := 0
var is_can_zoom_out := true
var is_level_complete := false

onready var weapon_node := $Weapon as Weapon
onready var sprite_node := $Sprite as Sprite
onready var collision_node := $Collision as CollisionPolygon2D
onready var scale_animation_node := $Scale as AnimationPlayer
onready var move_animation_node := $Move as AnimationPlayer
onready var floor_audio_node := $Floor as AudioStreamPlayer2D
onready var zoom_audio_node := $Zoom as AudioStreamPlayer2D
onready var delay_next_level_node := $DelayNextLevel as Timer


func _ready() -> void:
    scale = Vector2(0, 0)
    scale_animation_node.play('shape_zero_to_normal')


func _physics_process(_delta: float) -> void:
    if is_level_complete:
        Input.action_release('player_jump')
        Input.action_release('player_left')
        Input.action_release('player_right')

    if not visible:
        return

    moving()
    jumping()
    zoom()

    if is_first_entered:
        shoot()

    velocity = move_and_slide(velocity, FLOOR)


func _on_FirstEntered_timeout() -> void:
    is_first_entered = true


func moving() -> void:
    velocity.x = move.moving(velocity.x, shape.is_normal_shape)

    if is_on_wall():
        velocity.x = 0


func jumping() -> void:
    if is_on_floor():
        jump_quantity = 0
        velocity.y = jump.jumping(velocity.y, shape.is_normal_shape)

    elif Input.is_action_just_pressed('player_jump') and jump_quantity < ADDITIONAL_JUMP_QUANTITY:
        jump_quantity += 1
        velocity.y = jump.jumping(velocity.y, shape.is_normal_shape)

    if is_on_ceiling():
        velocity.y = jump.ceiling(velocity.y, shape.is_normal_shape)

    velocity.y = jump.continuous_jumping(velocity.y, shape.is_normal_shape)
    has_landing()


func has_landing() -> void:
    var y := round(velocity.y)

    if y == jump.GRAVITY:
        if landed_counter == 1 and is_first_entered:
            floor_audio_node.play()

        landed_counter += 1

    elif y != jump.GRAVITY * 2:
        landed_counter = 0


func shoot() -> void:
    animations.play(velocity, move_animation_node, sprite_node)

    var center_y := position.y - OFFSET_NORMAL_SHAPE if shape.is_normal_shape else position.y - OFFSET_SMALL_SHAPE;
    var player_center := Vector2(position.x, center_y)
    weapon_node.external_shot(move_animation_node, sprite_node, player_center, shape.is_normal_shape)


func zoom() -> void:
    if is_can_zoom_out:
        var is_resize := shape.switch_scale(scale_animation_node)

        if is_resize:
            zoom_audio_node.play()

    elif shape.is_normal_shape:
        scale = shape.force_to_small_shape(scale_animation_node)
        zoom_audio_node.play()


func external_zoom_out(flag: bool) -> void:
    is_can_zoom_out = flag


func external_game_over() -> void:
    collision_node.set_deferred('disabled', true)
    visible = false


func external_level_complete() -> void:
    is_level_complete = true

    if shape.is_normal_shape:
        scale_animation_node.play('shape_normal_to_zero')

    else:
        scale_animation_node.play('shape_small_to_zero')

    yield(scale_animation_node, 'animation_finished')
    visible = false

    delay_next_level_node.start(0.3)
    yield(delay_next_level_node, 'timeout')

    if GlobalController:
        GlobalController.external_next_level()
