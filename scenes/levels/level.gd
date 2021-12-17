extends Node2D

class_name Level

export(PackedScene) var DeadPlayerScene: PackedScene

onready var exit_node := $Exit as Exit
onready var rooms_node := $Rooms as Node2D
onready var roads_node := $Roads as Node2D
onready var tips_rerun_node := $Tips/Rerun as Label
onready var closed_doors := rooms_node.get_child_count() + 1
onready var is_character_not_added := true

# Levels / Verified:
# 01 / +

# Rooms Used:
# 01 - 1

func _ready() -> void:
    GlobalState.roads_quantity = roads_node.get_child_count()

    if GlobalController.RERUNS.get(GlobalController.current_level_number):
        tips_rerun_node.text = str(GlobalController.RERUNS[GlobalController.current_level_number])


func _exit_tree() -> void:
    GlobalState.roads_quantity = 0


func _on_RerunTime_timeout() -> void:
    tips_rerun_node.hide()


# type: activation | track_catcher
func external_can_activate_exit(type: String) -> void:
    if type == 'activation' and closed_doors > 0:
        closed_doors -= 1

    elif type == 'track_catcher' and GlobalState.roads_quantity > 0:
        return

    if closed_doors == 0 and GlobalState.roads_quantity == 0:
        exit_node.external_open()


func external_game_over() -> void:
    if is_character_not_added:
        is_character_not_added = false

        var dead_player_node := DeadPlayerScene.instance() as DeadPlayer
        call_deferred('add_child', dead_player_node)
