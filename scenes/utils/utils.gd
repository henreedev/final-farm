extends Node
class_name Utils

static var num_points = 50
static var arc_height = 50
static var better_zoom_shader = preload("res://scenes/map/better-zoom.gdshader")
static var plant_outline_gradient : GradientTexture1D = preload("res://scenes/plants/plant-outline-gradient.tres")
static var very_slow = 10.0
static var slow = 16.0
static var normal = 24.0
static var fast = 35.0
static var very_fast = 48.0

static var fly_mutated := false

static var food_supply_level : Plant.Level = Plant.Level.Level0
static var eggplant_level : Plant.Level = Plant.Level.Level0
static var broccoli_level : Plant.Level = Plant.Level.Level0
static var tomato_level : Plant.Level = Plant.Level.Level0
static var potato_level : Plant.Level = Plant.Level.Level0
static var celery_level : Plant.Level = Plant.Level.Level0
static var corn_level : Plant.Level = Plant.Level.Level0
static var watermelon_level : Plant.Level = Plant.Level.Level0
static var pepper_level : Plant.Level = Plant.Level.Level0
static var banana_level : Plant.Level = Plant.Level.Level0
static var lemonlime_level : Plant.Level = Plant.Level.Level0
static var willow_level : Plant.Level = Plant.Level.Level0

static var temp_food_supply_level : Plant.Level = Plant.Level.Level0
static var temp_eggplant_level : Plant.Level = Plant.Level.Level0
static var temp_broccoli_level : Plant.Level = Plant.Level.Level0
static var temp_tomato_level : Plant.Level = Plant.Level.Level0
static var temp_potato_level : Plant.Level = Plant.Level.Level0
static var temp_celery_level : Plant.Level = Plant.Level.Level0
static var temp_corn_level : Plant.Level = Plant.Level.Level0
static var temp_watermelon_level : Plant.Level = Plant.Level.Level0
static var temp_pepper_level : Plant.Level = Plant.Level.Level0
static var temp_banana_level : Plant.Level = Plant.Level.Level0
static var temp_lemonlime_level : Plant.Level = Plant.Level.Level0
static var temp_willow_level : Plant.Level = Plant.Level.Level0

#region: Insect functions

static func get_insect_damage(type : Insect.Type):
	match type:
		Insect.Type.FLY:
			return 25
		Insect.Type.GRUB:
			return 10
		Insect.Type.SNAIL:
			return 54
		Insect.Type.MOTH:
			return 40
		Insect.Type.BEE:
			return 16
		Insect.Type.FUNGI:
			return 500
		Insect.Type.ANT:
			return 72
		Insect.Type.CATERPILLAR:
			return 3
		Insect.Type.SPORESPAWN:
			return 200
		Insect.Type.LOCUST:
			return 18
		Insect.Type.BEETLE:
			return 300
		Insect.Type.CRICKET:
			return 2
		Insect.Type.FIREFLY:
			return 780

static func get_insect_health(type : Insect.Type):
	match type:
		Insect.Type.FLY:
			return 3
		Insect.Type.GRUB:
			return 1
		Insect.Type.SNAIL:
			return 50
		Insect.Type.MOTH:
			return 2
		Insect.Type.BEE:
			return 30
		Insect.Type.FUNGI:
			return 30
		Insect.Type.ANT:
			return 400
		Insect.Type.CATERPILLAR:
			return 80
		Insect.Type.SPORESPAWN:
			return 250
		Insect.Type.LOCUST:
			return 3
		Insect.Type.BEETLE:
			return 7200
		Insect.Type.CRICKET:
			return 1200
		Insect.Type.FIREFLY:
			return 800
static func get_insect_kill_reward(type : Insect.Type):
	match type:
		Insect.Type.FLY:
			return 1
		Insect.Type.GRUB:
			return 1
		Insect.Type.SNAIL:
			return 10
		Insect.Type.MOTH:
			return 2
		Insect.Type.BEE:
			return 5
		Insect.Type.FUNGI:
			return 5
		Insect.Type.ANT:
			return 30
		Insect.Type.CATERPILLAR:
			return 10
		Insect.Type.SPORESPAWN:
			return 50
		Insect.Type.LOCUST:
			return 3
		Insect.Type.BEETLE:
			return 100
		Insect.Type.CRICKET:
			return 80
		Insect.Type.FIREFLY:
			return 200
static func get_insect_range(type : Insect.Type):
	match type:
		Insect.Type.FLY:
			return 0
		Insect.Type.GRUB:
			return 0
		Insect.Type.SNAIL:
			return 0
		Insect.Type.MOTH:
			return 3
		Insect.Type.BEE:
			return 0
		Insect.Type.FUNGI:
			return 0
		Insect.Type.ANT:
			return 1
		Insect.Type.CATERPILLAR:
			return 0
		Insect.Type.SPORESPAWN:
			return 5
		Insect.Type.LOCUST:
			return 0
		Insect.Type.BEETLE:
			return 2
		Insect.Type.CRICKET:
			return 6
		Insect.Type.FIREFLY:
			return 8

