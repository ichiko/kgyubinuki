Simulator = require './simulator'
{ItoVM, KomaVM, YubinukiVM, SasiType} = require './viewmodel'
Formatter = require './formatter'

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
		@simulator.canvasResized()

		@yubinuki = ko.observable(new YubinukiVM(8, 2, 30))
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

		@dataToSave = ko.computed( ->
			JSON.stringify(Formatter.pack(self.yubinuki()))
		)
		@dataToLoad = ko.observable("a")

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

		@simulate()

	cmdSimulate: ->
		@simulate()

	simulate: (silent = false)->
		if @executing
			alert("前回のシミュレーションが終了していません。しばらくお待ちください。")
			return

		@executing = true
		yubinuki = @getYubinuki()
		animation = @showAnimation()

		if animation && !silent
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
			@simulator.simulate(yubinuki, @stepSimulation(), @stepNum(), silent)
			@simulateEnded()

	simulateEnded: ->
		@executing = false

		canvas = document.getElementById('canvas');
		cc = canvas.getContext('2d');
		cc.restore()

	getYubinuki: ->
		@yubinuki()

	loadYubinuki: ->
		input = @dataToLoad()
		json = []
		try
			json = JSON.parse(input)
		catch e
			console.log e
			alert("読み込みに失敗しました。形式が正しくありません。")
			return
		console.log json
		yubinuki = Formatter.unpack(json)
		@yubinuki(yubinuki)
		@simulate()
		$('#dataTextLoad').modal('hide')

vm = new YubinukiSimulatorVM()

# ===============
#  キャンバスサイズ
# ===============

queue = null
RESIZE_WAIT = 300
canvasContainer = $("#canvasContainer")
canvas1 = $("#canvas")[0]

setCanvasSize = ->
	canvas1.width = canvasContainer.width()
	canvas1.height = canvasContainer.height()
	console.log canvas1.width, canvas1.height
	vm.simulator.canvasResized()
	vm.simulate(true)

$(window).resize( ->
	console.log "resize"
	clearTimeout(queue)
	queue = setTimeout( ->
		setCanvasSize()
	, RESIZE_WAIT)
)

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

# ===============
#  Run
# ===============

ko.applyBindings(vm)
setCanvasSize()

console.log("hoge")