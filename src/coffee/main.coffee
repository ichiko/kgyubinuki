Simulator = require './simulator'
{ItoVM, KomaVM, YubinukiVM, SasiType} = require './viewmodel'

# ===============
#  Application
# ===============

class YubinukiSimulatorVM
	constructor: ->
		canvas = document.getElementById('canvas');
		cc = canvas.getContext('2d');
		cc.save()

		self = @

		@simulator = new Simulator(canvas, cc)
		@yubinuki = ko.observable(new YubinukiVM(8, 2, 30, false))
		@stepSimulation = ko.observable(false)
		@stepNum = ko.observable(10)
		@stepMax = ko.computed( ->
			yubinuki = self.yubinuki()
			# TODO Koma設定がひとつしかない場合の考慮
			max = yubinuki.fmTobi() * yubinuki.fmResolution()
			console.log "stepMax", max
			return max
		, @)

		# TEST
		yb = @yubinuki()
		yb.startManualSet()
		yb.clearKoma()
		koma = yb.addKoma(0, SasiType.Nami, false)
		koma.addIto('blue', 5)
		koma.addIto('skyblue', 5)
		koma = yb.addKoma(1, SasiType.Hiraki, false)
		koma.addIto('red', 1)
		yb.endManualSet()

	simulate: ->
		yubinuki = @getYubinuki()
		@simulator.draw(yubinuki)

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