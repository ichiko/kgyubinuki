class ValidatableModel
	constructor: ->
		@validateMessage = []

	validate: ->
		@validateMessage = []

	isValid: ->
		(@validateMessage.length == 0)

class Ito extends ValidatableModel
	constructor: (@color, @roundNum) ->
		super

	validate: ->
		super
		if @roundNum <= 0
			@validateMessage.push "段数は1以上の数値を指定してください。"
			return false
		return true

Direction =
	Down: 0
	Up: 1

class Koma extends ValidatableModel
	constructor: (@offset, @forward, @config) ->
		super
		@direction = Direction.Down
		@itoArray = []
		@sasiCount = 0
		@roundCount = 0
		@roundScale = 1

	setRoundScale: (s) ->
		@roundScale = s

	addIto: (color, roundNum) ->
		ito = new Ito(color, roundNum)
		@itoArray.push ito
		return ito

	# 戻り値：true(段が変わらない), false(次は段が変わる)
	kagaru: ->
		# 一段をかがるのに必要な針数：最小公倍数(コマ、トビ) / トビ * 2
		if @forward
			@sasiCount += @config.tobi / 2.0
		else
			@sasiCount -= @config.tobi / 2.0

		if @direction == Direction.Down
			@direction = Direction.Up
		else
			@direction = Direction.Down

		if (@sasiCount % @config.koma == 0) and (@sasiCount % @config.tobi == 0)
			@sasiCount = 0
			@roundCount += 1
			return false

		return true

	isFilled: ->
		@roundCount >= @config.resolution * @roundScale

	sasiStartIndex: ->
		@offset + @sasiCount

	sasiEndIndex: ->
		if @forward
			return @offset + @sasiCount + @config.tobi / 2.0
		else
			return @offset + @sasiCount - @config.tobi / 2.0

	currentIto: ->
		totalRound = 0
		for ito in @itoArray
			totalRound += ito.roundNum
		round =  @roundCount % totalRound
		roundSum = 0
		for ito in @itoArray
			roundSum += ito.roundNum
			if round < roundSum
				return ito
		throw "対応する色設定が見つかりません。現在" + @roundCount + "段目、存在する設定" + totalRound + "段、インデックス" + round

	validate: ->
		super

		for ito in @itoArray
			if !ito.validate()
				return false

		totalRound = 0
		for ito in @itoArray
			totalRound += ito.roundNum
		if totalRound > @config.resolution
			@validateMessage.push "コマ内の糸の段数指定が、針数をオーバーしています。段数の合計が、針数以内に収まるように指定してください。"
			return false

		return true

	isValid: ->
		for ito in @itoArray
			if !ito.isValid()
				return false
		super

class Yubinuki extends ValidatableModel
	# TODO @kasane 重ね差しの実装
	constructor: (komaNum, tobiNum, resolution, @kasane) ->
		super
		@config = 
			koma: komaNum
			tobi: tobiNum
			resolution: resolution
		@komaArray = []

	prepare: ->
		if !@validate()
			return false

		if @komaArray.length == 1
			@komaArray[0].setRoundScale(@config.tobi)

		return true

	addKoma: (offset, forward = true) ->
		koma = new Koma(offset, forward, @config)
		@komaArray.push koma
		return koma

	validate: ->
		super

		tobiNum = @config.tobi

		if @komaArray.length == 0
			@validateMessage.push "コマの設定がありません。"
			return false

		if tobiNum < @komaArray.length
			@validateMessage.push "コマの設定が、トビ数を越えています。"
			return false

		if @komaArray.length != 1 and @komaArray.length != tobiNum
			@validateMessage.push "コマの設定は、1またはトビ数と同じにする必要があります。(コマ数 : " + @komaArray.length + ", トビ数 : " + tobiNum + ")"
			return false

		for koma in @komaArray
			if !koma.validate()
				return false

		offsets_forward = []
		offsets_backward = []
		for koma in @komaArray
			forward = koma.forward
			offset = koma.offset
			if (forward and offsets_forward.indexOf(offset) >= 0) or (!forward and offsets_backward.indexOf(offset) >= 0)
				@validateMessage.push "同じ差し方向で、かがり始めの位置が重複しています。かがり始めの位置を変更するか、差し方向を変更してください。"
				return false
			if forward
				offsets_forward.push offset
			else
				offsets_backward.push offset
		return true

	isValid: ->
		for koma in @komaArray
			if !koma.isValid()
				return false
		super

	getErrorMessages: ->
		messages = []
		if @validateMessage.length > 0
			messages = messages.concat(@validateMessage)
		for koma in @komaArray
			if koma.validateMessage.length > 0
				messages = messages.concat(koma.validateMessage)
			for ito in koma.itoArray
				if ito.validateMessage.length > 0
					messages = messages.concat(ito.validateMessage)
		return messages

module.exports = {ValidatableModel, Ito, Koma, Yubinuki, Direction}
