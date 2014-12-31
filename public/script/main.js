(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var ANIMATION_INTERVAL_MS, ItoVM, KomaVM, RESIZE_WAIT, SasiType, Simulator, YubinukiSimulatorVM, YubinukiVM, canvas1, canvasContainer, queue, setCanvasSize, vm, _ref;

Simulator = require('./simulator');

_ref = require('./viewmodel'), ItoVM = _ref.ItoVM, KomaVM = _ref.KomaVM, YubinukiVM = _ref.YubinukiVM, SasiType = _ref.SasiType;

ANIMATION_INTERVAL_MS = 500;

YubinukiSimulatorVM = (function() {
  function YubinukiSimulatorVM() {
    var canvas, cc, koma, self, yb;
    canvas = document.getElementById('canvas');
    cc = canvas.getContext('2d');
    cc.save();
    self = this;
    this.executing = false;
    this.simulator = new Simulator(canvas, cc);
    this.simulator.canvasResized();
    this.yubinuki = ko.observable(new YubinukiVM(8, 2, 30, false));
    this.stepSimulation = ko.observable(false);
    this.stepNum = ko.observable(10);
    this.stepMax = ko.computed(function() {
      var max, yubinuki;
      yubinuki = self.yubinuki();
      max = yubinuki.fmTobi() * yubinuki.fmResolution();
      console.log("stepMax", max);
      return max;
    }, this);
    this.showAnimation = ko.observable(false);
    this.animationStep = ko.observable(0);
    this.animationStepMax = ko.observable(this.stepMax());
    this.animationProgress = ko.computed(function() {
      return Math.ceil(self.animationStep() / self.animationStepMax() * 100);
    });
    yb = this.yubinuki();
    yb.startManualSet();
    yb.clearKoma();
    koma = yb.addKoma(0, SasiType.Nami, false);
    koma.addIto('blue', 5);
    koma.addIto('skyblue', 5);
    koma = yb.addKoma(1, SasiType.Nami, false);
    koma.addIto('red', 1);
    yb.endManualSet();
    this.simulate();
  }

  YubinukiSimulatorVM.prototype.simulate = function(silent) {
    var animate, animation, animationCb, animationSimulator, animationStepMax, yubinuki;
    if (silent == null) {
      silent = false;
    }
    if (this.executing) {
      alert("前回のシミュレーションが終了していません。しばらくお待ちください。");
      return;
    }
    this.executing = true;
    yubinuki = this.getYubinuki();
    animation = this.showAnimation();
    if (animation && !silent) {
      animationStepMax = this.stepMax();
      if (this.stepSimulation()) {
        animationStepMax = this.stepNum();
      }
      this.animationStepMax(animationStepMax);
      console.log("Simulator Mode ANIMATION, maxStep=", animationStepMax);
      this.animationStep(0);
      animationSimulator = this;
      animationCb = null;
      animate = function() {
        var animationStep, ret;
        animationStep = animationSimulator.animationStep();
        if (animationStep >= animationStepMax) {
          clearInterval(animationCb);
          animationSimulator.simulateEnded();
          return;
        }
        animationSimulator.animationStep(animationStep + 1);
        ret = animationSimulator.simulator.simulate(yubinuki, true, animationStep);
        if (!ret) {
          clearInterval(animationCb);
          return animationSimulator.simulateEnded();
        }
      };
      return animationCb = setInterval(animate, ANIMATION_INTERVAL_MS);
    } else {
      this.simulator.simulate(yubinuki, this.stepSimulation(), this.stepNum(), silent);
      return this.simulateEnded();
    }
  };

  YubinukiSimulatorVM.prototype.simulateEnded = function() {
    var canvas, cc;
    this.executing = false;
    canvas = document.getElementById('canvas');
    cc = canvas.getContext('2d');
    return cc.restore();
  };

  YubinukiSimulatorVM.prototype.getYubinuki = function() {
    return this.yubinuki();
  };

  return YubinukiSimulatorVM;

})();

vm = new YubinukiSimulatorVM();

queue = null;

RESIZE_WAIT = 300;

canvasContainer = $("#canvasContainer");

canvas1 = $("#canvas")[0];

setCanvasSize = function() {
  canvas1.width = canvasContainer.width();
  canvas1.height = canvasContainer.height();
  console.log(canvas1.width, canvas1.height);
  vm.simulator.canvasResized();
  return vm.simulate(true);
};

$(window).resize(function() {
  console.log("resize");
  clearTimeout(queue);
  return queue = setTimeout(function() {
    return setCanvasSize();
  }, RESIZE_WAIT);
});

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

ko.applyBindings(vm);

setCanvasSize();

console.log("hoge");



},{"./simulator":2,"./viewmodel":3}],2:[function(require,module,exports){
var CHECKER_MAX, DEFAULT_SIMULATOR_MARGIN_LEFT, DEFAULT_SIMULATOR_WIDTH, Direction, Ito, Koma, SCALE_LINE_COLOR, SCALE_TEXT_COLOR, SIDE_CUTOFF, SasiType, Simulator, SimulatorConfig, ValidatableModel, Yubinuki, _ref;

_ref = require('./yubinuki'), ValidatableModel = _ref.ValidatableModel, Ito = _ref.Ito, Koma = _ref.Koma, Yubinuki = _ref.Yubinuki, Direction = _ref.Direction, SasiType = _ref.SasiType;

DEFAULT_SIMULATOR_WIDTH = 400;

DEFAULT_SIMULATOR_MARGIN_LEFT = 10;

SimulatorConfig = {
  Width: 400,
  Margin: {
    Left: 60,
    Top: 30
  },
  Scale: {
    Top: 30,
    Bottom: 110,
    LabelTop: 20
  },
  Kagari: {
    Top: 50,
    Bottom: 90
  }
};

SCALE_LINE_COLOR = '#000';

SCALE_TEXT_COLOR = '#000';

CHECKER_MAX = 100;

SIDE_CUTOFF = true;

Simulator = (function() {
  function Simulator(canvas, context) {
    this.canvas = canvas;
    this.context = context;
  }

  Simulator.prototype.drawScaleOnly = function(yubinuki) {
    var komaNum;
    komaNum = yubinuki.config.koma;
    this.clearAll();
    return this.drawScale(komaNum);
  };

  Simulator.prototype.canvasResized = function() {
    var height, width;
    width = this.canvas.width;
    height = this.canvas.height;
    if (width <= DEFAULT_SIMULATOR_WIDTH) {
      SimulatorConfig.Width = width - DEFAULT_SIMULATOR_MARGIN_LEFT * 2;
      return SimulatorConfig.Margin.Left = DEFAULT_SIMULATOR_MARGIN_LEFT;
    } else {
      SimulatorConfig.Width = DEFAULT_SIMULATOR_WIDTH;
      return SimulatorConfig.Margin.Left = (width - DEFAULT_SIMULATOR_WIDTH) / 2;
    }
  };

  Simulator.prototype.simulate = function(yubinuki, stepExecute, stepNum, silent) {
    var komaNum;
    if (stepExecute == null) {
      stepExecute = false;
    }
    if (stepNum == null) {
      stepNum = 0;
    }
    if (silent == null) {
      silent = false;
    }
    komaNum = yubinuki.config.koma;
    console.log("Simulate: stepExecute=", stepExecute, "stepNum=", stepNum);
    if (!yubinuki.prepare()) {
      console.log("Simulate: state invalid.");
      if (!silent) {
        alert(yubinuki.getErrorMessages());
      }
      return false;
    }
    this.clearAll();
    this.drawScale(komaNum);
    this.draw(yubinuki, stepExecute, stepNum);
    if (SIDE_CUTOFF) {
      this.cutoff();
    }
    console.log("Simulate: end");
    return true;
  };

  Simulator.prototype.clearAll = function() {
    return this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
  };

  Simulator.prototype.drawScale = function(komaNum) {
    var i, komaWidth, left, scaleBottom, scaleTop, _i, _results;
    komaWidth = SimulatorConfig.Width / komaNum;
    left = SimulatorConfig.Margin.Left;
    scaleTop = SimulatorConfig.Scale.Top;
    scaleBottom = SimulatorConfig.Scale.Bottom;
    _results = [];
    for (i = _i = 0; 0 <= komaNum ? _i <= komaNum : _i >= komaNum; i = 0 <= komaNum ? ++_i : --_i) {
      this.context.beginPath();
      this.context.strokeStyle = SCALE_LINE_COLOR;
      this.context.moveTo(left + komaWidth * i, scaleTop);
      this.context.lineTo(left + komaWidth * i, scaleBottom);
      this.context.stroke();
      this.context.textAlign = 'center';
      _results.push(this.context.fillText(i, left + komaWidth * i, SimulatorConfig.Scale.LabelTop));
    }
    return _results;
  };

  Simulator.prototype.cutoff = function() {
    var kagariBottom, kagariTop, left, width;
    width = SimulatorConfig.Width;
    left = SimulatorConfig.Margin.Left;
    kagariTop = SimulatorConfig.Kagari.Top;
    kagariBottom = SimulatorConfig.Kagari.Bottom;
    this.context.clearRect(0, kagariTop - 1, left - 1, kagariBottom - kagariTop + 2);
    return this.context.clearRect(left + width + 1, kagariTop - 1, this.canvas.width - (left + width + 1), kagariBottom - kagariTop + 2);
  };

  Simulator.prototype.draw = function(yubinuki, stepExecute, stepNum) {
    var allFilled, chk, koma, komaArray, komaKagari, komaNum, komaWidth, loopNum, prevKoma, resolution, sasiWidth, stepCount, tobiNum, _results;
    komaNum = yubinuki.config.koma;
    tobiNum = yubinuki.config.tobi;
    resolution = yubinuki.config.resolution;
    komaWidth = SimulatorConfig.Width / komaNum;
    sasiWidth = komaWidth / resolution;
    loopNum = komaNum * resolution;
    komaArray = yubinuki.getKomaArray();
    allFilled = false;
    chk = 0;
    stepCount = 0;
    _results = [];
    while (!allFilled && (!stepExecute || (stepExecute && stepCount < stepNum)) && chk < CHECKER_MAX) {
      chk += 1;
      allFilled = true;
      prevKoma = null;
      _results.push((function() {
        var _i, _len, _results1;
        _results1 = [];
        for (_i = 0, _len = komaArray.length; _i < _len; _i++) {
          koma = komaArray[_i];
          if (stepExecute && stepCount >= stepNum) {
            break;
          }
          komaKagari = koma.komaKagari;
          if (komaKagari) {
            if (prevKoma !== null && !prevKoma.komaKagari && !prevKoma.isFilled()) {
              continue;
            }
            while (!koma.isFilled()) {
              if (stepExecute && stepCount >= stepNum) {
                break;
              }
              this.drawKomaRound(koma, komaWidth, sasiWidth);
              stepCount += 1;
            }
          } else {
            prevKoma = koma;
            this.drawKomaRound(koma, komaWidth, sasiWidth);
            stepCount += 1;
          }
          _results1.push(allFilled &= koma.isFilled());
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  Simulator.prototype.drawKomaRound = function(koma, komaWidth, sasiWidth) {
    var color, direction, end_x, kagariBottom, kagariTop, left, more_one, offset, sameRound, sasiEnd, sasiOffset, sasiStart, simulatorWidth, start_x, type, _results;
    offset = koma.offset;
    type = koma.type;
    color = koma.currentIto().color;
    simulatorWidth = SimulatorConfig.Width;
    left = SimulatorConfig.Margin.Left;
    kagariTop = SimulatorConfig.Kagari.Top;
    kagariBottom = SimulatorConfig.Kagari.Bottom;
    sameRound = true;
    _results = [];
    while (sameRound) {
      direction = koma.direction;
      sasiStart = koma.sasiStartIndex();
      sasiEnd = koma.sasiEndIndex();
      sasiOffset = koma.roundCount * sasiWidth;
      if (type === SasiType.Hiraki) {
        sasiOffset *= -1;
      }
      start_x = left + sasiOffset + komaWidth * sasiStart;
      end_x = left + sasiOffset + komaWidth * sasiEnd;
      if (type === SasiType.Hiraki) {
        start_x += simulatorWidth;
        end_x += simulatorWidth;
      }
      this.context.beginPath();
      this.context.strokeStyle = color;
      if (direction === Direction.Down) {
        this.context.moveTo(start_x, kagariTop);
        this.context.lineTo(end_x, kagariBottom);
      } else {
        this.context.moveTo(start_x, kagariBottom);
        this.context.lineTo(end_x, kagariTop);
      }
      this.context.stroke();
      more_one = false;
      if (end_x >= left + simulatorWidth) {
        more_one = true;
        start_x -= simulatorWidth;
        end_x -= simulatorWidth;
      }
      if (type === SasiType.Hiraki && end_x <= PADDING_LEFT) {
        more_one = true;
        start_x += simulatorWidth;
        end_x += simulatorWidth;
      }
      if (more_one) {
        this.context.beginPath();
        this.context.strokeStyle = color;
        if (direction === Direction.Down) {
          this.context.moveTo(start_x, kagariTop);
          this.context.lineTo(end_x, kagariBottom);
        } else {
          this.context.moveTo(start_x, kagariBottom);
          this.context.lineTo(end_x, kagariTop);
        }
        this.context.stroke();
      }
      _results.push(sameRound = koma.kagaru());
    }
    return _results;
  };

  return Simulator;

})();

module.exports = Simulator;



},{"./yubinuki":4}],3:[function(require,module,exports){
var DefaultIto, Direction, Ito, ItoVM, Koma, KomaVM, NumericCompution, SasiType, SasiTypeViewModel, ValidatableModel, Yubinuki, YubinukiVM, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

_ref = require('./yubinuki'), ValidatableModel = _ref.ValidatableModel, Ito = _ref.Ito, Koma = _ref.Koma, Yubinuki = _ref.Yubinuki, Direction = _ref.Direction, SasiType = _ref.SasiType;

NumericCompution = function(arg) {
  return {
    read: function() {
      var value;
      value = arg.read();
      if (isNaN(value)) {
        value = parseInt(value.replace(/[^\d\-]/g, ""));
        if (isNaN(value)) {
          value = 0;
        }
      }
      arg.write(value);
      return value;
    },
    write: function(value) {
      value = value + "";
      value = parseInt(value.replace(/[^\d\-]/g, ""));
      if (isNaN(value)) {
        return arg.validFlag(false);
      } else if (arg.check) {
        if (arg.check(value)) {
          arg.validFlag(true);
          return arg.write(value);
        } else {
          return arg.validFlag(false);
        }
      } else {
        arg.validFlag(true);
        return arg.write(value);
      }
    },
    owner: arg.owner
  };
};

SasiTypeViewModel = [
  {
    typeName: "並み刺し",
    typeId: 0
  }, {
    typeName: "開き刺し",
    typeId: 1
  }
];

DefaultIto = {
  Color: 'gray',
  Round: 1
};

ItoVM = (function(_super) {
  __extends(ItoVM, _super);

  function ItoVM(color, roundNum) {
    var self;
    ItoVM.__super__.constructor.call(this, color, roundNum);
    self = this;
    this.fmColorValid = ko.observable(true);
    this.fmColor = ko.computed({
      read: function() {
        return self.color;
      },
      write: function(value) {
        if (value.length === 0) {
          return this.fmColorValid(false);
        } else {
          this.fmColorValid(true);
          return self.color = value;
        }
      },
      owner: this
    });
    this.fmRoundValid = ko.observable(true);
    this.fmRound = ko.computed(NumericCompution({
      read: function() {
        return self.roundNum;
      },
      write: function(value) {
        return self.roundNum = value;
      },
      check: function(value) {
        return value > 0;
      },
      validFlag: this.fmRoundValid,
      owner: this
    }));
  }

  return ItoVM;

})(Ito);

KomaVM = (function(_super) {
  __extends(KomaVM, _super);

  function KomaVM(offset, type, komaKagari, config, setDefault) {
    var self;
    if (setDefault == null) {
      setDefault = true;
    }
    KomaVM.__super__.constructor.call(this, offset, type, komaKagari, config);
    self = this;
    this.fmOffsetValid = ko.observable(true);
    this.fmOffset = ko.computed(NumericCompution({
      read: function() {
        return self.offset;
      },
      write: function(value) {
        return self.offset = value;
      },
      check: function(value) {
        return value >= 0 && value < self.config.tobi;
      },
      validFlag: this.fmOffsetValid,
      owner: this
    }));
    this.fmType = ko.computed({
      read: function() {
        return SasiTypeViewModel[self.type];
      },
      write: function(obj) {
        return self.type = obj.typeId;
      },
      owner: this
    });
    this.fmKomaKagariCheck = ko.observable(self.komaKagari);
    this.fmKomaKagari = ko.computed({
      read: function() {
        return this.fmKomaKagariCheck();
      },
      write: function(value) {
        self.komaKagari = value;
        return this.fmKomaKagariCheck(value);
      },
      owner: this
    });
    this.itoArray = ko.observableArray();
    this.addNewIto = function() {
      return self.addIto(DefaultIto.Color, DefaultIto.Round);
    };
    this.removeIto = function(ito) {
      return self.itoArray.remove(ito);
    };
    this.moveUp = function(ito) {
      var index, itoArray;
      itoArray = self.itoArray;
      index = itoArray.indexOf(ito);
      if (index > 0) {
        itoArray.remove(ito);
        return itoArray.splice(index - 1, 0, ito);
      }
    };
    this.moveDown = function(ito) {
      var index, itoArray, itoLen;
      itoArray = self.itoArray;
      itoLen = self.itoArray().length;
      index = itoArray.indexOf(ito);
      if (index > -1 && index < itoLen - 1) {
        itoArray.remove(ito);
        return itoArray.splice(index + 1, 0, ito);
      }
    };
    if (setDefault) {
      this.addNewIto();
    }
  }

  KomaVM.prototype.getItoArray = function() {
    return this.itoArray();
  };

  KomaVM.prototype.addIto = function(color, roundNum) {
    var ito;
    ito = new ItoVM(color, roundNum);
    this.itoArray.push(ito);
    return ito;
  };

  return KomaVM;

})(Koma);

YubinukiVM = (function(_super) {
  __extends(YubinukiVM, _super);

  function YubinukiVM(komaNum, tobiNum, resolution) {
    var self;
    YubinukiVM.__super__.constructor.call(this, komaNum, tobiNum, resolution);
    this.prepared = false;
    this.availableKomaNums = [6, 7, 8, 9, 10, 11, 12, 16, 18, 20, 21, 24, 28, 32];
    this.availableTobiNums = [2, 3, 4, 5];
    this.availableOffsets = ko.observableArray([0, 1]);
    this.availableResolutions = [10, 20, 30];
    this.availableSasiTypes = SasiTypeViewModel;
    this.availableRoundNums = ko.observableArray([1, 2, 3, 4, 5]);
    this.komaArray = ko.observableArray();
    self = this;
    this.fmKomaValid = ko.observable(true);
    this.fmKomaNum = ko.computed(NumericCompution({
      read: function() {
        return self.config.koma;
      },
      write: function(value) {
        return self.config.koma = value;
      },
      validFlag: this.fmKomaValid,
      owner: this
    }));
    this.fmTobiValid = ko.observable(true);
    this.fmTobi = ko.observable(tobiNum);
    this.fmTobiNum = ko.computed(NumericCompution({
      read: function() {
        return self.config.tobi;
      },
      write: function(value) {
        self.config.tobi = value;
        self.fmTobi(value);
        return self.updateConfig();
      },
      validFlag: this.fmTobiValid,
      owner: this
    }));
    this.fmResolution = ko.observable(resolution);
    this.fmResolutionNum = ko.computed({
      read: function() {
        return this.config.resolution;
      },
      write: function(value) {
        this.config.resolution = value;
        this.fmResolution(value);
        return this.updateConfig();
      },
      owner: this
    });
    this.fmUseOneKoma = ko.observable(false);
    this.clickUseOneKoma = function() {
      this.updateConfig();
      return true;
    };
    this.fmEnableKasaneSasi = ko.computed(function() {
      return self.enableKasaneSasi();
    });
    this.prepared = true;
    this.updateConfig();
  }

  YubinukiVM.prototype.startManualSet = function() {
    return this.manualMode = true;
  };

  YubinukiVM.prototype.endManualSet = function() {
    return this.manualMode = false;
  };

  YubinukiVM.prototype.clearKoma = function() {
    return this.komaArray.removeAll();
  };

  YubinukiVM.prototype.getKomaArray = function() {
    return this.komaArray();
  };

  YubinukiVM.prototype.addKoma = function(offset, type, komaKagari, setDefault) {
    var koma;
    if (type == null) {
      type = SasiType.Nami;
    }
    if (komaKagari == null) {
      komaKagari = false;
    }
    if (setDefault == null) {
      setDefault = !this.manualMode;
    }
    koma = new KomaVM(offset, type, komaKagari, this.config, setDefault);
    this.komaArray.push(koma);
    return koma;
  };

  YubinukiVM.prototype.updateConfig = function() {
    var i, komaLen, need, remove, resolution, tobi, useOneKoma, _i, _results;
    if (!this.prepared) {
      return;
    }
    if (this.manualMode) {
      return;
    }
    komaLen = this.komaArray().length;
    tobi = this.config.tobi;
    this.availableOffsets.removeAll();
    i = 0;
    while (i < tobi) {
      this.availableOffsets.push(i);
      i += 1;
    }
    resolution = this.fmResolution();
    this.availableRoundNums.removeAll();
    i = 1;
    while (i <= resolution) {
      this.availableRoundNums.push(i);
      i += 1;
    }
    useOneKoma = this.fmUseOneKoma();
    if (useOneKoma) {
      tobi = 1;
    }
    if (komaLen < tobi) {
      need = tobi - komaLen;
      _results = [];
      for (i = _i = 1; 1 <= need ? _i <= need : _i >= need; i = 1 <= need ? ++_i : --_i) {
        _results.push(this.addKoma(0));
      }
      return _results;
    } else if (komaLen > tobi) {
      remove = komaLen - tobi;
      return this.komaArray.splice(komaLen - remove, remove);
    }
  };

  return YubinukiVM;

})(Yubinuki);

exports.ItoVM = ItoVM;

exports.KomaVM = KomaVM;

exports.YubinukiVM = YubinukiVM;

exports.SasiType = SasiType;

exports.DefaultIto = DefaultIto;



},{"./yubinuki":4}],4:[function(require,module,exports){
var Direction, Ito, Koma, SasiType, ValidatableModel, Yubinuki,
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

  Ito.prototype.prepare = function() {};

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

SasiType = {
  Nami: 0,
  Hiraki: 1
};

Koma = (function(_super) {
  __extends(Koma, _super);

  function Koma(offset, type, komaKagari, config) {
    this.offset = offset;
    this.type = type;
    this.komaKagari = komaKagari;
    this.config = config;
    Koma.__super__.constructor.apply(this, arguments);
    this.direction = Direction.Down;
    this.itoArray = [];
    this.sasiCount = 0;
    this.roundCount = 0;
    this.roundScale = 1;
  }

  Koma.prototype.getItoArray = function() {
    return this.itoArray;
  };

  Koma.prototype.setRoundScale = function(s) {
    return this.roundScale = s;
  };

  Koma.prototype.addIto = function(color, roundNum) {
    var ito;
    ito = new Ito(color, roundNum);
    this.getItoArray().push(ito);
    return ito;
  };

  Koma.prototype.prepare = function() {
    var ito, _i, _len, _ref, _results;
    this.direction = Direction.Down;
    this.sasiCount = 0;
    this.roundCount = 0;
    _ref = this.getItoArray();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      ito = _ref[_i];
      _results.push(ito.prepare());
    }
    return _results;
  };

  Koma.prototype.kagaru = function() {
    if (this.type === SasiType.Nami) {
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
    if (this.type === SasiType.Nami) {
      return this.offset + this.sasiCount + this.config.tobi / 2.0;
    } else {
      return this.offset + this.sasiCount - this.config.tobi / 2.0;
    }
  };

  Koma.prototype.currentIto = function() {
    var ito, itoArray, round, roundSum, totalRound, _i, _j, _len, _len1;
    itoArray = this.getItoArray();
    totalRound = 0;
    for (_i = 0, _len = itoArray.length; _i < _len; _i++) {
      ito = itoArray[_i];
      totalRound += ito.roundNum;
    }
    round = this.roundCount % totalRound;
    roundSum = 0;
    for (_j = 0, _len1 = itoArray.length; _j < _len1; _j++) {
      ito = itoArray[_j];
      roundSum += ito.roundNum;
      if (round < roundSum) {
        return ito;
      }
    }
    throw "対応する色設定が見つかりません。現在" + this.roundCount + "段目、存在する設定" + totalRound + "段、インデックス" + round;
  };

  Koma.prototype.validate = function() {
    var ito, itoArray, totalRound, _i, _j, _len, _len1;
    Koma.__super__.validate.apply(this, arguments);
    itoArray = this.getItoArray();
    for (_i = 0, _len = itoArray.length; _i < _len; _i++) {
      ito = itoArray[_i];
      if (!ito.validate()) {
        return false;
      }
    }
    totalRound = 0;
    for (_j = 0, _len1 = itoArray.length; _j < _len1; _j++) {
      ito = itoArray[_j];
      totalRound += ito.roundNum;
    }
    if (totalRound > this.config.resolution) {
      this.validateMessage.push("コマ内の糸の段数指定が、針数をオーバーしています。段数の合計が、針数以内に収まるように指定してください。");
      return false;
    }
    return true;
  };

  Koma.prototype.isValid = function() {
    var ito, itoArray, _i, _len;
    itoArray = this.getItoArray();
    for (_i = 0, _len = itoArray.length; _i < _len; _i++) {
      ito = itoArray[_i];
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

  function Yubinuki(komaNum, tobiNum, resolution) {
    Yubinuki.__super__.constructor.apply(this, arguments);
    this.config = {
      koma: komaNum,
      tobi: tobiNum,
      resolution: resolution
    };
    this.komaArray = [];
  }

  Yubinuki.prototype.getKomaArray = function() {
    return this.komaArray;
  };

  Yubinuki.prototype.prepare = function() {
    var koma, _i, _len, _ref;
    if (!this.validate()) {
      return false;
    }
    if (this.getKomaArray().length === 1) {
      this.getKomaArray()[0].setRoundScale(this.config.tobi);
    }
    _ref = this.getKomaArray();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      koma = _ref[_i];
      koma.prepare();
    }
    return true;
  };

  Yubinuki.prototype.addKoma = function(offset, type, komaKagari) {
    var koma;
    if (type == null) {
      type = SasiType.Nami;
    }
    if (komaKagari == null) {
      komaKagari = false;
    }
    koma = new Koma(offset, type, komaKagari, this.config);
    this.getKomaArray().push(koma);
    return koma;
  };

  Yubinuki.prototype.enableKasaneSasi = function() {
    return this.getKomaArray().length > 1;
  };

  Yubinuki.prototype.validate = function() {
    var koma, komaArray, offset, offsets_hiraki, offsets_nami, tobiNum, type, _i, _j, _k, _len, _len1, _len2;
    Yubinuki.__super__.validate.apply(this, arguments);
    tobiNum = this.config.tobi;
    komaArray = this.getKomaArray();
    if (komaArray.length === 0) {
      this.validateMessage.push("コマの設定がありません。");
      return false;
    }
    if (tobiNum < komaArray.length) {
      this.validateMessage.push("コマの設定が、トビ数を越えています。");
      return false;
    }
    if (komaArray.length !== 1 && komaArray.length !== tobiNum) {
      this.validateMessage.push("コマの設定は、1またはトビ数と同じにする必要があります。(コマ数 : " + komaArray.length + ", トビ数 : " + tobiNum + ")");
      return false;
    }
    for (_i = 0, _len = komaArray.length; _i < _len; _i++) {
      koma = komaArray[_i];
      if (!koma.validate()) {
        return false;
      }
    }
    offsets_nami = [];
    offsets_hiraki = [];
    for (_j = 0, _len1 = komaArray.length; _j < _len1; _j++) {
      koma = komaArray[_j];
      type = koma.type;
      offset = koma.offset;
      if ((type === SasiType.Nami && offsets_nami.indexOf(offset) >= 0) || (type === SasiType.Hiraki && offsets_hiraki.indexOf(offset) >= 0)) {
        this.validateMessage.push("同じ刺し方向で、かがり始めの位置が重複しています。かがり始めの位置を変更するか、差し方向を変更してください。");
        return false;
      }
      if (type === SasiType.Nami) {
        offsets_nami.push(offset);
      } else {
        offsets_hiraki.push(offset);
      }
    }
    for (_k = 0, _len2 = offsets_nami.length; _k < _len2; _k++) {
      offset = offsets_nami[_k];
      if (offsets_hiraki.indexOf(offset + 1) >= 0) {
        this.validateMessage.push("異る刺し方向で、かがるコマの位置が重複しています。かがり始めの位置を変更するか、差し方向を変更してください。");
        return false;
      }
    }
    return true;
  };

  Yubinuki.prototype.isValid = function() {
    var koma, komaArray, _i, _len;
    komaArray = this.getKomaArray();
    for (_i = 0, _len = komaArray.length; _i < _len; _i++) {
      koma = komaArray[_i];
      if (!koma.isValid()) {
        return false;
      }
    }
    return Yubinuki.__super__.isValid.apply(this, arguments);
  };

  Yubinuki.prototype.getErrorMessages = function() {
    var ito, koma, komaArray, messages, _i, _j, _len, _len1, _ref;
    messages = [];
    if (this.validateMessage.length > 0) {
      messages = messages.concat(this.validateMessage);
    }
    komaArray = this.getKomaArray();
    for (_i = 0, _len = komaArray.length; _i < _len; _i++) {
      koma = komaArray[_i];
      if (koma.validateMessage.length > 0) {
        messages = messages.concat(koma.validateMessage);
      }
      _ref = koma.itoArray;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        ito = _ref[_j];
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
  Direction: Direction,
  SasiType: SasiType
};



},{}]},{},[1]);
