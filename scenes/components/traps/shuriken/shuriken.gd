extends RigidBody2D

class_name Shuriken

var is_first_entered := false

onready var cut_audio_node := $Cut as AudioStreamPlayer2D
onready var level_node := $'/root/Level' as Level


func _on_Timer_timeout() -> void:
    is_first_entered = true


func _on_Area2D_body_entered(player_node: Player) -> void:
    if not is_first_entered:
        return

    if not cut_audio_node.playing:
        cut_audio_node.play()

    if player_node:
        player_node.external_game_over()
        level_node.external_game_over()


func external_destroy() -> void:
    queue_free()
