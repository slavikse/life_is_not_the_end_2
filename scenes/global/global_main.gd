extends Node2D

var is_menu_shown := true
var is_submenu_shown := false
var is_manual_level_change := false

# 0: Play, 1: Levels, 2: Options, 3: Credits
var menu_button_active_index := 0
var levels_button_active_index := 0
var options_button_active_index := 0
var credits_link_active_index := 0

const LEVELS_BUTTONS_SCROLL_STEP := 46
var levels_buttons := []
var credits_links := []

const VOLUME_STEP := 25
const VOLUME_CHANNELS := ['Ambient', 'Effects']
var ambient_volume := 75
var ambient_volume_file_name := "user://ambient_volume.bin"
var effects_volume := 75
var effects_volume_file_name := "user://effects_volume.bin"

onready var menu_camera_node := $Menu/Camera as Camera2D
onready var menu_play_node := $Menu/Actions/Play as Button
onready var menu_levels_node := $Menu/Actions/Levels as Button
onready var menu_options_node := $Menu/Actions/Options as Button
onready var menu_credits_node := $Menu/Actions/Credits as Button
onready var menu_exit_node := $Menu/Actions/Exit as Button
onready var menu_buttons := [menu_play_node, menu_levels_node, menu_options_node, menu_credits_node, menu_exit_node]

onready var levels_camera_node := $Levels/Camera as Camera2D
onready var levels_return_node := $Levels/Return as Button
onready var levels_button_template_node := $Levels/Level_button_template as Button
onready var levels_buttons_scroll_container := $Levels/ScrollContainer as ScrollContainer
onready var levels_buttons_container_node := $Levels/ScrollContainer/VBoxContainer as VBoxContainer

onready var options_camera_node := $Options/Camera as Camera2D
onready var options_return_node := $Options/Return as Button
onready var options_ambient_volume_node := $Options/AmbientVolume as Button
onready var options_effects_volume_node := $Options/EffectsVolume as Button
onready var options_reset_progress_node := $Options/ResetProgress as Button
onready var options_reset_progress_status_node := $Options/ResetProgressStatus as Label
onready var options_buttons := [options_ambient_volume_node, options_effects_volume_node, options_reset_progress_node]

onready var credits_camera_node := $Credits/Camera as Camera2D
onready var credits_return_node := $Credits/Return as Button
onready var credits_links_container_node := $Credits/Links as Node2D

onready var game_end_camera_node := $GameEnd/Camera as Camera2D
onready var game_end_return_node := $GameEnd/Return as Button


func _ready() -> void:
    OS.set_window_size(OS.get_screen_size())
    OS.center_window()

    restore_volumes()
    change_button_active(menu_button_active_index, menu_buttons)

    options_reset_progress_status_node.hide()


func _process(_delta: float) -> void:
    if is_submenu_shown:
        if Input.is_action_just_pressed('ui_menu'):
            return_from_submenu()

        else:
            if menu_button_active_index == 1:
                ui_levels_controls()

            elif menu_button_active_index == 2:
                ui_options()

            elif menu_button_active_index == 3:
                ui_credits()

    else:
        if is_menu_shown:
            ui_menu_controls()

        if GlobalController.is_game_started:
            ui_menu()


func restore_volumes() -> void:
    ambient_volume = restore_volume(ambient_volume_file_name, ambient_volume)
    effects_volume = restore_volume(effects_volume_file_name, effects_volume)

    for channel in VOLUME_CHANNELS:
        _on_Volume_pressed(channel, 0)

    options_button_active_index = 0


func restore_volume(file_name: String, volume: int) -> int:
    var file := File.new() as File

    if file.file_exists(file_name):
        #warning-ignore:RETURN_VALUE_DISCARDED
        file.open(file_name, File.READ)
        volume = int(file.get_as_text())

    file.close()
    return volume


func return_from_submenu() -> void:
    levels_return_node.emit_signal('pressed')
    options_return_node.emit_signal('pressed')
    credits_return_node.emit_signal('pressed')
    game_end_return_node.emit_signal('pressed')


