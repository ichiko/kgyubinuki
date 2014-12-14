# viewmodel.coffee

{ValidatableModel, Ito, Koma, Yubinuki, Direction} = require './yubinuki'

NumericCompution = (setter, getter, validFlag, owner) ->
	{
		read: ->
			value = getter()
			if isNaN(value)
				value = parseInt(value.replace(/[^\d]/g, ""))
				if isNaN(value)
					value = 0
			setter(value)
			return value
		write: (value) ->
			value = parseInt(value.replace(/[^\d]/g, ""))
			if isNaN(value)
				validFlag(false)
			else
				validFlag(true)
				setter(value)
		owner: owner
	}

class ItoVM extends Ito
	constructor: (color, roundNum) ->
		super color, roundNum

class KomaVM extends Koma
	constructor: (offset, forward, config) ->
		super offset, forward, config

	addIto: (color, roundNum) ->
		ito = new ItoVM(color, roundNum)
		@itoArray.push ito
		return ito

class YubinukiVM extends Yubinuki
	constructor: (komaNum, tobiNum, resolution, kasane) ->
		super komaNum, tobiNum, resolution, kasane

		@availableResolutions = [10, 20, 30]

		self = @

		@fmKomaValid = ko.observable(true)
		@fmKomaNum = ko.computed(NumericCompution((value)->
			self.config.koma = value
		, ->
			return self.config.koma
		, @fmKomaValid, @))

		@fmTobiValid = ko.observable(true)
		@fmTobiNum = ko.computed(NumericCompution((value)->
			self.config.tobi = value
		, ->
			return self.config.tobi
		, @fmTobiValid, @))

		@fmResolution = ko.computed({
		read: ->
			@config.resolution
		write: (value) ->
			@config.resolution = value
		owner: @
		})

	addKoma: (offset, forward = true) ->
		koma = new KomaVM(offset, forward, @config)
		@komaArray.push koma
		return koma

exports.ItoVM = ItoVM
exports.KomaVM = KomaVM
exports.YubinukiVM = YubinukiVM