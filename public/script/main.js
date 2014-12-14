(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function() {
  var Direction, Ito, Koma, Simulator, ValidatableModel, Yubinuki, YubinukiSimulatorVM, _ref;

  Simulator = require('./simulator.js');

  _ref = require('../../src/js/yubinuki.js'), ValidatableModel = _ref.ValidatableModel, Ito = _ref.Ito, Koma = _ref.Koma, Yubinuki = _ref.Yubinuki, Direction = _ref.Direction;

  YubinukiSimulatorVM = (function() {
    function YubinukiSimulatorVM() {
      var canvas, cc;
      canvas = document.getElementById('canvas');
      cc = canvas.getContext('2d');
      cc.save();
      this.simulator = new Simulator(canvas, cc);
    }

    YubinukiSimulatorVM.prototype.simulate = function() {
      var canvas, cc, yubinuki;
      yubinuki = this.getYubinuki();
      this.simulator.draw(yubinuki);
      canvas = document.getElementById('canvas');
      cc = canvas.getContext('2d');
      return cc.restore();
    };

    YubinukiSimulatorVM.prototype.getYubinuki = function() {
      var koma, yubinuki;
      yubinuki = new Yubinuki(8, 2, 30, false);
      koma = yubinuki.addKoma(0);
      koma.addIto('blue', 1);
      koma = yubinuki.addKoma(0, false);
      koma.addIto('red', 1);
      return yubinuki;
    };

    return YubinukiSimulatorVM;

  })();

  ko.applyBindings(new YubinukiSimulatorVM());

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

},{"../../src/js/yubinuki.js":3,"./simulator.js":2}],2:[function(require,module,exports){
(function() {
  var CHECKER_MAX, Direction, Ito, KAGARI_BOTTOM, KAGARI_TOP, Koma, PADDING_LEFT, SCALE_BOTTOM, SCALE_LABEL_TOP, SCALE_LINE_COLOR, SCALE_TEXT_COLOR, SCALE_TOP, SIDE_CUTOFF, SIMULATOR_WIDTH, Simulator, ValidatableModel, Yubinuki, _ref;

  _ref = require('./yubinuki.js'), ValidatableModel = _ref.ValidatableModel, Ito = _ref.Ito, Koma = _ref.Koma, Yubinuki = _ref.Yubinuki, Direction = _ref.Direction;

  PADDING_LEFT = 60;

  SIMULATOR_WIDTH = 400;

  SCALE_TOP = 30;

  SCALE_BOTTOM = 110;

  SCALE_LABEL_TOP = SCALE_TOP - 10;

  KAGARI_TOP = 50;

  KAGARI_BOTTOM = 90;

  SCALE_LINE_COLOR = '#000';

  SCALE_TEXT_COLOR = '#000';

  CHECKER_MAX = 100;

  SIDE_CUTOFF = false;

  Simulator = (function() {
    function Simulator(canvas, context) {
      this.canvas = canvas;
      this.context = context;
    }

    Simulator.prototype.draw = function(yubinuki) {
      var kasane, komaNum;
      komaNum = yubinuki.config.koma;
      kasane = yubinuki.kasane;
      yubinuki.prepare();
      this.clearAll();
      this.drawScale(komaNum);
      if (kasane) {

      } else {
        this.drawSimple(yubinuki);
      }
      if (SIDE_CUTOFF) {
        return this.cutoff();
      }
    };

    Simulator.prototype.clearAll = function() {
      return this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    };

    Simulator.prototype.drawScale = function(komaNum) {
      var i, komaWidth, _i, _results;
      komaWidth = SIMULATOR_WIDTH / komaNum;
      _results = [];
      for (i = _i = 0; 0 <= komaNum ? _i <= komaNum : _i >= komaNum; i = 0 <= komaNum ? ++_i : --_i) {
        this.context.beginPath();
        this.context.strokeStyle = SCALE_LINE_COLOR;
        this.context.moveTo(PADDING_LEFT + komaWidth * i, SCALE_TOP);
        this.context.lineTo(PADDING_LEFT + komaWidth * i, SCALE_BOTTOM);
        this.context.stroke();
        this.context.textAlign = 'center';
        _results.push(this.context.fillText(i, PADDING_LEFT + komaWidth * i, SCALE_LABEL_TOP));
      }
      return _results;
    };

    Simulator.prototype.cutoff = function() {
      this.context.clearRect(0, KAGARI_TOP - 1, PADDING_LEFT - 1, KAGARI_BOTTOM - KAGARI_TOP + 2);
      return this.context.clearRect(PADDING_LEFT + SIMULATOR_WIDTH + 1, KAGARI_TOP - 1, this.canvas.width - (PADDING_LEFT + SIMULATOR_WIDTH + 1), KAGARI_BOTTOM - KAGARI_TOP + 2);
    };

    Simulator.prototype.drawSimple = function(yubinuki) {
      var anchor, chk, color, direction, end_x, forward, koma, komaNum, komaWidth, loopNum, more_one, nextRound, offset, resolution, sasiEnd, sasiOffset, sasiStart, sasiWidth, start_x, tobiNum, _results;
      komaNum = yubinuki.config.koma;
      tobiNum = yubinuki.config.tobi;
      resolution = yubinuki.config.resolution;
      komaWidth = SIMULATOR_WIDTH / komaNum;
      sasiWidth = komaWidth / resolution;
      loopNum = komaNum * resolution;
      anchor = yubinuki.komaArray[yubinuki.komaArray.length - 1];
      chk = 0;
      _results = [];
      while (!anchor.isFilled() && chk < CHECKER_MAX) {
        chk += 1;
        _results.push((function() {
          var _i, _len, _ref1, _results1;
          _ref1 = yubinuki.komaArray;
          _results1 = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            koma = _ref1[_i];
            offset = koma.offset;
            forward = koma.forward;
            color = koma.currentIto().color;
            nextRound = true;
            _results1.push((function() {
              var _results2;
              _results2 = [];
              while (nextRound) {
                direction = koma.direction;
                sasiStart = koma.sasiStartIndex();
                sasiEnd = koma.sasiEndIndex();
                sasiOffset = koma.roundCount * sasiWidth;
                if (!forward) {
                  sasiOffset *= -1;
                }
                start_x = PADDING_LEFT + sasiOffset + komaWidth * sasiStart;
                end_x = PADDING_LEFT + sasiOffset + komaWidth * sasiEnd;
                if (!forward) {
                  start_x += SIMULATOR_WIDTH;
                  end_x += SIMULATOR_WIDTH;
                }
                this.context.beginPath();
                this.context.strokeStyle = color;
                if (direction === Direction.Down) {
                  this.context.moveTo(start_x, KAGARI_TOP);
                  this.context.lineTo(end_x, KAGARI_BOTTOM);
                } else {
                  this.context.moveTo(start_x, KAGARI_BOTTOM);
                  this.context.lineTo(end_x, KAGARI_TOP);
                }
                this.context.stroke();
                more_one = false;
                if (end_x >= PADDING_LEFT + SIMULATOR_WIDTH) {
                  more_one = true;
                  start_x -= SIMULATOR_WIDTH;
                  end_x -= SIMULATOR_WIDTH;
                }
                if (!forward && end_x <= PADDING_LEFT) {
                  more_one = true;
                  start_x += SIMULATOR_WIDTH;
                  end_x += SIMULATOR_WIDTH;
                }
                if (more_one) {
                  this.context.beginPath();
                  this.context.strokeStyle = color;
                  if (direction === Direction.Down) {
                    this.context.moveTo(start_x, KAGARI_TOP);
                    this.context.lineTo(end_x, KAGARI_BOTTOM);
                  } else {
                    this.context.moveTo(start_x, KAGARI_BOTTOM);
                    this.context.lineTo(end_x, KAGARI_TOP);
                  }
                  this.context.stroke();
                }
                _results2.push(nextRound = koma.kagaru());
              }
              return _results2;
            }).call(this));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    return Simulator;

  })();

  module.exports = Simulator;

}).call(this);

},{"./yubinuki.js":3}],3:[function(require,module,exports){
(function() {
  var Direction, Ito, Koma, ValidatableModel, Yubinuki,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ValidatableModel = (function() {
    function ValidatableModel() {
      this.validateMessage = [];
    }

    ValidatableModel.prototype.validate = function() {
      return this.validateMessage = [];
    };

    ValidatableModel.prototype.isValid = function() {
      return this.validateMessage.length === 0;
    };

    return ValidatableModel;

  })();

  Ito = (function(_super) {
    __extends(Ito, _super);

    function Ito(color, roundNum) {
      this.color = color;
      this.roundNum = roundNum;
      Ito.__super__.constructor.apply(this, arguments);
    }

    Ito.prototype.validate = function() {
      Ito.__super__.validate.apply(this, arguments);
      if (this.roundNum <= 0) {
        this.validateMessage.push("段数は1以上の数値を指定してください。");
        return false;
      }
      return true;
    };

    return Ito;

  })(ValidatableModel);

  Direction = {
    Down: 0,
    Up: 1
  };

  Koma = (function(_super) {
    __extends(Koma, _super);

    function Koma(offset, forward, config) {
      this.offset = offset;
      this.forward = forward;
      this.config = config;
      Koma.__super__.constructor.apply(this, arguments);
      this.direction = Direction.Down;
      this.itoArray = [];
      this.sasiCount = 0;
      this.roundCount = 0;
      this.roundScale = 1;
    }

    Koma.prototype.setRoundScale = function(s) {
      return this.roundScale = s;
    };

    Koma.prototype.addIto = function(color, roundNum) {
      var ito;
      ito = new Ito(color, roundNum);
      this.itoArray.push(ito);
      return ito;
    };

    Koma.prototype.kagaru = function() {
      if (this.forward) {
        this.sasiCount += this.config.tobi / 2.0;
      } else {
        this.sasiCount -= this.config.tobi / 2.0;
      }
      if (this.direction === Direction.Down) {
        this.direction = Direction.Up;
      } else {
        this.direction = Direction.Down;
      }
      if ((this.sasiCount % this.config.koma === 0) && (this.sasiCount % this.config.tobi === 0)) {
        this.sasiCount = 0;
        this.roundCount += 1;
        return false;
      }
      return true;
    };

    Koma.prototype.isFilled = function() {
      return this.roundCount >= this.config.resolution * this.roundScale;
    };

    Koma.prototype.sasiStartIndex = function() {
      return this.offset + this.sasiCount;
    };

    Koma.prototype.sasiEndIndex = function() {
      if (this.forward) {
        return this.offset + this.sasiCount + this.config.tobi / 2.0;
      } else {
        return this.offset + this.sasiCount - this.config.tobi / 2.0;
      }
    };

    Koma.prototype.currentIto = function() {
      var ito, round, roundSum, totalRound, _i, _j, _len, _len1, _ref, _ref1;
      totalRound = 0;
      _ref = this.itoArray;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ito = _ref[_i];
        totalRound += ito.roundNum;
      }
      round = this.roundCount % totalRound;
      roundSum = 0;
      _ref1 = this.itoArray;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        ito = _ref1[_j];
        roundSum += ito.roundNum;
        if (round < roundSum) {
          return ito;
        }
      }
      throw "対応する色設定が見つかりません。現在" + this.roundCount + "段目、存在する設定" + totalRound + "段、インデックス" + round;
    };

    Koma.prototype.validate = function() {
      var ito, totalRound, _i, _j, _len, _len1, _ref, _ref1;
      Koma.__super__.validate.apply(this, arguments);
      _ref = this.itoArray;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ito = _ref[_i];
        if (!ito.validate()) {
          return false;
        }
      }
      totalRound = 0;
      _ref1 = this.itoArray;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        ito = _ref1[_j];
        totalRound += ito.roundNum;
      }
      if (totalRound > this.config.resolution) {
        this.validateMessage.push("コマ内の糸の段数指定が、針数をオーバーしています。段数の合計が、針数以内に収まるように指定してください。");
        return false;
      }
      return true;
    };

    Koma.prototype.isValid = function() {
      var ito, _i, _len, _ref;
      _ref = this.itoArray;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ito = _ref[_i];
        if (!ito.isValid()) {
          return false;
        }
      }
      return Koma.__super__.isValid.apply(this, arguments);
    };

    return Koma;

  })(ValidatableModel);

  Yubinuki = (function(_super) {
    __extends(Yubinuki, _super);

    function Yubinuki(komaNum, tobiNum, resolution, kasane) {
      this.kasane = kasane;
      Yubinuki.__super__.constructor.apply(this, arguments);
      this.config = {
        koma: komaNum,
        tobi: tobiNum,
        resolution: resolution
      };
      this.komaArray = [];
    }

    Yubinuki.prototype.prepare = function() {
      if (!this.validate()) {
        return false;
      }
      if (this.komaArray.length === 1) {
        this.komaArray[0].setRoundScale(this.config.tobi);
      }
      return true;
    };

    Yubinuki.prototype.addKoma = function(offset, forward) {
      var koma;
      if (forward == null) {
        forward = true;
      }
      koma = new Koma(offset, forward, this.config);
      this.komaArray.push(koma);
      return koma;
    };

    Yubinuki.prototype.validate = function() {
      var forward, koma, offset, offsets_backward, offsets_forward, tobiNum, _i, _j, _len, _len1, _ref, _ref1;
      Yubinuki.__super__.validate.apply(this, arguments);
      tobiNum = this.config.tobi;
      if (this.komaArray.length === 0) {
        this.validateMessage.push("コマの設定がありません。");
        return false;
      }
      if (tobiNum < this.komaArray.length) {
        this.validateMessage.push("コマの設定が、トビ数を越えています。");
        return false;
      }
      if (this.komaArray.length !== 1 && this.komaArray.length !== tobiNum) {
        this.validateMessage.push("コマの設定は、1またはトビ数と同じにする必要があります。(コマ数 : " + this.komaArray.length + ", トビ数 : " + tobiNum + ")");
        return false;
      }
      _ref = this.komaArray;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        koma = _ref[_i];
        if (!koma.validate()) {
          return false;
        }
      }
      offsets_forward = [];
      offsets_backward = [];
      _ref1 = this.komaArray;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        koma = _ref1[_j];
        forward = koma.forward;
        offset = koma.offset;
        if ((forward && offsets_forward.indexOf(offset) >= 0) || (!forward && offsets_backward.indexOf(offset) >= 0)) {
          this.validateMessage.push("同じ差し方向で、かがり始めの位置が重複しています。かがり始めの位置を変更するか、差し方向を変更してください。");
          return false;
        }
        if (forward) {
          offsets_forward.push(offset);
        } else {
          offsets_backward.push(offset);
        }
      }
      return true;
    };

    Yubinuki.prototype.isValid = function() {
      var koma, _i, _len, _ref;
      _ref = this.komaArray;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        koma = _ref[_i];
        if (!koma.isValid()) {
          return false;
        }
      }
      return Yubinuki.__super__.isValid.apply(this, arguments);
    };

    Yubinuki.prototype.getErrorMessages = function() {
      var ito, koma, messages, _i, _j, _len, _len1, _ref, _ref1;
      messages = [];
      if (this.validateMessage.length > 0) {
        messages = messages.concat(this.validateMessage);
      }
      _ref = this.komaArray;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        koma = _ref[_i];
        if (koma.validateMessage.length > 0) {
          messages = messages.concat(koma.validateMessage);
        }
        _ref1 = koma.itoArray;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          ito = _ref1[_j];
          if (ito.validateMessage.length > 0) {
            messages = messages.concat(ito.validateMessage);
          }
        }
      }
      return messages;
    };

    return Yubinuki;

  })(ValidatableModel);

  module.exports = {
    ValidatableModel: ValidatableModel,
    Ito: Ito,
    Koma: Koma,
    Yubinuki: Yubinuki,
    Direction: Direction
  };

}).call(this);

},{}]},{},[1]);
