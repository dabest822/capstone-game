extends AnimatedSprite2D

func _ready():
   setup_portal()
   setup_glow()
   setup_aura()
   setup_particles()
   setup_light()

func setup_portal():
   rotation_degrees = 90
   scale = Vector2(3, 1.5)
   play("portalidle")
   
   var border = Sprite2D.new()
   border.texture = sprite_frames.get_frame_texture("portalidle", 0)
   border.z_index = -1
   border.modulate = Color(0, 0, 0, 0.8)
   border.scale = Vector2(1.2, 1.2)
   add_child(border)

func setup_glow():
   var glow = Sprite2D.new()
   glow.z_index = -2
   glow.modulate = Color(0, 0.7, 1.0, 0.3)
   glow.scale = Vector2(4.5, 4.5)
   add_child(glow)
   
   var tween = create_tween()
   tween.set_loops()
   tween.tween_property(glow, "modulate:a", 0.1, 2.0)
   tween.tween_property(glow, "modulate:a", 0.3, 2.0)

func setup_aura():
   var aura = Sprite2D.new()
   aura.z_index = -3
   aura.modulate = Color(0.5, 0, 1.0, 0.2)
   aura.scale = Vector2(6.0, 6.0)
   add_child(aura)
   
   var tween = create_tween()
   tween.set_loops()
   tween.tween_property(aura, "rotation_degrees", 360.0, 8.0)

func setup_particles():
   var particles = GPUParticles2D.new()
   var particle_material = ParticleProcessMaterial.new()
   
   particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
   particle_material.emission_sphere_radius = 60.0
   particle_material.particle_flag_disable_z = true
   particle_material.direction = Vector3(0, -1, 0)
   particle_material.spread = 360.0
   particle_material.initial_velocity_min = 15.0
   particle_material.initial_velocity_max = 45.0
   particle_material.gravity = Vector3(0, 0, 0)
   
   # Add color to particles
   particle_material.color = Color(0, 0.7, 1.0, 1)  # Blue color
   
   particles.process_material = particle_material
   particles.amount = 30
   particles.lifetime = 1.0
   add_child(particles)

func setup_light():
   var light = PointLight2D.new()
   
   light.energy = 2.0
   light.range_layer_min = -1
   light.range_layer_max = 1
   light.color = Color(0, 0.7, 1.0, 1)
   light.shadow_enabled = true
   light.texture_scale = 6.0
   
   var texture = GradientTexture2D.new()
   var gradient = Gradient.new()
   gradient.colors = [Color(1, 1, 1, 1), Color(0, 0, 0, 0)]
   texture.gradient = gradient
   texture.fill = GradientTexture2D.FILL_RADIAL
   texture.width = 256
   texture.height = 256
   light.texture = texture
   
   add_child(light)

# Optional rainbow particles function - uncomment and modify particle_material.color above to use
#func create_color_gradient():
#    var gradient = Gradient.new()
#    gradient.colors = [
#        Color(0, 0.7, 1.0, 1),    # Blue
#        Color(0.5, 0, 1.0, 1),    # Purple
#        Color(1, 0, 0.7, 1)       # Pink
#    ]
#    var gradientTexture = GradientTexture1D.new()
#    gradientTexture.gradient = gradient
#    return gradientTexture