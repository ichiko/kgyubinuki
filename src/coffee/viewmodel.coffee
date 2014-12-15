# viewmodel.coffee

{ValidatableModel, Ito, Koma, Yubinuki, Direction, SasiType} = require './yubinuki'

NumericCompution = (arg) ->
	{
		read: ->
			value = arg.read()
			if isNaN(value)
				value = parseInt(value.replace(/[^\d\-]/g, ""))
				if isNaN(value)
					value = 0
			arg.write(value)
			return value
		write: (value) ->
			value = parseInt(value.replace(/[^\d\-]/g, ""))
			if isNaN(value)
				arg.validFlag(false)
			else if arg.check
				if arg.check(value)
					arg.validFlag(true)
					arg.write(value)
				else
					arg.validFlag(false)
			else
				arg.validFlag(true)
				arg.write(value)
		owner: arg.owner
	}

SasiTypeViewModel = [
	{ typeName: "並み刺し", typeId: 0 },
	{ typeName: "開き刺し", typeId: 1 }
	]

class ItoVM extends Ito
	constructor: (color, roundNum) ->
		super color, roundNum

		self = @

		@fmColorValid = ko.observable(true)
		@fmColor = ko.computed({
		read: ->
			self.color
		write: (value) ->
			if value.length == 0
				@fmColorValid(false)
			else
				@fmColorValid(true)
				self.color = value
		owner: @
		})

		@fmRoundValid = ko.observable(true)
		@fmRound = ko.computed(NumericCompution({
		read: ->
			self.roundNum
		write: (value) ->
			self.roundNum = value
		check: (value) ->
			value > 0
		validFlag: @fmRoundValid
		owner: @
		}))

class KomaVM extends Koma
	constructor: (offset, type, config) ->
		super offset, type, config

		self = @

		@fmOffsetValid = ko.observable(true)
		@fmOffset = ko.computed(NumericCompution({
		read: ->
			self.offset
		write: (value) ->
			self.offset = value
		check: (value) ->
			value >= 0 and value < self.config.tobi
		validFlag: @fmOffsetValid
		owner: @
		}))

		@fmType = ko.computed({
		read: ->
			SasiTypeViewModel[self.type]
		write: (obj) ->
			self.type = obj.typeId
		owner: @
		})

		@itoArray = ko.observableArray()

		@addNewIto = ->
			self.addIto('gray', 1)

		@removeIto = (ito) ->
			self.itoArray.remove(ito)

		# TODO 移動の処理が異様に遅い
		@moveUp = (ito) ->
			itoArray = self.itoArray
			index = itoArray.indexOf(ito)
			if index > 0
				itoArray.remove(ito)
				itoArray.splice(index - 1, 0, ito)

		@moveDown = (ito) ->
			itoArray = self.itoArray
			itoLen = self.itoArray().length
			index = itoArray.indexOf(ito)
			if index > -1 and index < itoLen - 1
				itoArray.remove(ito)
				itoArray.splice(index + 1, 0, ito)

	getItoArray: ->
		@itoArray()

	addIto: (color, roundNum) ->
		ito = new ItoVM(color, roundNum)
		@itoArray.push ito
		return ito

class YubinukiVM extends Yubinuki
	constructor: (komaNum, tobiNum, resolution, kasane) ->
		super komaNum, tobiNum, resolution, kasane

		@availableResolutions = [10, 20, 30]
		@availableSasiTypes = SasiTypeViewModel

		self = @

		@fmKomaValid = ko.observable(true)
		@fmKomaNum = ko.computed(NumericCompution({
		read: ->
			self.config.koma
		write: (value) ->
			self.config.koma = value
		validFlag: @fmKomaValid
		owner: @
		}))

		@fmTobiValid = ko.observable(true)
		@fmTobiNum = ko.computed(NumericCompution({
		read: ->
			self.config.tobi
		write: (value) ->
			self.config.tobi = value
		validFlag: @fmTobiValid
		owner: @
		}))

		@fmResolution = ko.computed({
		read: ->
			@config.resolution
		write: (value) ->
			@config.resolution = value
		owner: @
		})

		@komaArray = ko.observableArray()

	getKomaArray: ->
		@komaArray()

	addKoma: (offset, type = SasiType.Nami) ->
		koma = new KomaVM(offset, type, @config)
		@getKomaArray().push koma
		return koma

	updateConfig: ->
		komaLen = @komaArray().len
		if komaLen < @config.koma
			need = @config.koma - komaLen
			for i in [1..need]
				@addKoma(offset)
		else if komaLen > @config.koma
			remove = komaLen - @config.koma
			for i in [0..remove - 1]
				koma = komaArray[komaLen - i]
				komaArray.remove(koma)

exports.ItoVM = ItoVM
exports.KomaVM = KomaVM
exports.YubinukiVM = YubinukiVM
exports.SasiType = SasiType