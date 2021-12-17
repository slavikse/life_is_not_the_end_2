extends Area2D

class_name Exit

var is_can_out := false

onready var tardis_opened_node := $Tardis/Opened as Sprite
onready var tardis_door_node := $Tardis/Door as Sprite
onready var open_animation_node := $Open as AnimationPlayer
onready var opening_audio_node := $Opening as AudioStreamPlayer
onready var exit_audio_node := $Exit as AudioStreamPlayer2D


func external_open() -> void:
    is_can_out = true
    tardis_opened_node.show()
    tardis_door_node.show()

    yield(get_tree().create_timer(0.3), 'timeout')
    opening_audio_node.play()
    open_animation_node.play('open')


func _on_Exit_body_entered(player_node: Player) -> void:
    if player_node and is_can_out:
        exit_audio_node.play()
        player_node.external_level_complete()
