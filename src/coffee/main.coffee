Simulator = require './simulator'
{ItoVM, KomaVM, YubinukiVM, SasiType} = require './viewmodel'
Formatter = require './formatter'
YubinukiStorage = require './storage'

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
		@storage = ko.observable(new YubinukiStorage())
		@storage().loadAll()

		@enableStorage = store.enabled
		@yubinuki = ko.observable(new YubinukiVM(8, 2, 30))
		@stepSimulation = ko.observable(false)
		@stepNum = ko.observable(10)
		@stepMax = ko.computed( ->
			yubinuki = self.yubinuki()
			max = yubinuki.fmTobi() * yubinuki.fmResolution()
			return max
		, @)
		@showAnimation = ko.observable(false)
		@animationStep = ko.observable(0)
		@animationStepMax = ko.observable(@stepMax())
		@animationProgress = ko.computed( ->
			Math.ceil(self.animationStep() / self.animationStepMax() * 100)
		)

		@selectedStorageId = ko.observable("store01")
		@saveComment = ko.observable("")
		@selectedStorage = ko.computed({
			read: ->
				id = self.selectedStorageId()
				obj = self.storage().load(id)
				return obj
			write: (obj) ->
				if obj
					self.selectedStorageId(obj.key)
					self.saveComment(obj.comment)
			owner: self
		})
		@saveComment(@storage().load(@selectedStorageId()).comment)

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

	openSave: ->
		if !@getYubinuki().fmValid()
			alert("保存できません。入力エラーがあります。")
			return

		savePanel = $('#saveInformation')
		loadPanel = $('#loadInformation')
		if savePanel.hasClass('in')
			savePanel.collapse('hide')
			return
		if loadPanel.hasClass('in')
			loadPanel.collapse('hide')
			loadPanel.on('hidden.bs.collapse', ->
				savePanel.collapse('show')
				loadPanel.off('hidden.bs.collapse')
			)
		else
			savePanel.collapse('show')

	openLoad: ->
		savePanel = $('#saveInformation')
		loadPanel = $('#loadInformation')
		if loadPanel.hasClass('in')
			loadPanel.collapse('hide')
			return
		if savePanel.hasClass('in')
			savePanel.collapse('hide')
			savePanel.on('hidden.bs.collapse', ->
				loadPanel.collapse('show')
				savePanel.off('hidden.bs.collapse')
			)
		else
			loadPanel.collapse('show')

	saveYubinuki: ->
		if !@getYubinuki().fmValid()
			alert("保存できません。入力エラーがあります。")
			return

		key = @selectedStorageId()
		comment = @saveComment()
		@storage().save key, comment, Formatter.pack(@getYubinuki())
		@selectedStorage(@storage().load(key))
		alert("data No." + key + "に保存しました。")
		$('#saveInformation').collapse('hide')

	loadYubinuki: ->
		key = @selectedStorageId()
		data = @storage().load(key)
		if data
			yubinuki = Formatter.unpack(data.data)
			@yubinuki(yubinuki)
			@simulate()
			alert("data No." + key + "から読み込みました。")
			$('#loadInformation').collapse('hide')
		else
			alert("指定の場所にはデータが存在しませんでした。")

	closeSave: ->
		$('#saveInformation').collapse('toggle')

	closeLoad: ->
		$('#loadInformation').collapse('toggle')

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