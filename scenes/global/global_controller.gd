extends Node2D

# Изменяются вручную когда нужно изменить количество уровней и фоновую музыку.
const LEVELS_COUNT := 1
# Меняет фоновую музыку каждые N уровней. При этом в директории уровня должен находиться трек.
const AMBIENTS_EACH := 5

var LEVELS := []
var AMBIENTS := []

const LEVELS_FILE_NAME := "user://levels.bin"
var RERUNS := {}

var current_level_number := 1
var maximum_level_number := 1
var previous_ambient_number := 0

var is_game_started := false
var is_need_change_level := false
var external_is_need_reload_level := false

onready var ambient_audio_node := $Ambient as AudioStreamPlayer


func _ready() -> void:
    external_reset_all()


func _process(_delta: float) -> void:
    if external_is_need_reload_level:
        reload_level()

    elif is_need_change_level:
        change_level()

    if is_game_started and Input.is_action_just_pressed('game_reload_current_scene'):
        external_is_need_reload_level = true


func external_reset_all() -> void:
    current_level_number = 1
    maximum_level_number = 1
    previous_ambient_number = 0

    LEVELS = []
    AMBIENTS = []
    RERUNS = {}

    game_init()

    restore_level()
    restore_rerun()
    play_ambient()


func game_init() -> void:
    var ambients_index := 1

    for level_index in range(LEVELS_COUNT):
        var level_index_next := level_index + 1

        LEVELS.append(level_index_next)
        AMBIENTS.append(ambients_index)

        if level_index_next % AMBIENTS_EACH == 0 and ambients_index + 1 <= LEVELS_COUNT:
            ambients_index += AMBIENTS_EACH


func restore_level() -> void:
    var file := File.new() as File

    if file.file_exists(LEVELS_FILE_NAME):
        #warning-ignore:RETURN_VALUE_DISCARDED
        file.open(LEVELS_FILE_NAME, File.READ)
        current_level_number = int(file.get_as_text())

        # Защита от пустого файла сохранения.
        if current_level_number == 0:
            current_level_number = 1

        elif current_level_number > LEVELS_COUNT:
            current_level_number = LEVELS_COUNT

        maximum_level_number = current_level_number

    file.close()


func restore_rerun() -> void:
    var file := File.new() as File
    var file_name := 'user://level_%s.bin' % current_level_number

    if file.file_exists(file_name):
        #warning-ignore:RETURN_VALUE_DISCARDED
        file.open(file_name, File.READ)
        RERUNS[current_level_number] = int(file.get_as_text())

    file.close()


func play_ambient() -> void:
    # Начинает отсчет с 0, так как уровни начинаются с 1.
    var lvl := current_level_number - 1 if current_level_number - 1 < 20 else 16
    var ambient_number := int(AMBIENTS[lvl])

    var ambient_path := ''

    # TODO последний уровень запустит свой трек
    if current_level_number == 25:
        previous_ambient_number = -1
        ambient_path = 'res://scenes/levels/level_25/ambient.ogg'

        var ambient_audio := load(ambient_path) as AudioStream
        ambient_audio_node.set_stream(ambient_audio)
        ambient_audio_node.play()

    elif previous_ambient_number != ambient_number:
        previous_ambient_number = ambient_number

        if current_level_number <= 10:
            ambient_path = 'res://scenes/levels/level_0%s/ambient.ogg' % ambient_number

        else:
            ambient_path = 'res://scenes/levels/level_%s/ambient.ogg' % ambient_number

        var ambient_audio := load(ambient_path) as AudioStream
        ambient_audio_node.set_stream(ambient_audio)
        ambient_audio_node.play()


func reload_level() -> void:
    external_is_need_reload_level = false
    change_scene()
    save_rerun()


func change_scene() -> void:
    GlobalState.roads_ids = {}

    var level_path := ''

    if current_level_number < 10:
        level_path = 'res://scenes/levels/level_0%s/Level.tscn' % current_level_number

    else:
        level_path = 'res://scenes/levels/level_%s/Level.tscn' % current_level_number

    #warning-ignore:RETURN_VALUE_DISCARDED
    get_tree().change_scene(level_path)
    is_game_started = true


func save_rerun() -> void:
    if RERUNS.get(current_level_number):
        RERUNS[current_level_number] += 1

    else:
        RERUNS[current_level_number] = 1

    var file := File.new() as File
    #warning-ignore:RETURN_VALUE_DISCARDED
    file.open('user://level_%s.bin' % current_level_number, File.WRITE)
    file.store_string(str(RERUNS[current_level_number]))
    file.close()


func change_level() -> void:
    is_need_change_level = false
    change_scene()
    play_ambient()


func external_start_level(level_number: int) -> void:
    current_level_number = level_number
    is_need_change_level = true

    restore_rerun()

    if level_number > maximum_level_number:
        maximum_level_number = level_number
        save_level()


func save_level() -> void:
    var file := File.new() as File
    #warning-ignore:RETURN_VALUE_DISCARDED
    file.open(LEVELS_FILE_NAME, File.WRITE)
    file.store_string(str(maximum_level_number))
    file.close()


func external_next_level() -> void:
    var next_level_number := current_level_number + 1

    if next_level_number <= LEVELS_COUNT:
        external_start_level(next_level_number)

    else:
        current_level_number = 1
        is_game_started = false

        GlobalMain.external_game_end()
