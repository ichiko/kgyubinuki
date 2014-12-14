Simulator = require('./simulator.js')
{ValidatableModel, Ito, Koma, Yubinuki, Direction} = require '../../src/js/yubinuki.js'

class YubinukiSimulatorVM
	constructor: ->
		canvas = document.getElementById('canvas');
		cc = canvas.getContext('2d');
		cc.save()

		@simulator = new Simulator(canvas, cc)

	simulate: ->
		yubinuki = @getYubinuki()
		@simulator.draw(yubinuki)

		canvas = document.getElementById('canvas');
		cc = canvas.getContext('2d');
		cc.restore()

	getYubinuki: ->
		yubinuki = new Yubinuki(8, 2, 30, false)
		koma = yubinuki.addKoma(0)
		koma.addIto('blue', 1)
		koma = yubinuki.addKoma(0, false)
		koma.addIto('red', 1)
		return yubinuki

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