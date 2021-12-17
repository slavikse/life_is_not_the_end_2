extends RigidBody2D

class_name Bullet


func _on_Area2D_body_entered(body: Node2D) -> void:
    if body:
        external_destroy()

    if body is Block:
        (body as Block).external_increse_health()


func external_destroy() -> void:
    queue_free()