static func get_insect_attack_cooldown(type : Insect.Type):
	match type:
		Insect.Type.FLY:
			return 1.00
		Insect.Type.GRUB:
			return 0.50
		Insect.Type.SNAIL:
			return 3.60
		Insect.Type.MOTH:
			return 2.00
		Insect.Type.BEE:
			return 0.80
		Insect.Type.FUNGI:
			return 0.1
		Insect.Type.ANT:
			return 1.8
		Insect.Type.CATERPILLAR:
			return 0.2
		Insect.Type.SPORESPAWN:
			return 5.0
		Insect.Type.LOCUST:
			return 0.3
		Insect.Type.BEETLE:
			return 3.0
		Insect.Type.CRICKET:
			return 5.0
		Insect.Type.FIREFLY:
			return 1.3

static func get_insect_string(type : Insect.Type):
	match type:
		Insect.Type.FLY:
			return "fly"
		Insect.Type.GRUB:
			return "grub"
		Insect.Type.SNAIL:
			return "snail"
		Insect.Type.MOTH:
			return "moth"
		Insect.Type.BEE:
			return "bee"
		Insect.Type.FUNGI:
			return "fungi"
		Insect.Type.ANT:
			return "ant"
		Insect.Type.CATERPILLAR:
			return "caterpillar"
		Insect.Type.SPORESPAWN:
			return "sporespawn"
		Insect.Type.LOCUST:
			return "locust"
		Insect.Type.BEETLE:
			return "beetle"
		Insect.Type.CRICKET:
			return "cricket"
		Insect.Type.FIREFLY:
			return "firefly"

static func get_insect_speed(type : Insect.Type):
	match type:
		Insect.Type.FLY:
			return normal
		Insect.Type.GRUB:
			return fast
		Insect.Type.SNAIL:
			return very_slow
		Insect.Type.MOTH:
			return normal
		Insect.Type.BEE:
			return very_fast
		Insect.Type.FUNGI:
			return very_fast
		Insect.Type.ANT:
			return slow
		Insect.Type.CATERPILLAR:
			return very_fast
		Insect.Type.SPORESPAWN:
			return slow
		Insect.Type.LOCUST:
			return very_fast
		Insect.Type.BEETLE:
			return very_slow
		Insect.Type.CRICKET:
			return normal
		Insect.Type.FIREFLY:
			return normal

static func get_insect_detection_range(type : Insect.Type):
	match type:
		Insect.Type.FLY, Insect.Type.GRUB, Insect.Type.MOTH, Insect.Type.BEE, Insect.Type.FUNGI, \
		Insect.Type.ANT, Insect.Type.LOCUST, Insect.Type.BEETLE, \
		Insect.Type.CRICKET:
			return 8
		Insect.Type.SPORESPAWN, Insect.Type.FIREFLY:
			return 12
		Insect.Type.SNAIL, Insect.Type.CATERPILLAR:
			return 80

static func get_insect_hurtbox_radius(type):
	match type:
		Insect.Type.FIREFLY, Insect.Type.ANT, Insect.Type.CRICKET:
			return 4.0
		Insect.Type.SNAIL, Insect.Type.CATERPILLAR:
			return 6.5
		Insect.Type.BEETLE:
			return 10.0
		_:
			return 2.5

#endregion: Insect functions

#region: Plant functions

static func upgrade(type : Plant.Type):
	match type:
		Plant.Type.FOOD_SUPPLY:
			food_supply_level += 1 as Plant.Level
		Plant.Type.EGGPLANT:
			eggplant_level += 1 as Plant.Level
		Plant.Type.BROCCOLI:
			broccoli_level += 1 as Plant.Level			
		Plant.Type.TOMATO:
			tomato_level += 1 as Plant.Level			
		Plant.Type.POTATO:
			potato_level += 1 as Plant.Level			
		Plant.Type.CELERY:
			celery_level += 1 as Plant.Level			
		Plant.Type.CORN:
			corn_level += 1 as Plant.Level			
		Plant.Type.WATERMELON:
			watermelon_level += 1 as Plant.Level			
		Plant.Type.PEPPER:
			pepper_level += 1 as Plant.Level			
		Plant.Type.BANANA:
			banana_level += 1 as Plant.Level			
		Plant.Type.LEMONLIME:
			lemonlime_level += 1 as Plant.Level			
		Plant.Type.WILLOW:
			willow_level += 1 as Plant.Level			

static func temp_set_level(type : Plant.Type, level : Plant.Level):
	match type:
		Plant.Type.FOOD_SUPPLY:
			temp_food_supply_level = food_supply_level
			food_supply_level = level
		Plant.Type.EGGPLANT:
			temp_eggplant_level = eggplant_level
			eggplant_level = level
		Plant.Type.BROCCOLI:
			temp_broccoli_level = broccoli_level
			broccoli_level = level
		Plant.Type.TOMATO:
			temp_tomato_level = tomato_level
			tomato_level = level
		Plant.Type.POTATO:
			temp_potato_level = potato_level
			potato_level = level
		Plant.Type.CELERY:
			temp_celery_level = celery_level
			celery_level = level
		Plant.Type.CORN:
			temp_corn_level = corn_level
			corn_level = level
		Plant.Type.WATERMELON:
			temp_watermelon_level = watermelon_level
			watermelon_level = level
		Plant.Type.PEPPER:
			temp_pepper_level = pepper_level
			pepper_level = level
		Plant.Type.BANANA:
			temp_banana_level = banana_level
			banana_level = level
		Plant.Type.LEMONLIME:
			temp_lemonlime_level = lemonlime_level
			lemonlime_level = level
		Plant.Type.WILLOW:
			temp_willow_level = willow_level
			willow_level = level

