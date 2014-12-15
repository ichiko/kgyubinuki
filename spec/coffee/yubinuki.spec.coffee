{ValidatableModel, Ito, Koma, Yubinuki, Direction, SasiType} = require '../../src/coffee/yubinuki'

describe "ValidatableModel", ->
	it "initialize", ->
		vm = new ValidatableModel
		expect(vm.validateMessage.length).toBe(0)

	it "isValid", ->
		vm = new ValidatableModel
		expect(vm.isValid()).toBe(true)

	it "isInvalid", ->
		vm = new ValidatableModel
		vm.validateMessage.push "error message"
		expect(vm.isValid()).toBe(false)

describe "ItoModel", ->
	it "initialize", ->
		ito = new Ito('green', 4)
		expect(ito.color).toBe('green')
		expect(ito.roundNum).toBe(4)
		expect(ito.validate()).toBe(true)
		expect(ito.isValid()).toBe(true)

	it "invalid RoundNum", ->
		ito = new Ito('red', -1)
		expect(ito.color).toBe('red')
		expect(ito.roundNum).toBe(-1)
		expect(ito.validate()).toBe(false)
		expect(ito.isValid()).toBe(false)

describe "Koma", ->
	config = {}

	beforeEach ->
		config = {resolution: 10}

	it "initialize", ->
		koma = new Koma(0, SasiType.Nami, config)
		expect(koma.offset).toBe(0)
		expect(koma.type).toBe(SasiType.Nami)
		expect(koma.config).toBe(config)
		expect(koma.direction).toBe(Direction.Down)
		expect(koma.itoArray.length).toBe(0)
		expect(koma.validate()).toBe(true)
		expect(koma.isValid()).toBe(true)

	it "addIto", ->
		koma = new Koma(0, SasiType.Nami, config)
		koma.addIto('green', 1)
		expect(koma.itoArray.length).toBe(1)
		ito = koma.itoArray[0]
		expect(ito.color).toBe('green')
		expect(ito.roundNum).toBe(1)

	it "addIto (2)", ->
		koma = new Koma(0, SasiType.Nami, config)
		koma.addIto('green', 1)
		koma.addIto('red', 2)
		expect(koma.itoArray.length).toBe(2)
		ito = koma.itoArray[0]
		expect(ito.color).toBe('green')
		expect(ito.roundNum).toBe(1)
		ito = koma.itoArray[1]
		expect(ito.color).toBe('red')
		expect(ito.roundNum).toBe(2)
		expect(koma.isValid()).toBe(true)

	it "isInvalid error at a Ito", ->
		koma = new Koma(0, SasiType.Nami, config)
		
		ito = koma.addIto('red', 0)
		expect(ito.validate()).toBe(false)
		expect(ito.isValid()).toBe(false)

		expect(koma.validate()).toBe(false)
		expect(koma.isValid()).toBe(false)

	it "isInvalid error at itself", ->
		koma = new Koma(0, SasiType.Nami, config)

		ito = koma.addIto('green', 6)
		expect(ito.validate()).toBe(true)
		expect(ito.isValid()).toBe(true)
		ito = koma.addIto('blue', 6)
		expect(ito.validate()).toBe(true)
		expect(ito.isValid()).toBe(true)

		expect(koma.validate()).toBe(false)
		expect(koma.isValid()).toBe(false)

	describe "kagaru", ->
		it "step", ->
			koma = new Koma(0, SasiType.Nami, config)
			expect(koma.direction).toBe(Direction.Down)
			expect(koma.roundCount).toBe(0)
			expect(koma.kagaru()).toBe(true)
			expect(koma.direction).toBe(Direction.Up)
			expect(koma.roundCount).toBe(0)
			expect(koma.kagaru()).toBe(true)
			expect(koma.direction).toBe(Direction.Down)
			expect(koma.roundCount).toBe(0)

		it "round Up (4:2)", ->
			config.koma = 4
			config.tobi = 2
			koma = new Koma(0, SasiType.Nami, config)
			expect(koma.direction).toBe(Direction.Down)
			expect(koma.roundCount).toBe(0)
			for i in [1..3]
				expect(koma.kagaru()).toBe(true)
			expect(koma.direction).toBe(Direction.Up)
			expect(koma.roundCount).toBe(0)
			expect(koma.kagaru()).toBe(false)
			expect(koma.direction).toBe(Direction.Down)
			expect(koma.roundCount).toBe(1)

		it "round Up (6:2)", ->
			config.koma = 6
			config.tobi = 2
			koma = new Koma(0, SasiType.Nami, config)
			expect(koma.direction).toBe(Direction.Down)
			expect(koma.roundCount).toBe(0)
			for i in [1..5]
				expect(koma.kagaru()).toBe(true)
			expect(koma.direction).toBe(Direction.Up)
			expect(koma.roundCount).toBe(0)
			expect(koma.kagaru()).toBe(false)
			expect(koma.direction).toBe(Direction.Down)
			expect(koma.roundCount).toBe(1)

		it "round Up (5:2)", ->
			config.koma = 5
			config.tobi = 2
			koma = new Koma(0, SasiType.Nami, config)
			expect(koma.direction).toBe(Direction.Down)
			expect(koma.roundCount).toBe(0)
			for i in [1..9]
				expect(koma.kagaru()).toBe(true)
			expect(koma.direction).toBe(Direction.Up)
			expect(koma.roundCount).toBe(0)
			expect(koma.kagaru()).toBe(false)
			expect(koma.direction).toBe(Direction.Down)
			expect(koma.roundCount).toBe(1)

		it "round Up (11:2)", ->
			config.koma = 11
			config.tobi = 2
			koma = new Koma(0, SasiType.Nami, config)
			expect(koma.direction).toBe(Direction.Down)
			expect(koma.roundCount).toBe(0)
			for i in [1..21]
				expect(koma.kagaru()).toBe(true)
			expect(koma.direction).toBe(Direction.Up)
			expect(koma.roundCount).toBe(0)
			expect(koma.kagaru()).toBe(false)
			expect(koma.direction).toBe(Direction.Down)
			expect(koma.roundCount).toBe(1)

		it "round Up (6:3)", ->
			config.koma = 6
			config.tobi = 3
			koma = new Koma(0, SasiType.Nami, config)
			expect(koma.direction).toBe(Direction.Down)
			expect(koma.roundCount).toBe(0)
			for i in [1..3]
				expect(koma.kagaru()).toBe(true)
			expect(koma.direction).toBe(Direction.Up)
			expect(koma.roundCount).toBe(0)
			expect(koma.kagaru()).toBe(false)
			expect(koma.direction).toBe(Direction.Down)
			expect(koma.roundCount).toBe(1)

		it "round Up (10:3)", ->
			config.koma = 10
			config.tobi = 3
			koma = new Koma(0, SasiType.Nami, config)
			expect(koma.direction).toBe(Direction.Down)
			expect(koma.roundCount).toBe(0)
			for i in [1..19]
				expect(koma.kagaru()).toBe(true)
			expect(koma.direction).toBe(Direction.Up)
			expect(koma.roundCount).toBe(0)
			expect(koma.kagaru()).toBe(false)
			expect(koma.direction).toBe(Direction.Down)
			expect(koma.roundCount).toBe(1)

		it "round Up (15:3)", ->
			config.koma = 15
			config.tobi = 3
			koma = new Koma(0, SasiType.Nami, config)
			expect(koma.direction).toBe(Direction.Down)
			expect(koma.roundCount).toBe(0)
			for i in [1..9]
				expect(koma.kagaru()).toBe(true)
			expect(koma.direction).toBe(Direction.Up)
			expect(koma.roundCount).toBe(0)
			expect(koma.kagaru()).toBe(false)
			expect(koma.direction).toBe(Direction.Down)
			expect(koma.roundCount).toBe(1)

	describe "isFilled", ->
		beforeEach ->
			config.resolution = 10
			config.koma = 4
			config.tobi = 2

		it "not filled", ->
			koma = new Koma(0, SasiType.Nami, config)
			koma.addIto('green', 1)
			expect(koma.isFilled()).toBe(false)
			koma.kagaru()
			expect(koma.isFilled()).toBe(false)

		it "filled", ->
			koma = new Koma(0, SasiType.Nami, config)
			koma.addIto('green', 1)
			expect(koma.isFilled()).toBe(false)
			for i in [1..39]
				koma.kagaru()
			expect(koma.isFilled()).toBe(false)
			koma.kagaru()
			expect(koma.isFilled()).toBe(true)

	describe "sasiStart/End", ->
		it "offset 0, tobi 2, Nami", ->
			config.resolution = 10
			config.koma = 4
			config.tobi = 2

			koma = new Koma(0, SasiType.Nami, config)
			expect(koma.sasiStartIndex()).toBe(0)
			expect(koma.sasiEndIndex()).toBe(1)
			koma.kagaru()
			expect(koma.sasiStartIndex()).toBe(1)
			expect(koma.sasiEndIndex()).toBe(2)

		it "offset 0, tobi 3, Nami", ->
			config.resolution = 10
			config.koma = 6
			config.tobi = 3

			koma = new Koma(0, SasiType.Nami, config)
			expect(koma.sasiStartIndex()).toBe(0)
			expect(koma.sasiEndIndex()).toBe(1.5)
			koma.kagaru()
			expect(koma.sasiStartIndex()).toBe(1.5)
			expect(koma.sasiEndIndex()).toBe(3)

		it "offset 0, tobi 2, Hiraki", ->
			config.resolution = 10
			config.koma = 4
			config.tobi = 2

			koma = new Koma(0, SasiType.Hiraki, config)
			expect(koma.sasiStartIndex()).toBe(0)
			expect(koma.sasiEndIndex()).toBe(-1)
			koma.kagaru()
			expect(koma.sasiStartIndex()).toBe(-1)
			expect(koma.sasiEndIndex()).toBe(-2)

		it "offset 0, tobi 3, Hiraki", ->
			config.resolution = 10
			config.koma = 6
			config.tobi = 3

			koma = new Koma(0, SasiType.Hiraki, config)
			expect(koma.sasiStartIndex()).toBe(0)
			expect(koma.sasiEndIndex()).toBe(-1.5)
			koma.kagaru()
			expect(koma.sasiStartIndex()).toBe(-1.5)
			expect(koma.sasiEndIndex()).toBe(-3)

		it "offset 1, tobi 2, Nami", ->
			config.resolution = 10
			config.koma = 4
			config.tobi = 2

			koma = new Koma(1, SasiType.Nami, config)
			expect(koma.sasiStartIndex()).toBe(1)
			expect(koma.sasiEndIndex()).toBe(2)
			koma.kagaru()
			expect(koma.sasiStartIndex()).toBe(2)
			expect(koma.sasiEndIndex()).toBe(3)

		it "offset 1, tobi 3, Nami", ->
			config.resolution = 10
			config.koma = 6
			config.tobi = 3

			koma = new Koma(1, SasiType.Nami, config)
			expect(koma.sasiStartIndex()).toBe(1)
			expect(koma.sasiEndIndex()).toBe(2.5)
			koma.kagaru()
			expect(koma.sasiStartIndex()).toBe(2.5)
			expect(koma.sasiEndIndex()).toBe(4)

		it "offset 1, tobi 2, Hiraki", ->
			config.resolution = 10
			config.koma = 4
			config.tobi = 2

			koma = new Koma(1, SasiType.Hiraki, config)
			expect(koma.sasiStartIndex()).toBe(1)
			expect(koma.sasiEndIndex()).toBe(0)
			koma.kagaru()
			expect(koma.sasiStartIndex()).toBe(0)
			expect(koma.sasiEndIndex()).toBe(-1)

		it "offset 1, tobi 3, Hiraki", ->
			config.resolution = 10
			config.koma = 6
			config.tobi = 3

			koma = new Koma(1, SasiType.Hiraki, config)
			expect(koma.sasiStartIndex()).toBe(1)
			expect(koma.sasiEndIndex()).toBe(-0.5)
			koma.kagaru()
			expect(koma.sasiStartIndex()).toBe(-0.5)
			expect(koma.sasiEndIndex()).toBe(-2)

	describe "currentIto", ->
		beforeEach ->
			config.resolution = 10
			config.koma = 8
			config.tobi = 2

		it "single", ->
			koma = new Koma(0, SasiType.Nami, config)
			ito = koma.addIto('green', 1)
			expect(koma.currentIto()).toBe(ito)
			for i in [1..8]
				koma.kagaru()
			expect(koma.currentIto()).toBe(ito)
			expect(koma.roundCount).toBe(1)

		it "switch", ->
			koma = new Koma(0, SasiType.Nami, config)
			ito1 = koma.addIto('green', 1)
			ito2 = koma.addIto('blue', 1)
			expect(koma.currentIto()).toBe(ito1)
			for i in [1..8]
				koma.kagaru()
			expect(koma.currentIto()).toBe(ito2)
			expect(koma.roundCount).toBe(1)
			for i in [1..8]
				koma.kagaru()
			expect(koma.currentIto()).toBe(ito1)
			expect(koma.roundCount).toBe(2)

		it "round", ->
			koma = new Koma(0, SasiType.Nami, config)
			ito1 = koma.addIto('green', 1)
			ito2 = koma.addIto('blue', 1)
			ito3 = koma.addIto('yellow', 1)
			expect(koma.currentIto()).toBe(ito1)
			for i in [1..8]
				koma.kagaru()
			expect(koma.currentIto()).toBe(ito2)
			expect(koma.roundCount).toBe(1)
			for i in [1..8]
				koma.kagaru()
			expect(koma.currentIto()).toBe(ito3)
			expect(koma.roundCount).toBe(2)
			for i in [1..8]
				koma.kagaru()
			expect(koma.currentIto()).toBe(ito1)
			expect(koma.roundCount).toBe(3)

		it "round (1:2:1)", ->
			koma = new Koma(0, SasiType.Nami, config)
			ito1 = koma.addIto('green', 1)
			ito2 = koma.addIto('blue', 2)
			ito3 = koma.addIto('yellow', 1)
			expect(koma.currentIto()).toBe(ito1)
			for i in [1..8]
				koma.kagaru()
			expect(koma.currentIto()).toBe(ito2)
			expect(koma.roundCount).toBe(1)
			for i in [1..8]
				koma.kagaru()
			expect(koma.currentIto()).toBe(ito2)
			expect(koma.roundCount).toBe(2)
			for i in [1..8]
				koma.kagaru()
			expect(koma.currentIto()).toBe(ito3)
			expect(koma.roundCount).toBe(3)
			for i in [1..8]
				koma.kagaru()
			expect(koma.currentIto()).toBe(ito1)
			expect(koma.roundCount).toBe(4)

		it "round (2:1:2)", ->
			koma = new Koma(0, SasiType.Nami, config)
			ito1 = koma.addIto('green', 2)
			ito2 = koma.addIto('blue', 1)
			ito3 = koma.addIto('yellow', 2)
			expect(koma.currentIto()).toBe(ito1)
			for i in [1..8]
				koma.kagaru()
			expect(koma.currentIto()).toBe(ito1)
			expect(koma.roundCount).toBe(1)
			for i in [1..8]
				koma.kagaru()
			expect(koma.currentIto()).toBe(ito2)
			expect(koma.roundCount).toBe(2)
			for i in [1..8]
				koma.kagaru()
			expect(koma.currentIto()).toBe(ito3)
			expect(koma.roundCount).toBe(3)
			for i in [1..8]
				koma.kagaru()
			expect(koma.currentIto()).toBe(ito3)
			expect(koma.roundCount).toBe(4)
			for i in [1..8]
				koma.kagaru()
			expect(koma.currentIto()).toBe(ito1)
			expect(koma.roundCount).toBe(5)

