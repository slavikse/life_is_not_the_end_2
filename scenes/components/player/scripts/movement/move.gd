const N_SPEED := 50.0
const N_INITIAL_SPEED := N_SPEED / 1.5
const N_MAX_SPEED := N_SPEED * 7.0
const N_SPEED_DECREASE := N_SPEED * 1.5

const S_SPEED := 60.0
const S_INITIAL_SPEED := S_SPEED / 2.0
const S_MAX_SPEED := S_SPEED * 8.0
const S_SPEED_DECREASE := S_SPEED * 2.0

# N - Normal Shape | S - Small Shape

var is_left_pressed := false
var is_right_pressed := false


func moving(x: float, is_normal_shape: bool) -> float:
    controls()

    if is_left_pressed and is_right_pressed:
        x = fast_deceleration(x, is_normal_shape)

    else:
        x = move_left(x, is_normal_shape)
        x = move_right(x, is_normal_shape)

    return x


func controls() -> void:
    if Input.is_action_just_pressed('player_left'):
        is_left_pressed = true

    if Input.is_action_just_pressed('player_right'):
        is_right_pressed = true

    if Input.is_action_just_released('player_left'):
        is_left_pressed = false

    if Input.is_action_just_released('player_right'):
        is_right_pressed = false


func fast_deceleration(x: float, is_normal_shape: bool) -> float:
    x -= N_SPEED_DECREASE if is_normal_shape else S_SPEED_DECREASE

    if x < 0:
        x = 0

    return x


func move_left(x: float, is_normal_shape: bool) -> float:
    if is_left_pressed:
        if x == 0:
            x = -N_INITIAL_SPEED if is_normal_shape else -S_INITIAL_SPEED

        elif x > 0:
            x = 0

        else:
            x -= N_SPEED if is_normal_shape else S_SPEED

            var max_speed := N_MAX_SPEED if is_normal_shape else S_MAX_SPEED

            if x < -max_speed:
                x = -max_speed

    elif x < 0:
        x += N_SPEED_DECREASE if is_normal_shape else S_SPEED_DECREASE

        if x > 0:
            x = 0

    return x


func move_right(x: float, is_normal_shape: bool) -> float:
    if is_right_pressed:
        if x == 0:
            x = N_INITIAL_SPEED if is_normal_shape else S_INITIAL_SPEED

        elif x < 0:
            x = 0

        else:
            x += N_SPEED if is_normal_shape else S_SPEED

            var max_speed := N_MAX_SPEED if is_normal_shape else S_MAX_SPEED

            if x > max_speed:
                x = max_speed

    elif x > 0:
        x -= N_SPEED_DECREASE if is_normal_shape else S_SPEED_DECREASE

        if x < 0:
            x = 0

    return x
