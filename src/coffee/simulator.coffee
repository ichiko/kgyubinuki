# simulator.coffee

{ValidatableModel, Ito, Koma, Yubinuki, Direction, SasiType} = require './yubinuki'

DEFAULT_SIMULATOR_WIDTH = 400
DEFAULT_SIMULATOR_MARGIN_LEFT = 10

SimulatorConfig =
	Width:    400
	Margin:
		Left: 60
		Top:  30
	Scale:
		Top:  30
		Bottom: 110
		LabelTop: 20
	Kagari:
		Top:  50
		Bottom: 90

SCALE_LINE_COLOR = '#000'
SCALE_TEXT_COLOR = '#000'

CHECKER_MAX = 100

SIDE_CUTOFF = true

class Simulator
	constructor: (@canvas, @context) ->

	drawScaleOnly: (yubinuki) ->
		komaNum = yubinuki.config.koma

		@clearAll()
		@drawScale(komaNum)

	canvasResized: ->
		width = @canvas.width
		height = @canvas.height
		if width <= DEFAULT_SIMULATOR_WIDTH
			SimulatorConfig.Width = width - DEFAULT_SIMULATOR_MARGIN_LEFT * 2
			SimulatorConfig.Margin.Left = DEFAULT_SIMULATOR_MARGIN_LEFT
		else
			SimulatorConfig.Width = DEFAULT_SIMULATOR_WIDTH
			SimulatorConfig.Margin.Left = (width - DEFAULT_SIMULATOR_WIDTH) / 2

	simulate: (yubinuki, stepExecute = false, stepNum = 0, silent = false) ->
		komaNum = yubinuki.config.koma

		console.log "Simulate: stepExecute=", stepExecute, "stepNum=", stepNum

		if !yubinuki.prepare()
			console.log "Simulate: state invalid."
			if !silent
				alert(yubinuki.getErrorMessages())
			return false

		@clearAll()

		@drawScale(komaNum)

		@draw(yubinuki, stepExecute, stepNum)

		if SIDE_CUTOFF
			@cutoff()

		console.log "Simulate: end"
		return true

	clearAll: ->
		@context.clearRect(0, 0, @canvas.width, @canvas.height);

	drawScale: (komaNum) ->
		komaWidth = SimulatorConfig.Width / komaNum
		left = SimulatorConfig.Margin.Left
		scaleTop = SimulatorConfig.Scale.Top
		scaleBottom = SimulatorConfig.Scale.Bottom

		for i in [0..komaNum]
			@context.beginPath()
			@context.strokeStyle = SCALE_LINE_COLOR
			@context.moveTo(left + komaWidth * i, scaleTop)
			@context.lineTo(left + komaWidth * i, scaleBottom)
			@context.stroke()

			@context.textAlign = 'center'
			@context.fillText(i, left + komaWidth * i, SimulatorConfig.Scale.LabelTop)

	cutoff: ->
		width = SimulatorConfig.Width
		left = SimulatorConfig.Margin.Left
		kagariTop = SimulatorConfig.Kagari.Top
		kagariBottom = SimulatorConfig.Kagari.Bottom

		@context.clearRect(0, kagariTop - 1, left - 1, kagariBottom - kagariTop + 2)
		@context.clearRect(left + width + 1, kagariTop - 1, @canvas.width - (left + width + 1), kagariBottom - kagariTop + 2)

	draw: (yubinuki, stepExecute, stepNum) ->
		komaNum = yubinuki.config.koma
		tobiNum = yubinuki.config.tobi
		resolution = yubinuki.config.resolution

		komaWidth = SimulatorConfig.Width / komaNum
		sasiWidth = komaWidth / resolution

		loopNum = komaNum * resolution
		komaArray = yubinuki.getKomaArray()
		allFilled = false
		chk = 0
		stepCount = 0
		while !allFilled and ( !stepExecute or (stepExecute and stepCount < stepNum) ) and chk < CHECKER_MAX
			chk += 1

			allFilled = true

			prevKoma = null
			for koma in komaArray
				if stepExecute and stepCount >= stepNum
					break

				if koma.isFilled()
					continue

				komaKagari = koma.komaKagari
				if komaKagari
					if prevKoma != null and !prevKoma.komaKagari and !prevKoma.isFilled()
						allFilled = false
						break
					while !koma.isFilled()
						if stepExecute and stepCount >= stepNum
							break

						@drawKomaRound(koma, komaWidth, sasiWidth)
						stepCount += 1
				else
					prevKoma = koma
					@drawKomaRound(koma, komaWidth, sasiWidth)
					stepCount += 1

				allFilled &= koma.isFilled()

	drawKomaRound: (koma, komaWidth, sasiWidth) ->
		offset = koma.offset
		type = koma.type
		color = koma.currentIto().color

		simulatorWidth = SimulatorConfig.Width
		left = SimulatorConfig.Margin.Left
		kagariTop = SimulatorConfig.Kagari.Top
		kagariBottom = SimulatorConfig.Kagari.Bottom

		sameRound = true
		while sameRound
			direction = koma.direction
			sasiStart = koma.sasiStartIndex()
			sasiEnd = koma.sasiEndIndex()
			sasiOffset = koma.roundCount * sasiWidth
			if type == SasiType.Hiraki
				sasiOffset *= -1

			start_x = left + sasiOffset + komaWidth * sasiStart
			end_x = left + sasiOffset + komaWidth * sasiEnd

			if type == SasiType.Hiraki and sasiEnd < 0
				start_x += simulatorWidth
				end_x += simulatorWidth

			@context.beginPath()
			@context.strokeStyle = color
			if direction == Direction.Down
				@context.moveTo(start_x, kagariTop)
				@context.lineTo(end_x, kagariBottom)
			else
				@context.moveTo(start_x, kagariBottom)
				@context.lineTo(end_x, kagariTop)
			@context.stroke()

			more_one = false
			if end_x >= left + simulatorWidth
				more_one = true
				start_x -= simulatorWidth
				end_x -= simulatorWidth
			if type == SasiType.Hiraki and end_x <= left
				more_one = true
				start_x += simulatorWidth
				end_x += simulatorWidth

			if more_one
				@context.beginPath()
				@context.strokeStyle = color
				if direction == Direction.Down
					@context.moveTo(start_x, kagariTop)
					@context.lineTo(end_x, kagariBottom)
				else
					@context.moveTo(start_x, kagariBottom)
					@context.lineTo(end_x, kagariTop)
				@context.stroke()

			sameRound = koma.kagaru()


module.exports = Simulator