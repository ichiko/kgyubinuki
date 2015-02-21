# formatter.coffee

{ItoVM, KomaVM, YubinukiVM, SasiType} = require './viewmodel'

pack = (yubinuki) ->
	komas = []
	for koma in yubinuki.getKomaArray()
		komas.push packKoma(koma)
	return {
		komaNum: yubinuki.config.koma,
		tobiNum: yubinuki.config.tobi,
		resolution: yubinuki.config.resolution,
		koma: komas
	}

packKoma = (koma) ->
	itos = []
	for ito in koma.getItoArray()
		itos.push packIto(ito)
	return {
		offset: koma.offset,
		type: koma.type,
		komaKagari: koma.komaKagari,
		ito: itos
	}

packIto = (ito) ->
	return {
		color: ito.color,
		round: ito.roundNum
	}

unpack = (json) ->
	yb = new YubinukiVM(json.komaNum, json.tobiNum, json.resolution)
	yb.startManualSet()
	yb.clearKoma()
	types = [SasiType.Nami, SasiType.Hiraki]
	for k in json.koma
		koma = yb.addKoma(k.offset, types[k.type], k.komaKagari)
		for i in k.ito
			koma.addIto(i.color, i.round)
	yb.endManualSet()
	return yb

module.exports.pack = pack
module.exports.unpack = unpack