describe "Yubinuki", ->
	describe "initialize", ->
		it "empty", ->
			yb = new Yubinuki(8, 2, 20, false)
			expect(yb.config.koma).toBe(8)
			expect(yb.config.tobi).toBe(2)
			expect(yb.config.resolution).toBe(20)
			expect(yb.kasane).toBe(false)
			expect(yb.komaArray.length).toBe(0)

		it "a koma", ->
			yb = new Yubinuki(8, 2, 20, false)
			yb.addKoma(0, SasiType.Nami)
			expect(yb.config.koma).toBe(8)
			expect(yb.config.tobi).toBe(2)
			expect(yb.config.resolution).toBe(20)
			expect(yb.kasane).toBe(false)
			expect(yb.komaArray.length).toBe(1)

	describe "prepare", ->
		it "no koma", ->
			yb = new Yubinuki(6, 2, 10, false)
			expect(yb.prepare()).toBe(false)

		it "a koma (2)", ->
			yb = new Yubinuki(6, 2, 10, false)
			yb.addKoma(0, SasiType.Nami)
			expect(yb.prepare()).toBe(true)

		it "a koma (3)", ->
			yb = new Yubinuki(6, 3, 10, false)
			yb.addKoma(0, SasiType.Nami)
			expect(yb.prepare()).toBe(true)

		it "more than 1 and less than koma", ->
			yb = new Yubinuki(6, 3, 10, false)
			yb.addKoma(0, SasiType.Nami)
			yb.addKoma(1, SasiType.Nami)
			expect(yb.prepare()).toBe(false)

		it "over koma", ->
			yb = new Yubinuki(6, 2, 10, false)
			yb.addKoma(0, SasiType.Nami)
			yb.addKoma(1, SasiType.Nami)
			yb.addKoma(2, SasiType.Nami)
			expect(yb.prepare()).toBe(false)

		it "invalid koma", ->
			yb = new Yubinuki(6, 2, 10, false)
			koma = yb.addKoma(0, SasiType.Nami)
			koma.addIto('yellow', 5)
			koma.addIto('red', 6)
			expect(yb.prepare()).toBe(false)

		it "offset conflict", ->
			yb = new Yubinuki(6, 2, 10, false)
			yb.addKoma(0, SasiType.Nami)
			yb.addKoma(0, SasiType.Nami)
			expect(yb.prepare()).toBe(false)

		it "offset conflict (2)", ->
			yb = new Yubinuki(6, 2, 10, false)
			yb.addKoma(0, SasiType.Hiraki)
			yb.addKoma(0, SasiType.Hiraki)
			expect(yb.prepare()).toBe(false)

		it "offset conflict (3)", ->
			yb = new Yubinuki(6, 2, 10, false)
			yb.addKoma(0, SasiType.Nami)
			yb.addKoma(1, SasiType.Hiraki)
			expect(yb.prepare()).toBe(false)

	it "addKoma", ->
		yb = new Yubinuki(6, 2, 10, false)
		yb.addKoma(0, SasiType.Nami)
		yb.addKoma(1, SasiType.Hiraki)
		expect(yb.komaArray.length).toBe(2)
		expect(yb.komaArray[0].offset).toBe(0)
		expect(yb.komaArray[0].type).toBe(SasiType.Nami)
		expect(yb.komaArray[1].offset).toBe(1)
		expect(yb.komaArray[1].type).toBe(SasiType.Hiraki)

	it "addKoma (default arg)", ->
		yb = new Yubinuki(8, 2, 20, false)
		yb.addKoma(0)
		expect(yb.komaArray.length).toBe(1)
		expect(yb.komaArray[0].offset).toBe(0)
		expect(yb.komaArray[0].type).toBe(SasiType.Nami)

	describe "validate", ->
		it "no koma", ->
			yb = new Yubinuki(6, 2, 10, false)
			expect(yb.validate()).toBe(false)
			expect(yb.isValid()).toBe(false)

		it "a koma (2)", ->
			yb = new Yubinuki(6, 2, 10, false)
			yb.addKoma(0, SasiType.Nami)
			expect(yb.validate()).toBe(true)
			expect(yb.isValid()).toBe(true)

		it "a koma (3)", ->
			yb = new Yubinuki(6, 3, 10, false)
			yb.addKoma(0, SasiType.Nami)
			expect(yb.validate()).toBe(true)
			expect(yb.isValid()).toBe(true)

		it "more than 1 and less than koma", ->
			yb = new Yubinuki(6, 3, 10, false)
			yb.addKoma(0, SasiType.Nami)
			yb.addKoma(1, SasiType.Nami)
			expect(yb.validate()).toBe(false)
			expect(yb.isValid()).toBe(false)

		it "over koma", ->
			yb = new Yubinuki(6, 2, 10, false)
			yb.addKoma(0, SasiType.Nami)
			yb.addKoma(1, SasiType.Nami)
			yb.addKoma(2, SasiType.Nami)
			expect(yb.validate()).toBe(false)
			expect(yb.isValid()).toBe(false)

		it "invalid koma", ->
			yb = new Yubinuki(6, 2, 10, false)
			koma = yb.addKoma(0, SasiType.Nami)
			koma.addIto('yellow', 5)
			koma.addIto('red', 6)
			expect(yb.validate()).toBe(false)
			expect(yb.isValid()).toBe(false)

		it "offset conflict", ->
			yb = new Yubinuki(6, 2, 10, false)
			yb.addKoma(0, SasiType.Nami)
			yb.addKoma(0, SasiType.Nami)
			expect(yb.validate()).toBe(false)
			expect(yb.isValid()).toBe(false)

		it "offset conflict (2)", ->
			yb = new Yubinuki(6, 2, 10, false)
			yb.addKoma(0, SasiType.Hiraki)
			yb.addKoma(0, SasiType.Hiraki)
			expect(yb.validate()).toBe(false)
			expect(yb.isValid()).toBe(false)

		it "offset conflict (3)", ->
			yb = new Yubinuki(6, 2, 10, false)
			yb.addKoma(0, SasiType.Nami)
			yb.addKoma(1, SasiType.Hiraki)
			expect(yb.validate()).toBe(false)
			expect(yb.isValid()).toBe(false)

		it "offset not conflict", ->
			yb = new Yubinuki(6, 2, 10, false)
			yb.addKoma(0, SasiType.Nami)
			yb.addKoma(0, SasiType.Hiraki)
			expect(yb.validate()).toBe(true)
			expect(yb.isValid()).toBe(true)
