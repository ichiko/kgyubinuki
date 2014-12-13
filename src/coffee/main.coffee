Simulator = require('./simulator.js')
{ValidatableModel, Ito, Koma, Yubinuki, Direction} = require '../../src/js/yubinuki.js'

class YubinukiSimulatorVM
	constructor: ->
		canvas = document.getElementById('canvas');
		cc = canvas.getContext('2d');
		cc.save()

		@simulator = new Simulator(cc)

	simulate: ->
		yubinuki = @getYubinuki()
		@simulator.draw(yubinuki)

		canvas = document.getElementById('canvas');
		cc = canvas.getContext('2d');
		cc.restore()

	getYubinuki: ->
		yubinuki = new Yubinuki(8, 2, 30, false)
		koma = yubinuki.addKoma(0)
		koma.addIto('blue', 10)
		koma.addIto('red', 5)
		return yubinuki

ko.applyBindings(new YubinukiSimulatorVM())

#CHECKER_MAX = 100
#
#class Sasi
#	constructor: (offset, @color, round) ->
#		self = @
#
#		@offset = ko.observable(offset)
#		@validOffset = ko.observable(true)
#		@round = ko.observable(round)
#		@validRound = ko.observable(true)
#
#		@formattedOffset = ko.computed({
#		read: ->
#			value = @offset()
#			if isNaN(value)
#				value = parseInt(value.replace(/[^\d]/g, ""))
#				if isNaN(value)
#					value = 0
#			@offset(value)
#			return value
#		write: (value) ->
#			value = parseInt(value.replace(/[^\d]/g, ""))
#			if isNaN(value)
#				@validOffset(false)
#			else
#				@validOffset(true)
#				@offset(value)
#		owner: @
#		})
#
#		@formattedRound = ko.computed({
#		read: ->
#			value = @round()
#			if isNaN(value)
#				value = parseInt(value.replace(/[^\d]/g, ""))
#				if isNaN(value)
#					value = 0
#			@round(if value <= 0 then 1 else value)
#			return @round()
#		write: (value) ->
#			value = parseInt(value.replace(/[^\d]/g, ""))
#			if isNaN(value)
#				@validRound(false)
#			else
#				@validRound(true)
#				@round(value)
#		owner: @
#		})
#
#class PatternViewModel
#	constructor: ->
#		@patterns = ko.observableArray([
#			new Sasi(0, 'red', 1)
#			new Sasi(0, 'blue', 1)
#		])
#		@division = ko.observable(8)
#		@jump = ko.observable(2)
#		@resolution = ko.observable(30)
#		@step_simulation = ko.observable(false)
#		@steps = ko.observable(3)
#
#	addPattern: ->
#		@patterns.push(new Sasi(0, '#000000', 1))
#
#	# ★注意★
#	# ViewModelの子として定義できるが、実行コンテキストはViewModelでない
#	# このメソッドが実行されるとき、@ == pattern
#	removePattern: (pattern) ->
#		vm.patterns.remove(pattern)
#
#	duplicate: (pattern) ->
#		vm.patterns.push(new Sasi(pattern.offset, pattern.color, pattern.round))
#
#	moveUp: (pattern) ->
#		index = vm.patterns.indexOf(pattern)
#		if (index > 0)
#			vm.patterns.remove(pattern)
#			vm.patterns.splice(index - 1, 0, pattern)
#
#	moveDown: (pattern) ->
#		index = vm.patterns.indexOf(pattern)
#		if (index < vm.patterns().length)
#			vm.patterns.remove(pattern)
#			vm.patterns.splice(index + 1, 0, pattern)
#
#	draw: ->
#		canvas = document.getElementById('canvas');
#		cc = canvas.getContext('2d');
#
#		cc.clearRect(0, 0, canvas.width, canvas.height);
#		cc.save()
#
#		@drawScale(cc)
#		cc.restore()
#
#		div = vm.division()
#		jump = vm.jump()
#		resolution = vm.resolution()
#		step_simulation = vm.step_simulation()
#		steps = vm.steps()
#		round_max = resolution * jump
#
#		if step_simulation
#			round_max = steps * jump
#
#		console.log "div=", div, "jump=", jump, "resolution=", resolution, "stepSimulation=", step_simulation, "steps=", steps, "round_max=", round_max
#
#		## FIXME
#		# ・トビをかえると、元の値に戻ってもシミュレーション結果がおかしい
#		# ・条件により無限ループする
#
#		sec = 400 / div
#		if resolution > 0
#			hari = sec / resolution
#		else 
#			hari = 0
#		offset_scale = 40
#
#		console.log "sec=", sec, "hari=", hari
#
#		patterns = vm.patterns()
#		offset_hari = []
#		for j in [0...patterns.length]
#			offset_hari.push -hari
#
#		rounds = 1
#		checker = 1
#		while (rounds < round_max) and (checker < CHECKER_MAX)
#			checker += 1
#
#			for sasi, idx in patterns
#				round = sasi.round()
#				offset = sasi.offset()
#				color = sasi.color
#
#				if rounds <= patterns.length
#					console.log "round=", round, ", offset=", offset, ", color=", color
#
#				h = 0
#				while h < round
#					h += 1
#
#					rounds += 1
#					offset_x = 0
#					offset_hari[offset] += hari
#					offset_x = offset_hari[offset]
#
#					i = offset
#					while i <= div
#						cc.beginPath()
#						cc.strokeStyle = color
#						cc.moveTo(offset_scale + offset_x + sec * i, 50)
#						cc.lineTo(offset_scale + offset_x + sec * (i + jump / 2), 80)
#						cc.stroke()
#
#						cc.beginPath()
#						cc.moveTo(offset_scale + offset_x + sec * (i - jump / 2), 80)
#						cc.lineTo(offset_scale + offset_x + sec * i, 50)
#						cc.stroke()
#
#						i += jump
#
#		cc.restore()
#
#
#	drawScale: (cc) ->
#		div = @division()
#		sec = 400 / div
#
#		offset_x = 40
#
#		for i in [0..div]
#			cc.beginPath()
#			cc.strokeStyle = '#000'
#			cc.moveTo(offset_x + sec * i, 30)
#			cc.lineTo(offset_x + sec * i, 100)
#			cc.stroke()
#
#
#vm = new PatternViewModel
#
#ko.applyBindings(vm)

#------

$('#colorpallet').hide()

$('#colorpallet_link').click ->
	text = ''
	if ($('#colorpallet').is(':visible'))
		text = '開く'
	else
		text = '閉じる'
	$('#colorpallet_link').html(text)
	$('#colorpallet').toggle()


console.log("hoge")