static func undo_temp_set_level(type):
	match type:
		Plant.Type.FOOD_SUPPLY:
			food_supply_level = temp_food_supply_level
		Plant.Type.EGGPLANT:
			eggplant_level = temp_eggplant_level
		Plant.Type.BROCCOLI:
			broccoli_level = temp_broccoli_level
		Plant.Type.TOMATO:
			tomato_level = temp_tomato_level
		Plant.Type.POTATO:
			potato_level = temp_potato_level
		Plant.Type.CELERY:
			celery_level = temp_celery_level
		Plant.Type.CORN:
			corn_level = temp_corn_level
		Plant.Type.WATERMELON:
			watermelon_level = temp_watermelon_level
		Plant.Type.PEPPER:
			pepper_level = temp_pepper_level
		Plant.Type.BANANA:
			banana_level = temp_banana_level
		Plant.Type.LEMONLIME:
			lemonlime_level = temp_lemonlime_level
		Plant.Type.WILLOW:
			willow_level = temp_willow_level

static func get_plant_scale(type : Plant.Type):
	match type:
		Plant.Type.WILLOW:
			match willow_level:
				Plant.Level.Level0:
					return Vector2(1, 1)
				Plant.Level.Level1:
					return Vector2(3.5 / 2.5, 3.5 / 2.5)
				Plant.Level.Level2:
					return Vector2(4.5 / 2.5, 4.5 / 2.5)
				Plant.Level.Level3:
					return Vector2(5.5 / 2.5, 5.5 / 2.5)

static func get_plant_damage(type : Plant.Type):
	match type:
		Plant.Type.FOOD_SUPPLY:
			match food_supply_level:
				Plant.Level.Level0:
					return 1
				Plant.Level.Level1:
					return 15
				Plant.Level.Level2: 
					return 50
				Plant.Level.Level3: 
					return 100
		Plant.Type.EGGPLANT:
			return 0
		Plant.Type.BROCCOLI:
			match broccoli_level: 
				Plant.Level.Level0:
					return 1
				Plant.Level.Level1:
					return 2
				Plant.Level.Level2: 
					return 3
				Plant.Level.Level3: 
					return 4
		Plant.Type.TOMATO:
			match tomato_level: 
				Plant.Level.Level0:
					return 12
				Plant.Level.Level1:
					return 18
				Plant.Level.Level2: 
					return 25
				Plant.Level.Level3: 
					return 33
		Plant.Type.POTATO:
			match potato_level:
				Plant.Level.Level0:
					return 50
				Plant.Level.Level1:
					return 75
				Plant.Level.Level2: 
					return 125
				Plant.Level.Level3: 
					return 200
		Plant.Type.CELERY:
			match celery_level: 
				Plant.Level.Level0:
					return 30
				Plant.Level.Level1:
					return 40
				Plant.Level.Level2: 
					return 55
				Plant.Level.Level3: 
					return 85
		Plant.Type.CORN:
			match corn_level:
				Plant.Level.Level0:
					return 3
				Plant.Level.Level1:
					return 6
				Plant.Level.Level2: 
					return 10
				Plant.Level.Level3: 
					return 16
		Plant.Type.WATERMELON:
			match watermelon_level: 
				Plant.Level.Level0:
					return 180
				Plant.Level.Level1:
					return 250
				Plant.Level.Level2: 
					return 320
				Plant.Level.Level3: 
					return 400
		Plant.Type.PEPPER:
			match pepper_level:
				Plant.Level.Level0:
					return 42
				Plant.Level.Level1:
					return 60
				Plant.Level.Level2: 
					return 90
				Plant.Level.Level3: 
					return 120
		Plant.Type.BANANA:
			match banana_level:
				Plant.Level.Level0:
					return 800
				Plant.Level.Level1:
					return 1200
				Plant.Level.Level2: 
					return 1500
				Plant.Level.Level3: 
					return 2000
		Plant.Type.LEMONLIME:
			match lemonlime_level: 
				Plant.Level.Level0:
					return 350
				Plant.Level.Level1:
					return 495
				Plant.Level.Level2: 
					return 720
				Plant.Level.Level3: 
					return 960
		Plant.Type.WILLOW:
			match willow_level: 
				Plant.Level.Level0:
					return 195
				Plant.Level.Level1:
					return 270
				Plant.Level.Level2: 
					return 286
				Plant.Level.Level3: 
					return 320

