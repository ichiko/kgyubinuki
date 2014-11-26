class Sasi
	constructor: (@offset, @color, @jump, @round) ->

class PatternViewModel
	constructor: ->
		@patterns = ko.observableArray([
			new Sasi(0, '#ff0000', 2, 3)
			new Sasi(0, '#0000ff', 2, 3)
		])
		@division = ko.observable(8)
		@resolution = ko.observable(30)

	addPattern: ->
		@patterns.push(new Sasi(0, '#000000', 2, 1))

	# ★注意★
	# ViewModelの子として定義できるが、実行コンテキストはViewModelでない
	# このメソッドが実行されるとき、@ == pattern
	removePattern: (pattern) ->
		vm.patterns.remove(pattern)

	duplicate: (pattern) ->
		vm.patterns.push(new Sasi(pattern.offset, pattern.color, pattern.jump, pattern.round))

	moveUp: (pattern) ->
		index = vm.patterns.indexOf(pattern)
		if (index > 0)
			vm.patterns.remove(pattern)
			vm.patterns.splice(index - 1, 0, pattern)

	moveDown: (pattern) ->
		index = vm.patterns.indexOf(pattern)
		if (index < vm.patterns().length)
			vm.patterns.remove(pattern)
			vm.patterns.splice(index + 1, 0, pattern)

	draw: ->
		canvas = document.getElementById('canvas');
		cc = canvas.getContext('2d');

		cc.clearRect(0, 0, canvas.width, canvas.height);
		cc.save()

		vm.drawScale(cc)
		cc.restore()

		div = vm.division()
		resolution = vm.resolution()
		sec = 400 / div
		if resolution > 0
			hari = sec / resolution
		else 
			hari = 0
		offset_scale = 40

		offset_hari_even = -hari
		offset_hari_odd = -hari

		patterns = vm.patterns()
		for sasi in patterns
			for h in [0...sasi.round]
				offset_x = 0
				if sasi.offset % sasi.jump == 0
					offset_hari_even += hari
					offset_x = offset_hari_even
				else
					offset_hari_odd += hari
					offset_x = offset_hari_odd

				i = 0
				while i < div
					cc.beginPath()
					cc.strokeStyle = sasi.color
					if (sasi.offset % sasi.jump == 0 and i % sasi.jump == 0) or (sasi.offset % sasi.jump != 0 and i % sasi.jump != 0)
						cc.moveTo(offset_scale + offset_x + sec * i, 50)
						cc.lineTo(offset_scale + offset_x + sec * (i + sasi.jump / 2), 80)
					else
						cc.moveTo(offset_scale + offset_x + sec * i, 80)
						cc.lineTo(offset_scale + offset_x + sec * (i + sasi.jump / 2), 50)
					cc.stroke()
					i += sasi.jump / 2

		cc.restore()


	drawScale: (cc) ->
		div = @division()
		sec = 400 / div

		offset_x = 40

		for i in [0..div]
			cc.beginPath()
			cc.strokeStyle = '#000'
			cc.moveTo(offset_x + sec * i, 30)
			cc.lineTo(offset_x + sec * i, 100)
			cc.stroke()


vm = new PatternViewModel

ko.applyBindings(vm)

console.log("hoge")