# viewmodel.coffee

{ValidatableModel, Ito, Koma, Yubinuki, Direction, SasiType} = require './yubinuki'

NumericCompution = (arg) ->
	{
		read: ->
			value = arg.read()
			if isNaN(value)
				value = parseInt(value.replace(/[^\d]/g, ""))
				if isNaN(value)
					value = 0
			arg.write(value)
			return value
		write: (value) ->
			value = parseInt(value.replace(/[^\d]/g, ""))
			if isNaN(value)
				arg.validFlag(false)
			else
				arg.validFlag(true)
				arg.write(value)
		owner: arg.owner
	}

class ItoVM extends Ito
	constructor: (color, roundNum) ->
		super color, roundNum

class KomaVM extends Koma
	constructor: (offset, type, config) ->
		super offset, type, config

	addIto: (color, roundNum) ->
		ito = new ItoVM(color, roundNum)
		@getItoArray().push ito
		return ito

class YubinukiVM extends Yubinuki
	constructor: (komaNum, tobiNum, resolution, kasane) ->
		super komaNum, tobiNum, resolution, kasane

		@availableResolutions = [10, 20, 30]

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

	addKoma: (offset, type = SasiType.Nami) ->
		koma = new KomaVM(offset, type, @config)
		@getKomaArray().push koma
		return koma

	updateConfig: ->
		komaArray = @getKomaArray()

		if komaArray.length < @config.koma
			need = @config.koma - komaArray.length
			for i in [1..need]
				@addKoma(offset)
		else if komaArray.length > @config.koma
			len = komaArray.length
			remove = komaArray.length - @config.koma
			for i in [0..remove - 1]
				koma = komaArray[len - i]
				komaArray.remove(koma)

exports.ItoVM = ItoVM
exports.KomaVM = KomaVM
exports.YubinukiVM = YubinukiVM