static func get_plant_health(type : Plant.Type):
	match type:
		Plant.Type.FOOD_SUPPLY:
			match food_supply_level:
				Plant.Level.Level0:
					return 250
				Plant.Level.Level1:
					return 500
				Plant.Level.Level2: 
					return 750
				Plant.Level.Level3: 
					return 1000
		Plant.Type.EGGPLANT:
			match eggplant_level:
				Plant.Level.Level0:
					return 100
				Plant.Level.Level1:
					return 150
				Plant.Level.Level2: 
					return 225
				Plant.Level.Level3: 
					return 300
		Plant.Type.BROCCOLI:
			match broccoli_level: 
				Plant.Level.Level0:
					return 50
				Plant.Level.Level1:
					return 75
				Plant.Level.Level2: 
					return 100
				Plant.Level.Level3: 
					return 150
		Plant.Type.TOMATO:
			match tomato_level: 
				Plant.Level.Level0:
					return 150
				Plant.Level.Level1:
					return 175
				Plant.Level.Level2: 
					return 200
				Plant.Level.Level3: 
					return 225
		Plant.Type.POTATO:
			match potato_level:
				Plant.Level.Level0:
					return 50
				Plant.Level.Level1:
					return 75
				Plant.Level.Level2: 
					return 100
				Plant.Level.Level3: 
					return 150
		Plant.Type.CELERY:
			match celery_level: 
				Plant.Level.Level0:
					return 200
				Plant.Level.Level1:
					return 275
				Plant.Level.Level2: 
					return 350
				Plant.Level.Level3: 
					return 425
		Plant.Type.CORN:
			match corn_level:
				Plant.Level.Level0:
					return 150
				Plant.Level.Level1:
					return 200
				Plant.Level.Level2: 
					return 275
				Plant.Level.Level3: 
					return 350
		Plant.Type.WATERMELON:
			match watermelon_level: 
				Plant.Level.Level0:
					return 500
				Plant.Level.Level1:
					return 600
				Plant.Level.Level2: 
					return 725
				Plant.Level.Level3: 
					return 850
		Plant.Type.PEPPER:
			match pepper_level:
				Plant.Level.Level0:
					return 350
				Plant.Level.Level1:
					return 450
				Plant.Level.Level2: 
					return 600
				Plant.Level.Level3: 
					return 750
		Plant.Type.BANANA:
			match banana_level:
				Plant.Level.Level0:
					return 180
				Plant.Level.Level1:
					return 220
				Plant.Level.Level2: 
					return 260
				Plant.Level.Level3: 
					return 320
		Plant.Type.LEMONLIME:
			match lemonlime_level: 
				Plant.Level.Level0:
					return 800
				Plant.Level.Level1:
					return 1000
				Plant.Level.Level2: 
					return 1200
				Plant.Level.Level3: 
					return 1500
		Plant.Type.WILLOW:
			match willow_level: 
				Plant.Level.Level0:
					return 5500
				Plant.Level.Level1:
					return 6750
				Plant.Level.Level2: 
					return 8000
				Plant.Level.Level3: 
					return 12000

static func get_plant_range(type : Plant.Type):
	match type:
		Plant.Type.FOOD_SUPPLY:
			return 3
		Plant.Type.EGGPLANT:
			return 0
		Plant.Type.BROCCOLI:
			match broccoli_level: 
				Plant.Level.Level0:
					return 3
				Plant.Level.Level1:
					return 3
				Plant.Level.Level2: 
					return 4
				Plant.Level.Level3: 
					return 4
		Plant.Type.TOMATO:
			match tomato_level: 
				Plant.Level.Level0:
					return 2
				Plant.Level.Level1:
					return 2
				Plant.Level.Level2: 
					return 3
				Plant.Level.Level3: 
					return 3
		Plant.Type.POTATO:
			match potato_level:
				Plant.Level.Level0:
					return 1
				Plant.Level.Level1:
					return 2
				Plant.Level.Level2: 
					return 2
				Plant.Level.Level3: 
					return 3
		Plant.Type.CELERY:
			match celery_level: 
				Plant.Level.Level0:
					return 1
				Plant.Level.Level1:
					return 1
				Plant.Level.Level2: 
					return 2
				Plant.Level.Level3: 
					return 2
		Plant.Type.CORN:
			match corn_level:
				Plant.Level.Level0:
					return 4
				Plant.Level.Level1:
					return 4
				Plant.Level.Level2: 
					return 5
				Plant.Level.Level3: 
					return 6
		Plant.Type.WATERMELON:
			match watermelon_level: 
				Plant.Level.Level0:
					return 8
				Plant.Level.Level1:
					return 10
				Plant.Level.Level2: 
					return 12
				Plant.Level.Level3: 
					return 15
		Plant.Type.PEPPER:
			match pepper_level:
				Plant.Level.Level0:
					return 3
				Plant.Level.Level1:
					return 4
				Plant.Level.Level2: 
					return 5
				Plant.Level.Level3: 
					return 5
		Plant.Type.BANANA:
			match banana_level:
				Plant.Level.Level0:
					return 10
				Plant.Level.Level1:
					return 12
				Plant.Level.Level2: 
					return 15
				Plant.Level.Level3: 
					return 20
		Plant.Type.LEMONLIME:
			match lemonlime_level: 
				Plant.Level.Level0:
					return 5
				Plant.Level.Level1:
					return 6
				Plant.Level.Level2: 
					return 7
				Plant.Level.Level3: 
					return 8
		Plant.Type.WILLOW:
			match willow_level: 
				Plant.Level.Level0:
					return 2
				Plant.Level.Level1:
					return 3
				Plant.Level.Level2: 
					return 4
				Plant.Level.Level3: 
					return 5

