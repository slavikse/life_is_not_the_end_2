extends Area2D


func _on_ZoneShots_body_exited(bullet: Bullet) -> void:
    if bullet:
        bullet.external_destroy()
