(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function() {
  var CHECKER_MAX, PatternViewModel, Sasi, vm;

  CHECKER_MAX = 100;

  Sasi = (function() {
    function Sasi(offset, color, round) {
      var self;
      this.color = color;
      self = this;
      this.offset = ko.observable(offset);
      this.validOffset = ko.observable(true);
      this.round = ko.observable(round);
      this.validRound = ko.observable(true);
      this.formattedOffset = ko.computed({
        read: function() {
          var value;
          value = this.offset();
          if (isNaN(value)) {
            value = parseInt(value.replace(/[^\d]/g, ""));
            if (isNaN(value)) {
              value = 0;
            }
          }
          this.offset(value);
          return value;
        },
        write: function(value) {
          value = parseInt(value.replace(/[^\d]/g, ""));
          if (isNaN(value)) {
            return this.validOffset(false);
          } else {
            this.validOffset(true);
            return this.offset(value);
          }
        },
        owner: this
      });
      this.formattedRound = ko.computed({
        read: function() {
          var value;
          value = this.round();
          if (isNaN(value)) {
            value = parseInt(value.replace(/[^\d]/g, ""));
            if (isNaN(value)) {
              value = 0;
            }
          }
          this.round(value <= 0 ? 1 : value);
          return this.round();
        },
        write: function(value) {
          value = parseInt(value.replace(/[^\d]/g, ""));
          if (isNaN(value)) {
            return this.validRound(false);
          } else {
            this.validRound(true);
            return this.round(value);
          }
        },
        owner: this
      });
    }

    return Sasi;

  })();

  PatternViewModel = (function() {
    function PatternViewModel() {
      this.patterns = ko.observableArray([new Sasi(0, 'red', 1), new Sasi(0, 'blue', 1)]);
      this.division = ko.observable(8);
      this.jump = ko.observable(2);
      this.resolution = ko.observable(30);
      this.step_simulation = ko.observable(false);
      this.steps = ko.observable(3);
    }

    PatternViewModel.prototype.addPattern = function() {
      return this.patterns.push(new Sasi(0, '#000000', 1));
    };

    PatternViewModel.prototype.removePattern = function(pattern) {
      return vm.patterns.remove(pattern);
    };

    PatternViewModel.prototype.duplicate = function(pattern) {
      return vm.patterns.push(new Sasi(pattern.offset, pattern.color, pattern.round));
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
      var canvas, cc, checker, color, div, h, hari, i, idx, j, jump, offset, offset_hari, offset_scale, offset_x, patterns, resolution, round, round_max, rounds, sasi, sec, step_simulation, steps, _i, _j, _len, _ref;
      canvas = document.getElementById('canvas');
      cc = canvas.getContext('2d');
      cc.clearRect(0, 0, canvas.width, canvas.height);
      cc.save();
      this.drawScale(cc);
      cc.restore();
      div = vm.division();
      jump = vm.jump();
      resolution = vm.resolution();
      step_simulation = vm.step_simulation();
      steps = vm.steps();
      round_max = resolution * jump;
      if (step_simulation) {
        round_max = steps * jump;
      }
      console.log("div=", div, "jump=", jump, "resolution=", resolution, "stepSimulation=", step_simulation, "steps=", steps, "round_max=", round_max);
      sec = 400 / div;
      if (resolution > 0) {
        hari = sec / resolution;
      } else {
        hari = 0;
      }
      offset_scale = 40;
      console.log("sec=", sec, "hari=", hari);
      patterns = vm.patterns();
      offset_hari = [];
      for (j = _i = 0, _ref = patterns.length; 0 <= _ref ? _i < _ref : _i > _ref; j = 0 <= _ref ? ++_i : --_i) {
        offset_hari.push(-hari);
      }
      rounds = 1;
      checker = 1;
      while ((rounds < round_max) && (checker < CHECKER_MAX)) {
        checker += 1;
        for (idx = _j = 0, _len = patterns.length; _j < _len; idx = ++_j) {
          sasi = patterns[idx];
          round = sasi.round();
          offset = sasi.offset();
          color = sasi.color;
          if (rounds <= patterns.length) {
            console.log("round=", round, ", offset=", offset, ", color=", color);
          }
          h = 0;
          while (h < round) {
            h += 1;
            rounds += 1;
            offset_x = 0;
            offset_hari[offset] += hari;
            offset_x = offset_hari[offset];
            i = offset;
            while (i <= div) {
              cc.beginPath();
              cc.strokeStyle = color;
              cc.moveTo(offset_scale + offset_x + sec * i, 50);
              cc.lineTo(offset_scale + offset_x + sec * (i + jump / 2), 80);
              cc.stroke();
              cc.beginPath();
              cc.moveTo(offset_scale + offset_x + sec * (i - jump / 2), 80);
              cc.lineTo(offset_scale + offset_x + sec * i, 50);
              cc.stroke();
              i += jump;
            }
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