static func get_plant_attack_cooldown(type : Plant.Type, level : Plant.Level = -1):
	if level >= 0:
		match type:
			Plant.Type.FOOD_SUPPLY:
				match food_supply_level:
					Plant.Level.Level0:
						return 1.0
					Plant.Level.Level1:
						return 1.0
					Plant.Level.Level2: 
						return 1.0
					Plant.Level.Level3: 
						return 1.0
			Plant.Type.EGGPLANT:
				match level:
					Plant.Level.Level0:
						return 10.0
					Plant.Level.Level1:
						return 9.0
					Plant.Level.Level2: 
						return 7.0
					Plant.Level.Level3: 
						return 4.0
			Plant.Type.BROCCOLI:
				match level: 
					Plant.Level.Level0:
						return 1.0
					Plant.Level.Level1:
						return 1.0
					Plant.Level.Level2: 
						return 0.9
					Plant.Level.Level3: 
						return 0.8
			Plant.Type.TOMATO:
				match level: 
					Plant.Level.Level0:
						return 3.0
					Plant.Level.Level1:
						return 2.70
					Plant.Level.Level2: 
						return 2.50
					Plant.Level.Level3: 
						return 2.20
			Plant.Type.POTATO:
				return 1.0
			Plant.Type.CELERY:
				match level: 
					Plant.Level.Level0:
						return 1.5
					Plant.Level.Level1:
						return 1.4
					Plant.Level.Level2: 
						return 1.25
					Plant.Level.Level3: 
						return 1.0
			Plant.Type.CORN:
				match level:
					Plant.Level.Level0:
						return 0.2
					Plant.Level.Level1:
						return 0.2
					Plant.Level.Level2: 
						return 0.15
					Plant.Level.Level3: 
						return 0.1
			Plant.Type.WATERMELON:
				match level: 
					Plant.Level.Level0:
						return 7.00
					Plant.Level.Level1:
						return 6.70
					Plant.Level.Level2: 
						return 6.20
					Plant.Level.Level3: 
						return 5.5
			Plant.Type.PEPPER:
				return 0.5
			Plant.Type.BANANA:
				match level:
					Plant.Level.Level0:
						return 5.0
					Plant.Level.Level1:
						return 4.80
					Plant.Level.Level2: 
						return 4.5
					Plant.Level.Level3: 
						return 4.0
			Plant.Type.LEMONLIME:
				match level: 
					Plant.Level.Level0:
						return 0.5
					Plant.Level.Level1:
						return 0.45
					Plant.Level.Level2: 
						return 0.4
					Plant.Level.Level3: 
						return 0.3
			Plant.Type.WILLOW:
				match level: 
					Plant.Level.Level0:
						return 1.3
					Plant.Level.Level1:
						return 1.2
					Plant.Level.Level2: 
						return 1.1
					Plant.Level.Level3: 
						return 1.0
	else:
		match type:
			Plant.Type.FOOD_SUPPLY:
				match food_supply_level:
					Plant.Level.Level0:
						return 1.0
					Plant.Level.Level1:
						return 1.0
					Plant.Level.Level2: 
						return 1.0
					Plant.Level.Level3: 
						return 1.0
			Plant.Type.EGGPLANT:
				match eggplant_level:
					Plant.Level.Level0:
						return 10.0
					Plant.Level.Level1:
						return 9.0
					Plant.Level.Level2: 
						return 7.0
					Plant.Level.Level3: 
						return 4.0
			Plant.Type.BROCCOLI:
				match broccoli_level: 
					Plant.Level.Level0:
						return 1.0
					Plant.Level.Level1:
						return 1.0
					Plant.Level.Level2: 
						return 0.9
					Plant.Level.Level3: 
						return 0.8
			Plant.Type.TOMATO:
				match tomato_level: 
					Plant.Level.Level0:
						return 3.0
					Plant.Level.Level1:
						return 2.70
					Plant.Level.Level2: 
						return 2.50
					Plant.Level.Level3: 
						return 2.20
			Plant.Type.POTATO:
				return 1.0
			Plant.Type.CELERY:
				match celery_level: 
					Plant.Level.Level0:
						return 1.5
					Plant.Level.Level1:
						return 1.4
					Plant.Level.Level2: 
						return 1.25
					Plant.Level.Level3: 
						return 1.0
			Plant.Type.CORN:
				match corn_level:
					Plant.Level.Level0:
						return 0.2
					Plant.Level.Level1:
						return 0.2
					Plant.Level.Level2: 
						return 0.15
					Plant.Level.Level3: 
						return 0.1
			Plant.Type.WATERMELON:
				match watermelon_level: 
					Plant.Level.Level0:
						return 7.00
					Plant.Level.Level1:
						return 6.70
					Plant.Level.Level2: 
						return 6.20
					Plant.Level.Level3: 
						return 5.5
			Plant.Type.PEPPER:
				return 0.5
			Plant.Type.BANANA:
				match banana_level:
					Plant.Level.Level0:
						return 5.0
					Plant.Level.Level1:
						return 4.80
					Plant.Level.Level2: 
						return 4.5
					Plant.Level.Level3: 
						return 4.0
			Plant.Type.LEMONLIME:
				match lemonlime_level: 
					Plant.Level.Level0:
						return 0.5
					Plant.Level.Level1:
						return 0.45
					Plant.Level.Level2: 
						return 0.4
					Plant.Level.Level3: 
						return 0.3
			Plant.Type.WILLOW:
				match willow_level: 
					Plant.Level.Level0:
						return 1.3
					Plant.Level.Level1:
						return 1.2
					Plant.Level.Level2: 
						return 1.1
					Plant.Level.Level3: 
						return 1.0

