Simulator = require './simulator'
{ItoVM, KomaVM, YubinukiVM, SasiType} = require './viewmodel'

# ===============
#  Application
# ===============

ANIMATION_INTERVAL_MS = 500

class YubinukiSimulatorVM
	constructor: ->
		canvas = document.getElementById('canvas');
		cc = canvas.getContext('2d');
		cc.save()

		self = @

		@executing = false
		@simulator = new Simulator(canvas, cc)
		@yubinuki = ko.observable(new YubinukiVM(8, 2, 30, false))
		@stepSimulation = ko.observable(false)
		@stepNum = ko.observable(10)
		@stepMax = ko.computed( ->
			yubinuki = self.yubinuki()
			# TODO 重ね刺しの場合
			max = yubinuki.fmTobi() * yubinuki.fmResolution()
			console.log "stepMax", max
			return max
		, @)
		@showAnimation = ko.observable(false)
		@animationStep = ko.observable(0)
		@animationStepMax = ko.observable(@stepMax())
		@animationProgress = ko.computed( ->
			Math.ceil(self.animationStep() / self.animationStepMax() * 100)
		)

		@simulator.drawScaleOnly(@yubinuki())

		# TEST
		yb = @yubinuki()
		yb.startManualSet()
		yb.clearKoma()
		koma = yb.addKoma(0, SasiType.Nami, false)
		koma.addIto('blue', 5)
		koma.addIto('skyblue', 5)
		koma = yb.addKoma(1, SasiType.Nami, false)
		koma.addIto('red', 1)
		yb.endManualSet()

	simulate: ->
		if @executing
			console.log "前回のシミュレーションが終了していません。しばらくお待ちください。"
			return

		@executing = true
		yubinuki = @getYubinuki()
		animation = @showAnimation()

		if animation
			animationStepMax = @stepMax()
			if @stepSimulation()
				animationStepMax = @stepNum()
			@animationStepMax(animationStepMax)

			console.log "Simulator Mode ANIMATION, maxStep=", animationStepMax

			@animationStep(0)
			animationSimulator = @
			animationCb = null
			animate = ->
				animationStep = animationSimulator.animationStep()
				if animationStep >= animationStepMax
					clearInterval(animationCb)
					animationSimulator.simulateEnded()
					return
				animationSimulator.animationStep(animationStep + 1)
				ret = animationSimulator.simulator.simulate(yubinuki, true, animationStep)
				if !ret
					clearInterval(animationCb)
					animationSimulator.simulateEnded()
			animationCb = setInterval(animate, ANIMATION_INTERVAL_MS)
		else
			@simulator.simulate(yubinuki, @stepSimulation(), @stepNum())
			@simulateEnded()

	simulateEnded: ->
		@executing = false

		canvas = document.getElementById('canvas');
		cc = canvas.getContext('2d');
		cc.restore()

	getYubinuki: ->
#		yubinuki = new YubinukiVM(8, 2, 30, false)
#		koma = yubinuki.addKoma(0)
#		koma.addIto('blue', 1)
#		koma = yubinuki.addKoma(0, false)
#		koma.addIto('red', 1)
#		return yubinuki
		@yubinuki()

ko.applyBindings(new YubinukiSimulatorVM())

# ===============
#  色一覧 開閉
# ===============

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