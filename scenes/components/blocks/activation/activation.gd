extends StaticBody2D

class_name Activation

var is_activated := false

onready var level_node := $"/root/Level" as Level
onready var activate_audio_node := $Activate as AudioStreamPlayer2D
onready var open_animation_node := $Open as AnimationPlayer


func _on_Area2D_body_entered(bullet_node: Bullet) -> void:
    if bullet_node and not is_activated:
        is_activated = true
        activate_audio_node.play()

        open_animation_node.play("open")
        level_node.external_can_activate_exit("activation")