static func get_plant_spawn_duration(type : Plant.Type):
	match type:
		Plant.Type.FOOD_SUPPLY:
			return 1.0
		Plant.Type.EGGPLANT:
			return 5.0
		Plant.Type.BROCCOLI:
			return 1.0
		Plant.Type.TOMATO:
			return 3.0
		Plant.Type.POTATO:
			return 0.5
		Plant.Type.CELERY:
			return 5.0
		Plant.Type.CORN:
			return 10.0
		Plant.Type.WATERMELON:
			return 30.0
		Plant.Type.PEPPER:
			return 15.0
		Plant.Type.BANANA:
			return 60.0
		Plant.Type.LEMONLIME:
			return 150.0
		Plant.Type.WILLOW:
			return 180.0

static func get_plant_health_decay(type : Plant.Type):
	match type:
		Plant.Type.FOOD_SUPPLY:
			return -1.66
		Plant.Type.BROCCOLI:
			return 5.0
	return 0.0

static func get_next_upgrade_cost(type : Plant.Type):
	match type:
		Plant.Type.EGGPLANT:
			match eggplant_level:
				Plant.Level.Level0:
					return 100
				Plant.Level.Level1:
					return 200
				Plant.Level.Level2: 
					return 300
		Plant.Type.BROCCOLI:
			match broccoli_level: 
				Plant.Level.Level0:
					return 20
				Plant.Level.Level1:
					return 40
				Plant.Level.Level2: 
					return 80
		Plant.Type.TOMATO:
			match tomato_level: 
				Plant.Level.Level0:
					return 30
				Plant.Level.Level1:
					return 60
				Plant.Level.Level2: 
					return 120
		Plant.Type.POTATO:
			match potato_level: 
				Plant.Level.Level0:
					return 50
				Plant.Level.Level1:
					return 100
				Plant.Level.Level2: 
					return 200
		Plant.Type.CELERY:
			match celery_level: 
				Plant.Level.Level0:
					return 60
				Plant.Level.Level1:
					return 120
				Plant.Level.Level2: 
					return 240
		Plant.Type.CORN:
			match corn_level:
				Plant.Level.Level0:
					return 100
				Plant.Level.Level1:
					return 200
				Plant.Level.Level2: 
					return 400
		Plant.Type.WATERMELON:
			match watermelon_level: 
				Plant.Level.Level0:
					return 200
				Plant.Level.Level1:
					return 350
				Plant.Level.Level2: 
					return 650
		Plant.Type.PEPPER:
			match pepper_level: 
				Plant.Level.Level0:
					return 400
				Plant.Level.Level1:
					return 600
				Plant.Level.Level2: 
					return 900
		Plant.Type.BANANA:
			match banana_level:
				Plant.Level.Level0:
					return 600
				Plant.Level.Level1:
					return 800
				Plant.Level.Level2: 
					return 1200
		Plant.Type.LEMONLIME:
			match lemonlime_level: 
				Plant.Level.Level0:
					return 3000
				Plant.Level.Level1:
					return 5500
				Plant.Level.Level2: 
					return 8000
		Plant.Type.WILLOW:
			match willow_level:
				Plant.Level.Level0:
					return 4000
				Plant.Level.Level1:
					return 7000
				Plant.Level.Level2: 
					return 10000
	return -1

static func get_current_upgrade_cost(type : Plant.Type):
	match type:
		Plant.Type.EGGPLANT:
			match eggplant_level:
				Plant.Level.Level1:
					return 100
				Plant.Level.Level2:
					return 200
				Plant.Level.Level3: 
					return 300
		Plant.Type.BROCCOLI:
			match broccoli_level: 
				Plant.Level.Level1:
					return 20
				Plant.Level.Level2:
					return 40
				Plant.Level.Level3: 
					return 80
		Plant.Type.TOMATO:
			match tomato_level: 
				Plant.Level.Level1:
					return 30
				Plant.Level.Level2:
					return 60
				Plant.Level.Level3: 
					return 120
		Plant.Type.POTATO:
			match potato_level: 
				Plant.Level.Level1:
					return 50
				Plant.Level.Level2:
					return 100
				Plant.Level.Level3: 
					return 200
		Plant.Type.CELERY:
			match celery_level: 
				Plant.Level.Level1:
					return 60
				Plant.Level.Level2:
					return 120
				Plant.Level.Level3: 
					return 240
		Plant.Type.CORN:
			match corn_level:
				Plant.Level.Level1:
					return 100
				Plant.Level.Level2:
					return 200
				Plant.Level.Level3: 
					return 400
		Plant.Type.WATERMELON:
			match watermelon_level: 
				Plant.Level.Level1:
					return 200
				Plant.Level.Level2:
					return 350
				Plant.Level.Level3: 
					return 650
		Plant.Type.PEPPER:
			match pepper_level: 
				Plant.Level.Level1:
					return 400
				Plant.Level.Level2:
					return 600
				Plant.Level.Level3: 
					return 900
		Plant.Type.BANANA:
			match banana_level:
				Plant.Level.Level1:
					return 600
				Plant.Level.Level2:
					return 800
				Plant.Level.Level3: 
					return 1200
		Plant.Type.LEMONLIME:
			match lemonlime_level: 
				Plant.Level.Level1:
					return 3000
				Plant.Level.Level2:
					return 5500
				Plant.Level.Level3: 
					return 8000
		Plant.Type.WILLOW:
			match willow_level:
				Plant.Level.Level1:
					return 4000
				Plant.Level.Level2:
					return 7000
				Plant.Level.Level3: 
					return 10000
	return -1