func ui_levels_controls() -> void:
    if Input.is_action_just_pressed('ui_arrow_top'):
        levels_button_active_index = prev_button_active(levels_button_active_index, levels_buttons)
        change_button_active(levels_button_active_index, levels_buttons)

        levels_buttons_scroll_container.scroll_vertical -= LEVELS_BUTTONS_SCROLL_STEP

        if levels_button_active_index == -1:
            levels_button_active_index = GlobalController.maximum_level_number - 1

        update_scroll_vertical()

    elif Input.is_action_just_pressed('ui_arrow_bottom'):
        levels_button_active_index = next_button_active(levels_button_active_index, levels_buttons)
        change_button_active(levels_button_active_index, levels_buttons)

        levels_buttons_scroll_container.scroll_vertical += LEVELS_BUTTONS_SCROLL_STEP

        if levels_button_active_index == GlobalController.maximum_level_number:
            levels_button_active_index = 0

        update_scroll_vertical()

    elif Input.is_action_just_pressed('ui_enter'):
        levels_buttons[levels_button_active_index].emit_signal('pressed')


func update_scroll_vertical() -> void:
    change_button_active(levels_button_active_index, levels_buttons)
    levels_buttons_scroll_container.scroll_vertical = levels_button_active_index * LEVELS_BUTTONS_SCROLL_STEP


func ui_menu_controls() -> void:
    if Input.is_action_just_pressed('ui_arrow_top'):
        menu_button_active_index = prev_button_active(menu_button_active_index, menu_buttons)
        change_button_active(menu_button_active_index, menu_buttons)

    elif Input.is_action_just_pressed('ui_arrow_bottom'):
        menu_button_active_index = next_button_active(menu_button_active_index, menu_buttons)
        change_button_active(menu_button_active_index, menu_buttons)

    elif Input.is_action_just_pressed('ui_enter'):
        menu_buttons[menu_button_active_index].emit_signal('pressed')


func prev_button_active(button_active_index: int, buttons: Array) -> int:
    if button_active_index > 0:
        button_active_index -= 1

    else:
        button_active_index = buttons.size() - 1

    return button_active_index


func next_button_active(button_active_index: int, buttons: Array) -> int:
    if button_active_index < buttons.size() - 1:
        button_active_index += 1

    else:
        button_active_index = 0

    return button_active_index


func change_button_active(button_active_index: int, buttons: Array) -> void:
    for button in buttons:
        button.add_color_override('font_color', '#102027')

    # Два типа: Button, LinkButton.
    var button = buttons[button_active_index]
    button.add_color_override('font_color', '#cfd8dc')


func ui_options() -> void:
    if Input.is_action_just_pressed('ui_arrow_top'):
        options_button_active_index = prev_button_active(options_button_active_index, options_buttons)
        change_button_active(options_button_active_index, options_buttons)

    elif Input.is_action_just_pressed('ui_arrow_bottom'):
        options_button_active_index = next_button_active(options_button_active_index, options_buttons)
        change_button_active(options_button_active_index, options_buttons)

    else:
        if Input.is_action_just_pressed('ui_left'):
            _on_Volume_pressed(VOLUME_CHANNELS[options_button_active_index], -VOLUME_STEP)

        if Input.is_action_just_pressed('ui_right'):
            _on_Volume_pressed(VOLUME_CHANNELS[options_button_active_index], VOLUME_STEP)

        if options_button_active_index == 2 and Input.is_action_just_pressed('ui_enter'):
            _on_ResetProgress_pressed()


func ui_credits() -> void:
    if Input.is_action_just_pressed('ui_arrow_top'):
        credits_link_active_index = prev_button_active(credits_link_active_index, credits_links)
        change_button_active(credits_link_active_index, credits_links)

    elif Input.is_action_just_pressed('ui_arrow_bottom'):
        credits_link_active_index = next_button_active(credits_link_active_index, credits_links)
        change_button_active(credits_link_active_index, credits_links)

    elif Input.is_action_just_pressed('ui_enter'):
        credits_links[credits_link_active_index].emit_signal('pressed')


