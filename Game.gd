extends Node2D

const SnakePart = preload("res://SnakePart.tscn")
const Food = preload("res://Food.tscn")
const Wall = preload("res://Wall.tscn")

export (int) var SNAKEPART_SIZE = 10
export (int) var SNAKE_GROW = 2

const NORTH = 0
const EAST = 1
const SOUTH = 2
const WEST = 3

const directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

onready var facing = EAST
onready var grow = 0
onready var dirchange = 0
onready var food = null
onready var dead: bool = false

export (Color) var headColor
export (Color) var bodyColor
export (Color) var foodColor
export (Color) var wallColor

var Snake = []

func _physics_process(_delta):
	if Input.is_action_just_released("ui_left"):
		dirchange = 3
	elif Input.is_action_just_released("ui_right"):
		dirchange = 1
	elif Input.is_action_just_released("ui_EAST"):
		facing = EAST
	elif Input.is_action_just_released("ui_WEST"):
		facing = WEST
	elif Input.is_action_just_released("ui_NORTH"):
		facing = NORTH
	elif Input.is_action_just_released("ui_SOUTH"):
		facing = SOUTH

func _ready():
	randomize()
	draw_walls()
	start_game()
	
func start_game():
	dead = false
	facing = EAST
	grow = 0
	dirchange = 0
	food = null
	place_food()
	# make initial snake

	for i in range(10,15):
		var snakePart = SnakePart.instance()
		place_part(snakePart, Vector2(i * SNAKEPART_SIZE, 150), bodyColor)
		Snake.append(snakePart)
	Snake[-1].connect("snake_dead", self, "on_snake_dead")	
	update_snake()
	
func draw_walls():
	for x in range(0,40):
		place_part(Wall.instance(), Vector2(x * SNAKEPART_SIZE, 0), wallColor)
		place_part(Wall.instance(), Vector2(x * SNAKEPART_SIZE, 300 - SNAKEPART_SIZE), wallColor)
	for y in range(0,30):
		place_part(Wall.instance(), Vector2(0 , y * SNAKEPART_SIZE), wallColor)
		place_part(Wall.instance(), Vector2(400 - SNAKEPART_SIZE, y * SNAKEPART_SIZE), wallColor)

func place_part(part_instance, pos: Vector2, color: Color):
	part_instance.position = Vector2(pos)
	get_tree().current_scene.add_child(part_instance)
	part_instance.setColor(color)
	
func update_snake(growmore = 0):
	if not dead:
		grow += growmore
		if(grow > 0):
			grow -= 1
		else:
			Snake.pop_front().queue_free()

		#place new head
		var head_pos = Snake[-1].position
		Snake[-1].setColor(bodyColor)
		Snake[-1].disconnect("snake_dead", self, "on_snake_dead")

		facing = (facing + dirchange) % 4
		dirchange = 0
		var posx = head_pos.x + (directions[facing].x * SNAKEPART_SIZE)
		var posy = head_pos.y + (directions[facing].y * SNAKEPART_SIZE)

		var newHead = SnakePart.instance()
		place_part(newHead, Vector2(posx, posy), headColor)
		Snake.append(newHead)
		newHead.connect("snake_dead", self, "on_snake_dead")	

func _on_Timer_timeout():
	if not dead:
		update_snake()
	else:
		restart_game()

func place_food():
	food = Food.instance()
	food.connect("food_eaten", self, "on_food_eaten")	
	food.position = Vector2(SNAKEPART_SIZE * (randi() % 40), SNAKEPART_SIZE * (randi() % 30))
	get_tree().current_scene.add_child(food)
	food.setColor(foodColor)
	
func on_food_eaten():
	call_deferred("place_food")
	grow += SNAKE_GROW

func on_snake_dead():
	dead=true

func restart_game():
	food.queue_free()
	for snakePart in Snake:
		snakePart.queue_free()
	Snake.resize(0)
	start_game()
