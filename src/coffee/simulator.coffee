# simulator.coffee

{ValidatableModel, Ito, Koma, Yubinuki, Direction} = require './yubinuki.js'

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

	draw: (yubinuki) ->
		komaNum = yubinuki.config.koma
		kasane = yubinuki.kasane

		# TODO validate
		yubinuki.prepare()

		@clearAll()

		@drawScale(komaNum)

		if kasane
			# TODO
		else
			@drawSimple(yubinuki)

		if SIDE_CUTOFF
			@cutoff()

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

	drawSimple: (yubinuki) ->
		komaNum = yubinuki.config.koma
		tobiNum = yubinuki.config.tobi
		resolution = yubinuki.config.resolution

		komaWidth = SIMULATOR_WIDTH / komaNum
		sasiWidth = komaWidth / resolution

		loopNum = komaNum * resolution
		anchor = yubinuki.komaArray[yubinuki.komaArray.length - 1]
		chk = 0
		while !anchor.isFilled() and chk < CHECKER_MAX
			chk += 1

			for koma in yubinuki.komaArray
				offset = koma.offset
				forward = koma.forward
				color = koma.currentIto().color

				nextRound = true
				while nextRound
					direction = koma.direction
					sasiStart = koma.sasiStartIndex()
					sasiEnd = koma.sasiEndIndex()
					sasiOffset = koma.roundCount * sasiWidth
					if !forward
						sasiOffset *= -1

					start_x = PADDING_LEFT + sasiOffset + komaWidth * sasiStart
					end_x = PADDING_LEFT + sasiOffset + komaWidth * sasiEnd

					if !forward
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
					if !forward and end_x <= PADDING_LEFT
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

					nextRound = koma.kagaru()

module.exports = Simulator