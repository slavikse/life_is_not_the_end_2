extends Area2D

onready var level_node := $'/root/Level' as Level


func _on_GameArea_body_exited(body: Node2D) -> void:
    if body is Player:
        (body as Player).external_game_over()
        level_node.external_game_over()

    elif body is Shuriken:
        (body as Shuriken).external_destroy()