func ui_menu() -> void:
    if Input.is_action_just_pressed('ui_menu'):
        is_menu_shown = !is_menu_shown

        if is_menu_shown:
            game_paused()

        else:
            _on_Start_pressed()

    if is_manual_level_change:
        is_manual_level_change = false
        active_player_camera()


func game_paused() -> void:
    get_tree().paused = true
    menu_camera_node.current = true

    menu_button_active_index = 0
    change_button_active(menu_button_active_index, menu_buttons)

    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_Start_pressed() -> void:
    get_tree().paused = false

    if GlobalController.is_game_started:
        game_continue()

    else:
        game_start()


func game_continue() -> void:
    is_menu_shown = false
    is_submenu_shown = false

    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    active_player_camera()


func active_player_camera() -> void:
    if GlobalController.is_game_started:
        var level_node := get_node_or_null('/root/Level') as Level

        if level_node:
            var player_camera_node := level_node.get_node('Player/Camera') as Camera2D
            player_camera_node.current = true

        else:
            is_manual_level_change = true


func game_start(level := 0) -> void:
    var current_level_number := GlobalController.current_level_number if level == 0 else level

    GlobalController.external_start_level(current_level_number)
    game_continue()

    yield(get_tree().create_timer(0.1), 'timeout')
    menu_play_node.text = 'RESUME'


func _on_AmbientVolume_pressed() -> void:
    _on_Volume_pressed(VOLUME_CHANNELS[0], VOLUME_STEP)


func _on_EffectsVolume_pressed() -> void:
    _on_Volume_pressed(VOLUME_CHANNELS[1], VOLUME_STEP)


func _on_ResetProgress_pressed() -> void:
    var dir := Directory.new()
    var levels_path := "user://levels.bin"

    if dir.file_exists(levels_path):
        #warning-ignore:RETURN_VALUE_DISCARDED
        dir.remove(levels_path)

    for level_index in GlobalController.LEVELS_COUNT:
        var level_index_normalize := int(level_index) + 1
        var level_path := "user://level_%s" % str(level_index_normalize) + ".bin"

        if dir.file_exists(level_path):
            #warning-ignore:RETURN_VALUE_DISCARDED
            dir.remove(level_path)

    GlobalController.is_game_started = false
    is_manual_level_change = true
    menu_play_node.text = 'PLAY'

    GlobalController.external_reset_all()

    options_reset_progress_status_node.show()
    yield(get_tree().create_timer(1.0), 'timeout')
    options_reset_progress_status_node.hide()


func _on_Volume_pressed(bus_name: String, volume_value: int) -> void:
    var file_name := ''
    var volume := 0

    if bus_name == 'Ambient':
        options_button_active_index = 0
        file_name = ambient_volume_file_name
        ambient_volume += volume_value

        volume = normalize_volume(ambient_volume)
        ambient_volume = volume

    elif bus_name == 'Effects':
        options_button_active_index = 1
        file_name = effects_volume_file_name
        effects_volume += volume_value

        volume = normalize_volume(effects_volume)
        effects_volume = volume

    change_button_active(options_button_active_index, options_buttons)
    options_buttons[options_button_active_index].text = str(volume)

    change_volume(bus_name, volume)
    save_volume(file_name, volume)


func normalize_volume(volume: int) -> int:
    if volume < 0:
        volume = 100

    elif volume > 100:
        volume = 0

    return volume


func change_volume(bus_name: String, volume: int) -> void:
    var bus_idx := AudioServer.get_bus_index(bus_name)

    if volume == 0:
        AudioServer.set_bus_volume_db(bus_idx, -80.0)

    elif volume == VOLUME_STEP:
        AudioServer.set_bus_volume_db(bus_idx, -20.0)

    elif volume == VOLUME_STEP * 2:
        AudioServer.set_bus_volume_db(bus_idx, -10.0)

    elif volume == VOLUME_STEP * 3:
        AudioServer.set_bus_volume_db(bus_idx, 0.0)

    elif volume == VOLUME_STEP * 4:
        AudioServer.set_bus_volume_db(bus_idx, 2.0)


