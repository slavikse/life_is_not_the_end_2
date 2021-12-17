extends Area2D


func _on_ForceZoomOut_body_entered(player_node: Player) -> void:
    if player_node:
        player_node.external_zoom_out(false)


func _on_ForceZoomOut_body_exited(player_node: Player) -> void:
    if player_node:
        player_node.external_zoom_out(true)