static func get_plant_cost(type : Plant.Type):
	match type:
		Plant.Type.EGGPLANT:
			return 5
		Plant.Type.BROCCOLI:
			return 1			
		Plant.Type.TOMATO:
			return 8
		Plant.Type.POTATO:
			return 10
		Plant.Type.CELERY:
			return 16
		Plant.Type.CORN:
			return 28
		Plant.Type.WATERMELON:
			return 40
		Plant.Type.PEPPER:
			return 60
		Plant.Type.BANANA:
			return 100
		Plant.Type.LEMONLIME:
			return 350
		Plant.Type.WILLOW:
			return 500

static func get_plant_blurb(type : Plant.Type):
	match type:
		Plant.Type.EGGPLANT:
			return "The starting production tower. Generates food at a slow but steady rate"
		Plant.Type.BROCCOLI:
			return "The starting tower. Fires single-target florets that deal low damage at a medium rate"
		Plant.Type.TOMATO:
			return "A short-range multi-target tower. Spews fire in a cone, dealing moderate area damage"
		Plant.Type.POTATO:
			return "A cheap but effective one-time use area damage tower. Blows up after a brief delay when an enemy enters its range"
		Plant.Type.CELERY:
			return "A short-range melee tower with high health. Deals powerful single-target attacks to enemies"
		Plant.Type.CORN:
			return "A single-target tower with a high firerate. Pelts enemies with kernels of corn"
		Plant.Type.WATERMELON:
			return "A long-range mortar tower. Hurls watermelons that explode in a large radius on impact"
		Plant.Type.PEPPER:
			return "A strong single-target tower that attaches to and continuously attacks one enemy until it dies before switching targets"
		Plant.Type.BANANA:
			return "A long-range sniper tower. Fires heavy projectiles that deal high single-target damage but at a slow rate"
		Plant.Type.LEMONLIME:
			return "An extremely high damage tower that spews volatile acid at a fast rate. Melts armor and shreds bosses"
		Plant.Type.WILLOW:
			return "An expensive but exceptionally powerful tower that deals high melee damage to multiple enemies at once"

static func get_plant_upgrade_blurb(type : Plant.Type, level : Plant.Level):
	return ""
	match type: 
		Plant.Type.EGGPLANT:
			match level: # TODO
				Plant.Level.Level1:
					return "Level 1 upgrade blurb not added yet"
				Plant.Level.Level2: 
					return "Level 2 upgrade blurb not added yet"
				Plant.Level.Level3: 
					return "Level 3 upgrade blurb not added yet"
		Plant.Type.BROCCOLI:
			match level: # TODO
				Plant.Level.Level1:
					return "Level 1 upgrade blurb not added yet"
				Plant.Level.Level2: 
					return "Level 2 upgrade blurb not added yet"
				Plant.Level.Level3: 
					return "Level 3 upgrade blurb not added yet"
		_:
			return "-1"
static func get_plant_special_blurb(type : Plant.Type):
	match type:
		Plant.Type.BROCCOLI:
			return "Health Decay Rate"
		Plant.Type.WILLOW:
			return "Number of Arms"
		_:
			return "Special Stat (N/A)"

static func get_plant_special_value(type : Plant.Type): 
	match type:
		Plant.Type.WILLOW:
			match willow_level:
				Plant.Level.Level0:
					return 2
				Plant.Level.Level1:
					return 3
				Plant.Level.Level2: 
					return 5
				Plant.Level.Level3: 
					return 8
		Plant.Type.BROCCOLI:
			return str(get_plant_health_decay(Plant.Type.BROCCOLI)) + "%/sec"
	return ""

static func get_plant_level(type : Plant.Type):
	match type:
		Plant.Type.FOOD_SUPPLY:
			return food_supply_level
		Plant.Type.EGGPLANT:
			return eggplant_level
		Plant.Type.BROCCOLI:
			return broccoli_level
		Plant.Type.TOMATO:
			return tomato_level
		Plant.Type.POTATO:
			return potato_level
		Plant.Type.CELERY:
			return celery_level
		Plant.Type.CORN:
			return corn_level
		Plant.Type.WATERMELON:
			return watermelon_level
		Plant.Type.PEPPER:
			return pepper_level
		Plant.Type.BANANA:
			return banana_level
		Plant.Type.LEMONLIME:
			return lemonlime_level
		Plant.Type.WILLOW:
			return willow_level

