extends CharacterBody2D

@export var walk_speed = 3.0
const TILE_SIZE = 16

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")

enum PlayerState { IDLE, TURNING, WALKING }
enum FacingDirection { LEFT, RIGHT, UP, DOWN }

var player_state = PlayerState.IDLE
var facing_direction = FacingDirection.DOWN

var initial_position = Vector2(0, 0)
var input_direction = Vector2(0, 0)
var is_moving = false
var percent_moved_to_next_tile = 0.0

func _ready():
	anim_tree.active = true
	initial_position = position
	
func _physics_process(delta):
	# Ignora novos comandos de movimento enquanto a animação de virar não termina
	if player_state == PlayerState.TURNING:
		return 
	elif is_moving == false:
		process_player_movement_input()
	elif input_direction != Vector2.ZERO: 
		anim_state.travel("Walk")
		move(delta)
	else:
		anim_state.travel("Idle")
		is_moving = false
		
func process_player_movement_input():
	# Essa lógica bloqueia movimento na diagonal:
	# Só checamos o eixo X se o Y estiver zerado e vice-versa
	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up")) 
	
	if input_direction != Vector2.ZERO:
		# Atualiza para onde o personagem tá olhando lá na AnimationTree
		anim_tree.set("parameters/Idle/blend_position", input_direction)
		anim_tree.set("parameters/Walk/blend_position", input_direction)
		anim_tree.set("parameters/Turn/blend_position", input_direction)
		
		# Se ele mudou de direção, toca a animação de virar antes de sair andando
		if need_to_turn():
			player_state = PlayerState.TURNING
			anim_state.travel("Turn")
		else:
			# Se já tá virado pro lado certo, salva de onde ele tá saindo e começa a andar
			initial_position = position
			is_moving = true
	else:
		anim_state.travel("Idle")
		
func need_to_turn():
	var new_facing_direction
	if input_direction.x < 0:
		new_facing_direction = FacingDirection.LEFT
	elif input_direction.x > 0: 
		new_facing_direction = FacingDirection.RIGHT
	elif input_direction.y < 0:
		new_facing_direction = FacingDirection.UP
	elif input_direction.y > 0:
		new_facing_direction = FacingDirection.DOWN

	# Só retorna true se a nova direção apertada for diferente da que ele tava olhando antes
	if facing_direction != new_facing_direction:
		facing_direction = new_facing_direction
		return true
	
	facing_direction = new_facing_direction
	return false

# Chamado pelo AnimationPlayer no final da animação "Turn" pra liberar o personagem
func finished_turning():
	player_state = PlayerState.IDLE

func move(delta):
	# Avança a % do trajeto baseada na velocidade
	percent_moved_to_next_tile += walk_speed * delta
	
	# Chegou no destino (passou de 100%)
	if percent_moved_to_next_tile >= 1.0:
		position = initial_position + (TILE_SIZE * input_direction)
		percent_moved_to_next_tile = 0.0
		is_moving = false
	else:
		# Ainda tá no caminho, interpola o visual aos pouquinhos
		position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
		
