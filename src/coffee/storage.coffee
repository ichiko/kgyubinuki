# storage.coffee

PareparedKey = ['store01', 'store02', 'store03', 'store04', 'store05']

class YubinukiStorage
	constructor: ->
		@dataArray = ko.observableArray()
		@dataMap = new Array()

	loadAll: ->
		if !store.enabled
			return

		@dataArray.removeAll()
		for key in PareparedKey
			value = store.get(key)
			label = key + " - (NO DATA)"
			comment = ""
			yubinuki = null
			if value
				label = key + " - " + value.comment
				comment = value.comment
				yubinuki = value.data
			
			data = {
				key: key, 
				label: label,
				comment: comment,
				data: yubinuki
			}
			@dataArray.push data
			@dataMap[key] = data


	load: (key) ->
		return @dataMap[key]

	save: (key, comment, data) ->
		if !store.enabled
			return

		store.set(key, {
			comment: comment,
			data: data
		})
		@loadAll()

module.exports = YubinukiStorage