func save_volume(file_name: String, volume: int) -> void:
    var file := File.new() as File
    #warning-ignore:RETURN_VALUE_DISCARDED
    file.open(file_name, File.WRITE)
    file.store_string(str(volume))
    file.close()


func _on_Return_pressed() -> void:
    is_menu_shown = true
    is_submenu_shown = false

    menu_camera_node.current = true


func _on_Levels_pressed() -> void:
    menu_button_active_index = 1
    change_button_active(menu_button_active_index, menu_buttons)

    levels_camera_node.current = true
    is_submenu_shown = true

    update_levels_buttons()

    levels_button_active_index = GlobalController.current_level_number - 1
    levels_buttons = levels_buttons_container_node.get_children()

    change_button_active(levels_button_active_index, levels_buttons)

    yield(get_tree().create_timer(0.001), 'timeout')
    levels_buttons_scroll_container.scroll_vertical = levels_button_active_index * LEVELS_BUTTONS_SCROLL_STEP


func update_levels_buttons() -> void:
    for level_button_node in levels_buttons_container_node.get_children():
        levels_buttons_container_node.remove_child(level_button_node)

    for level_button_index in range(GlobalController.maximum_level_number):
        var levels_button_count := int(level_button_index) + 1
        var level_button_node := levels_button_template_node.duplicate() as Button

        #warning-ignore:RETURN_VALUE_DISCARDED
        level_button_node.connect('pressed', self, '_on_Level_pressed', [levels_button_count])
        level_button_node.show()

        if levels_button_count < 10:
            level_button_node.text = "LEVEL 0%s" % str(levels_button_count)

        else:
            level_button_node.text = "LEVEL %s" % str(levels_button_count)

        if levels_button_count < GlobalController.maximum_level_number:
            var complete_node := level_button_node.get_node('Complete') as Polygon2D
            complete_node.show()

        levels_buttons_container_node.add_child(level_button_node)


func _on_Level_pressed(level: int) -> void:
    get_tree().paused = false
    game_start(level)

    is_menu_shown = false
    is_submenu_shown = false

    is_manual_level_change = true


func _on_Options_pressed() -> void:
    menu_button_active_index = 2
    change_button_active(menu_button_active_index, menu_buttons)
    change_button_active(options_button_active_index, options_buttons)

    options_camera_node.current = true
    is_submenu_shown = true


func _on_Credits_pressed() -> void:
    menu_button_active_index = 3
    change_button_active(menu_button_active_index, menu_buttons)

    credits_links = credits_links_container_node.get_children()
    change_button_active(credits_link_active_index, credits_links)

    credits_camera_node.current = true
    is_submenu_shown = true


func _on_GodotLink_pressed() -> void:
    #warning-ignore:RETURN_VALUE_DISCARDED
    OS.shell_open('https://godotengine.org')


func _on_AbmientsLink_pressed() -> void:
    #warning-ignore:RETURN_VALUE_DISCARDED
    OS.shell_open('https://incompetech.com/music/royalty-free/music.html')


func _on_EffectsLink_pressed() -> void:
    #warning-ignore:RETURN_VALUE_DISCARDED
    OS.shell_open('https://kenney.nl/assets?q=audio')


func _on_FontLink_pressed() -> void:
    #warning-ignore:RETURN_VALUE_DISCARDED
    OS.shell_open('https://fontlibrary.org')


func _on_Exit_pressed() -> void:
    get_tree().quit()


func external_game_end() -> void:
    GlobalController.external_start_level(GlobalController.LEVELS_COUNT)

    menu_play_node.text = 'PLAY'
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    menu_button_active_index = 0
    change_button_active(menu_button_active_index, menu_buttons)

    game_end_camera_node.current = true
    is_submenu_shown = true
