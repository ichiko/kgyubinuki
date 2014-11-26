(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function() {
  var PatternViewModel, Sasi, vm;

  Sasi = (function() {
    function Sasi(offset, color, jump, round) {
      this.offset = offset;
      this.color = color;
      this.jump = jump;
      this.round = round;
    }

    return Sasi;

  })();

  PatternViewModel = (function() {
    function PatternViewModel() {
      this.patterns = ko.observableArray([new Sasi(0, '#ff0000', 2, 3), new Sasi(0, '#0000ff', 2, 3)]);
      this.division = ko.observable(8);
      this.resolution = ko.observable(30);
    }

    PatternViewModel.prototype.addPattern = function() {
      return this.patterns.push(new Sasi(0, '#000000', 2, 1));
    };

    PatternViewModel.prototype.removePattern = function(pattern) {
      return vm.patterns.remove(pattern);
    };

    PatternViewModel.prototype.duplicate = function(pattern) {
      return vm.patterns.push(new Sasi(pattern.offset, pattern.color, pattern.jump, pattern.round));
    };

    PatternViewModel.prototype.moveUp = function(pattern) {
      var index;
      index = vm.patterns.indexOf(pattern);
      if (index > 0) {
        vm.patterns.remove(pattern);
        return vm.patterns.splice(index - 1, 0, pattern);
      }
    };

    PatternViewModel.prototype.moveDown = function(pattern) {
      var index;
      index = vm.patterns.indexOf(pattern);
      if (index < vm.patterns().length) {
        vm.patterns.remove(pattern);
        return vm.patterns.splice(index + 1, 0, pattern);
      }
    };

    PatternViewModel.prototype.draw = function() {
      var canvas, cc, div, h, hari, i, offset_hari_even, offset_hari_odd, offset_scale, offset_x, patterns, resolution, sasi, sec, _i, _j, _len, _ref;
      canvas = document.getElementById('canvas');
      cc = canvas.getContext('2d');
      cc.clearRect(0, 0, canvas.width, canvas.height);
      cc.save();
      vm.drawScale(cc);
      cc.restore();
      div = vm.division();
      resolution = vm.resolution();
      sec = 400 / div;
      if (resolution > 0) {
        hari = sec / resolution;
      } else {
        hari = 0;
      }
      offset_scale = 40;
      offset_hari_even = -hari;
      offset_hari_odd = -hari;
      patterns = vm.patterns();
      for (_i = 0, _len = patterns.length; _i < _len; _i++) {
        sasi = patterns[_i];
        for (h = _j = 0, _ref = sasi.round; 0 <= _ref ? _j < _ref : _j > _ref; h = 0 <= _ref ? ++_j : --_j) {
          offset_x = 0;
          if (sasi.offset % sasi.jump === 0) {
            offset_hari_even += hari;
            offset_x = offset_hari_even;
          } else {
            offset_hari_odd += hari;
            offset_x = offset_hari_odd;
          }
          i = 0;
          while (i < div) {
            cc.beginPath();
            cc.strokeStyle = sasi.color;
            if ((sasi.offset % sasi.jump === 0 && i % sasi.jump === 0) || (sasi.offset % sasi.jump !== 0 && i % sasi.jump !== 0)) {
              cc.moveTo(offset_scale + offset_x + sec * i, 50);
              cc.lineTo(offset_scale + offset_x + sec * (i + sasi.jump / 2), 80);
            } else {
              cc.moveTo(offset_scale + offset_x + sec * i, 80);
              cc.lineTo(offset_scale + offset_x + sec * (i + sasi.jump / 2), 50);
            }
            cc.stroke();
            i += sasi.jump / 2;
          }
        }
      }
      return cc.restore();
    };

    PatternViewModel.prototype.drawScale = function(cc) {
      var div, i, offset_x, sec, _i, _results;
      div = this.division();
      sec = 400 / div;
      offset_x = 40;
      _results = [];
      for (i = _i = 0; 0 <= div ? _i <= div : _i >= div; i = 0 <= div ? ++_i : --_i) {
        cc.beginPath();
        cc.strokeStyle = '#000';
        cc.moveTo(offset_x + sec * i, 30);
        cc.lineTo(offset_x + sec * i, 100);
        _results.push(cc.stroke());
      }
      return _results;
    };

    return PatternViewModel;

  })();

  vm = new PatternViewModel;

  ko.applyBindings(vm);

  $('#colorpallet').hide();

  $('#colorpallet_link').click(function() {
    var text;
    text = '';
    if ($('#colorpallet').is(':visible')) {
      text = '開く';
    } else {
      text = '閉じる';
    }
    $('#colorpallet_link').html(text);
    return $('#colorpallet').toggle();
  });

  console.log("hoge");

}).call(this);

},{}]},{},[1]);
