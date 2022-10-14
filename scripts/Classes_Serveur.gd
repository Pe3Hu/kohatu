extends Node


class Ressource:
	var num = {}
	var word = {}
	var obj = {}
	
	func _init(input_):
		num.value = {}
		num.value.max = 100
		num.value.current = 0
		word.name = input_.name
		word.type = input_.type

class Module:
	var num = {}
	var word = {}
	var obj = {}
	
	func _init(input_):
		num.energy = {}
		num.job = {}
		word.type = input_.type
		num.job.power = input_.power
		num.job.efficiency = input_.efficiency
		num.payload = input_.payload
		num.energy.battery = input_.battery
		num.energy.consumption = input_.consumption

class Drone:
	var num = {}
	var word = {}
	var arr = {}
	var obj = {}
	
	func _init(input_):
		word.type = input_.type
		arr.module = []
		
		init_modules()

	func init_modules():
		var input = {}
		input.type = "Chassis"
		input.power = 100
		input.efficiency = 0.1
		input.payload = 100
		input.battery = 1000
		input.consumption = 1
		var module = Classes_Serveur.Module.new(input)
		arr.module.append(module)
		
		input.type = Global.dict.drone.job[word.type]
		input.power = 100
		input.efficiency = 0.1
		input.battery = 1000
		input.consumption = 1
		module = Classes_Serveur.Module.new(input)
		arr.module.append(module)

class Server:
	var num = {}
	var arr = {}
	var obj = {}
	
	func _init(input_):
		arr.drone = []
		init_basic_drones()

	func init_basic_drones():
		var input = {}
		input.type = "Driller"
		var drone = Classes_Serveur.Drone.new(input)
		arr.drone.append(drone)
		
		input.type = "Carter"
		drone = Classes_Serveur.Drone.new(input)
		arr.drone.append(drone)
		
		input.type = "Keeper"
		drone = Classes_Serveur.Drone.new(input)
		arr.drone.append(drone)
		
		input.type = "Scouter"
		drone = Classes_Serveur.Drone.new(input)
		arr.drone.append(drone)
		
		input.type = "Reviser"
		drone = Classes_Serveur.Drone.new(input)
		arr.drone.append(drone)
		
		input.type = "Prognosticator"
		drone = Classes_Serveur.Drone.new(input)
		arr.drone.append(drone)
		
		input.type = "Planner"
		drone = Classes_Serveur.Drone.new(input)
		arr.drone.append(drone)
		
		input.type = "Broadcaster"
		drone = Classes_Serveur.Drone.new(input)
		arr.drone.append(drone)
