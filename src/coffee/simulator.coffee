# simulator.coffee

{ValidatableModel, Ito, Koma, Yubinuki, Direction, SasiType} = require './yubinuki'

PADDING_LEFT = 60
SIMULATOR_WIDTH = 400

SCALE_TOP = 30
SCALE_BOTTOM = 110
SCALE_LABEL_TOP = SCALE_TOP - 10

KAGARI_TOP = 50
KAGARI_BOTTOM = 90

SCALE_LINE_COLOR = '#000'
SCALE_TEXT_COLOR = '#000'

CHECKER_MAX = 100

SIDE_CUTOFF = false

class Simulator
	constructor: (@canvas, @context) ->

	drawScaleOnly: (yubinuki) ->
		komaNum = yubinuki.config.koma

		@clearAll()
		@drawScale(komaNum)

	simulate: (yubinuki, stepExecute = false, stepNum = 0) ->
		komaNum = yubinuki.config.koma

		console.log "Simulate: stepExecute=", stepExecute, "stepNum=", stepNum

		if !yubinuki.prepare()
			alert(yubinuki.getErrorMessages())
			console.log "Simulate: state invalid."
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
		komaWidth = SIMULATOR_WIDTH / komaNum

		for i in [0..komaNum]
			@context.beginPath()
			@context.strokeStyle = SCALE_LINE_COLOR
			@context.moveTo(PADDING_LEFT + komaWidth * i, SCALE_TOP)
			@context.lineTo(PADDING_LEFT + komaWidth * i, SCALE_BOTTOM)
			@context.stroke()

			@context.textAlign = 'center'
			@context.fillText(i, PADDING_LEFT + komaWidth * i, SCALE_LABEL_TOP)

	cutoff: ->
		@context.clearRect(0, KAGARI_TOP - 1, PADDING_LEFT - 1, KAGARI_BOTTOM - KAGARI_TOP + 2)
		@context.clearRect(PADDING_LEFT + SIMULATOR_WIDTH + 1, KAGARI_TOP - 1, @canvas.width - (PADDING_LEFT + SIMULATOR_WIDTH + 1), KAGARI_BOTTOM - KAGARI_TOP + 2)

	draw: (yubinuki, stepExecute, stepNum) ->
		komaNum = yubinuki.config.koma
		tobiNum = yubinuki.config.tobi
		resolution = yubinuki.config.resolution

		komaWidth = SIMULATOR_WIDTH / komaNum
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

				komaKagari = koma.komaKagari
				if komaKagari
					if prevKoma != null and !prevKoma.komaKagari and !prevKoma.isFilled()
						continue
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

		sameRound = true
		while sameRound
			direction = koma.direction
			sasiStart = koma.sasiStartIndex()
			sasiEnd = koma.sasiEndIndex()
			sasiOffset = koma.roundCount * sasiWidth
			if type == SasiType.Hiraki
				sasiOffset *= -1

			start_x = PADDING_LEFT + sasiOffset + komaWidth * sasiStart
			end_x = PADDING_LEFT + sasiOffset + komaWidth * sasiEnd

			if type == SasiType.Hiraki
				start_x += SIMULATOR_WIDTH
				end_x += SIMULATOR_WIDTH

			@context.beginPath()
			@context.strokeStyle = color
			if direction == Direction.Down
				@context.moveTo(start_x, KAGARI_TOP)
				@context.lineTo(end_x, KAGARI_BOTTOM)
			else
				@context.moveTo(start_x, KAGARI_BOTTOM)
				@context.lineTo(end_x, KAGARI_TOP)
			@context.stroke()

			more_one = false
			if end_x >= PADDING_LEFT + SIMULATOR_WIDTH
				more_one = true
				start_x -= SIMULATOR_WIDTH
				end_x -= SIMULATOR_WIDTH
			if type == SasiType.Hiraki and end_x <= PADDING_LEFT
				more_one = true
				start_x += SIMULATOR_WIDTH
				end_x += SIMULATOR_WIDTH

			if more_one
				@context.beginPath()
				@context.strokeStyle = color
				if direction == Direction.Down
					@context.moveTo(start_x, KAGARI_TOP)
					@context.lineTo(end_x, KAGARI_BOTTOM)
				else
					@context.moveTo(start_x, KAGARI_BOTTOM)
					@context.lineTo(end_x, KAGARI_TOP)
				@context.stroke()

			sameRound = koma.kagaru()


module.exports = Simulator