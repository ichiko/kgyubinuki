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

class Simulator
	constructor: (@context) ->

	draw: (yubinuki) ->
		komaNum = yubinuki.config.koma
		kasane = yubinuki.kasane

		# TODO validate
		yubinuki.prepare()

		@drawScale(komaNum)

		if kasane
			# TODO
		else
			@drawSimple(yubinuki)

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

	drawSimple: (yubinuki) ->
		komaNum = yubinuki.config.koma
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
				color = koma.currentIto().color

				nextRound = true
				while nextRound
					direction = koma.direction
					sasiStart = koma.sasiStartIndex()
					sasiEnd = koma.sasiEndIndex()
					sasiOffset = koma.roundCount * sasiWidth

					start_x = PADDING_LEFT + sasiOffset + komaWidth * sasiStart
					end_x = PADDING_LEFT + sasiOffset + komaWidth * sasiEnd

					@context.beginPath()
					@context.strokeStyle = color
					if direction == Direction.Down
						console.log "down"
						@context.moveTo(start_x, KAGARI_TOP)
						@context.lineTo(end_x, KAGARI_BOTTOM)
					else
						console.log "up"
						@context.moveTo(start_x, KAGARI_BOTTOM)
						@context.lineTo(end_x, KAGARI_TOP)
					@context.stroke()

					if end_x >= PADDING_LEFT + SIMULATOR_WIDTH
						start_x -= SIMULATOR_WIDTH
						end_x -= SIMULATOR_WIDTH

						@context.beginPath()
						@context.strokeStyle = color
						if direction == Direction.Down
							console.log "down"
							@context.moveTo(start_x, KAGARI_TOP)
							@context.lineTo(end_x, KAGARI_BOTTOM)
						else
							console.log "up"
							@context.moveTo(start_x, KAGARI_BOTTOM)
							@context.lineTo(end_x, KAGARI_TOP)
						@context.stroke()

					nextRound = koma.kagaru()

				break

module.exports = Simulator