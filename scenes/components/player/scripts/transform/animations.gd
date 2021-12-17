const HORIZONTAL_VELOCITY_DEFAULT := 0.0
const HORIZONTAL_VELOCITIES := [HORIZONTAL_VELOCITY_DEFAULT, HORIZONTAL_VELOCITY_DEFAULT]

 # Величина влияния гравитации для нормальной и малой форм.
const VERTICAL_VELOCITY_DEFAULT := 20.0
const VERTICAL_VELOCITIES := [VERTICAL_VELOCITY_DEFAULT, VERTICAL_VELOCITY_DEFAULT]


func play(velocity: Vector2, move_animation_node: AnimationPlayer, sprite_node: Sprite) -> void:
    var y_floored := velocities_collecting(velocity)
    play_animation(move_animation_node)
    flip_h_and_v(velocity, y_floored, sprite_node)


func velocities_collecting(velocity: Vector2) -> float:
    HORIZONTAL_VELOCITIES.pop_front()
    HORIZONTAL_VELOCITIES.push_back(floor(velocity.x))

    var y_floored := floor(velocity.y)
    VERTICAL_VELOCITIES.pop_front()
    VERTICAL_VELOCITIES.push_back(y_floored)

    return y_floored


func play_animation(move_animation_node: AnimationPlayer) -> void:
    var is_moving_horizontal := HORIZONTAL_VELOCITIES.has(HORIZONTAL_VELOCITY_DEFAULT)
    var is_moving_vertical := VERTICAL_VELOCITIES.has(VERTICAL_VELOCITY_DEFAULT)

    if is_moving_horizontal and is_moving_vertical:
        move_animation_node.play('idle')

    elif not is_moving_horizontal and not is_moving_vertical:
        move_animation_node.play('corner')

    else:
        var h_0 := float(HORIZONTAL_VELOCITIES[0])
        var h_1 := float(HORIZONTAL_VELOCITIES[1])

        var v_0 := float(VERTICAL_VELOCITIES[0])
        var v_1 := float(VERTICAL_VELOCITIES[1])

        if h_0 != HORIZONTAL_VELOCITY_DEFAULT and h_1 != HORIZONTAL_VELOCITY_DEFAULT:
            move_animation_node.play('horizontal')

        elif v_0 != VERTICAL_VELOCITY_DEFAULT and v_1 != VERTICAL_VELOCITY_DEFAULT:
            move_animation_node.play('vertical')


func flip_h_and_v(velocity: Vector2, y_floored: float, sprite_node: Sprite) -> void:
    if velocity.x != 0:
        sprite_node.flip_h = velocity.x < 0

    if y_floored != VERTICAL_VELOCITY_DEFAULT:
        sprite_node.flip_v = y_floored > VERTICAL_VELOCITY_DEFAULT