static func get_plant_string(type):
	match type:
		Plant.Type.FOOD_SUPPLY:
			return "food_supply"
		Plant.Type.EGGPLANT:
			return "eggplant"
		Plant.Type.BROCCOLI:
			return "broccoli"
		Plant.Type.TOMATO:
			return "tomato"
		Plant.Type.POTATO:
			return "potato"
		Plant.Type.CELERY:
			return "celery"
		Plant.Type.CORN:
			return "corn"
		Plant.Type.WATERMELON:
			return "watermelon"
		Plant.Type.PEPPER:
			return "pepper"
		Plant.Type.BANANA:
			return "banana"
		Plant.Type.LEMONLIME:
			return "lemonlime"
		Plant.Type.WILLOW:
			return "willow"

static func get_plant_display_string(type):
	match type:
		Plant.Type.FOOD_SUPPLY:
			return "Food Supply"
		Plant.Type.EGGPLANT:
			return "Eggplant"
		Plant.Type.BROCCOLI:
			return "Broccoli"
		Plant.Type.TOMATO:
			return "Tomato"
		Plant.Type.POTATO:
			return "Potato"
		Plant.Type.CELERY:
			return "Celery"
		Plant.Type.CORN:
			return "Corn"
		Plant.Type.WATERMELON:
			return "Watermelon"
		Plant.Type.PEPPER:
			return "Pepper"
		Plant.Type.BANANA:
			return "Banana"
		Plant.Type.LEMONLIME:
			return "Lemon and Lime"
		Plant.Type.WILLOW:
			return "Weeping Willow"

static func get_plant_projectile_scale(type):
	var range = get_plant_range(type)
	match type:
		Plant.Type.POTATO:
			# FIXME hardcoded base range
			const BASE_RANGE = 1.5
			var factor = (range + 0.5) / BASE_RANGE
			return Vector2(factor, factor)
		Plant.Type.TOMATO:
			# FIXME hardcoded base range
			const BASE_RANGE = 2.5
			var factor = (range + 0.5) / BASE_RANGE
			return Vector2(factor, factor)
		_:
			return Vector2(1, 1)
#endregion: Plant functions

#region: General functions

static func restart():
	food_supply_level = Plant.Level.Level0
	eggplant_level = Plant.Level.Level0
	broccoli_level = Plant.Level.Level0
	tomato_level = Plant.Level.Level0
	celery_level = Plant.Level.Level0
	corn_level = Plant.Level.Level0
	potato_level = Plant.Level.Level0
	banana_level = Plant.Level.Level0
	pepper_level = Plant.Level.Level0
	lemonlime_level = Plant.Level.Level0
	willow_level = Plant.Level.Level0



static func give_zoom_shader(node_with_mat : Node2D):
	node_with_mat.material = ShaderMaterial.new()
	node_with_mat.material.shader = better_zoom_shader
	if node_with_mat is Plant:
		node_with_mat.material.set_shader_parameter("use_gradient", 1.0)
		node_with_mat.material.set_shader_parameter("gradient", plant_outline_gradient)
		node_with_mat.material.set_shader_parameter("scroll_dir", 1.0)
		node_with_mat.material.set_shader_parameter("scroll_speed", 0.0)

static func set_range_area_radii(shape : CollisionShape2D, tile_radius : int):
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 8 + 16 * tile_radius



static func calc_arc_between(p1 : Vector2, p2 : Vector2):
	var points = []
	for i in range(num_points + 1):
		var t := float(i) / float(num_points)
		var x = lerp(p1.x, p2.x, t)
		var y = lerp(p1.y, p2.y, t) - arc_height * sin(PI * t)
		points.append(Vector2(x, y))
	return points

static func calc_point_on_arc_between(p1 : Vector2, p2 : Vector2, t : float):
	var x = lerp(p1.x, p2.x, t)
	var y = lerp(p1.y, p2.y, t) - arc_height * sin(PI * t)
	return Vector2(x, y)
	
static func tween_arc_between(parent : Node2D, p1 : Vector2, p2 : Vector2, duration : float):
	var hoz_tween = parent.create_tween()
	var vert_tween = parent.create_tween()
	var half_dur = duration / 2.0
	
	var diff = p2 - p1
	var angle = (diff).angle()
	if angle < PI / 4 or (angle > PI * 0.75 and angle < PI):
		# Throwing horizontally, so y should have a smooth arc and x should be linear
		hoz_tween.tween_property(parent, "global_position:x", p2.x, duration).from(p1.x)
		vert_tween.tween_property(parent, "global_position:y", p2.y - arc_height, half_dur).from(p1.y).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		vert_tween.tween_property(parent, "global_position:y", p2.y, half_dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	else:
		# Throwing vertically, so opposite
		hoz_tween.tween_property(parent, "global_position:x", p2.x - diff.x / 2, half_dur).from(p1.x).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		hoz_tween.tween_property(parent, "global_position:x", p2.x, half_dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		vert_tween.tween_property(parent, "global_position:y", p2.y - arc_height, half_dur).from(p1.y).set_ease(Tween.EASE_OUT)
		vert_tween.tween_property(parent, "global_position:y", p2.y, half_dur).set_ease(Tween.EASE_IN)
		
	
	return hoz_tween

#endregion: General functions
