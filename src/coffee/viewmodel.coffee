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

DefaultIto =
	Color: 'gray'
	Round: 1

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
	constructor: (offset, type, komaKagari, config, setDefault = true) ->
		super offset, type, komaKagari, config

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

		@fmKomaKagariCheck = ko.observable(self.komaKagari)
		@fmKomaKagari = ko.computed({
		read: ->
			@fmKomaKagariCheck()
		write: (value) ->
			self.komaKagari = value
			@fmKomaKagariCheck(value)
		owner: @
		})

		@itoArray = ko.observableArray()

		@addNewIto = ->
			self.addIto(DefaultIto.Color, DefaultIto.Round)

		@removeIto = (ito) ->
			self.itoArray.remove(ito)

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

		if setDefault
			# add Default one
			@addNewIto()

	getItoArray: ->
		@itoArray()

	addIto: (color, roundNum) ->
		ito = new ItoVM(color, roundNum)
		@itoArray.push ito
		return ito

class YubinukiVM extends Yubinuki
	constructor: (komaNum, tobiNum, resolution) ->
		super komaNum, tobiNum, resolution

		@prepared = false

		@availableResolutions = [10, 20, 30]
		@availableSasiTypes = SasiTypeViewModel

		@komaArray = ko.observableArray()

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
		@fmTobi = ko.observable(tobiNum)
		@fmTobiNum = ko.computed(NumericCompution({
		read: ->
			self.config.tobi
		write: (value) ->
			self.config.tobi = value
			self.fmTobi(value)
			self.updateConfig()
		validFlag: @fmTobiValid
		owner: @
		}))

		@fmResolution = ko.observable(resolution)
		@fmResolutionNum = ko.computed({
		read: ->
			@config.resolution
		write: (value) ->
			@config.resolution = value
			@fmResolution(value)
		owner: @
		})

		@fmUseOneKoma = ko.observable(false)
		@clickUseOneKoma = ->
			@updateConfig()
			return true

		@fmEnableKasaneSasi = ko.computed( ->
			self.enableKasaneSasi()
		)

		@prepared = true

	startManualSet: ->
		@manualMode = true

	endManualSet: ->
		@manualMode = false

	clearKoma: ->
		@komaArray.removeAll()

	getKomaArray: ->
		@komaArray()

	addKoma: (offset, type = SasiType.Nami, komaKagari = false, setDefault = !@manualMode) ->
		koma = new KomaVM(offset, type, komaKagari, @config, setDefault)
		@komaArray.push koma
		return koma

	updateConfig: ->
		if !@prepared
			return
		if @manualMode
			return
		komaLen = @komaArray().length
		tobi = @config.tobi
		useOneKoma = @fmUseOneKoma()
		if useOneKoma
			tobi = 1
		if komaLen < tobi
			need = tobi - komaLen
			for i in [1..need]
				@addKoma(0)
		else if komaLen > tobi
			remove = komaLen - tobi
			@komaArray.splice(komaLen - remove, remove)

exports.ItoVM = ItoVM
exports.KomaVM = KomaVM
exports.YubinukiVM = YubinukiVM
exports.SasiType = SasiType
exports.DefaultIto = DefaultIto