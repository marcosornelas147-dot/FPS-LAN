extends Node3D
const PORT := 24567
var player: CharacterBody3D
var camera: Camera3D
var pitch := 0.0
var health := 100
var ammo := 30
var score := 0
var hud: CanvasLayer
var status_label: Label

func _ready():
	_build_world()
	_build_player()
	_build_hud()
	if not OS.has_feature("mobile"): Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _build_world():
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	e.sky = Sky.new()
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.55,0.66,0.82)
	e.ambient_light_energy = 0.7
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48,-32,0)
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	add_child(sun)
	_box(Vector3(0,-0.5,0),Vector3(42,1,42),Color(0.12,0.17,0.19))
	for x in range(-18,19,6):
		for z in range(-18,19,6):
			if abs(x)+abs(z)<9: continue
			var h := randf_range(1.5,4.0)
			_box(Vector3(x,h/2,z),Vector3(2.8,h,2.8),Color(0.18+randf()*0.12,0.25,0.31))

func _box(pos: Vector3,size: Vector3,color: Color):
	var body := StaticBody3D.new()
	body.position = pos
	var mesh := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.82
	mesh.material_override = mat
	body.add_child(mesh)
	var col := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	col.shape = bs
	body.add_child(col)
	add_child(body)

func _build_player():
	player = CharacterBody3D.new()
	player.position = Vector3(0,1,8)
	add_child(player)
	var col := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.38
	capsule.height = 1.8
	col.shape = capsule
	player.add_child(col)
	camera = Camera3D.new()
	camera.position.y = 0.58
	camera.current = true
	player.add_child(camera)

func _build_hud():
	hud = CanvasLayer.new()
	add_child(hud)
	var panel := ColorRect.new()
	panel.color = Color(0.015,0.025,0.04,0.78)
	panel.position = Vector2(18,18)
	panel.size = Vector2(300,82)
	hud.add_child(panel)
	status_label = Label.new()
	status_label.position = Vector2(32,28)
	status_label.add_theme_font_size_override("font_size",22)
	status_label.text = "FPS LAN  |  VIDA 100\nMUNIÇÃO 30  |  KILLS 0"
	hud.add_child(status_label)
	var cross := Label.new()
	cross.text = "+"
	cross.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	cross.position = Vector2(-12,-22)
	cross.add_theme_font_size_override("font_size",34)
	cross.add_theme_color_override("font_color",Color(0.2,1,0.8))
	hud.add_child(cross)
	var host := Button.new()
	host.text = "CRIAR SALA"
	host.position = Vector2(18,112)
	host.size = Vector2(140,48)
	host.pressed.connect(_host_game)
	hud.add_child(host)
	var join := Button.new()
	join.text = "ENTRAR LAN"
	join.position = Vector2(168,112)
	join.size = Vector2(140,48)
	join.pressed.connect(_join_game)
	hud.add_child(join)
	var shoot := Button.new()
	shoot.text = "ATIRAR"
	shoot.position = Vector2(1060,560)
	shoot.size = Vector2(170,110)
	shoot.add_theme_font_size_override("font_size",24)
	shoot.pressed.connect(_shoot)
	hud.add_child(shoot)
	var jump := Button.new()
	jump.text = "PULAR"
	jump.position = Vector2(900,600)
	jump.size = Vector2(130,70)
	jump.pressed.connect(_jump)
	hud.add_child(jump)
	var help := Label.new()
	help.text = "Arraste a tela para olhar  •  WASD no PC"
	help.position = Vector2(420,680)
	help.add_theme_color_override("font_color",Color(0.8,0.9,1))
	hud.add_child(help)

func _jump():
	if player.is_on_floor(): player.velocity.y = 6.5

func _host_game():
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(PORT,8)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		status_label.text = "SALA ABERTA :24567\nVIDA 100  |  MUNIÇÃO %d" % ammo
	else: status_label.text = "ERRO AO CRIAR SALA: %d" % err

func _join_game():
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client("192.168.1.2",PORT)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		status_label.text = "CONECTANDO...\nConfigure o IP do host em main.gd"
	else: status_label.text = "ERRO LAN: %d" % err

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: _look(event.relative)
	if event is InputEventScreenDrag: _look(event.relative)
	if event is InputEventKey and event.keycode == KEY_ESCAPE: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _look(delta: Vector2):
	player.rotate_y(-delta.x*0.003)
	pitch = clamp(pitch-delta.y*0.003,-1.45,1.45)
	camera.rotation.x = pitch

func _physics_process(delta):
	var input_dir := Vector2(Input.get_action_strength("move_right")-Input.get_action_strength("move_left"),Input.get_action_strength("move_back")-Input.get_action_strength("move_forward"))
	var dir := (player.transform.basis*Vector3(input_dir.x,0,input_dir.y)).normalized()
	player.velocity.x = dir.x*6.0
	player.velocity.z = dir.z*6.0
	if not player.is_on_floor(): player.velocity.y -= 18.0*delta
	player.move_and_slide()

func _shoot():
	if ammo<=0: return
	ammo-=1
	var query := PhysicsRayQueryParameters3D.create(camera.global_position,camera.global_position-camera.global_transform.basis.z*80)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty(): score+=1
	status_label.text = "FPS LAN  |  VIDA %d\nMUNIÇÃO %d  |  KILLS %d" % [health,ammo,score]
	if ammo==0:
		await get_tree().create_timer(1.0).timeout
		ammo=30
		status_label.text = "RECARREGADO\nVIDA %d  |  MUNIÇÃO 30" % health
