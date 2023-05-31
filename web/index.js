(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
"use strict";

var _fcl = require("@onflow/fcl");

var fcl = _interopRequireWildcard(_fcl);

var _types = require("@onflow/types");

var types = _interopRequireWildcard(_types);

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

fcl.config({
  "accessNode.api": "https://rest-testnet.onflow.org",
  "discovery.wallet": "https://fcl-discovery.onflow.org/testnet/authn"
});

window.authenticate = fcl.authenticate;
window.unauthenticate = fcl.unauthenticate;
window.subscribe = fcl.currentUser.subscribe;
window.getAddr = function(user) {
  return user.addr;
};

// transactions
window.createPlayer = async function (playerName) {
  var transactionId = await fcl.mutate({
    cadence: "\n      import CodeOfFlowAlpha6 from 0x9e447fb949c3f1b6\n\n      transaction(nickname: String) {\n        prepare(acct: AuthAccount) {\n          acct.save(<- CodeOfFlowAlpha6.createPlayer(nickname: nickname), to: CodeOfFlowAlpha6.PlayerStoragePath)\n          acct.link<&CodeOfFlowAlpha6.Player{CodeOfFlowAlpha6.IPlayerPublic}>(CodeOfFlowAlpha6.PlayerPublicPath, target: CodeOfFlowAlpha6.PlayerStoragePath)\n          }\n        execute {\n          log(\"success\")\n        }\n      }\n    ",
    args: function args(arg, t) {
      return [arg(playerName ? playerName : 'Test Player', t.String)];
    },
    proposer: fcl.authz,
    payer: fcl.authz,
    authorizations: [fcl.authz],
    limit: 999
  });
  console.log("TransactionId: " + transactionId);
};

// scripts
window.isRegistered = async function (address) {
  const result = await fcl.query({
    cadence: `
    import CodeOfFlowAlpha6 from 0x9e447fb949c3f1b6
    pub fun main(address: Address): &CodeOfFlowAlpha6.Player{CodeOfFlowAlpha6.IPlayerPublic}? {
        return getAccount(address).getCapability<&CodeOfFlowAlpha6.Player{CodeOfFlowAlpha6.IPlayerPublic}>(CodeOfFlowAlpha6.PlayerPublicPath).borrow()
    }
    `,
    args: (arg, t) => [
      arg(address, t.Address)
    ]
  })
  return result;
}
window.getCurrentStatus = async function (address) {
  const result = await fcl.query({
    cadence: `
    import CodeOfFlowAlpha6 from 0x9e447fb949c3f1b6
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha6.Player{CodeOfFlowAlpha6.IPlayerPublic}>(CodeOfFlowAlpha6.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_current_status()
    }
    `,
    args: (arg, t) => [
      arg(address, t.Address)
    ]
  });
  console.log(result);
  return result;
};
window.getMariganCards = async function (address, playerId) {
  const result = await fcl.query({
    cadence: `
    import CodeOfFlowAlpha6 from 0x9e447fb949c3f1b6
    pub fun main(address: Address, player_id: UInt32): [[UInt16]] {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha6.Player{CodeOfFlowAlpha6.IPlayerPublic}>(CodeOfFlowAlpha6.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_marigan_cards(player_id: player_id)
    }
    `,
    args: (arg, t) => [
      arg(address, t.Address),
      arg(playerId, t.UInt32)
    ]
  });
  console.log(result);
  return result
};
window.getPlayerName = function(player) {
  return player.nickname;
};
window.getPlayerId = function(player) {
  return player.player_id;
};
window.getPlayerUUId = function(player) {
  return player.uuid;
};

},{"@onflow/fcl":37,"@onflow/types":41}],2:[function(require,module,exports){
function _arrayLikeToArray(arr, len) {
  if (len == null || len > arr.length) len = arr.length;
  for (var i = 0, arr2 = new Array(len); i < len; i++) arr2[i] = arr[i];
  return arr2;
}
module.exports = _arrayLikeToArray, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{}],3:[function(require,module,exports){
function _arrayWithHoles(arr) {
  if (Array.isArray(arr)) return arr;
}
module.exports = _arrayWithHoles, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{}],4:[function(require,module,exports){
var arrayLikeToArray = require("./arrayLikeToArray.js");
function _arrayWithoutHoles(arr) {
  if (Array.isArray(arr)) return arrayLikeToArray(arr);
}
module.exports = _arrayWithoutHoles, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./arrayLikeToArray.js":2}],5:[function(require,module,exports){
function _assertThisInitialized(self) {
  if (self === void 0) {
    throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
  }
  return self;
}
module.exports = _assertThisInitialized, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{}],6:[function(require,module,exports){
function asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) {
  try {
    var info = gen[key](arg);
    var value = info.value;
  } catch (error) {
    reject(error);
    return;
  }
  if (info.done) {
    resolve(value);
  } else {
    Promise.resolve(value).then(_next, _throw);
  }
}
function _asyncToGenerator(fn) {
  return function () {
    var self = this,
      args = arguments;
    return new Promise(function (resolve, reject) {
      var gen = fn.apply(self, args);
      function _next(value) {
        asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value);
      }
      function _throw(err) {
        asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err);
      }
      _next(undefined);
    });
  };
}
module.exports = _asyncToGenerator, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{}],7:[function(require,module,exports){
function _classCallCheck(instance, Constructor) {
  if (!(instance instanceof Constructor)) {
    throw new TypeError("Cannot call a class as a function");
  }
}
module.exports = _classCallCheck, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{}],8:[function(require,module,exports){
var setPrototypeOf = require("./setPrototypeOf.js");
var isNativeReflectConstruct = require("./isNativeReflectConstruct.js");
function _construct(Parent, args, Class) {
  if (isNativeReflectConstruct()) {
    module.exports = _construct = Reflect.construct.bind(), module.exports.__esModule = true, module.exports["default"] = module.exports;
  } else {
    module.exports = _construct = function _construct(Parent, args, Class) {
      var a = [null];
      a.push.apply(a, args);
      var Constructor = Function.bind.apply(Parent, a);
      var instance = new Constructor();
      if (Class) setPrototypeOf(instance, Class.prototype);
      return instance;
    }, module.exports.__esModule = true, module.exports["default"] = module.exports;
  }
  return _construct.apply(null, arguments);
}
module.exports = _construct, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./isNativeReflectConstruct.js":16,"./setPrototypeOf.js":26}],9:[function(require,module,exports){
var toPropertyKey = require("./toPropertyKey.js");
function _defineProperties(target, props) {
  for (var i = 0; i < props.length; i++) {
    var descriptor = props[i];
    descriptor.enumerable = descriptor.enumerable || false;
    descriptor.configurable = true;
    if ("value" in descriptor) descriptor.writable = true;
    Object.defineProperty(target, toPropertyKey(descriptor.key), descriptor);
  }
}
function _createClass(Constructor, protoProps, staticProps) {
  if (protoProps) _defineProperties(Constructor.prototype, protoProps);
  if (staticProps) _defineProperties(Constructor, staticProps);
  Object.defineProperty(Constructor, "prototype", {
    writable: false
  });
  return Constructor;
}
module.exports = _createClass, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./toPropertyKey.js":31}],10:[function(require,module,exports){
var unsupportedIterableToArray = require("./unsupportedIterableToArray.js");
function _createForOfIteratorHelper(o, allowArrayLike) {
  var it = typeof Symbol !== "undefined" && o[Symbol.iterator] || o["@@iterator"];
  if (!it) {
    if (Array.isArray(o) || (it = unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") {
      if (it) o = it;
      var i = 0;
      var F = function F() {};
      return {
        s: F,
        n: function n() {
          if (i >= o.length) return {
            done: true
          };
          return {
            done: false,
            value: o[i++]
          };
        },
        e: function e(_e) {
          throw _e;
        },
        f: F
      };
    }
    throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.");
  }
  var normalCompletion = true,
    didErr = false,
    err;
  return {
    s: function s() {
      it = it.call(o);
    },
    n: function n() {
      var step = it.next();
      normalCompletion = step.done;
      return step;
    },
    e: function e(_e2) {
      didErr = true;
      err = _e2;
    },
    f: function f() {
      try {
        if (!normalCompletion && it["return"] != null) it["return"]();
      } finally {
        if (didErr) throw err;
      }
    }
  };
}
module.exports = _createForOfIteratorHelper, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./unsupportedIterableToArray.js":33}],11:[function(require,module,exports){
var getPrototypeOf = require("./getPrototypeOf.js");
var isNativeReflectConstruct = require("./isNativeReflectConstruct.js");
var possibleConstructorReturn = require("./possibleConstructorReturn.js");
function _createSuper(Derived) {
  var hasNativeReflectConstruct = isNativeReflectConstruct();
  return function _createSuperInternal() {
    var Super = getPrototypeOf(Derived),
      result;
    if (hasNativeReflectConstruct) {
      var NewTarget = getPrototypeOf(this).constructor;
      result = Reflect.construct(Super, arguments, NewTarget);
    } else {
      result = Super.apply(this, arguments);
    }
    return possibleConstructorReturn(this, result);
  };
}
module.exports = _createSuper, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./getPrototypeOf.js":13,"./isNativeReflectConstruct.js":16,"./possibleConstructorReturn.js":24}],12:[function(require,module,exports){
var toPropertyKey = require("./toPropertyKey.js");
function _defineProperty(obj, key, value) {
  key = toPropertyKey(key);
  if (key in obj) {
    Object.defineProperty(obj, key, {
      value: value,
      enumerable: true,
      configurable: true,
      writable: true
    });
  } else {
    obj[key] = value;
  }
  return obj;
}
module.exports = _defineProperty, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./toPropertyKey.js":31}],13:[function(require,module,exports){
function _getPrototypeOf(o) {
  module.exports = _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf.bind() : function _getPrototypeOf(o) {
    return o.__proto__ || Object.getPrototypeOf(o);
  }, module.exports.__esModule = true, module.exports["default"] = module.exports;
  return _getPrototypeOf(o);
}
module.exports = _getPrototypeOf, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{}],14:[function(require,module,exports){
var setPrototypeOf = require("./setPrototypeOf.js");
function _inherits(subClass, superClass) {
  if (typeof superClass !== "function" && superClass !== null) {
    throw new TypeError("Super expression must either be null or a function");
  }
  subClass.prototype = Object.create(superClass && superClass.prototype, {
    constructor: {
      value: subClass,
      writable: true,
      configurable: true
    }
  });
  Object.defineProperty(subClass, "prototype", {
    writable: false
  });
  if (superClass) setPrototypeOf(subClass, superClass);
}
module.exports = _inherits, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./setPrototypeOf.js":26}],15:[function(require,module,exports){
function _isNativeFunction(fn) {
  return Function.toString.call(fn).indexOf("[native code]") !== -1;
}
module.exports = _isNativeFunction, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{}],16:[function(require,module,exports){
function _isNativeReflectConstruct() {
  if (typeof Reflect === "undefined" || !Reflect.construct) return false;
  if (Reflect.construct.sham) return false;
  if (typeof Proxy === "function") return true;
  try {
    Boolean.prototype.valueOf.call(Reflect.construct(Boolean, [], function () {}));
    return true;
  } catch (e) {
    return false;
  }
}
module.exports = _isNativeReflectConstruct, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{}],17:[function(require,module,exports){
function _iterableToArray(iter) {
  if (typeof Symbol !== "undefined" && iter[Symbol.iterator] != null || iter["@@iterator"] != null) return Array.from(iter);
}
module.exports = _iterableToArray, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{}],18:[function(require,module,exports){
function _iterableToArrayLimit(arr, i) {
  var _i = null == arr ? null : "undefined" != typeof Symbol && arr[Symbol.iterator] || arr["@@iterator"];
  if (null != _i) {
    var _s,
      _e,
      _x,
      _r,
      _arr = [],
      _n = !0,
      _d = !1;
    try {
      if (_x = (_i = _i.call(arr)).next, 0 === i) {
        if (Object(_i) !== _i) return;
        _n = !1;
      } else for (; !(_n = (_s = _x.call(_i)).done) && (_arr.push(_s.value), _arr.length !== i); _n = !0);
    } catch (err) {
      _d = !0, _e = err;
    } finally {
      try {
        if (!_n && null != _i["return"] && (_r = _i["return"](), Object(_r) !== _r)) return;
      } finally {
        if (_d) throw _e;
      }
    }
    return _arr;
  }
}
module.exports = _iterableToArrayLimit, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{}],19:[function(require,module,exports){
function _nonIterableRest() {
  throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.");
}
module.exports = _nonIterableRest, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{}],20:[function(require,module,exports){
function _nonIterableSpread() {
  throw new TypeError("Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.");
}
module.exports = _nonIterableSpread, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{}],21:[function(require,module,exports){
var defineProperty = require("./defineProperty.js");
function ownKeys(object, enumerableOnly) {
  var keys = Object.keys(object);
  if (Object.getOwnPropertySymbols) {
    var symbols = Object.getOwnPropertySymbols(object);
    enumerableOnly && (symbols = symbols.filter(function (sym) {
      return Object.getOwnPropertyDescriptor(object, sym).enumerable;
    })), keys.push.apply(keys, symbols);
  }
  return keys;
}
function _objectSpread2(target) {
  for (var i = 1; i < arguments.length; i++) {
    var source = null != arguments[i] ? arguments[i] : {};
    i % 2 ? ownKeys(Object(source), !0).forEach(function (key) {
      defineProperty(target, key, source[key]);
    }) : Object.getOwnPropertyDescriptors ? Object.defineProperties(target, Object.getOwnPropertyDescriptors(source)) : ownKeys(Object(source)).forEach(function (key) {
      Object.defineProperty(target, key, Object.getOwnPropertyDescriptor(source, key));
    });
  }
  return target;
}
module.exports = _objectSpread2, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./defineProperty.js":12}],22:[function(require,module,exports){
var objectWithoutPropertiesLoose = require("./objectWithoutPropertiesLoose.js");
function _objectWithoutProperties(source, excluded) {
  if (source == null) return {};
  var target = objectWithoutPropertiesLoose(source, excluded);
  var key, i;
  if (Object.getOwnPropertySymbols) {
    var sourceSymbolKeys = Object.getOwnPropertySymbols(source);
    for (i = 0; i < sourceSymbolKeys.length; i++) {
      key = sourceSymbolKeys[i];
      if (excluded.indexOf(key) >= 0) continue;
      if (!Object.prototype.propertyIsEnumerable.call(source, key)) continue;
      target[key] = source[key];
    }
  }
  return target;
}
module.exports = _objectWithoutProperties, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./objectWithoutPropertiesLoose.js":23}],23:[function(require,module,exports){
function _objectWithoutPropertiesLoose(source, excluded) {
  if (source == null) return {};
  var target = {};
  var sourceKeys = Object.keys(source);
  var key, i;
  for (i = 0; i < sourceKeys.length; i++) {
    key = sourceKeys[i];
    if (excluded.indexOf(key) >= 0) continue;
    target[key] = source[key];
  }
  return target;
}
module.exports = _objectWithoutPropertiesLoose, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{}],24:[function(require,module,exports){
var _typeof = require("./typeof.js")["default"];
var assertThisInitialized = require("./assertThisInitialized.js");
function _possibleConstructorReturn(self, call) {
  if (call && (_typeof(call) === "object" || typeof call === "function")) {
    return call;
  } else if (call !== void 0) {
    throw new TypeError("Derived constructors may only return object or undefined");
  }
  return assertThisInitialized(self);
}
module.exports = _possibleConstructorReturn, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./assertThisInitialized.js":5,"./typeof.js":32}],25:[function(require,module,exports){
var _typeof = require("./typeof.js")["default"];
function _regeneratorRuntime() {
  "use strict"; /*! regenerator-runtime -- Copyright (c) 2014-present, Facebook, Inc. -- license (MIT): https://github.com/facebook/regenerator/blob/main/LICENSE */
  module.exports = _regeneratorRuntime = function _regeneratorRuntime() {
    return exports;
  }, module.exports.__esModule = true, module.exports["default"] = module.exports;
  var exports = {},
    Op = Object.prototype,
    hasOwn = Op.hasOwnProperty,
    defineProperty = Object.defineProperty || function (obj, key, desc) {
      obj[key] = desc.value;
    },
    $Symbol = "function" == typeof Symbol ? Symbol : {},
    iteratorSymbol = $Symbol.iterator || "@@iterator",
    asyncIteratorSymbol = $Symbol.asyncIterator || "@@asyncIterator",
    toStringTagSymbol = $Symbol.toStringTag || "@@toStringTag";
  function define(obj, key, value) {
    return Object.defineProperty(obj, key, {
      value: value,
      enumerable: !0,
      configurable: !0,
      writable: !0
    }), obj[key];
  }
  try {
    define({}, "");
  } catch (err) {
    define = function define(obj, key, value) {
      return obj[key] = value;
    };
  }
  function wrap(innerFn, outerFn, self, tryLocsList) {
    var protoGenerator = outerFn && outerFn.prototype instanceof Generator ? outerFn : Generator,
      generator = Object.create(protoGenerator.prototype),
      context = new Context(tryLocsList || []);
    return defineProperty(generator, "_invoke", {
      value: makeInvokeMethod(innerFn, self, context)
    }), generator;
  }
  function tryCatch(fn, obj, arg) {
    try {
      return {
        type: "normal",
        arg: fn.call(obj, arg)
      };
    } catch (err) {
      return {
        type: "throw",
        arg: err
      };
    }
  }
  exports.wrap = wrap;
  var ContinueSentinel = {};
  function Generator() {}
  function GeneratorFunction() {}
  function GeneratorFunctionPrototype() {}
  var IteratorPrototype = {};
  define(IteratorPrototype, iteratorSymbol, function () {
    return this;
  });
  var getProto = Object.getPrototypeOf,
    NativeIteratorPrototype = getProto && getProto(getProto(values([])));
  NativeIteratorPrototype && NativeIteratorPrototype !== Op && hasOwn.call(NativeIteratorPrototype, iteratorSymbol) && (IteratorPrototype = NativeIteratorPrototype);
  var Gp = GeneratorFunctionPrototype.prototype = Generator.prototype = Object.create(IteratorPrototype);
  function defineIteratorMethods(prototype) {
    ["next", "throw", "return"].forEach(function (method) {
      define(prototype, method, function (arg) {
        return this._invoke(method, arg);
      });
    });
  }
  function AsyncIterator(generator, PromiseImpl) {
    function invoke(method, arg, resolve, reject) {
      var record = tryCatch(generator[method], generator, arg);
      if ("throw" !== record.type) {
        var result = record.arg,
          value = result.value;
        return value && "object" == _typeof(value) && hasOwn.call(value, "__await") ? PromiseImpl.resolve(value.__await).then(function (value) {
          invoke("next", value, resolve, reject);
        }, function (err) {
          invoke("throw", err, resolve, reject);
        }) : PromiseImpl.resolve(value).then(function (unwrapped) {
          result.value = unwrapped, resolve(result);
        }, function (error) {
          return invoke("throw", error, resolve, reject);
        });
      }
      reject(record.arg);
    }
    var previousPromise;
    defineProperty(this, "_invoke", {
      value: function value(method, arg) {
        function callInvokeWithMethodAndArg() {
          return new PromiseImpl(function (resolve, reject) {
            invoke(method, arg, resolve, reject);
          });
        }
        return previousPromise = previousPromise ? previousPromise.then(callInvokeWithMethodAndArg, callInvokeWithMethodAndArg) : callInvokeWithMethodAndArg();
      }
    });
  }
  function makeInvokeMethod(innerFn, self, context) {
    var state = "suspendedStart";
    return function (method, arg) {
      if ("executing" === state) throw new Error("Generator is already running");
      if ("completed" === state) {
        if ("throw" === method) throw arg;
        return doneResult();
      }
      for (context.method = method, context.arg = arg;;) {
        var delegate = context.delegate;
        if (delegate) {
          var delegateResult = maybeInvokeDelegate(delegate, context);
          if (delegateResult) {
            if (delegateResult === ContinueSentinel) continue;
            return delegateResult;
          }
        }
        if ("next" === context.method) context.sent = context._sent = context.arg;else if ("throw" === context.method) {
          if ("suspendedStart" === state) throw state = "completed", context.arg;
          context.dispatchException(context.arg);
        } else "return" === context.method && context.abrupt("return", context.arg);
        state = "executing";
        var record = tryCatch(innerFn, self, context);
        if ("normal" === record.type) {
          if (state = context.done ? "completed" : "suspendedYield", record.arg === ContinueSentinel) continue;
          return {
            value: record.arg,
            done: context.done
          };
        }
        "throw" === record.type && (state = "completed", context.method = "throw", context.arg = record.arg);
      }
    };
  }
  function maybeInvokeDelegate(delegate, context) {
    var methodName = context.method,
      method = delegate.iterator[methodName];
    if (undefined === method) return context.delegate = null, "throw" === methodName && delegate.iterator["return"] && (context.method = "return", context.arg = undefined, maybeInvokeDelegate(delegate, context), "throw" === context.method) || "return" !== methodName && (context.method = "throw", context.arg = new TypeError("The iterator does not provide a '" + methodName + "' method")), ContinueSentinel;
    var record = tryCatch(method, delegate.iterator, context.arg);
    if ("throw" === record.type) return context.method = "throw", context.arg = record.arg, context.delegate = null, ContinueSentinel;
    var info = record.arg;
    return info ? info.done ? (context[delegate.resultName] = info.value, context.next = delegate.nextLoc, "return" !== context.method && (context.method = "next", context.arg = undefined), context.delegate = null, ContinueSentinel) : info : (context.method = "throw", context.arg = new TypeError("iterator result is not an object"), context.delegate = null, ContinueSentinel);
  }
  function pushTryEntry(locs) {
    var entry = {
      tryLoc: locs[0]
    };
    1 in locs && (entry.catchLoc = locs[1]), 2 in locs && (entry.finallyLoc = locs[2], entry.afterLoc = locs[3]), this.tryEntries.push(entry);
  }
  function resetTryEntry(entry) {
    var record = entry.completion || {};
    record.type = "normal", delete record.arg, entry.completion = record;
  }
  function Context(tryLocsList) {
    this.tryEntries = [{
      tryLoc: "root"
    }], tryLocsList.forEach(pushTryEntry, this), this.reset(!0);
  }
  function values(iterable) {
    if (iterable) {
      var iteratorMethod = iterable[iteratorSymbol];
      if (iteratorMethod) return iteratorMethod.call(iterable);
      if ("function" == typeof iterable.next) return iterable;
      if (!isNaN(iterable.length)) {
        var i = -1,
          next = function next() {
            for (; ++i < iterable.length;) if (hasOwn.call(iterable, i)) return next.value = iterable[i], next.done = !1, next;
            return next.value = undefined, next.done = !0, next;
          };
        return next.next = next;
      }
    }
    return {
      next: doneResult
    };
  }
  function doneResult() {
    return {
      value: undefined,
      done: !0
    };
  }
  return GeneratorFunction.prototype = GeneratorFunctionPrototype, defineProperty(Gp, "constructor", {
    value: GeneratorFunctionPrototype,
    configurable: !0
  }), defineProperty(GeneratorFunctionPrototype, "constructor", {
    value: GeneratorFunction,
    configurable: !0
  }), GeneratorFunction.displayName = define(GeneratorFunctionPrototype, toStringTagSymbol, "GeneratorFunction"), exports.isGeneratorFunction = function (genFun) {
    var ctor = "function" == typeof genFun && genFun.constructor;
    return !!ctor && (ctor === GeneratorFunction || "GeneratorFunction" === (ctor.displayName || ctor.name));
  }, exports.mark = function (genFun) {
    return Object.setPrototypeOf ? Object.setPrototypeOf(genFun, GeneratorFunctionPrototype) : (genFun.__proto__ = GeneratorFunctionPrototype, define(genFun, toStringTagSymbol, "GeneratorFunction")), genFun.prototype = Object.create(Gp), genFun;
  }, exports.awrap = function (arg) {
    return {
      __await: arg
    };
  }, defineIteratorMethods(AsyncIterator.prototype), define(AsyncIterator.prototype, asyncIteratorSymbol, function () {
    return this;
  }), exports.AsyncIterator = AsyncIterator, exports.async = function (innerFn, outerFn, self, tryLocsList, PromiseImpl) {
    void 0 === PromiseImpl && (PromiseImpl = Promise);
    var iter = new AsyncIterator(wrap(innerFn, outerFn, self, tryLocsList), PromiseImpl);
    return exports.isGeneratorFunction(outerFn) ? iter : iter.next().then(function (result) {
      return result.done ? result.value : iter.next();
    });
  }, defineIteratorMethods(Gp), define(Gp, toStringTagSymbol, "Generator"), define(Gp, iteratorSymbol, function () {
    return this;
  }), define(Gp, "toString", function () {
    return "[object Generator]";
  }), exports.keys = function (val) {
    var object = Object(val),
      keys = [];
    for (var key in object) keys.push(key);
    return keys.reverse(), function next() {
      for (; keys.length;) {
        var key = keys.pop();
        if (key in object) return next.value = key, next.done = !1, next;
      }
      return next.done = !0, next;
    };
  }, exports.values = values, Context.prototype = {
    constructor: Context,
    reset: function reset(skipTempReset) {
      if (this.prev = 0, this.next = 0, this.sent = this._sent = undefined, this.done = !1, this.delegate = null, this.method = "next", this.arg = undefined, this.tryEntries.forEach(resetTryEntry), !skipTempReset) for (var name in this) "t" === name.charAt(0) && hasOwn.call(this, name) && !isNaN(+name.slice(1)) && (this[name] = undefined);
    },
    stop: function stop() {
      this.done = !0;
      var rootRecord = this.tryEntries[0].completion;
      if ("throw" === rootRecord.type) throw rootRecord.arg;
      return this.rval;
    },
    dispatchException: function dispatchException(exception) {
      if (this.done) throw exception;
      var context = this;
      function handle(loc, caught) {
        return record.type = "throw", record.arg = exception, context.next = loc, caught && (context.method = "next", context.arg = undefined), !!caught;
      }
      for (var i = this.tryEntries.length - 1; i >= 0; --i) {
        var entry = this.tryEntries[i],
          record = entry.completion;
        if ("root" === entry.tryLoc) return handle("end");
        if (entry.tryLoc <= this.prev) {
          var hasCatch = hasOwn.call(entry, "catchLoc"),
            hasFinally = hasOwn.call(entry, "finallyLoc");
          if (hasCatch && hasFinally) {
            if (this.prev < entry.catchLoc) return handle(entry.catchLoc, !0);
            if (this.prev < entry.finallyLoc) return handle(entry.finallyLoc);
          } else if (hasCatch) {
            if (this.prev < entry.catchLoc) return handle(entry.catchLoc, !0);
          } else {
            if (!hasFinally) throw new Error("try statement without catch or finally");
            if (this.prev < entry.finallyLoc) return handle(entry.finallyLoc);
          }
        }
      }
    },
    abrupt: function abrupt(type, arg) {
      for (var i = this.tryEntries.length - 1; i >= 0; --i) {
        var entry = this.tryEntries[i];
        if (entry.tryLoc <= this.prev && hasOwn.call(entry, "finallyLoc") && this.prev < entry.finallyLoc) {
          var finallyEntry = entry;
          break;
        }
      }
      finallyEntry && ("break" === type || "continue" === type) && finallyEntry.tryLoc <= arg && arg <= finallyEntry.finallyLoc && (finallyEntry = null);
      var record = finallyEntry ? finallyEntry.completion : {};
      return record.type = type, record.arg = arg, finallyEntry ? (this.method = "next", this.next = finallyEntry.finallyLoc, ContinueSentinel) : this.complete(record);
    },
    complete: function complete(record, afterLoc) {
      if ("throw" === record.type) throw record.arg;
      return "break" === record.type || "continue" === record.type ? this.next = record.arg : "return" === record.type ? (this.rval = this.arg = record.arg, this.method = "return", this.next = "end") : "normal" === record.type && afterLoc && (this.next = afterLoc), ContinueSentinel;
    },
    finish: function finish(finallyLoc) {
      for (var i = this.tryEntries.length - 1; i >= 0; --i) {
        var entry = this.tryEntries[i];
        if (entry.finallyLoc === finallyLoc) return this.complete(entry.completion, entry.afterLoc), resetTryEntry(entry), ContinueSentinel;
      }
    },
    "catch": function _catch(tryLoc) {
      for (var i = this.tryEntries.length - 1; i >= 0; --i) {
        var entry = this.tryEntries[i];
        if (entry.tryLoc === tryLoc) {
          var record = entry.completion;
          if ("throw" === record.type) {
            var thrown = record.arg;
            resetTryEntry(entry);
          }
          return thrown;
        }
      }
      throw new Error("illegal catch attempt");
    },
    delegateYield: function delegateYield(iterable, resultName, nextLoc) {
      return this.delegate = {
        iterator: values(iterable),
        resultName: resultName,
        nextLoc: nextLoc
      }, "next" === this.method && (this.arg = undefined), ContinueSentinel;
    }
  }, exports;
}
module.exports = _regeneratorRuntime, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./typeof.js":32}],26:[function(require,module,exports){
function _setPrototypeOf(o, p) {
  module.exports = _setPrototypeOf = Object.setPrototypeOf ? Object.setPrototypeOf.bind() : function _setPrototypeOf(o, p) {
    o.__proto__ = p;
    return o;
  }, module.exports.__esModule = true, module.exports["default"] = module.exports;
  return _setPrototypeOf(o, p);
}
module.exports = _setPrototypeOf, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{}],27:[function(require,module,exports){
var arrayWithHoles = require("./arrayWithHoles.js");
var iterableToArrayLimit = require("./iterableToArrayLimit.js");
var unsupportedIterableToArray = require("./unsupportedIterableToArray.js");
var nonIterableRest = require("./nonIterableRest.js");
function _slicedToArray(arr, i) {
  return arrayWithHoles(arr) || iterableToArrayLimit(arr, i) || unsupportedIterableToArray(arr, i) || nonIterableRest();
}
module.exports = _slicedToArray, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./arrayWithHoles.js":3,"./iterableToArrayLimit.js":18,"./nonIterableRest.js":19,"./unsupportedIterableToArray.js":33}],28:[function(require,module,exports){
var arrayWithHoles = require("./arrayWithHoles.js");
var iterableToArray = require("./iterableToArray.js");
var unsupportedIterableToArray = require("./unsupportedIterableToArray.js");
var nonIterableRest = require("./nonIterableRest.js");
function _toArray(arr) {
  return arrayWithHoles(arr) || iterableToArray(arr) || unsupportedIterableToArray(arr) || nonIterableRest();
}
module.exports = _toArray, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./arrayWithHoles.js":3,"./iterableToArray.js":17,"./nonIterableRest.js":19,"./unsupportedIterableToArray.js":33}],29:[function(require,module,exports){
var arrayWithoutHoles = require("./arrayWithoutHoles.js");
var iterableToArray = require("./iterableToArray.js");
var unsupportedIterableToArray = require("./unsupportedIterableToArray.js");
var nonIterableSpread = require("./nonIterableSpread.js");
function _toConsumableArray(arr) {
  return arrayWithoutHoles(arr) || iterableToArray(arr) || unsupportedIterableToArray(arr) || nonIterableSpread();
}
module.exports = _toConsumableArray, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./arrayWithoutHoles.js":4,"./iterableToArray.js":17,"./nonIterableSpread.js":20,"./unsupportedIterableToArray.js":33}],30:[function(require,module,exports){
var _typeof = require("./typeof.js")["default"];
function _toPrimitive(input, hint) {
  if (_typeof(input) !== "object" || input === null) return input;
  var prim = input[Symbol.toPrimitive];
  if (prim !== undefined) {
    var res = prim.call(input, hint || "default");
    if (_typeof(res) !== "object") return res;
    throw new TypeError("@@toPrimitive must return a primitive value.");
  }
  return (hint === "string" ? String : Number)(input);
}
module.exports = _toPrimitive, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./typeof.js":32}],31:[function(require,module,exports){
var _typeof = require("./typeof.js")["default"];
var toPrimitive = require("./toPrimitive.js");
function _toPropertyKey(arg) {
  var key = toPrimitive(arg, "string");
  return _typeof(key) === "symbol" ? key : String(key);
}
module.exports = _toPropertyKey, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./toPrimitive.js":30,"./typeof.js":32}],32:[function(require,module,exports){
function _typeof(obj) {
  "@babel/helpers - typeof";

  return (module.exports = _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (obj) {
    return typeof obj;
  } : function (obj) {
    return obj && "function" == typeof Symbol && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj;
  }, module.exports.__esModule = true, module.exports["default"] = module.exports), _typeof(obj);
}
module.exports = _typeof, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{}],33:[function(require,module,exports){
var arrayLikeToArray = require("./arrayLikeToArray.js");
function _unsupportedIterableToArray(o, minLen) {
  if (!o) return;
  if (typeof o === "string") return arrayLikeToArray(o, minLen);
  var n = Object.prototype.toString.call(o).slice(8, -1);
  if (n === "Object" && o.constructor) n = o.constructor.name;
  if (n === "Map" || n === "Set") return Array.from(o);
  if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return arrayLikeToArray(o, minLen);
}
module.exports = _unsupportedIterableToArray, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./arrayLikeToArray.js":2}],34:[function(require,module,exports){
var getPrototypeOf = require("./getPrototypeOf.js");
var setPrototypeOf = require("./setPrototypeOf.js");
var isNativeFunction = require("./isNativeFunction.js");
var construct = require("./construct.js");
function _wrapNativeSuper(Class) {
  var _cache = typeof Map === "function" ? new Map() : undefined;
  module.exports = _wrapNativeSuper = function _wrapNativeSuper(Class) {
    if (Class === null || !isNativeFunction(Class)) return Class;
    if (typeof Class !== "function") {
      throw new TypeError("Super expression must either be null or a function");
    }
    if (typeof _cache !== "undefined") {
      if (_cache.has(Class)) return _cache.get(Class);
      _cache.set(Class, Wrapper);
    }
    function Wrapper() {
      return construct(Class, arguments, getPrototypeOf(this).constructor);
    }
    Wrapper.prototype = Object.create(Class.prototype, {
      constructor: {
        value: Wrapper,
        enumerable: false,
        writable: true,
        configurable: true
      }
    });
    return setPrototypeOf(Wrapper, Class);
  }, module.exports.__esModule = true, module.exports["default"] = module.exports;
  return _wrapNativeSuper(Class);
}
module.exports = _wrapNativeSuper, module.exports.__esModule = true, module.exports["default"] = module.exports;
},{"./construct.js":8,"./getPrototypeOf.js":13,"./isNativeFunction.js":15,"./setPrototypeOf.js":26}],35:[function(require,module,exports){
// TODO(Babel 8): Remove this file.

var runtime = require("../helpers/regeneratorRuntime")();
module.exports = runtime;

// Copied from https://github.com/facebook/regenerator/blob/main/packages/runtime/runtime.js#L736=
try {
  regeneratorRuntime = runtime;
} catch (accidentalStrictMode) {
  if (typeof globalThis === "object") {
    globalThis.regeneratorRuntime = runtime;
  } else {
    Function("r", "regeneratorRuntime = r")(runtime);
  }
}

},{"../helpers/regeneratorRuntime":25}],36:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var _toArray = require('@babel/runtime/helpers/toArray');
var _typeof = require('@babel/runtime/helpers/typeof');
var _asyncToGenerator = require('@babel/runtime/helpers/asyncToGenerator');
var _defineProperty = require('@babel/runtime/helpers/defineProperty');
var _objectSpread = require('@babel/runtime/helpers/objectSpread2');
var _regeneratorRuntime = require('@babel/runtime/regenerator');
var utilActor = require('@onflow/util-actor');

function _interopDefaultLegacy (e) { return e && typeof e === 'object' && 'default' in e ? e : { 'default': e }; }

var _toArray__default = /*#__PURE__*/_interopDefaultLegacy(_toArray);
var _typeof__default = /*#__PURE__*/_interopDefaultLegacy(_typeof);
var _asyncToGenerator__default = /*#__PURE__*/_interopDefaultLegacy(_asyncToGenerator);
var _defineProperty__default = /*#__PURE__*/_interopDefaultLegacy(_defineProperty);
var _objectSpread__default = /*#__PURE__*/_interopDefaultLegacy(_objectSpread);
var _regeneratorRuntime__default = /*#__PURE__*/_interopDefaultLegacy(_regeneratorRuntime);

var _HANDLERS;
var NAME = "config";
var PUT = "PUT_CONFIG";
var GET = "GET_CONFIG";
var GET_ALL = "GET_ALL_CONFIG";
var UPDATE = "UPDATE_CONFIG";
var DELETE = "DELETE_CONFIG";
var CLEAR = "CLEAR_CONFIG";
var WHERE = "WHERE_CONFIG";
var UPDATED = "CONFIG/UPDATED";

var identity = function identity(v) {
  return v;
};

var HANDLERS = (_HANDLERS = {}, _defineProperty__default["default"](_HANDLERS, PUT, function (ctx, _letter, _ref) {
  var key = _ref.key,
      value = _ref.value;
  if (key == null) throw new Error("Missing 'key' for config/put.");
  ctx.put(key, value);
  ctx.broadcast(UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, GET, function (ctx, letter, _ref2) {
  var key = _ref2.key,
      fallback = _ref2.fallback;
  if (key == null) throw new Error("Missing 'key' for config/get");
  letter.reply(ctx.get(key, fallback));
}), _defineProperty__default["default"](_HANDLERS, GET_ALL, function (ctx, letter) {
  letter.reply(_objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, UPDATE, function (ctx, letter, _ref3) {
  var key = _ref3.key,
      fn = _ref3.fn;
  if (key == null) throw new Error("Missing 'key' for config/update");
  ctx.update(key, fn || identity);
  ctx.broadcast(UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, DELETE, function (ctx, letter, _ref4) {
  var key = _ref4.key;
  if (key == null) throw new Error("Missing 'key' for config/delete");
  ctx["delete"](key);
  ctx.broadcast(UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, CLEAR, function (ctx, letter) {
  var keys = Object.keys(ctx.all());

  for (var _i = 0, _keys = keys; _i < _keys.length; _i++) {
    var key = _keys[_i];
    ctx["delete"](key);
  }

  ctx.broadcast(UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, WHERE, function (ctx, letter, _ref5) {
  var pattern = _ref5.pattern;
  if (pattern == null) throw new Error("Missing 'pattern' for config/where");
  letter.reply(ctx.where(pattern));
}), _defineProperty__default["default"](_HANDLERS, utilActor.SUBSCRIBE, function (ctx, letter) {
  ctx.subscribe(letter.from);
  ctx.send(letter.from, UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, utilActor.UNSUBSCRIBE, function (ctx, letter) {
  ctx.unsubscribe(letter.from);
}), _HANDLERS);
utilActor.spawn(HANDLERS, NAME);

function put(key, value) {
  utilActor.send(NAME, PUT, {
    key: key,
    value: value
  });
  return config();
}

function get(key, fallback) {
  return utilActor.send(NAME, GET, {
    key: key,
    fallback: fallback
  }, {
    expectReply: true,
    timeout: 10
  });
}

function first() {
  return _first.apply(this, arguments);
}

function _first() {
  _first = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2() {
    var wants,
        fallback,
        _wants,
        head,
        rest,
        ret,
        _args2 = arguments;

    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            wants = _args2.length > 0 && _args2[0] !== undefined ? _args2[0] : [];
            fallback = _args2.length > 1 ? _args2[1] : undefined;

            if (wants.length) {
              _context2.next = 4;
              break;
            }

            return _context2.abrupt("return", fallback);

          case 4:
            _wants = _toArray__default["default"](wants), head = _wants[0], rest = _wants.slice(1);
            _context2.next = 7;
            return get(head);

          case 7:
            ret = _context2.sent;

            if (!(ret == null)) {
              _context2.next = 10;
              break;
            }

            return _context2.abrupt("return", first(rest, fallback));

          case 10:
            return _context2.abrupt("return", ret);

          case 11:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _first.apply(this, arguments);
}

function all() {
  return utilActor.send(NAME, GET_ALL, null, {
    expectReply: true,
    timeout: 10
  });
}

function update(key) {
  var fn = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : identity;
  utilActor.send(NAME, UPDATE, {
    key: key,
    fn: fn
  });
  return config();
}

function _delete(key) {
  utilActor.send(NAME, DELETE, {
    key: key
  });
  return config();
}

function where(pattern) {
  return utilActor.send(NAME, WHERE, {
    pattern: pattern
  }, {
    expectReply: true,
    timeout: 10
  });
}

function subscribe(callback) {
  return utilActor.subscriber(NAME, function () {
    return utilActor.spawn(HANDLERS, NAME);
  }, callback);
}

function clearConfig() {
  return utilActor.send(NAME, CLEAR);
}

function resetConfig(oldConfig) {
  return clearConfig().then(config(oldConfig));
}

function config(values) {
  if (values != null && _typeof__default["default"](values) === "object") {
    Object.keys(values).map(function (d) {
      return put(d, values[d]);
    });
  }

  return {
    put: put,
    get: get,
    all: all,
    first: first,
    update: update,
    "delete": _delete,
    where: where,
    subscribe: subscribe,
    overload: overload
  };
}

config.put = put;
config.get = get;
config.all = all;
config.first = first;
config.update = update;
config["delete"] = _delete;
config.where = where;
config.subscribe = subscribe;
config.overload = overload;

var noop = function noop(v) {
  return v;
};

function overload() {
  var opts = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
  var callback = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : noop;
  return new Promise( /*#__PURE__*/function () {
    var _ref6 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(resolve, reject) {
      var oldConfig, result;
      return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
        while (1) {
          switch (_context.prev = _context.next) {
            case 0:
              _context.next = 2;
              return all();

            case 2:
              oldConfig = _context.sent;
              _context.prev = 3;
              config(opts);
              _context.t0 = callback;
              _context.next = 8;
              return all();

            case 8:
              _context.t1 = _context.sent;
              _context.next = 11;
              return (0, _context.t0)(_context.t1);

            case 11:
              result = _context.sent;
              _context.next = 14;
              return resetConfig(oldConfig);

            case 14:
              resolve(result);
              _context.next = 22;
              break;

            case 17:
              _context.prev = 17;
              _context.t2 = _context["catch"](3);
              _context.next = 21;
              return resetConfig(oldConfig);

            case 21:
              reject(_context.t2);

            case 22:
            case "end":
              return _context.stop();
          }
        }
      }, _callee, null, [[3, 17]]);
    }));

    return function (_x, _x2) {
      return _ref6.apply(this, arguments);
    };
  }());
}

exports.clearConfig = clearConfig;
exports.config = config;


},{"@babel/runtime/helpers/asyncToGenerator":6,"@babel/runtime/helpers/defineProperty":12,"@babel/runtime/helpers/objectSpread2":21,"@babel/runtime/helpers/toArray":28,"@babel/runtime/helpers/typeof":32,"@babel/runtime/regenerator":35,"@onflow/util-actor":42}],37:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var _slicedToArray = require('@babel/runtime/helpers/slicedToArray');
var _asyncToGenerator = require('@babel/runtime/helpers/asyncToGenerator');
var _regeneratorRuntime = require('@babel/runtime/regenerator');
var config = require('@onflow/config');
var utilInvariant = require('@onflow/util-invariant');
var sdk = require('@onflow/sdk');
var _typeof = require('@babel/runtime/helpers/typeof');
var t$1 = require('@onflow/types');
var fetchTransport = require('node-fetch');
var utilAddress = require('@onflow/util-address');
var _createForOfIteratorHelper = require('@babel/runtime/helpers/createForOfIteratorHelper');
var _defineProperty = require('@babel/runtime/helpers/defineProperty');
var _objectSpread = require('@babel/runtime/helpers/objectSpread2');
var utilActor = require('@onflow/util-actor');
var rlp = require('@onflow/rlp');
var _toConsumableArray = require('@babel/runtime/helpers/toConsumableArray');
var utilLogger = require('@onflow/util-logger');
var utilUid = require('@onflow/util-uid');
var require$$0 = require('buffer');
var utilTemplate = require('@onflow/util-template');

function _interopDefaultLegacy (e) { return e && typeof e === 'object' && 'default' in e ? e : { 'default': e }; }

function _interopNamespace(e) {
  if (e && e.__esModule) return e;
  var n = Object.create(null);
  if (e) {
    Object.keys(e).forEach(function (k) {
      if (k !== 'default') {
        var d = Object.getOwnPropertyDescriptor(e, k);
        Object.defineProperty(n, k, d.get ? d : {
          enumerable: true,
          get: function () { return e[k]; }
        });
      }
    });
  }
  n["default"] = e;
  return Object.freeze(n);
}

var _slicedToArray__default = /*#__PURE__*/_interopDefaultLegacy(_slicedToArray);
var _asyncToGenerator__default = /*#__PURE__*/_interopDefaultLegacy(_asyncToGenerator);
var _regeneratorRuntime__default = /*#__PURE__*/_interopDefaultLegacy(_regeneratorRuntime);
var sdk__namespace = /*#__PURE__*/_interopNamespace(sdk);
var _typeof__default = /*#__PURE__*/_interopDefaultLegacy(_typeof);
var t__namespace = /*#__PURE__*/_interopNamespace(t$1);
var fetchTransport__default = /*#__PURE__*/_interopDefaultLegacy(fetchTransport);
var _createForOfIteratorHelper__default = /*#__PURE__*/_interopDefaultLegacy(_createForOfIteratorHelper);
var _defineProperty__default = /*#__PURE__*/_interopDefaultLegacy(_defineProperty);
var _objectSpread__default = /*#__PURE__*/_interopDefaultLegacy(_objectSpread);
var rlp__namespace = /*#__PURE__*/_interopNamespace(rlp);
var _toConsumableArray__default = /*#__PURE__*/_interopDefaultLegacy(_toConsumableArray);
var require$$0__default = /*#__PURE__*/_interopDefaultLegacy(require$$0);

var isServerSide = function isServerSide() {
  return typeof window === "undefined";
};

var SESSION_STORAGE = {
  can: !isServerSide(),
  get: function () {
    var _get = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(key) {
      return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
        while (1) {
          switch (_context.prev = _context.next) {
            case 0:
              return _context.abrupt("return", JSON.parse(sessionStorage.getItem(key)));

            case 1:
            case "end":
              return _context.stop();
          }
        }
      }, _callee);
    }));

    function get(_x) {
      return _get.apply(this, arguments);
    }

    return get;
  }(),
  put: function () {
    var _put = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(key, value) {
      return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
        while (1) {
          switch (_context2.prev = _context2.next) {
            case 0:
              return _context2.abrupt("return", sessionStorage.setItem(key, JSON.stringify(value)));

            case 1:
            case "end":
              return _context2.stop();
          }
        }
      }, _callee2);
    }));

    function put(_x2, _x3) {
      return _put.apply(this, arguments);
    }

    return put;
  }()
};
config.config({
  "discovery.wallet.method.default": "IFRAME/RPC",
  "fcl.storage.default": SESSION_STORAGE
});
function configLens(_x4) {
  return _configLens.apply(this, arguments);
}

function _configLens() {
  _configLens = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(regex) {
    return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
      while (1) {
        switch (_context3.prev = _context3.next) {
          case 0:
            _context3.t0 = Object;
            _context3.t1 = Object;
            _context3.next = 4;
            return config.config().where(regex);

          case 4:
            _context3.t2 = _context3.sent;
            _context3.t3 = _context3.t1.entries.call(_context3.t1, _context3.t2).map(function (_ref) {
              var _ref2 = _slicedToArray__default["default"](_ref, 2),
                  key = _ref2[0],
                  value = _ref2[1];

              return [key.replace(regex, ""), value];
            });
            return _context3.abrupt("return", _context3.t0.fromEntries.call(_context3.t0, _context3.t3));

          case 7:
          case "end":
            return _context3.stop();
        }
      }
    }, _callee3);
  }));
  return _configLens.apply(this, arguments);
}

var VERSION = "1.3.2" ;

var is = function is(type) {
  return function (d) {
    return _typeof__default["default"](d) === type;
  };
};

var isRequired = function isRequired(d) {
  return d != null;
};
var isObject = is("object");
var isString = is("string");
var isFunc = is("function");
var isNumber = is("number");

function normalizeArgs(ax) {
  if (isFunc(ax)) return ax(sdk__namespace.arg, t__namespace);
  return [];
}

function httpDocumentResolver(_x) {
  return _httpDocumentResolver.apply(this, arguments);
}

function _httpDocumentResolver() {
  _httpDocumentResolver = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(_ref) {
    var url, res, document;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            url = _ref.url;
            utilInvariant.invariant(typeof url !== "undefined", "retrieve({ url }) -- url must be defined");
            _context.prev = 2;
            _context.next = 5;
            const fetchT = fetchTransport__default["default"];
            return fetchT(url);

          case 5:
            res = _context.sent;
            _context.next = 11;
            break;

          case 8:
            _context.prev = 8;
            _context.t0 = _context["catch"](2);
            throw new Error("httpDocumentResolver Error: Failed to retrieve document.");

          case 11:
            if (!res.ok) {
              _context.next = 17;
              break;
            }

            _context.next = 14;
            return res.json();

          case 14:
            _context.t1 = _context.sent;
            _context.next = 18;
            break;

          case 17:
            _context.t1 = null;

          case 18:
            document = _context.t1;
            return _context.abrupt("return", document);

          case 20:
          case "end":
            return _context.stop();
        }
      }
    }, _callee, null, [[2, 8]]);
  }));
  return _httpDocumentResolver.apply(this, arguments);
}

var DOCUMENT_RESOLVERS = new Map([["http", httpDocumentResolver], ["https", httpDocumentResolver]]);
function retrieve(_x2) {
  return _retrieve.apply(this, arguments);
}

function _retrieve() {
  _retrieve = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(_ref2) {
    var url, documentResolversFromConfig, urlParts, protocol, resolver, document;
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            url = _ref2.url;
            utilInvariant.invariant(typeof url !== "undefined", "retrieve({ url }) -- url must be defined");
            utilInvariant.invariant(typeof url === "string", "retrieve({ url }) -- url must be a string");
            _context2.next = 5;
            return config.config().where(/^document\.resolver\./);

          case 5:
            documentResolversFromConfig = _context2.sent;
            Object.keys(documentResolversFromConfig).map(function (key) {
              var resolverFromConfig = documentResolversFromConfig[key];
              var resolverProtocol = key.replace(/^document\.resolver\./, "");
              DOCUMENT_RESOLVERS.set(resolverProtocol, resolverFromConfig);
            });
            urlParts = /^(.*):\/\/([A-Za-z0-9\-\.]+)(:[0-9]+)?(.*)$/.exec(url);
            utilInvariant.invariant(urlParts, "Failed to parse URL");
            protocol = urlParts[1];
            utilInvariant.invariant(urlParts, "Failed to parse URL protocol");
            resolver = DOCUMENT_RESOLVERS.get(protocol);
            utilInvariant.invariant(resolver, "No resolver found for protcol=".concat(protocol));
            _context2.next = 15;
            return resolver({
              url: url
            });

          case 15:
            document = _context2.sent;
            return _context2.abrupt("return", document);

          case 17:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _retrieve.apply(this, arguments);
}

function normalizeInteractionTemplate(template) {
  if (template == null) return null;

  switch (template["f_version"]) {
    case "1.0.0":
      return template;

    default:
      throw new Error("normalizeInteractionTemplate Error: Invalid InteractionTemplate");
  }
}

function deriveCadenceByNetwork(_ref) {
  var _template, _template$data;

  var network = _ref.network,
      template = _ref.template;
  sdk.invariant(network != undefined, "deriveCadenceByNetwork({ network }) -- network must be defined");
  sdk.invariant(typeof network === "string", "deriveCadenceByNetwork({ network }) -- network must be a string");
  sdk.invariant(template != undefined, "generateDependencyPin({ template }) -- template must be defined");
  sdk.invariant(_typeof__default["default"](template) === "object", "generateDependencyPin({ template }) -- template must be an object");
  sdk.invariant(template.f_type === "InteractionTemplate", "generateDependencyPin({ template }) -- template must be an InteractionTemplate");
  template = normalizeInteractionTemplate(template);

  switch (template.f_version) {
    case "1.0.0":
      var networkDependencies = Object.keys((_template = template) === null || _template === void 0 ? void 0 : (_template$data = _template.data) === null || _template$data === void 0 ? void 0 : _template$data.dependencies).map(function (dependencyPlaceholder) {
        var _template2, _template2$data, _template2$data$depen;

        var dependencyNetworkContracts = Object.values((_template2 = template) === null || _template2 === void 0 ? void 0 : (_template2$data = _template2.data) === null || _template2$data === void 0 ? void 0 : (_template2$data$depen = _template2$data.dependencies) === null || _template2$data$depen === void 0 ? void 0 : _template2$data$depen[dependencyPlaceholder]);
        sdk.invariant(dependencyNetworkContracts, "deriveCadenceByNetwork -- Could not find contracts for dependency placeholder: ".concat(dependencyPlaceholder));
        sdk.invariant(dependencyNetworkContracts.length === 0, "deriveCadenceByNetwork -- Could not find contracts for dependency placeholder: ".concat(dependencyPlaceholder));
        var dependencyContract = dependencyNetworkContracts[0];
        var dependencyContractForNetwork = dependencyContract === null || dependencyContract === void 0 ? void 0 : dependencyContract[network];
        sdk.invariant(dependencyContractForNetwork, "deriveCadenceByNetwork -- Could not find ".concat(network, " network information for dependency: ").concat(dependencyPlaceholder));
        return [dependencyPlaceholder, dependencyContractForNetwork.address];
      });
      return networkDependencies.reduce(function (cadence, _ref2) {
        var _ref3 = _slicedToArray__default["default"](_ref2, 2),
            placeholder = _ref3[0],
            address = _ref3[1];

        var regex = new RegExp("(\\b" + placeholder + "\\b)", "g");
        return cadence.replace(regex, address);
      }, template.data.cadence);

    default:
      throw new Error("deriveCadenceByNetwork Error: Unsupported template version");
  }
}

function deriveDependencies(_x) {
  return _deriveDependencies.apply(this, arguments);
}

function _deriveDependencies() {
  _deriveDependencies = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(_ref) {
    var _template$data;

    var template, network, derivedDependencies, dependencyPlaceholderKeys, _i, _dependencyPlaceholde, _template$data2, dependencyPlaceholderKey, dependencyPlaceholder, dependencyPlaceholderContractsKeys, dependencyPlaceholderContract, dependency;

    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            template = _ref.template;
            _context.next = 3;
            return config.config.get("flow.network");

          case 3:
            network = _context.sent;
            utilInvariant.invariant(network, "FCL configureDependencies Error: Missing configuration value for 'flow.network'");
            derivedDependencies = {};
            _context.t0 = template["f_version"];
            _context.next = _context.t0 === "1.0.0" ? 9 : 12;
            break;

          case 9:
            dependencyPlaceholderKeys = Object.keys(template === null || template === void 0 ? void 0 : (_template$data = template.data) === null || _template$data === void 0 ? void 0 : _template$data.dependencies);

            for (_i = 0, _dependencyPlaceholde = dependencyPlaceholderKeys; _i < _dependencyPlaceholde.length; _i++) {
              dependencyPlaceholderKey = _dependencyPlaceholde[_i];
              dependencyPlaceholder = template === null || template === void 0 ? void 0 : (_template$data2 = template.data) === null || _template$data2 === void 0 ? void 0 : _template$data2.dependencies[dependencyPlaceholderKey];
              dependencyPlaceholderContractsKeys = Object.keys(dependencyPlaceholder);
              utilInvariant.invariant(dependencyPlaceholderContractsKeys.length > 0, "FCL configureDependencies Error: No contracts found in template for placeholder=".concat(dependencyPlaceholderKey));
              dependencyPlaceholderContract = dependencyPlaceholder[dependencyPlaceholderContractsKeys[0]];
              dependency = dependencyPlaceholderContract[network];
              utilInvariant.invariant(dependency, "FCL configureDependencies Error: No dependency information for placeholder=".concat(dependencyPlaceholderKey, " contract=").concat(dependencyPlaceholderContractsKeys[0], " network=").concat(network));
              utilInvariant.invariant(dependency === null || dependency === void 0 ? void 0 : dependency.address, "FCL configureDependencies Error: No address information for placeholder=".concat(dependencyPlaceholderKey, " contract=").concat(dependencyPlaceholderContractsKeys[0], " network=").concat(network));
              derivedDependencies[dependencyPlaceholderKey] = utilAddress.withPrefix(dependency === null || dependency === void 0 ? void 0 : dependency.address);
            }

            return _context.abrupt("return", derivedDependencies);

          case 12:
            throw new Error("FCL configureDependencies Error: Unsupported template version");

          case 13:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _deriveDependencies.apply(this, arguments);
}

function prepTemplateOpts(_x) {
  return _prepTemplateOpts.apply(this, arguments);
}

function _prepTemplateOpts() {
  _prepTemplateOpts = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(opts) {
    var dependencies, cadence;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            if (!isString(opts === null || opts === void 0 ? void 0 : opts.template)) {
              _context.next = 4;
              break;
            }

            _context.next = 3;
            return retrieve({
              url: opts === null || opts === void 0 ? void 0 : opts.template
            });

          case 3:
            opts.template = _context.sent;

          case 4:
            dependencies = {};

            if (!(opts !== null && opts !== void 0 && opts.template)) {
              _context.next = 10;
              break;
            }

            opts.template = normalizeInteractionTemplate(opts === null || opts === void 0 ? void 0 : opts.template);
            _context.next = 9;
            return deriveDependencies({
              template: opts.template
            });

          case 9:
            dependencies = _context.sent;

          case 10:
            _context.t0 = opts.cadence;

            if (_context.t0) {
              _context.next = 19;
              break;
            }

            _context.t1 = deriveCadenceByNetwork;
            _context.t2 = opts.template;
            _context.next = 16;
            return sdk__namespace.config().get("flow.network");

          case 16:
            _context.t3 = _context.sent;
            _context.t4 = {
              template: _context.t2,
              network: _context.t3
            };
            _context.t0 = (0, _context.t1)(_context.t4);

          case 19:
            cadence = _context.t0;
            opts.cadence = cadence;
            opts.dependencies = dependencies;
            return _context.abrupt("return", opts);

          case 23:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _prepTemplateOpts.apply(this, arguments);
}

function pre(_x, _x2) {
  return _pre.apply(this, arguments);
}

function _pre() {
  _pre = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(type, opts) {
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            // prettier-ignore
            utilInvariant.invariant(isRequired(opts), "".concat(type, "(opts) -- opts is required")); // prettier-ignore

            utilInvariant.invariant(isObject(opts), "".concat(type, "(opts) -- opts must be an object")); // prettier-ignore

            utilInvariant.invariant(!(opts.cadence && opts.template), "".concat(type, "({ template, cadence }) -- cannot pass both cadence and template")); // prettier-ignore

            utilInvariant.invariant(isRequired(opts.cadence || (opts === null || opts === void 0 ? void 0 : opts.template)), "".concat(type, "({ cadence }) -- cadence is required")); // // prettier-ignore

            utilInvariant.invariant(isString(opts.cadence) || (opts === null || opts === void 0 ? void 0 : opts.template), "".concat(type, "({ cadence }) -- cadence must be a string")); // prettier-ignore

            _context.t0 = utilInvariant.invariant;
            _context.t1 = opts.cadence;

            if (_context.t1) {
              _context.next = 11;
              break;
            }

            _context.next = 10;
            return sdk__namespace.config().get("flow.network");

          case 10:
            _context.t1 = _context.sent;

          case 11:
            _context.t2 = _context.t1;
            _context.t3 = "".concat(type, "(opts) -- Required value for \"flow.network\" not defined in config. See: ", "https://github.com/onflow/flow-js-sdk/blob/master/packages/fcl/src/exec/query.md#configuration");
            (0, _context.t0)(_context.t2, _context.t3);
            _context.t4 = utilInvariant.invariant;
            _context.next = 17;
            return sdk__namespace.config().get("accessNode.api");

          case 17:
            _context.t5 = _context.sent;
            _context.t6 = "".concat(type, "(opts) -- Required value for \"accessNode.api\" not defined in config. See: ", "https://github.com/onflow/flow-js-sdk/blob/master/packages/fcl/src/exec/query.md#configuration");
            (0, _context.t4)(_context.t5, _context.t6);

          case 20:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _pre.apply(this, arguments);
}

function preMutate(_x3) {
  return _preMutate.apply(this, arguments);
}

function _preMutate() {
  _preMutate = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(opts) {
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            return _context2.abrupt("return", pre("mutate", opts));

          case 1:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _preMutate.apply(this, arguments);
}

function preQuery(_x4) {
  return _preQuery.apply(this, arguments);
}

function _preQuery() {
  _preQuery = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(opts) {
    return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
      while (1) {
        switch (_context3.prev = _context3.next) {
          case 0:
            return _context3.abrupt("return", pre("query", opts));

          case 1:
          case "end":
            return _context3.stop();
        }
      }
    }, _callee3);
  }));
  return _preQuery.apply(this, arguments);
}

/** Query the Flow Blockchain
 *
 *  @arg {Object} opts         - Query Options and configuration
 *  @arg {string} opts.cadence - Cadence Script used to query Flow
 *  @arg {ArgsFn} opts.args    - Arguments passed to cadence script
 *  @arg {Object} opts.template - Interaction Template for a script
 *  @arg {number} opts.limit   - Compute Limit for Query
 *  @returns {Promise<Response>}
 *
 *  Where:
 *    @callback ArgsFn
 *    @arg {ArgFn}  arg - Argument function to define a single argument
 *    @arg {Object} t   - Cadence Types object used to define the type
 *    @returns {args[]}
 *
 *    @callback ArgFn
 *    @arg {Any}  value - the value of the argument
 *    @arg {Type} type  - the cadence type of the value
 *    @returns {arg}
 *
 *  Example:
 *    const cadence = `
 *      cadence: `
 *        pub fun main(a: Int, b: Int, c: Address): Int {
 *          log(c)
 *          return a + b
 *        }
 *    `.trim()
 *
 *    const args = (arg, t) => [
 *      arg(5, t.Int),
 *      arg(7, t.Int),
 *      arg("0xb2db43ad6bc345fec9", t.Address),
 *    ]
 *
 *    await query({ cadence, args })
 */

function query() {
  return _query.apply(this, arguments);
}

function _query() {
  _query = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2() {
    var opts,
        _args2 = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            opts = _args2.length > 0 && _args2[0] !== undefined ? _args2[0] : {};
            _context2.next = 3;
            return preQuery(opts);

          case 3:
            _context2.next = 5;
            return prepTemplateOpts(opts);

          case 5:
            opts = _context2.sent;
            return _context2.abrupt("return", sdk__namespace.config().overload(opts.dependencies || {}, /*#__PURE__*/_asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee() {
              return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
                while (1) {
                  switch (_context.prev = _context.next) {
                    case 0:
                      return _context.abrupt("return", // prettier-ignore
                      sdk__namespace.send([sdk__namespace.script(opts.cadence), sdk__namespace.args(normalizeArgs(opts.args || [])), opts.limit && typeof opts.limit === "number" && sdk__namespace.limit(opts.limit)]).then(sdk__namespace.decode));

                    case 1:
                    case "end":
                      return _context.stop();
                  }
                }
              }, _callee);
            }))));

          case 7:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _query.apply(this, arguments);
}

function fetchServices(_x, _x2) {
  return _fetchServices.apply(this, arguments);
}

function _fetchServices() {
  _fetchServices = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(servicesURL, code) {
    var url, resp, services, _iterator, _step, service;

    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            if (!(servicesURL == null || code == null)) {
              _context.next = 2;
              break;
            }

            return _context.abrupt("return", []);

          case 2:
            url = new URL(servicesURL);
            url.searchParams.append("code", code);
            _context.next = 6;
            return fetch(url, {
              method: "GET",
              headers: {
                "Content-Type": "application/json"
              }
            }).then(function (d) {
              return d.json();
            });

          case 6:
            resp = _context.sent;

            if (!Array.isArray(resp)) {
              _context.next = 9;
              break;
            }

            return _context.abrupt("return", resp);

          case 9:
            // Backwards compatibility for First-Gen Wallet Providers
            services = []; // Convert authorizations into authz services

            if (Array.isArray(resp.authorizations)) {
              _iterator = _createForOfIteratorHelper__default["default"](resp.authorizations);

              try {
                for (_iterator.s(); !(_step = _iterator.n()).done;) {
                  service = _step.value;
                  services.push(_objectSpread__default["default"]({
                    type: "authz",
                    keyId: resp.keyId
                  }, service));
                }
              } catch (err) {
                _iterator.e(err);
              } finally {
                _iterator.f();
              }
            } // Convert Provider info into an authn service


            if (resp.provider != null) {
              services.push(_objectSpread__default["default"]({
                type: "authn",
                id: "wallet-provider#authn"
              }, resp.provider));
            }

            return _context.abrupt("return", services);

          case 13:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _fetchServices.apply(this, arguments);
}

function mergeServices() {
  var sx1 = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : [];
  var sx2 = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : [];
  // TODO: Make this smarter
  return [].concat(_toConsumableArray__default["default"](sx1), _toConsumableArray__default["default"](sx2));
}

var SERVICE_PRAGMA = {
  f_type: "Service",
  f_vsn: "1.0.0"
};
var IDENTITY_PRAGMA = {
  f_type: "Identity",
  f_vsn: "1.0.0"
};
var USER_PRAGMA = {
  f_type: "USER",
  f_vsn: "1.0.0"
};
var POLLING_RESPONSE_PRAGMA = {
  f_type: "PollingResponse",
  f_vsn: "1.0.0"
};
var COMPOSITE_SIGNATURE_PRAGMA = {
  f_type: "CompositeSignature",
  f_vsn: "1.0.0"
};

//   "f_type": "Service",
//   "f_vsn": "1.0.0",
//   "type": "authn",
//   "uid": "uniqueDedupeKey",
//   "endpoint": "https://rawr",
//   "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", // wallets internal id for the user
//   "identity": {
//     "address": "0x____"
//   },
//   "provider": {
//     "address": "0x____",
//     "name": "Best Wallet",
//     "description": "The Best Wallet"
//     "icon": "https://",
//   }
// }

function normalizeAuthn(service) {
  if (service == null) return null;

  switch (service["f_vsn"]) {
    case "1.0.0":
      return service;

    default:
      return _objectSpread__default["default"](_objectSpread__default["default"]({}, SERVICE_PRAGMA), {}, {
        type: service.type,
        uid: service.id,
        endpoint: service.authn,
        id: service.pid,
        provider: {
          address: utilAddress.withPrefix(service.addr),
          name: service.name,
          icon: service.icon
        }
      });
  }
}

//   "f_type": "service",
//   "f_vsn": "1.0.0",
//   "type": "authz",
//   "uid": "uniqueDedupeKey",
//   "endpoint": "https://rawr",
//   "method": "HTTP/POST", // HTTP/POST | IFRAME/RPC | HTTP/RPC
//   "identity": {
//      "address": "0x______",
//      "keyId": 0,
//   },
//   "data": {}, // included in body of authz request
//   "params": {}, // included as query params on endpoint url
// }

function normalizeAuthz(service) {
  if (service == null) return null;

  switch (service["f_vsn"]) {
    case "1.0.0":
      return service;

    default:
      return _objectSpread__default["default"](_objectSpread__default["default"]({}, SERVICE_PRAGMA), {}, {
        type: service.type,
        uid: service.id,
        endpoint: service.endpoint,
        method: service.method,
        identity: _objectSpread__default["default"](_objectSpread__default["default"]({}, IDENTITY_PRAGMA), {}, {
          address: utilAddress.withPrefix(service.addr),
          keyId: service.keyId
        }),
        params: service.params,
        data: service.data
      });
  }
}

//   "f_type": "service",
//   "f_vsn": "1.0.0",
//   "type": "pre-authz",
//   "uid": "uniqueDedupeKey",
//   "endpoint": "https://rawr",
//   "method": "HTTP/POST", // HTTP/POST | IFRAME/RPC | HTTP/RPC
//   "identity": {
//      "address": "0x______",
//      "keyId": 0,
//   },
//   "data": {}, // included in body of pre-authz request
//   "params": {}, // included as query params on endpoint url
// }

function normalizePreAuthz(service) {
  if (service == null) return null;

  switch (service["f_vsn"]) {
    case "1.0.0":
      return service;

    default:
      return _objectSpread__default["default"](_objectSpread__default["default"]({}, SERVICE_PRAGMA), {}, {
        type: service.type,
        uid: service.id,
        endpoint: service.endpoint,
        method: service.method,
        identity: _objectSpread__default["default"](_objectSpread__default["default"]({}, IDENTITY_PRAGMA), {}, {
          address: utilAddress.withPrefix(service.addr),
          keyId: service.keyId
        }),
        params: service.params,
        data: service.data
      });
  }
}

//    "f_type": "Service",
//    "f_vsn": "1.0.0",
//    "type": "frame",
//    "endpoint": "https://rawr",
//    "data": {},   // Sent to frame when ready
//    "params": {}, // include in query params on frame
// }

function normalizeFrame(service) {
  if (service == null) return null;

  switch (service["f_vsn"]) {
    case "1.0.0":
      return service;

    default:
      return _objectSpread__default["default"](_objectSpread__default["default"]({
        old: service
      }, SERVICE_PRAGMA), {}, {
        type: "frame",
        endpoint: service.endpoint,
        params: service.params || {},
        data: service.data || {}
      });
  }
}

//    "f_type": "Service",
//    "f_vsn": "1.0.0",
//    "type": "back-channel-rpc",
//    "endpoint": "https://rawr",
//    "method": "HTTP/GET", // HTTP/GET | HTTP/POST
//    "data": {},           // included in body of rpc
//    "params": {},         // included as query params on endpoint url
// }

function normalizeBackChannelRpc(service) {
  if (service == null) return null;

  switch (service["f_vsn"]) {
    case "1.0.0":
      return service;

    default:
      return _objectSpread__default["default"](_objectSpread__default["default"]({}, SERVICE_PRAGMA), {}, {
        type: "back-channel-rpc",
        endpoint: service.endpoint,
        method: service.method,
        params: service.params || {},
        data: service.data || {}
      });
  }
}

//   "f_type": "Service",
//   "f_vsn": "1.0.0",
//   "type": "open-id",
//   "uid": "uniqueDedupeKey",
//   "method: "data",
//   "data": {
//      "profile": {
//        "name": "Bob",
//        "family_name": "Builder",
//        "given_name": "Robert",
//        "middle_name": "the",
//        "nickname": "Bob the Builder",
//        "perferred_username": "bob",
//        "profile": "https://www.bobthebuilder.com/",
//        "picture": "https://avatars.onflow.org/avatar/bob",
//        "gender": "...",
//        "birthday": "2001-01-18",
//        "zoneinfo": "America/Vancouver",
//        "locale": "en-us",
//        "updated_at": "1614970797388"
//      },
//      "email": {
//        "email": "bob@bob.bob",
//        "email_verified": true
//      },
//      "address": {
//        "address": "One Apple Park Way, Cupertino, CA 95014, USA"
//      },
//      "phone": {
//        "phone_number": "+1 (xxx) yyy-zzzz",
//        "phone_number_verified": true
//      },
//      "social": {
//        "twitter": "@_qvvg",
//        "twitter_verified": true
//      },
//   }
// }

function normalizeOpenId(service) {
  if (service == null) return null;

  switch (service["f_vsn"]) {
    case "1.0.0":
      return service;

    default:
      return null;
  }
}

// {
//   "f_type": "Service",
//   "f_vsn": "1.0.0",
//   "type": "user-signature",
//   "uid": "uniqueDedupeKey",
//   "endpoint": "https://rawr",
//   "method": "IFRAME/RPC", // HTTP/POST | IFRAME/RPC | HTTP/RPC
//   "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", // wallets internal id for the user
//   "data": {}, // included in body of user-signature request
//   "params": {}, // included as query params on endpoint url
// }
function normalizeUserSignature(service) {
  if (service == null) return null;

  switch (service["f_vsn"]) {
    case "1.0.0":
      return service;

    default:
      throw new Error("Invalid user-signature service");
  }
}

//    "f_type": "Service",
//    "f_vsn": "1.0.0",
//    type: "local-view",
//    method: "VIEW/IFRAME",
//    endpoint: "https://woot.org/authz/local",
//    data: {},
//    params: {},
// }

function normalizeLocalView(resp) {
  if (resp == null) return null;

  if (resp.method == null) {
    resp = _objectSpread__default["default"](_objectSpread__default["default"]({}, resp), {}, {
      type: "local-view",
      method: "VIEW/IFRAME"
    });
  }

  switch (resp["f_vsn"]) {
    case "1.0.0":
      return resp;

    default:
      return _objectSpread__default["default"](_objectSpread__default["default"]({}, SERVICE_PRAGMA), {}, {
        type: resp.type || "local-view",
        method: resp.method,
        endpoint: resp.endpoint,
        data: resp.data || {},
        params: resp.params || {}
      });
  }
}

// {
//   "f_type": "Service",                    // Its a service!
//   "f_vsn": "1.0.0",                       // Follows the v1.0.0 spec for the service
//   "type": "account-proof",                // the type of service it is
//   "method": "DATA",                       // Its data!
//   "uid": "awesome-wallet#account-proof",  // A unique identifier for the service
//   "data": {
//     "f_type": "account-proof",
//     "f_vsn": "1.0.0",
//     "nonce": "0A1BC2FF",                  // Nonce signed by the current account-proof (minimum 32 bytes in total, i.e 64 hex characters)
//     "address": "0xUSER",                  // The user's address (8 bytes, i.e 16 hex characters)
//     "signature": CompositeSignature,      // address (sans-prefix), keyId, signature (hex)
// }
function normalizeAccountProof(service) {
  if (service == null) return null;

  switch (service["f_vsn"]) {
    case "1.0.0":
      return service;

    default:
      throw new Error("FCL Normalizer Error: Invalid account-proof service");
  }
}

// {
//   "f_type": "Service",
//   "f_vsn": "1.0.0",
//   "type": "authn-refresh",
//   "uid": "uniqueDedupeKey",
//   "endpoint": "https://rawr",
//   "method": "HTTP/POST",  // "HTTP/POST", // HTTP/POST | IFRAME/RPC | HTTP/RPC
//   "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", // wallets internal id for the user
//   "data": {}, // included in body of request
//   "params": {}, // included as query params on endpoint url
// }
function normalizeAuthnRefresh(service) {
  if (service == null) return null;

  switch (service["f_vsn"]) {
    case "1.0.0":
      return service;

    default:
      throw new Error("Invalid authn-refresh service");
  }
}

var serviceNormalizers = {
  "back-channel-rpc": normalizeBackChannelRpc,
  "pre-authz": normalizePreAuthz,
  authz: normalizeAuthz,
  authn: normalizeAuthn,
  frame: normalizeFrame,
  "open-id": normalizeOpenId,
  "user-signature": normalizeUserSignature,
  "local-view": normalizeLocalView,
  "account-proof": normalizeAccountProof,
  "authn-refresh": normalizeAuthnRefresh
};
function normalizeService(service, data) {
  try {
    var normalized = serviceNormalizers[service.type](service, data);
    return normalized;
  } catch (error) {
    console.error("Unrecognized FCL Service Type [".concat(service.type, "]"), service, error);
    return service;
  }
}

function deriveCompositeId(authn) {
  return rlp__namespace.encode([authn.provider.address || authn.provider.name || "UNSPECIFIED", authn.id]).toString("hex");
}

function normalizeData(data) {
  data.addr = data.addr ? utilAddress.withPrefix(data.addr) : null;
  data.paddr = data.paddr ? utilAddress.withPrefix(data.paddr) : null;
  return data;
}

function findService(type, services) {
  return services.find(function (d) {
    return d.type === type;
  });
}

function buildUser(_x) {
  return _buildUser.apply(this, arguments);
}

function _buildUser() {
  _buildUser = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(data) {
    var services, authn;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            data = normalizeData(data);
            _context.t0 = mergeServices;
            _context.t1 = data.services || [];
            _context.next = 5;
            return fetchServices(data.hks, data.code);

          case 5:
            _context.t2 = _context.sent;
            services = (0, _context.t0)(_context.t1, _context.t2).map(function (service) {
              return normalizeService(service, data);
            });
            authn = findService("authn", services);
            return _context.abrupt("return", _objectSpread__default["default"](_objectSpread__default["default"]({}, USER_PRAGMA), {}, {
              addr: utilAddress.withPrefix(data.addr),
              cid: deriveCompositeId(authn),
              loggedIn: true,
              services: services,
              expiresAt: data.expires
            }));

          case 9:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _buildUser.apply(this, arguments);
}

function serviceOfType() {
  var services = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : [];
  var type = arguments.length > 1 ? arguments[1] : undefined;
  return services.find(function (service) {
    return service.type === type;
  });
}

function serviceEndpoint(service) {
  var url = new URL(service.endpoint);
  url.searchParams.append("l6n", window.location.origin);

  if (service.params != null) {
    for (var _i = 0, _Object$entries = Object.entries(service.params || {}); _i < _Object$entries.length; _i++) {
      var _Object$entries$_i = _slicedToArray__default["default"](_Object$entries[_i], 2),
          key = _Object$entries$_i[0],
          value = _Object$entries$_i[1];

      url.searchParams.append(key, value);
    }
  }

  return url;
}

function fetchService(service) {
  var opts = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};
  var method = opts.method || "POST";
  var body = method === "GET" ? undefined : JSON.stringify(opts.data || service.data || {});
  return fetch(serviceEndpoint(service), {
    method: method,
    headers: _objectSpread__default["default"](_objectSpread__default["default"](_objectSpread__default["default"]({}, service.headers || {}), opts.headers || {}), {}, {
      "Content-Type": "application/json"
    }),
    body: body
  }).then(function (d) {
    return d.json();
  });
}

//    "f_type": "PollingResponse",
//    "f_vsn": "1.0.0",
//    "status": "PENDING", // PENDING | APPROVED | DECLINED | REDIRECT
//    "reason": null,      // Reason for Declining Transaction
//    "data": null,        // Return value for APPROVED
//    "updates": BackChannelRpc,
//    "local": Frame,
// }

function normalizePollingResponse(resp) {
  var _resp$status, _resp$reason;

  if (resp == null) return null;

  switch (resp["f_vsn"]) {
    case "1.0.0":
      return resp;

    default:
      return _objectSpread__default["default"](_objectSpread__default["default"]({}, POLLING_RESPONSE_PRAGMA), {}, {
        status: (_resp$status = resp.status) !== null && _resp$status !== void 0 ? _resp$status : "APPROVED",
        reason: (_resp$reason = resp.reason) !== null && _resp$reason !== void 0 ? _resp$reason : null,
        data: resp.compositeSignature || resp.data || _objectSpread__default["default"]({}, resp) || {},
        updates: normalizeBackChannelRpc(resp.authorizationUpdates),
        local: normalizeFrame((resp.local || [])[0])
      });
  }
}

var OPTIONS = {
  "HTTP/GET": "GET",
  "HTTP/POST": "POST"
};

var serviceMethod = function serviceMethod(service) {
  utilInvariant.invariant(OPTIONS[service.method], "Invalid Service Method for type back-channel-rpc", {
    service: service
  });
  return OPTIONS[service.method];
};

function poll(_x) {
  return _poll.apply(this, arguments);
}

function _poll() {
  _poll = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(service) {
    var canContinue,
        resp,
        _args = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            canContinue = _args.length > 1 && _args[1] !== undefined ? _args[1] : function () {
              return true;
            };
            utilInvariant.invariant(service, "Missing Polling Service", {
              service: service
            });

            if (canContinue()) {
              _context.next = 4;
              break;
            }

            throw new Error("Externally Halted");

          case 4:
            _context.next = 6;
            return fetchService(service, {
              method: serviceMethod(service)
            }).then(normalizePollingResponse);

          case 6:
            resp = _context.sent;
            _context.t0 = resp.status;
            _context.next = _context.t0 === "APPROVED" ? 10 : _context.t0 === "DECLINED" ? 11 : 12;
            break;

          case 10:
            return _context.abrupt("return", resp.data);

          case 11:
            throw new Error("Declined: ".concat(resp.reason || "No reason supplied."));

          case 12:
            _context.next = 14;
            return new Promise(function (r) {
              return setTimeout(r, 500);
            });

          case 14:
            return _context.abrupt("return", poll(resp.updates, canContinue));

          case 15:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _poll.apply(this, arguments);
}

var FRAME = "FCL_IFRAME";
var FRAME_STYLES = "\n  position:fixed;\n  top: 0px;\n  right: 0px;\n  bottom: 0px;\n  left: 0px;\n  height: 100%;\n  width: 100vw;\n  display:block;\n  background:rgba(0,0,0,0.25);\n  z-index: 2147483647;\n  box-sizing: border-box;\n  color-scheme: light;\n";
function renderFrame(src) {
  utilInvariant.invariant(!document.getElementById(FRAME), "Attempt at triggering multiple Frames", {
    src: src
  });
  var $frame = document.createElement("iframe");
  $frame.src = src;
  $frame.id = FRAME;
  $frame.allow = "usb *; hid *";
  $frame.frameBorder = "0";
  $frame.style.cssText = FRAME_STYLES;
  document.body.append($frame);

  var unmount = function unmount() {
    if (document.getElementById(FRAME)) {
      document.getElementById(FRAME).remove();
    }
  };

  return [$frame.contentWindow, unmount];
}

var POP = "FCL_POP";
var popup = null;
var previousUrl$1 = null;

function popupWindow(url, windowName, win, w, h) {
  var y = win.top.outerHeight / 2 + win.top.screenY - h / 2;
  var x = win.top.outerWidth / 2 + win.top.screenX - w / 2;
  var popup = win.open(url, windowName, "toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, width=".concat(w, ", height=").concat(h, ", top=").concat(y, ", left=").concat(x));
  if (!popup) throw new Error("Popup failed to open (was it blocked by a popup blocker?)");
  return popup;
}

function renderPop(src) {
  var _popup;

  if (popup == null || (_popup = popup) !== null && _popup !== void 0 && _popup.closed) {
    popup = popupWindow(src, POP, window, 640, 770);
  } else if (previousUrl$1 !== src) {
    popup.location.replace(src);
    popup.focus();
  } else {
    popup.focus();
  }

  previousUrl$1 = src;

  var unmount = function unmount() {
    if (popup && !popup.closed) {
      popup.close();
    }

    popup = null;
  };

  return [popup, unmount];
}

var tab$1 = null;
var previousUrl = null;
function renderTab(src) {
  var _tab;

  if (tab$1 == null || (_tab = tab$1) !== null && _tab !== void 0 && _tab.closed) {
    tab$1 = window.open(src, "_blank");
    if (!tab$1) throw new Error("Tab failed to open (was it blocked by the browser?)");
  } else if (previousUrl !== src) {
    tab$1.location.replace(src);
    tab$1.focus();
  } else {
    tab$1.focus();
  }

  previousUrl = src;

  var unmount = function unmount() {
    if (tab$1 && !tab$1.closed) {
      tab$1.close();
    }

    tab$1 = null;
  };

  return [tab$1, unmount];
}

var VIEWS = {
  "VIEW/IFRAME": renderFrame,
  "VIEW/POP": renderPop,
  "VIEW/TAB": renderTab
};
function execLocal(_x) {
  return _execLocal.apply(this, arguments);
}

function _execLocal() {
  _execLocal = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(service) {
    var opts,
        _args = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            opts = _args.length > 1 && _args[1] !== undefined ? _args[1] : {};
            _context.prev = 1;
            return _context.abrupt("return", VIEWS[service.method](serviceEndpoint(service), opts));

          case 5:
            _context.prev = 5;
            _context.t0 = _context["catch"](1);
            console.error("execLocal({service, opts = {}})", _context.t0, {
              service: service,
              opts: opts
            });
            throw _context.t0;

          case 9:
          case "end":
            return _context.stop();
        }
      }
    }, _callee, null, [[1, 5]]);
  }));
  return _execLocal.apply(this, arguments);
}

function execHttpPost(_x) {
  return _execHttpPost.apply(this, arguments);
}

function _execHttpPost() {
  _execHttpPost = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(_ref) {
    var service, body, config, resp, canContinue, _yield$execLocal, _yield$execLocal2, unmount, close;

    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            service = _ref.service, body = _ref.body, config = _ref.config, _ref.opts;
            _context.next = 3;
            return fetchService(service, {
              data: _objectSpread__default["default"]({
                fclVersion: VERSION,
                service: {
                  params: service.params,
                  data: service.data,
                  type: service.type
                },
                config: config
              }, body)
            }).then(normalizePollingResponse);

          case 3:
            resp = _context.sent;

            if (!(resp.status === "APPROVED")) {
              _context.next = 8;
              break;
            }

            return _context.abrupt("return", resp.data);

          case 8:
            if (!(resp.status === "DECLINED")) {
              _context.next = 12;
              break;
            }

            throw new Error("Declined: ".concat(resp.reason || "No reason supplied."));

          case 12:
            if (!(resp.status === "REDIRECT")) {
              _context.next = 16;
              break;
            }

            return _context.abrupt("return", resp);

          case 16:
            if (!(resp.status === "PENDING")) {
              _context.next = 28;
              break;
            }

            canContinue = true;
            _context.next = 20;
            return execLocal(normalizeLocalView(resp.local));

          case 20:
            _yield$execLocal = _context.sent;
            _yield$execLocal2 = _slicedToArray__default["default"](_yield$execLocal, 2);
            _yield$execLocal2[0];
            unmount = _yield$execLocal2[1];

            close = function close() {
              try {
                unmount();
                canContinue = false;
              } catch (error) {
                console.error("Frame Close Error", error);
              }
            };

            return _context.abrupt("return", poll(resp.updates, function () {
              return canContinue;
            }).then(function (serviceResponse) {
              close();
              return serviceResponse;
            })["catch"](function (error) {
              console.error(error);
              close();
              throw error;
            }));

          case 28:
            console.error("Auto Decline: Invalid Response", {
              service: service,
              resp: resp
            });
            throw new Error("Auto Decline: Invalid Response");

          case 30:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _execHttpPost.apply(this, arguments);
}

var CLOSE_EVENT = "FCL:VIEW:CLOSE";
var READY_EVENT = "FCL:VIEW:READY";
var RESPONSE_EVENT = "FCL:VIEW:RESPONSE";

var _ = function _(e) {
  return typeof e === "string" && e.toLowerCase();
};

var IGNORE = new Set(["monetizationstart", "monetizationpending", "monetizationprogress", "monetizationstop"]);

var deprecate = function deprecate(was, want) {
  return console.warn("DEPRECATION NOTICE", "Received ".concat(was, ", please use ").concat(want, " for this and future versions of FCL"));
};

var buildMessageHandler = function buildMessageHandler(_ref) {
  var close = _ref.close,
      send = _ref.send,
      onReady = _ref.onReady,
      onResponse = _ref.onResponse,
      onMessage = _ref.onMessage;
  return function (e) {
    try {
      if (_typeof__default["default"](e.data) !== "object") return;
      if (IGNORE.has(e.data.type)) return;
      if (_(e.data.type) === _(CLOSE_EVENT)) close();
      if (_(e.data.type) === _(READY_EVENT)) onReady(e, {
        send: send,
        close: close
      });
      if (_(e.data.type) === _(RESPONSE_EVENT)) onResponse(e, {
        send: send,
        close: close
      });
      onMessage(e, {
        send: send,
        close: close
      }); // Backwards Compatible

      if (_(e.data.type) === _("FCL:FRAME:READY")) {
        deprecate(e.data.type, READY_EVENT);
        onReady(e, {
          send: send,
          close: close
        });
      }

      if (_(e.data.type) === _("FCL:FRAME:RESPONSE")) {
        deprecate(e.data.type, RESPONSE_EVENT);
        onResponse(e, {
          send: send,
          close: close
        });
      }

      if (_(e.data.type) === _("FCL:FRAME:CLOSE")) {
        deprecate(e.data.type, CLOSE_EVENT);
        close();
      } //


      if (_(e.data.type) === _("FCL::CHALLENGE::RESPONSE")) {
        deprecate(e.data.type, RESPONSE_EVENT);
        onResponse(e, {
          send: send,
          close: close
        });
      }

      if (_(e.data.type) === _("FCL::AUTHZ_READY")) {
        deprecate(e.data.type, READY_EVENT);
        onReady(e, {
          send: send,
          close: close
        });
      }

      if (_(e.data.type) === _("FCL::CHALLENGE::CANCEL")) {
        deprecate(e.data.type, CLOSE_EVENT);
        close();
      }

      if (_(e.data.type) === _("FCL::CANCEL")) {
        deprecate(e.data.type, CLOSE_EVENT);
        close();
      }
    } catch (error) {
      console.error("Frame Callback Error", error);
      close();
    }
  };
};

var noop$3 = function noop() {};

function frame(service) {
  var opts = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};
  if (service == null) return {
    send: noop$3,
    close: noop$3
  };
  var onClose = opts.onClose || noop$3;
  var onMessage = opts.onMessage || noop$3;
  var onReady = opts.onReady || noop$3;
  var onResponse = opts.onResponse || noop$3;
  var handler = buildMessageHandler({
    close: close,
    send: send,
    onReady: onReady,
    onResponse: onResponse,
    onMessage: onMessage
  });
  window.addEventListener("message", handler);

  var _renderFrame = renderFrame(serviceEndpoint(service)),
      _renderFrame2 = _slicedToArray__default["default"](_renderFrame, 2),
      $frame = _renderFrame2[0],
      unmount = _renderFrame2[1];

  return {
    send: send,
    close: close
  };

  function close() {
    try {
      window.removeEventListener("message", handler);
      unmount();
      onClose();
    } catch (error) {
      console.error("Frame Close Error", error);
    }
  }

  function send(msg) {
    try {
      $frame.postMessage(JSON.parse(JSON.stringify(msg || {})), "*");
    } catch (error) {
      console.error("Frame Send Error", msg, error);
    }
  }
}

function execIframeRPC(_ref) {
  var service = _ref.service,
      body = _ref.body,
      config = _ref.config,
      opts = _ref.opts;
  return new Promise(function (resolve, reject) {
    var id = utilUid.uid();
    var includeOlderJsonRpcCall = opts.includeOlderJsonRpcCall;
    frame(service, {
      onReady: function onReady(_, _ref2) {
        return _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee() {
          var send;
          return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
            while (1) {
              switch (_context.prev = _context.next) {
                case 0:
                  send = _ref2.send;
                  _context.prev = 1;
                  send({
                    type: "FCL:VIEW:READY:RESPONSE",
                    fclVersion: VERSION,
                    body: body,
                    service: {
                      params: service.params,
                      data: service.data,
                      type: service.type
                    },
                    config: config
                  });
                  send({
                    fclVersion: VERSION,
                    type: "FCL:FRAME:READY:RESPONSE",
                    body: body,
                    service: {
                      params: service.params,
                      data: service.data,
                      type: service.type
                    },
                    config: config,
                    deprecated: {
                      message: "FCL:FRAME:READY:RESPONSE is deprecated and replaced with type: FCL:VIEW:READY:RESPONSE"
                    }
                  });

                  if (includeOlderJsonRpcCall) {
                    send({
                      jsonrpc: "2.0",
                      id: id,
                      method: "fcl:sign",
                      params: [body, service.params],
                      deprecated: {
                        message: "jsonrpc is deprecated and replaced with type: FCL:VIEW:READY:RESPONSE"
                      }
                    });
                  }

                  _context.next = 10;
                  break;

                case 7:
                  _context.prev = 7;
                  _context.t0 = _context["catch"](1);
                  throw _context.t0;

                case 10:
                case "end":
                  return _context.stop();
              }
            }
          }, _callee, null, [[1, 7]]);
        }))();
      },
      onResponse: function onResponse(e, _ref3) {
        var close = _ref3.close;

        try {
          if (_typeof__default["default"](e.data) !== "object") return;
          var resp = normalizePollingResponse(e.data);

          switch (resp.status) {
            case "APPROVED":
              resolve(resp.data);
              close();
              break;

            case "DECLINED":
              reject("Declined: ".concat(resp.reason || "No reason supplied"));
              close();
              break;

            case "REDIRECT":
              resolve(resp);
              close();
              break;

            default:
              reject("Declined: No reason supplied");
              close();
              break;
          }
        } catch (error) {
          console.error("execIframeRPC onResponse error", error);
          throw error;
        }
      },
      onMessage: function onMessage(e, _ref4) {
        var close = _ref4.close;

        try {
          if (_typeof__default["default"](e.data) !== "object") return;
          if (e.data.jsonrpc !== "2.0") return;
          if (e.data.id !== id) return;
          var resp = normalizePollingResponse(e.data.result);

          switch (resp.status) {
            case "APPROVED":
              resolve(resp.data);
              close();
              break;

            case "DECLINED":
              reject("Declined: ".concat(resp.reason || "No reason supplied"));
              close();
              break;

            case "REDIRECT":
              resolve(resp);
              close();
              break;

            default:
              reject("Declined: No reason supplied");
              close();
              break;
          }
        } catch (error) {
          console.error("execIframeRPC onMessage error", error);
          throw error;
        }
      },
      onClose: function onClose() {
        reject("Declined: Externally Halted");
      }
    });
  });
}

var noop$2 = function noop() {};

function pop(service) {
  var opts = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};
  if (service == null) return {
    send: noop$2,
    close: noop$2
  };
  var onClose = opts.onClose || noop$2;
  var onMessage = opts.onMessage || noop$2;
  var onReady = opts.onReady || noop$2;
  var onResponse = opts.onResponse || noop$2;
  var handler = buildMessageHandler({
    close: close,
    send: send,
    onReady: onReady,
    onResponse: onResponse,
    onMessage: onMessage
  });
  window.addEventListener("message", handler);

  var _renderPop = renderPop(serviceEndpoint(service)),
      _renderPop2 = _slicedToArray__default["default"](_renderPop, 2),
      $pop = _renderPop2[0],
      unmount = _renderPop2[1];

  var timer = setInterval(function () {
    if ($pop && $pop.closed) {
      close();
    }
  }, 500);
  return {
    send: send,
    close: close
  };

  function close() {
    try {
      window.removeEventListener("message", handler);
      clearInterval(timer);
      unmount();
      onClose();
    } catch (error) {
      console.error("Popup Close Error", error);
    }
  }

  function send(msg) {
    try {
      $pop.postMessage(JSON.parse(JSON.stringify(msg || {})), "*");
    } catch (error) {
      console.error("Popup Send Error", msg, error);
    }
  }
}

function execPopRPC(_ref) {
  var service = _ref.service,
      body = _ref.body,
      config = _ref.config,
      opts = _ref.opts;
  return new Promise(function (resolve, reject) {
    var id = utilUid.uid();
    var redir = opts.redir,
        includeOlderJsonRpcCall = opts.includeOlderJsonRpcCall;
    pop(service, {
      onReady: function onReady(_, _ref2) {
        return _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee() {
          var send;
          return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
            while (1) {
              switch (_context.prev = _context.next) {
                case 0:
                  send = _ref2.send;
                  _context.prev = 1;
                  send({
                    fclVersion: VERSION,
                    type: "FCL:VIEW:READY:RESPONSE",
                    body: body,
                    service: {
                      params: service.params,
                      data: service.data,
                      type: service.type
                    },
                    config: config
                  });
                  send({
                    fclVersion: VERSION,
                    type: "FCL:FRAME:READY:RESPONSE",
                    body: body,
                    service: {
                      params: service.params,
                      data: service.data,
                      type: service.type
                    },
                    config: config,
                    deprecated: {
                      message: "FCL:FRAME:READY:RESPONSE is deprecated and replaced with type: FCL:VIEW:READY:RESPONSE"
                    }
                  });

                  if (includeOlderJsonRpcCall) {
                    send({
                      jsonrpc: "2.0",
                      id: id,
                      method: "fcl:sign",
                      params: [body, service.params]
                    });
                  }

                  _context.next = 10;
                  break;

                case 7:
                  _context.prev = 7;
                  _context.t0 = _context["catch"](1);
                  throw _context.t0;

                case 10:
                case "end":
                  return _context.stop();
              }
            }
          }, _callee, null, [[1, 7]]);
        }))();
      },
      onResponse: function onResponse(e, _ref3) {
        var close = _ref3.close;

        try {
          if (_typeof__default["default"](e.data) !== "object") return;
          var resp = normalizePollingResponse(e.data);

          switch (resp.status) {
            case "APPROVED":
              resolve(resp.data);
              !redir && close();
              break;

            case "DECLINED":
              reject("Declined: ".concat(resp.reason || "No reason supplied"));
              close();
              break;

            case "REDIRECT":
              resolve(resp);
              close();
              break;

            default:
              reject("Declined: No reason supplied");
              close();
              break;
          }
        } catch (error) {
          console.error("execPopRPC onResponse error", error);
          throw error;
        }
      },
      onMessage: function onMessage(e, _ref4) {
        var close = _ref4.close;

        try {
          if (_typeof__default["default"](e.data) !== "object") return;
          if (e.data.jsonrpc !== "2.0") return;
          if (e.data.id !== id) return;
          var resp = normalizePollingResponse(e.data.result);

          switch (resp.status) {
            case "APPROVED":
              resolve(resp.data);
              !redir && close();
              break;

            case "DECLINED":
              reject("Declined: ".concat(resp.reason || "No reason supplied"));
              close();
              break;

            case "REDIRECT":
              resolve(resp);
              close();
              break;

            default:
              reject("Declined: No reason supplied");
              close();
              break;
          }
        } catch (error) {
          console.error("execPopRPC onMessage error", error);
          throw error;
        }
      },
      onClose: function onClose() {
        reject("Declined: Externally Halted");
      }
    });
  });
}

var noop$1 = function noop() {};

function tab(service) {
  var opts = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};
  if (service == null) return {
    send: noop$1,
    close: noop$1
  };
  var onClose = opts.onClose || noop$1;
  var onMessage = opts.onMessage || noop$1;
  var onReady = opts.onReady || noop$1;
  var onResponse = opts.onResponse || noop$1;
  var handler = buildMessageHandler({
    close: close,
    send: send,
    onReady: onReady,
    onResponse: onResponse,
    onMessage: onMessage
  });
  window.addEventListener("message", handler);

  var _renderTab = renderTab(serviceEndpoint(service)),
      _renderTab2 = _slicedToArray__default["default"](_renderTab, 2),
      $tab = _renderTab2[0],
      unmount = _renderTab2[1];

  var timer = setInterval(function () {
    if ($tab && $tab.closed) {
      close();
    }
  }, 500);
  return {
    send: send,
    close: close
  };

  function close() {
    try {
      window.removeEventListener("message", handler);
      clearInterval(timer);
      unmount();
      onClose();
    } catch (error) {
      console.error("Tab Close Error", error);
    }
  }

  function send(msg) {
    try {
      $tab.postMessage(JSON.parse(JSON.stringify(msg || {})), "*");
    } catch (error) {
      console.error("Tab Send Error", msg, error);
    }
  }
}

function execTabRPC(_ref) {
  var service = _ref.service,
      body = _ref.body,
      config = _ref.config,
      opts = _ref.opts;
  return new Promise(function (resolve, reject) {
    var id = utilUid.uid();
    var redir = opts.redir,
        includeOlderJsonRpcCall = opts.includeOlderJsonRpcCall;
    tab(service, {
      onReady: function onReady(_, _ref2) {
        return _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee() {
          var send;
          return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
            while (1) {
              switch (_context.prev = _context.next) {
                case 0:
                  send = _ref2.send;
                  _context.prev = 1;
                  send({
                    fclVersion: VERSION,
                    type: "FCL:VIEW:READY:RESPONSE",
                    body: body,
                    service: {
                      params: service.params,
                      data: service.data,
                      type: service.type
                    },
                    config: config
                  });
                  send({
                    fclVersion: VERSION,
                    type: "FCL:FRAME:READY:RESPONSE",
                    body: body,
                    service: {
                      params: service.params,
                      data: service.data,
                      type: service.type
                    },
                    config: config,
                    deprecated: {
                      message: "FCL:FRAME:READY:RESPONSE is deprecated and replaced with type: FCL:VIEW:READY:RESPONSE"
                    }
                  });

                  if (includeOlderJsonRpcCall) {
                    send({
                      jsonrpc: "2.0",
                      id: id,
                      method: "fcl:sign",
                      params: [body, service.params]
                    });
                  }

                  _context.next = 10;
                  break;

                case 7:
                  _context.prev = 7;
                  _context.t0 = _context["catch"](1);
                  throw _context.t0;

                case 10:
                case "end":
                  return _context.stop();
              }
            }
          }, _callee, null, [[1, 7]]);
        }))();
      },
      onResponse: function onResponse(e, _ref3) {
        var close = _ref3.close;

        try {
          if (_typeof__default["default"](e.data) !== "object") return;
          var resp = normalizePollingResponse(e.data);

          switch (resp.status) {
            case "APPROVED":
              resolve(resp.data);
              !redir && close();
              break;

            case "DECLINED":
              reject("Declined: ".concat(resp.reason || "No reason supplied"));
              close();
              break;

            case "REDIRECT":
              resolve(resp);
              close();
              break;

            default:
              reject("Declined: No reason supplied");
              close();
              break;
          }
        } catch (error) {
          console.error("execPopRPC onResponse error", error);
          throw error;
        }
      },
      onMessage: function onMessage(e, _ref4) {
        var close = _ref4.close;

        try {
          if (_typeof__default["default"](e.data) !== "object") return;
          if (e.data.jsonrpc !== "2.0") return;
          if (e.data.id !== id) return;
          var resp = normalizePollingResponse(e.data.result);

          switch (resp.status) {
            case "APPROVED":
              resolve(resp.data);
              !redir && close();
              break;

            case "DECLINED":
              reject("Declined: ".concat(resp.reason || "No reason supplied"));
              close();
              break;

            case "REDIRECT":
              resolve(resp);
              close();
              break;

            default:
              reject("Declined: No reason supplied");
              close();
              break;
          }
        } catch (error) {
          console.error("execPopRPC onMessage error", error);
          throw error;
        }
      },
      onClose: function onClose() {
        reject("Declined: Externally Halted");
      }
    });
  });
}

var noop = function noop() {};

function extension(service) {
  var opts = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};
  if (service == null) return {
    send: noop,
    close: noop
  };
  var onClose = opts.onClose || noop;
  var onMessage = opts.onMessage || noop;
  var onReady = opts.onReady || noop;
  var onResponse = opts.onResponse || noop;
  var handler = buildMessageHandler({
    close: close,
    send: send,
    onReady: onReady,
    onResponse: onResponse,
    onMessage: onMessage
  });
  window.addEventListener("message", handler);
  send({
    service: service
  });
  return {
    send: send,
    close: close
  };

  function close() {
    try {
      window.removeEventListener("message", handler);
      onClose();
    } catch (error) {
      console.error("Ext Close Error", error);
    }
  }

  function send(msg) {
    try {
      window && window.postMessage(JSON.parse(JSON.stringify(msg || {})), "*");
    } catch (error) {
      console.error("Ext Send Error", msg, error);
    }
  }
}

function execExtRPC(_ref) {
  var service = _ref.service,
      body = _ref.body,
      config = _ref.config;
      _ref.opts;
  return new Promise(function (resolve, reject) {
    extension(service, {
      onReady: function onReady(_, _ref2) {
        return _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee() {
          var send;
          return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
            while (1) {
              switch (_context.prev = _context.next) {
                case 0:
                  send = _ref2.send;
                  _context.prev = 1;
                  send({
                    fclVersion: VERSION,
                    type: "FCL:VIEW:READY:RESPONSE",
                    body: body,
                    service: {
                      params: service.params,
                      data: service.data,
                      type: service.type
                    },
                    config: config
                  });
                  _context.next = 8;
                  break;

                case 5:
                  _context.prev = 5;
                  _context.t0 = _context["catch"](1);
                  throw _context.t0;

                case 8:
                case "end":
                  return _context.stop();
              }
            }
          }, _callee, null, [[1, 5]]);
        }))();
      },
      onResponse: function onResponse(e, _ref3) {
        var close = _ref3.close;

        try {
          if (_typeof__default["default"](e.data) !== "object") return;
          var resp = normalizePollingResponse(e.data);

          switch (resp.status) {
            case "APPROVED":
              resolve(resp.data);
              close();
              break;

            case "DECLINED":
              reject("Declined: ".concat(resp.reason || "No reason supplied"));
              close();
              break;

            case "REDIRECT":
              resolve(resp);
              close();
              break;

            default:
              reject("Declined: No reason supplied");
              close();
              break;
          }
        } catch (error) {
          console.error("execExtRPC onResponse error", error);
          throw error;
        }
      },
      onClose: function onClose() {
        reject("Declined: Externally Halted");
      }
    });
  });
}

var CORE_STRATEGIES = {
  "HTTP/RPC": execHttpPost,
  "HTTP/POST": execHttpPost,
  "IFRAME/RPC": execIframeRPC,
  "POP/RPC": execPopRPC,
  "TAB/RPC": execTabRPC,
  "EXT/RPC": execExtRPC
};
var supportedPlugins = ["ServicePlugin"];
var supportedServicePlugins = ["discovery-service"];

var validateDiscoveryPlugin = function validateDiscoveryPlugin(servicePlugin) {
  var services = servicePlugin.services,
      serviceStrategy = servicePlugin.serviceStrategy;
  utilInvariant.invariant(Array.isArray(services) && services.length, "Array of Discovery Services is required");

  var _iterator = _createForOfIteratorHelper__default["default"](services),
      _step;

  try {
    for (_iterator.s(); !(_step = _iterator.n()).done;) {
      var ds = _step.value;
      utilInvariant.invariant(isRequired(ds.f_type) && ds.f_type === "Service", "Service is required");
      utilInvariant.invariant(isRequired(ds.type) && ds.type === "authn", "Service must be type authn. Received ".concat(ds.type));
      utilInvariant.invariant(ds.method in CORE_STRATEGIES || serviceStrategy.method === ds.method, "Service method ".concat(ds.method, " is not supported"));
    }
  } catch (err) {
    _iterator.e(err);
  } finally {
    _iterator.f();
  }

  utilInvariant.invariant(isRequired(serviceStrategy), "Service strategy is required");
  utilInvariant.invariant(isRequired(serviceStrategy.method) && isString(serviceStrategy.method), "Service strategy method is required");
  utilInvariant.invariant(isRequired(serviceStrategy.exec) && isFunc(serviceStrategy.exec), "Service strategy exec function is required");
  return {
    discoveryServices: services,
    serviceStrategy: serviceStrategy
  };
};

var ServiceRegistry = function ServiceRegistry() {
  var services = new Set();
  var strategies = new Map(Object.entries(CORE_STRATEGIES));

  var add = function add(servicePlugin) {
    utilInvariant.invariant(supportedServicePlugins.includes(servicePlugin.type), "Service Plugin type ".concat(servicePlugin.type, " is not supported"));

    if (servicePlugin.type === "discovery-service") {
      var _validateDiscoveryPlu = validateDiscoveryPlugin(servicePlugin),
          discoveryServices = _validateDiscoveryPlu.discoveryServices,
          serviceStrategy = _validateDiscoveryPlu.serviceStrategy;

      setServices(discoveryServices);

      if (!strategies.has(serviceStrategy.method)) {
        strategies.set(serviceStrategy.method, serviceStrategy.exec);
      } else {
        utilLogger.log({
          title: "Add Service Plugin",
          message: "Service strategy for ".concat(serviceStrategy.method, " already exists"),
          level: utilLogger.LEVELS.warn
        });
      }
    }
  };

  var setServices = function setServices(discoveryServices) {
    return services = new Set(_toConsumableArray__default["default"](discoveryServices));
  };

  var getServices = function getServices() {
    return _toConsumableArray__default["default"](services);
  };

  var getStrategy = function getStrategy(method) {
    return strategies.get(method);
  };

  var getStrategies = function getStrategies() {
    return _toConsumableArray__default["default"](strategies.keys());
  };

  return Object.freeze({
    add: add,
    getServices: getServices,
    getStrategy: getStrategy,
    getStrategies: getStrategies
  });
};

var validatePlugins = function validatePlugins(plugins) {
  var pluginsArray;
  utilInvariant.invariant(plugins, "No plugins supplied");

  if (!Array.isArray(plugins)) {
    pluginsArray = [plugins];
  } else {
    pluginsArray = _toConsumableArray__default["default"](plugins);
  }

  var _iterator2 = _createForOfIteratorHelper__default["default"](pluginsArray),
      _step2;

  try {
    for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
      var p = _step2.value;
      utilInvariant.invariant(isRequired(p.name), "Plugin name is required");
      utilInvariant.invariant(isRequired(p.f_type), "Plugin f_type is required");
      utilInvariant.invariant(supportedPlugins.includes(p.f_type), "Plugin type ".concat(p.f_type, " is not supported"));
    }
  } catch (err) {
    _iterator2.e(err);
  } finally {
    _iterator2.f();
  }

  return pluginsArray;
};

var PluginRegistry = function PluginRegistry() {
  var pluginsMap = new Map();

  var getPlugins = function getPlugins() {
    return pluginsMap;
  };

  var add = function add(plugins) {
    var pluginsArray = validatePlugins(plugins);

    var _iterator3 = _createForOfIteratorHelper__default["default"](pluginsArray),
        _step3;

    try {
      for (_iterator3.s(); !(_step3 = _iterator3.n()).done;) {
        var p = _step3.value;
        pluginsMap.set(p.name, p);

        if (p.f_type === "ServicePlugin") {
          serviceRegistry.add(p);
        }
      }
    } catch (err) {
      _iterator3.e(err);
    } finally {
      _iterator3.f();
    }
  };

  return Object.freeze({
    add: add,
    getPlugins: getPlugins
  });
};

var serviceRegistry = ServiceRegistry();
var pluginRegistry = PluginRegistry();

var execStrategy = /*#__PURE__*/function () {
  var _ref2 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(_ref) {
    var service, body, config, opts, strategy;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            service = _ref.service, body = _ref.body, config = _ref.config, opts = _ref.opts;
            strategy = serviceRegistry.getStrategy(service.method);
            return _context.abrupt("return", strategy({
              service: service,
              body: body,
              config: config,
              opts: opts
            }));

          case 3:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));

  return function execStrategy(_x) {
    return _ref2.apply(this, arguments);
  };
}();

function execService(_x2) {
  return _execService.apply(this, arguments);
}

function _execService() {
  _execService = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(_ref3) {
    var _window$location$host, _window, _window$location;

    var service, _ref3$msg, msg, _ref3$config, config, _ref3$opts, opts, execConfig, res;

    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            service = _ref3.service, _ref3$msg = _ref3.msg, msg = _ref3$msg === void 0 ? {} : _ref3$msg, _ref3$config = _ref3.config, config = _ref3$config === void 0 ? {} : _ref3$config, _ref3$opts = _ref3.opts, opts = _ref3$opts === void 0 ? {} : _ref3$opts;
            msg.data = service.data;
            _context2.next = 4;
            return configLens(/^service\./);

          case 4:
            _context2.t0 = _context2.sent;
            _context2.next = 7;
            return configLens(/^app\.detail\./);

          case 7:
            _context2.t1 = _context2.sent;
            _context2.t2 = _objectSpread__default["default"](_objectSpread__default["default"]({}, config.client), {}, {
              fclVersion: VERSION,
              fclLibrary: "https://github.com/onflow/fcl-js",
              hostname: (_window$location$host = (_window = window) === null || _window === void 0 ? void 0 : (_window$location = _window.location) === null || _window$location === void 0 ? void 0 : _window$location.hostname) !== null && _window$location$host !== void 0 ? _window$location$host : null
            });
            execConfig = {
              services: _context2.t0,
              app: _context2.t1,
              client: _context2.t2
            };
            _context2.prev = 10;
            _context2.next = 13;
            return execStrategy({
              service: service,
              body: msg,
              config: execConfig,
              opts: opts
            });

          case 13:
            res = _context2.sent;

            if (!(res.status === "REDIRECT")) {
              _context2.next = 21;
              break;
            }

            utilInvariant.invariant(service.type === res.data.type, "Cannot shift recursive service type in execService");
            _context2.next = 18;
            return execService({
              service: res.data,
              msg: msg,
              config: execConfig,
              opts: opts
            });

          case 18:
            return _context2.abrupt("return", _context2.sent);

          case 21:
            return _context2.abrupt("return", res);

          case 22:
            _context2.next = 28;
            break;

          case 24:
            _context2.prev = 24;
            _context2.t3 = _context2["catch"](10);
            utilLogger.log({
              title: "Error on execService ".concat(service === null || service === void 0 ? void 0 : service.type),
              message: _context2.t3,
              level: utilLogger.LEVELS.error
            });
            throw _context2.t3;

          case 28:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2, null, [[10, 24]]);
  }));
  return _execService.apply(this, arguments);
}

//    "f_type": "CompositeSignature",
//    "f_vsn": "1.0.0",
//    "addr": "_____",         // sans-prefix
//    "signature": "adfe1234", // hex
//    "keyId": 3,
// }

function normalizeCompositeSignature(resp) {
  if (resp == null) return null;

  switch (resp["f_vsn"]) {
    case "1.0.0":
      return resp;

    default:
      return _objectSpread__default["default"](_objectSpread__default["default"]({}, COMPOSITE_SIGNATURE_PRAGMA), {}, {
        addr: utilAddress.sansPrefix(resp.addr || resp.address),
        signature: resp.signature || resp.sig,
        keyId: resp.keyId
      });
  }
}

var makeDiscoveryServices = /*#__PURE__*/function () {
  var _ref = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee() {
    var _window;

    var extensionServices;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            extensionServices = ((_window = window) === null || _window === void 0 ? void 0 : _window.fcl_extensions) || [];
            return _context.abrupt("return", [].concat(_toConsumableArray__default["default"](extensionServices), _toConsumableArray__default["default"](serviceRegistry.getServices())));

          case 2:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));

  return function makeDiscoveryServices() {
    return _ref.apply(this, arguments);
  };
}();
function getDiscoveryService(_x) {
  return _getDiscoveryService.apply(this, arguments);
}

function _getDiscoveryService() {
  _getDiscoveryService = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(service) {
    var _service$endpoint;

    var discoveryAuthnInclude, discoveryWalletMethod, method, endpoint;
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            _context2.next = 2;
            return config.config.get("discovery.authn.include", []);

          case 2:
            discoveryAuthnInclude = _context2.sent;
            _context2.next = 5;
            return config.config.first(["discovery.wallet.method", "discovery.wallet.method.default"]);

          case 5:
            discoveryWalletMethod = _context2.sent;
            method = service !== null && service !== void 0 && service.method ? service.method : discoveryWalletMethod;

            if (!((_service$endpoint = service === null || service === void 0 ? void 0 : service.endpoint) !== null && _service$endpoint !== void 0)) {
              _context2.next = 11;
              break;
            }

            _context2.t0 = _service$endpoint;
            _context2.next = 14;
            break;

          case 11:
            _context2.next = 13;
            return config.config.first(["discovery.wallet", "challenge.handshake"]);

          case 13:
            _context2.t0 = _context2.sent;

          case 14:
            endpoint = _context2.t0;
            utilInvariant.invariant(endpoint, "\n    If no service is passed to \"authenticate,\" then \"discovery.wallet\" must be defined in fcl config.\n    See: \"https://docs.onflow.org/fcl/reference/api/#setting-configuration-values\"\n    ");
            return _context2.abrupt("return", _objectSpread__default["default"](_objectSpread__default["default"]({}, service), {}, {
              type: "authn",
              endpoint: endpoint,
              method: method,
              discoveryAuthnInclude: discoveryAuthnInclude
            }));

          case 17:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _getDiscoveryService.apply(this, arguments);
}

function getServices(_x) {
  return _getServices.apply(this, arguments);
}

function _getServices() {
  _getServices = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(_ref) {
    var _window, _window$navigator;

    var types, endpoint, include, url;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            types = _ref.types;
            _context.next = 3;
            return config.config.get("discovery.authn.endpoint");

          case 3:
            endpoint = _context.sent;
            utilInvariant.invariant(Boolean(endpoint), "\"discovery.authn.endpoint\" in config must be defined.");
            _context.next = 7;
            return config.config.get("discovery.authn.include", []);

          case 7:
            include = _context.sent;
            url = new URL(endpoint);
            _context.t0 = fetch;
            _context.t1 = url;
            _context.t2 = {
              "Content-Type": "application/json"
            };
            _context.t3 = JSON;
            _context.t4 = types;
            _context.t5 = VERSION;
            _context.t6 = include;
            _context.next = 18;
            return makeDiscoveryServices();

          case 18:
            _context.t7 = _context.sent;
            _context.t8 = serviceRegistry.getStrategies();
            _context.t9 = (_window = window) === null || _window === void 0 ? void 0 : (_window$navigator = _window.navigator) === null || _window$navigator === void 0 ? void 0 : _window$navigator.userAgent;
            _context.t10 = {
              type: _context.t4,
              fclVersion: _context.t5,
              include: _context.t6,
              clientServices: _context.t7,
              supportedStrategies: _context.t8,
              userAgent: _context.t9
            };
            _context.t11 = _context.t3.stringify.call(_context.t3, _context.t10);
            _context.t12 = {
              method: "POST",
              headers: _context.t2,
              body: _context.t11
            };
            return _context.abrupt("return", (0, _context.t0)(_context.t1, _context.t12).then(function (d) {
              return d.json();
            }));

          case 25:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _getServices.apply(this, arguments);
}

var _HANDLERS$3;
var SERVICE_ACTOR_KEYS = {
  AUTHN: "authn",
  RESULTS: "results",
  SNAPSHOT: "SNAPSHOT",
  UPDATED: "UPDATED",
  UPDATE_RESULTS: "UPDATE_RESULTS"
};

var warn = function warn(fact, msg) {
  if (fact) {
    console.warn("\n      %cFCL Warning\n      ============================\n      ".concat(msg, "\n      For more info, please see the docs: https://docs.onflow.org/fcl/\n      ============================\n      "), "font-weight:bold;font-family:monospace;");
  }
};

var fetchServicesFromDiscovery = /*#__PURE__*/function () {
  var _ref = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee() {
    var services;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            _context.prev = 0;
            _context.next = 3;
            return getServices({
              types: [SERVICE_ACTOR_KEYS.AUTHN]
            });

          case 3:
            services = _context.sent;
            utilActor.send(SERVICE_ACTOR_KEYS.AUTHN, SERVICE_ACTOR_KEYS.UPDATE_RESULTS, {
              results: services
            });
            _context.next = 10;
            break;

          case 7:
            _context.prev = 7;
            _context.t0 = _context["catch"](0);
            utilLogger.log({
              title: "".concat(_context.t0.name, " Error fetching Discovery API services."),
              message: _context.t0.message,
              level: utilLogger.LEVELS.error
            });

          case 10:
          case "end":
            return _context.stop();
        }
      }
    }, _callee, null, [[0, 7]]);
  }));

  return function fetchServicesFromDiscovery() {
    return _ref.apply(this, arguments);
  };
}();

var HANDLERS$3 = (_HANDLERS$3 = {}, _defineProperty__default["default"](_HANDLERS$3, utilActor.INIT, function () {
  var _ref2 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(ctx) {
    return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
      while (1) {
        switch (_context3.prev = _context3.next) {
          case 0:
            warn(typeof window === "undefined", '"fcl.discovery" is only available in the browser.'); // If you call this before the window is loaded extensions will not be set yet

            if (document.readyState === 'complete') {
              fetchServicesFromDiscovery();
            } else {
              window.onload = /*#__PURE__*/_asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2() {
                return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
                  while (1) {
                    switch (_context2.prev = _context2.next) {
                      case 0:
                        fetchServicesFromDiscovery();

                      case 1:
                      case "end":
                        return _context2.stop();
                    }
                  }
                }, _callee2);
              }));
            }

          case 2:
          case "end":
            return _context3.stop();
        }
      }
    }, _callee3);
  }));

  return function (_x) {
    return _ref2.apply(this, arguments);
  };
}()), _defineProperty__default["default"](_HANDLERS$3, SERVICE_ACTOR_KEYS.UPDATE_RESULTS, function (ctx, _letter, data) {
  ctx.merge(data);
  ctx.broadcast(SERVICE_ACTOR_KEYS.UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS$3, utilActor.SUBSCRIBE, function (ctx, letter) {
  ctx.subscribe(letter.from);
  ctx.send(letter.from, SERVICE_ACTOR_KEYS.UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS$3, utilActor.UNSUBSCRIBE, function (ctx, letter) {
  return ctx.unsubscribe(letter.from);
}), _defineProperty__default["default"](_HANDLERS$3, SERVICE_ACTOR_KEYS.SNAPSHOT, function () {
  var _ref4 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee4(ctx, letter) {
    return _regeneratorRuntime__default["default"].wrap(function _callee4$(_context4) {
      while (1) {
        switch (_context4.prev = _context4.next) {
          case 0:
            return _context4.abrupt("return", letter.reply(_objectSpread__default["default"]({}, ctx.all())));

          case 1:
          case "end":
            return _context4.stop();
        }
      }
    }, _callee4);
  }));

  return function (_x2, _x3) {
    return _ref4.apply(this, arguments);
  };
}()), _HANDLERS$3);

var spawnProviders = function spawnProviders() {
  return utilActor.spawn(HANDLERS$3, SERVICE_ACTOR_KEYS.AUTHN);
};

var authn = {
  subscribe: function subscribe(cb) {
    return utilActor.subscriber(SERVICE_ACTOR_KEYS.AUTHN, spawnProviders, cb);
  },
  snapshot: function snapshot() {
    return utilActor.snapshoter(SERVICE_ACTOR_KEYS.AUTHN, spawnProviders);
  },
  update: function update() {
    return fetchServicesFromDiscovery();
  }
};

var discovery = {
  authn: authn
};

function isAndroid() {
  return typeof navigator !== "undefined" && /android/i.test(navigator.userAgent);
}
function isSmallIOS() {
  return typeof navigator !== "undefined" && /iPhone|iPod/.test(navigator.userAgent);
}
function isLargeIOS() {
  return typeof navigator !== "undefined" && /iPad/.test(navigator.userAgent);
}
function isIOS() {
  return isSmallIOS() || isLargeIOS();
}
function isMobile() {
  return isAndroid() || isIOS();
}

var _HANDLERS$2;
var isFn = function isFn(d) {
  return typeof d === "function";
};
var NAME = "CURRENT_USER";
var UPDATED$1 = "CURRENT_USER/UPDATED";
var SNAPSHOT = "SNAPSHOT";
var SET_CURRENT_USER = "SET_CURRENT_USER";
var DEL_CURRENT_USER = "DEL_CURRENT_USER";
var DATA = "{\n  \"f_type\": \"User\",\n  \"f_vsn\": \"1.0.0\",\n  \"addr\":null,\n  \"cid\":null,\n  \"loggedIn\":null,\n  \"expiresAt\":null,\n  \"services\":[]\n}";

var getStoredUser = /*#__PURE__*/function () {
  var _ref = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(storage) {
    var fallback, stored;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            fallback = JSON.parse(DATA);
            _context.next = 3;
            return storage.get(NAME);

          case 3:
            stored = _context.sent;

            if (!(stored != null && fallback["f_vsn"] !== stored["f_vsn"])) {
              _context.next = 7;
              break;
            }

            storage.removeItem(NAME);
            return _context.abrupt("return", fallback);

          case 7:
            return _context.abrupt("return", stored || fallback);

          case 8:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));

  return function getStoredUser(_x) {
    return _ref.apply(this, arguments);
  };
}();

var HANDLERS$2 = (_HANDLERS$2 = {}, _defineProperty__default["default"](_HANDLERS$2, utilActor.INIT, function () {
  var _ref2 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(ctx) {
    var storage, user;
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            if (typeof window === "undefined") {
              console.warn("\n        %cFCL Warning\n        ============================\n        \"currentUser\" is only available in the browser.\n        For more info, please see the docs: https://docs.onflow.org/fcl/\n        ============================\n        ", "font-weight:bold;font-family:monospace;");
            }

            ctx.merge(JSON.parse(DATA));
            _context2.next = 4;
            return config.config.first(["fcl.storage", "fcl.storage.default"]);

          case 4:
            storage = _context2.sent;

            if (!storage.can) {
              _context2.next = 10;
              break;
            }

            _context2.next = 8;
            return getStoredUser(storage);

          case 8:
            user = _context2.sent;
            if (notExpired(user)) ctx.merge(user);

          case 10:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));

  return function (_x2) {
    return _ref2.apply(this, arguments);
  };
}()), _defineProperty__default["default"](_HANDLERS$2, utilActor.SUBSCRIBE, function (ctx, letter) {
  ctx.subscribe(letter.from);
  ctx.send(letter.from, UPDATED$1, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS$2, utilActor.UNSUBSCRIBE, function (ctx, letter) {
  ctx.unsubscribe(letter.from);
}), _defineProperty__default["default"](_HANDLERS$2, SNAPSHOT, function () {
  var _ref3 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(ctx, letter) {
    return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
      while (1) {
        switch (_context3.prev = _context3.next) {
          case 0:
            letter.reply(_objectSpread__default["default"]({}, ctx.all()));

          case 1:
          case "end":
            return _context3.stop();
        }
      }
    }, _callee3);
  }));

  return function (_x3, _x4) {
    return _ref3.apply(this, arguments);
  };
}()), _defineProperty__default["default"](_HANDLERS$2, SET_CURRENT_USER, function () {
  var _ref4 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee4(ctx, letter, data) {
    var storage;
    return _regeneratorRuntime__default["default"].wrap(function _callee4$(_context4) {
      while (1) {
        switch (_context4.prev = _context4.next) {
          case 0:
            ctx.merge(data);
            _context4.next = 3;
            return config.config.first(["fcl.storage", "fcl.storage.default"]);

          case 3:
            storage = _context4.sent;
            if (storage.can) storage.put(NAME, ctx.all());
            ctx.broadcast(UPDATED$1, _objectSpread__default["default"]({}, ctx.all()));

          case 6:
          case "end":
            return _context4.stop();
        }
      }
    }, _callee4);
  }));

  return function (_x5, _x6, _x7) {
    return _ref4.apply(this, arguments);
  };
}()), _defineProperty__default["default"](_HANDLERS$2, DEL_CURRENT_USER, function () {
  var _ref5 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee5(ctx, letter) {
    var storage;
    return _regeneratorRuntime__default["default"].wrap(function _callee5$(_context5) {
      while (1) {
        switch (_context5.prev = _context5.next) {
          case 0:
            ctx.merge(JSON.parse(DATA));
            _context5.next = 3;
            return config.config.first(["fcl.storage", "fcl.storage.default"]);

          case 3:
            storage = _context5.sent;
            if (storage.can) storage.put(NAME, ctx.all());
            ctx.broadcast(UPDATED$1, _objectSpread__default["default"]({}, ctx.all()));

          case 6:
          case "end":
            return _context5.stop();
        }
      }
    }, _callee5);
  }));

  return function (_x8, _x9) {
    return _ref5.apply(this, arguments);
  };
}()), _HANDLERS$2);

var spawnCurrentUser = function spawnCurrentUser() {
  return utilActor.spawn(HANDLERS$2, NAME);
};

function notExpired(user) {
  return user.expiresAt == null || user.expiresAt === 0 || user.expiresAt > Date.now();
}

function getAccountProofData() {
  return _getAccountProofData.apply(this, arguments);
}

function _getAccountProofData() {
  _getAccountProofData = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee8() {
    var accountProofDataResolver, accountProofData;
    return _regeneratorRuntime__default["default"].wrap(function _callee8$(_context8) {
      while (1) {
        switch (_context8.prev = _context8.next) {
          case 0:
            _context8.next = 2;
            return config.config.get("fcl.accountProof.resolver");

          case 2:
            accountProofDataResolver = _context8.sent;

            if (isFn(accountProofDataResolver)) {
              _context8.next = 5;
              break;
            }

            return _context8.abrupt("return");

          case 5:
            _context8.next = 7;
            return accountProofDataResolver();

          case 7:
            accountProofData = _context8.sent;

            if (!(accountProofData == null)) {
              _context8.next = 10;
              break;
            }

            return _context8.abrupt("return");

          case 10:
            utilInvariant.invariant(typeof accountProofData.appIdentifier === "string", "appIdentifier must be a string");
            utilInvariant.invariant(/^[0-9a-f]+$/i.test(accountProofData.nonce), "Nonce must be a hex string");
            return _context8.abrupt("return", accountProofData);

          case 13:
          case "end":
            return _context8.stop();
        }
      }
    }, _callee8);
  }));
  return _getAccountProofData.apply(this, arguments);
}

var makeConfig = /*#__PURE__*/function () {
  var _ref7 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee6(_ref6) {
    var discoveryAuthnInclude;
    return _regeneratorRuntime__default["default"].wrap(function _callee6$(_context6) {
      while (1) {
        switch (_context6.prev = _context6.next) {
          case 0:
            discoveryAuthnInclude = _ref6.discoveryAuthnInclude;
            _context6.t0 = discoveryAuthnInclude;
            _context6.next = 4;
            return makeDiscoveryServices();

          case 4:
            _context6.t1 = _context6.sent;
            _context6.t2 = serviceRegistry.getStrategies();
            _context6.t3 = {
              discoveryAuthnInclude: _context6.t0,
              clientServices: _context6.t1,
              supportedStrategies: _context6.t2
            };
            return _context6.abrupt("return", {
              client: _context6.t3
            });

          case 8:
          case "end":
            return _context6.stop();
        }
      }
    }, _callee6);
  }));

  return function makeConfig(_x10) {
    return _ref7.apply(this, arguments);
  };
}();

function authenticate$1() {
  return _authenticate.apply(this, arguments);
}

function _authenticate() {
  _authenticate = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee10() {
    var _service$provider, _service$provider2;

    var _ref11,
        service,
        _ref11$redir,
        redir,
        _service$provider3,
        _args10 = arguments;

    return _regeneratorRuntime__default["default"].wrap(function _callee10$(_context10) {
      while (1) {
        switch (_context10.prev = _context10.next) {
          case 0:
            _ref11 = _args10.length > 0 && _args10[0] !== undefined ? _args10[0] : {}, service = _ref11.service, _ref11$redir = _ref11.redir, redir = _ref11$redir === void 0 ? false : _ref11$redir;

            if (!(service && !(service !== null && service !== void 0 && (_service$provider = service.provider) !== null && _service$provider !== void 0 && _service$provider.is_installed) && service !== null && service !== void 0 && (_service$provider2 = service.provider) !== null && _service$provider2 !== void 0 && _service$provider2.requires_install)) {
              _context10.next = 4;
              break;
            }

            window.location.href = service === null || service === void 0 ? void 0 : (_service$provider3 = service.provider) === null || _service$provider3 === void 0 ? void 0 : _service$provider3.install_link;
            return _context10.abrupt("return");

          case 4:
            return _context10.abrupt("return", new Promise( /*#__PURE__*/function () {
              var _ref12 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee9(resolve, reject) {
                var opts, user, discoveryService, refreshService, accountProofData, response, _response;

                return _regeneratorRuntime__default["default"].wrap(function _callee9$(_context9) {
                  while (1) {
                    switch (_context9.prev = _context9.next) {
                      case 0:
                        spawnCurrentUser();
                        opts = {
                          redir: redir
                        };
                        _context9.next = 4;
                        return snapshot();

                      case 4:
                        user = _context9.sent;
                        _context9.next = 7;
                        return getDiscoveryService(service);

                      case 7:
                        discoveryService = _context9.sent;
                        refreshService = serviceOfType(user.services, "authn-refresh");
                        _context9.prev = 9;
                        _context9.next = 12;
                        return getAccountProofData();

                      case 12:
                        accountProofData = _context9.sent;
                        _context9.next = 19;
                        break;

                      case 15:
                        _context9.prev = 15;
                        _context9.t0 = _context9["catch"](9);
                        console.error("Error During Authentication: Could not resolve account proof data.\n        ".concat(_context9.t0));
                        return _context9.abrupt("return", reject(_context9.t0));

                      case 19:
                        if (!user.loggedIn) {
                          _context9.next = 47;
                          break;
                        }

                        if (!refreshService) {
                          _context9.next = 46;
                          break;
                        }

                        _context9.prev = 21;
                        _context9.next = 24;
                        return execService({
                          service: refreshService,
                          msg: accountProofData,
                          opts: opts
                        });

                      case 24:
                        response = _context9.sent;
                        _context9.t1 = utilActor.send;
                        _context9.t2 = NAME;
                        _context9.t3 = SET_CURRENT_USER;
                        _context9.next = 30;
                        return buildUser(response);

                      case 30:
                        _context9.t4 = _context9.sent;
                        (0, _context9.t1)(_context9.t2, _context9.t3, _context9.t4);
                        _context9.next = 37;
                        break;

                      case 34:
                        _context9.prev = 34;
                        _context9.t5 = _context9["catch"](21);
                        console.error("Error: Could not refresh authentication.", _context9.t5);

                      case 37:
                        _context9.prev = 37;
                        _context9.t6 = resolve;
                        _context9.next = 41;
                        return snapshot();

                      case 41:
                        _context9.t7 = _context9.sent;
                        return _context9.abrupt("return", (0, _context9.t6)(_context9.t7));

                      case 44:
                        _context9.next = 47;
                        break;

                      case 46:
                        return _context9.abrupt("return", resolve(user));

                      case 47:
                        _context9.prev = 47;
                        _context9.t8 = execService;
                        _context9.t9 = discoveryService;
                        _context9.t10 = accountProofData;
                        _context9.next = 53;
                        return makeConfig(discoveryService);

                      case 53:
                        _context9.t11 = _context9.sent;
                        _context9.t12 = opts;
                        _context9.t13 = {
                          service: _context9.t9,
                          msg: _context9.t10,
                          config: _context9.t11,
                          opts: _context9.t12
                        };
                        _context9.next = 58;
                        return (0, _context9.t8)(_context9.t13);

                      case 58:
                        _response = _context9.sent;
                        _context9.t14 = utilActor.send;
                        _context9.t15 = NAME;
                        _context9.t16 = SET_CURRENT_USER;
                        _context9.next = 64;
                        return buildUser(_response);

                      case 64:
                        _context9.t17 = _context9.sent;
                        (0, _context9.t14)(_context9.t15, _context9.t16, _context9.t17);
                        _context9.next = 71;
                        break;

                      case 68:
                        _context9.prev = 68;
                        _context9.t18 = _context9["catch"](47);
                        console.error("Error while authenticating", _context9.t18);

                      case 71:
                        _context9.prev = 71;
                        _context9.t19 = resolve;
                        _context9.next = 75;
                        return snapshot();

                      case 75:
                        _context9.t20 = _context9.sent;
                        (0, _context9.t19)(_context9.t20);
                        return _context9.finish(71);

                      case 78:
                      case "end":
                        return _context9.stop();
                    }
                  }
                }, _callee9, null, [[9, 15], [21, 34, 37, 44], [47, 68, 71, 78]]);
              }));

              return function (_x14, _x15) {
                return _ref12.apply(this, arguments);
              };
            }()));

          case 5:
          case "end":
            return _context10.stop();
        }
      }
    }, _callee10);
  }));
  return _authenticate.apply(this, arguments);
}

function unauthenticate$1() {
  spawnCurrentUser();
  utilActor.send(NAME, DEL_CURRENT_USER);
}

var normalizePreAuthzResponse = function normalizePreAuthzResponse(authz) {
  return {
    f_type: "PreAuthzResponse",
    f_vsn: "1.0.0",
    proposer: (authz || {}).proposer,
    payer: (authz || {}).payer || [],
    authorization: (authz || {}).authorization || []
  };
};

function resolvePreAuthz(authz) {
  var resp = normalizePreAuthzResponse(authz);
  var axs = [];
  if (resp.proposer != null) axs.push(["PROPOSER", resp.proposer]);

  var _iterator = _createForOfIteratorHelper__default["default"](resp.payer || []),
      _step;

  try {
    for (_iterator.s(); !(_step = _iterator.n()).done;) {
      var az = _step.value;
      axs.push(["PAYER", az]);
    }
  } catch (err) {
    _iterator.e(err);
  } finally {
    _iterator.f();
  }

  var _iterator2 = _createForOfIteratorHelper__default["default"](resp.authorization || []),
      _step2;

  try {
    for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
      var _az = _step2.value;
      axs.push(["AUTHORIZER", _az]);
    }
  } catch (err) {
    _iterator2.e(err);
  } finally {
    _iterator2.f();
  }

  var result = axs.map(function (_ref8) {
    var _ref9 = _slicedToArray__default["default"](_ref8, 2),
        role = _ref9[0],
        az = _ref9[1];

    return {
      tempId: [az.identity.address, az.identity.keyId].join("|"),
      addr: az.identity.address,
      keyId: az.identity.keyId,
      signingFunction: function signingFunction(signable) {
        return execService({
          service: az,
          msg: signable
        });
      },
      role: {
        proposer: role === "PROPOSER",
        payer: role === "PAYER",
        authorizer: role === "AUTHORIZER"
      }
    };
  });
  return result;
}

function authorization(_x11) {
  return _authorization.apply(this, arguments);
}

function _authorization() {
  _authorization = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee13(account) {
    return _regeneratorRuntime__default["default"].wrap(function _callee13$(_context13) {
      while (1) {
        switch (_context13.prev = _context13.next) {
          case 0:
            spawnCurrentUser();
            return _context13.abrupt("return", _objectSpread__default["default"](_objectSpread__default["default"]({}, account), {}, {
              tempId: "CURRENT_USER",
              resolve: function resolve(account, preSignable) {
                return _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee12() {
                  var user, authz, preAuthz, windowRef;
                  return _regeneratorRuntime__default["default"].wrap(function _callee12$(_context12) {
                    while (1) {
                      switch (_context12.prev = _context12.next) {
                        case 0:
                          _context12.next = 2;
                          return authenticate$1({
                            redir: true
                          });

                        case 2:
                          user = _context12.sent;
                          authz = serviceOfType(user.services, "authz");
                          preAuthz = serviceOfType(user.services, "pre-authz");

                          if (!preAuthz) {
                            _context12.next = 11;
                            break;
                          }

                          _context12.t0 = resolvePreAuthz;
                          _context12.next = 9;
                          return execService({
                            service: preAuthz,
                            msg: preSignable
                          });

                        case 9:
                          _context12.t1 = _context12.sent;
                          return _context12.abrupt("return", (0, _context12.t0)(_context12.t1));

                        case 11:
                          if (!authz) {
                            _context12.next = 14;
                            break;
                          }

                          if (isMobile() && authz.method === "WC/RPC") {
                            windowRef = window.open("", "_blank");
                          }

                          return _context12.abrupt("return", _objectSpread__default["default"](_objectSpread__default["default"]({}, account), {}, {
                            tempId: "CURRENT_USER",
                            resolve: null,
                            addr: utilAddress.sansPrefix(authz.identity.address),
                            keyId: authz.identity.keyId,
                            sequenceNum: null,
                            signature: null,
                            signingFunction: function signingFunction(signable) {
                              return _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee11() {
                                return _regeneratorRuntime__default["default"].wrap(function _callee11$(_context11) {
                                  while (1) {
                                    switch (_context11.prev = _context11.next) {
                                      case 0:
                                        _context11.t0 = normalizeCompositeSignature;
                                        _context11.next = 3;
                                        return execService({
                                          service: authz,
                                          msg: signable,
                                          opts: {
                                            includeOlderJsonRpcCall: true,
                                            windowRef: windowRef
                                          }
                                        });

                                      case 3:
                                        _context11.t1 = _context11.sent;
                                        return _context11.abrupt("return", (0, _context11.t0)(_context11.t1));

                                      case 5:
                                      case "end":
                                        return _context11.stop();
                                    }
                                  }
                                }, _callee11);
                              }))();
                            }
                          }));

                        case 14:
                          throw new Error("No Authz or PreAuthz Service configured for CURRENT_USER");

                        case 15:
                        case "end":
                          return _context12.stop();
                      }
                    }
                  }, _callee12);
                }))();
              }
            }));

          case 2:
          case "end":
            return _context13.stop();
        }
      }
    }, _callee13);
  }));
  return _authorization.apply(this, arguments);
}

function subscribe(callback) {
  spawnCurrentUser();
  var EXIT = "@EXIT";
  var self = utilActor.spawn( /*#__PURE__*/function () {
    var _ref10 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee7(ctx) {
      var letter;
      return _regeneratorRuntime__default["default"].wrap(function _callee7$(_context7) {
        while (1) {
          switch (_context7.prev = _context7.next) {
            case 0:
              ctx.send(NAME, utilActor.SUBSCRIBE);

            case 1:

              _context7.next = 4;
              return ctx.receive();

            case 4:
              letter = _context7.sent;

              if (!(letter.tag === EXIT)) {
                _context7.next = 8;
                break;
              }

              ctx.send(NAME, utilActor.UNSUBSCRIBE);
              return _context7.abrupt("return");

            case 8:
              callback(letter.data);
              _context7.next = 1;
              break;

            case 11:
            case "end":
              return _context7.stop();
          }
        }
      }, _callee7);
    }));

    return function (_x12) {
      return _ref10.apply(this, arguments);
    };
  }());
  return function () {
    return utilActor.send(self, EXIT);
  };
}

function snapshot() {
  spawnCurrentUser();
  return utilActor.send(NAME, SNAPSHOT, null, {
    expectReply: true,
    timeout: 0
  });
}

function resolveArgument() {
  return _resolveArgument.apply(this, arguments);
}

function _resolveArgument() {
  _resolveArgument = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee15() {
    var _yield$authenticate, addr;

    return _regeneratorRuntime__default["default"].wrap(function _callee15$(_context15) {
      while (1) {
        switch (_context15.prev = _context15.next) {
          case 0:
            _context15.next = 2;
            return authenticate$1();

          case 2:
            _yield$authenticate = _context15.sent;
            addr = _yield$authenticate.addr;
            return _context15.abrupt("return", sdk.arg(utilAddress.withPrefix(addr), t__namespace.Address));

          case 5:
          case "end":
            return _context15.stop();
        }
      }
    }, _callee15);
  }));
  return _resolveArgument.apply(this, arguments);
}

var makeSignable = function makeSignable(msg) {
  utilInvariant.invariant(/^[0-9a-f]+$/i.test(msg), "Message must be a hex string");
  return {
    message: msg
  };
};

function signUserMessage(_x13) {
  return _signUserMessage.apply(this, arguments);
}

function _signUserMessage() {
  _signUserMessage = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee16(msg) {
    var user, signingService, response;
    return _regeneratorRuntime__default["default"].wrap(function _callee16$(_context16) {
      while (1) {
        switch (_context16.prev = _context16.next) {
          case 0:
            spawnCurrentUser();
            _context16.next = 3;
            return authenticate$1({
              redir: true
            });

          case 3:
            user = _context16.sent;
            signingService = serviceOfType(user.services, "user-signature");
            utilInvariant.invariant(signingService, "Current user must have authorized a signing service.");
            _context16.prev = 6;
            _context16.next = 9;
            return execService({
              service: signingService,
              msg: makeSignable(msg)
            });

          case 9:
            response = _context16.sent;

            if (!Array.isArray(response)) {
              _context16.next = 14;
              break;
            }

            return _context16.abrupt("return", response.map(function (compSigs) {
              return normalizeCompositeSignature(compSigs);
            }));

          case 14:
            return _context16.abrupt("return", [normalizeCompositeSignature(response)]);

          case 15:
            _context16.next = 20;
            break;

          case 17:
            _context16.prev = 17;
            _context16.t0 = _context16["catch"](6);
            return _context16.abrupt("return", _context16.t0);

          case 20:
          case "end":
            return _context16.stop();
        }
      }
    }, _callee16, null, [[6, 17]]);
  }));
  return _signUserMessage.apply(this, arguments);
}

var currentUser = function currentUser() {
  return {
    authenticate: authenticate$1,
    unauthenticate: unauthenticate$1,
    authorization: authorization,
    signUserMessage: signUserMessage,
    subscribe: subscribe,
    snapshot: snapshot,
    resolveArgument: resolveArgument
  };
};

currentUser.authenticate = authenticate$1;
currentUser.unauthenticate = unauthenticate$1;
currentUser.authorization = authorization;
currentUser.signUserMessage = signUserMessage;
currentUser.subscribe = subscribe;
currentUser.snapshot = snapshot;
currentUser.resolveArgument = resolveArgument;

/** As the current user Mutate the Flow Blockchain
 *
 *  @arg {Object} opts - Mutation Options and configuration
 *  @arg {string} opts.cadence - Cadence Transaction used to mutate Flow
 *  @arg {ArgsFn} opts.args - Arguments passed to cadence transaction
 *  @arg {Object} opts.template - Interaction Template for a transaction
 *  @arg {number} opts.limit - Compute Limit for transaction
 *  @returns {string} Transaction Id
 *
 *  Where:
 *    @callback ArgsFn
 *    @arg {ArgFn}  arg - Argument function to define a single argument
 *    @arg {Object} t   - Cadence Types object used to define the type
 *    @returns {args[]}
 *
 *    @callback ArgFn
 *    @arg {Any}  value - the value of the argument
 *    @arg {Type} type  - the cadence type of the value
 *    @returns {arg}
 *
 *  Example:
 *    fcl.mutate({
 *      cadence: `
 *        transaction(a: Int, b: Int, c: Address) {
 *          prepare(acct: AuthAccount) {
 *            log(acct)
 *            log(a)
 *            log(b)
 *            log(c)
 *          }
 *        }
 *      `,
 *      args: (arg, t) => [
 *        arg(6, t.Int),
 *        arg(7, t.Int),
 *        arg("0xba1132bc08f82fe2", t.Address),
 *      ],
 *    })
 *
 *
 *  Options:
 *    type Options = {
 *      template: InteractionTemplate | String // InteractionTemplate or url to one
 *      cadence: String!,
 *      args: (arg, t) => Array<Arg>,
 *      limit: Number,
 *      authz: AuthzFn, // will overload the trinity of signatory roles
 *      proposer: AuthzFn, // will overload the proposer signatory role
 *      payer: AuthzFn, // will overload the payer signatory role
 *      authorizations: [AuthzFn], // an array of authorization functions used as authorizations signatory roles
 *    }
 */

function mutate() {
  return _mutate.apply(this, arguments);
}

function _mutate() {
  _mutate = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2() {
    var opts,
        txid,
        authz,
        _args2 = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            opts = _args2.length > 0 && _args2[0] !== undefined ? _args2[0] : {};
            _context2.prev = 1;
            _context2.next = 4;
            return preMutate(opts);

          case 4:
            _context2.next = 6;
            return prepTemplateOpts(opts);

          case 6:
            opts = _context2.sent;
            _context2.next = 9;
            return sdk__namespace.config().get("fcl.authz", currentUser().authorization);

          case 9:
            authz = _context2.sent;
            txid = sdk__namespace.config().overload(opts.dependencies || {}, /*#__PURE__*/_asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee() {
              return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
                while (1) {
                  switch (_context.prev = _context.next) {
                    case 0:
                      return _context.abrupt("return", // prettier-ignore
                      sdk__namespace.send([sdk__namespace.transaction(opts.cadence), sdk__namespace.args(normalizeArgs(opts.args || [])), opts.limit && isNumber(opts.limit) && sdk__namespace.limit(opts.limit), // opts.proposer > opts.authz > authz
                      sdk__namespace.proposer(opts.proposer || opts.authz || authz), // opts.payer > opts.authz > authz
                      sdk__namespace.payer(opts.payer || opts.authz || authz), // opts.authorizations > [opts.authz > authz]
                      sdk__namespace.authorizations(opts.authorizations || [opts.authz || authz])]).then(sdk__namespace.decode));

                    case 1:
                    case "end":
                      return _context.stop();
                  }
                }
              }, _callee);
            })));
            return _context2.abrupt("return", txid);

          case 14:
            _context2.prev = 14;
            _context2.t0 = _context2["catch"](1);
            throw _context2.t0;

          case 17:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2, null, [[1, 14]]);
  }));
  return _mutate.apply(this, arguments);
}

var onMessageFromFCL = function onMessageFromFCL(messageType) {
  var cb = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : function () {};

  var buildData = function buildData(data) {
    var _data$body;

    if (data.deprecated) console.warn("DEPRECATION NOTICE", data.deprecated.message);
    data === null || data === void 0 ? true : (_data$body = data.body) === null || _data$body === void 0 ? true : delete _data$body.interaction;
    return data;
  };

  var internal = function internal(e) {
    var data = e.data;
    if (_typeof__default["default"](data) !== "object") return;
    if (_typeof__default["default"](data) == null) return;
    if (data.type !== messageType) return;
    cb(buildData(data));
  };

  window.addEventListener("message", internal);
  return function () {
    return window.removeEventListener("message", internal);
  };
};

var sendMsgToFCL = function sendMsgToFCL(type) {
  var msg = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};

  if (window.location !== window.parent.location) {
    window.parent.postMessage(_objectSpread__default["default"](_objectSpread__default["default"]({}, msg), {}, {
      type: type
    }), "*");
  } else if (window.opener) {
    window.opener.postMessage(_objectSpread__default["default"](_objectSpread__default["default"]({}, msg), {}, {
      type: type
    }), "*");
  } else {
    throw new Error("Unable to communicate with parent FCL instance");
  }
};
var ready = function ready(cb) {
  onMessageFromFCL("FCL:VIEW:READY:RESPONSE", cb);
  sendMsgToFCL("FCL:VIEW:READY");
};
var close = function close() {
  sendMsgToFCL("FCL:VIEW:CLOSE");
};
var approve = function approve(data) {
  sendMsgToFCL("FCL:VIEW:RESPONSE", {
    f_type: "PollingResponse",
    f_vsn: "1.0.0",
    status: "APPROVED",
    reason: null,
    data: data
  });
};
var decline = function decline(reason) {
  sendMsgToFCL("FCL:VIEW:RESPONSE", {
    f_type: "PollingResponse",
    f_vsn: "1.0.0",
    status: "DECLINED",
    reason: reason,
    data: null
  });
};
var redirect = function redirect(data) {
  sendMsgToFCL("FCL:VIEW:RESPONSE", {
    f_type: "PollingResponse",
    f_vsn: "1.0.0",
    status: "REDIRECT",
    reason: null,
    data: data
  });
};

function CompositeSignature(addr, keyId, signature) {
  this.f_type = COMPOSITE_SIGNATURE_PRAGMA.f_type;
  this.f_vsn = COMPOSITE_SIGNATURE_PRAGMA.f_vsn;
  this.addr = utilAddress.withPrefix(addr);
  this.keyId = Number(keyId);
  this.signature = signature;
}

var rightPaddedHexBuffer = function rightPaddedHexBuffer(value, pad) {
  return rlp.Buffer.from(value.padEnd(pad * 2, "0"), "hex");
};

var leftPaddedHexBuffer = function leftPaddedHexBuffer(value, pad) {
  return rlp.Buffer.from(value.padStart(pad * 2, "0"), "hex");
};

var addressBuffer = function addressBuffer(addr) {
  return leftPaddedHexBuffer(addr, 8);
};

var nonceBuffer = function nonceBuffer(nonce) {
  return rlp.Buffer.from(nonce, "hex");
};

var encodeAccountProof = function encodeAccountProof(_ref) {
  var address = _ref.address,
      nonce = _ref.nonce,
      appIdentifier = _ref.appIdentifier;
  var includeDomainTag = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : true;
  utilInvariant.invariant(address, "Encode Message For Provable Authn Error: address must be defined");
  utilInvariant.invariant(nonce, "Encode Message For Provable Authn Error: nonce must be defined");
  utilInvariant.invariant(appIdentifier, "Encode Message For Provable Authn Error: appIdentifier must be defined");
  utilInvariant.invariant(nonce.length >= 64, "Encode Message For Provable Authn Error: nonce must be minimum of 32 bytes");
  var ACCOUNT_PROOF_DOMAIN_TAG = rightPaddedHexBuffer(rlp.Buffer.from("FCL-ACCOUNT-PROOF-V0.0").toString("hex"), 32);

  if (includeDomainTag) {
    return rlp.Buffer.concat([ACCOUNT_PROOF_DOMAIN_TAG, rlp.encode([appIdentifier, addressBuffer(utilAddress.sansPrefix(address)), nonceBuffer(nonce)])]).toString("hex");
  }

  return rlp.encode([appIdentifier, addressBuffer(utilAddress.sansPrefix(address)), nonceBuffer(nonce)]).toString("hex");
};

function injectExtService(service) {
  if (service.type === "authn" && service.endpoint != null) {
    if (!Array.isArray(window.fcl_extensions)) {
      window.fcl_extensions = [];
    }

    window.fcl_extensions.push(service);
  } else {
    console.warn("Authn service is required");
  }
}

var index$2 = /*#__PURE__*/Object.freeze({
  __proto__: null,
  sendMsgToFCL: sendMsgToFCL,
  ready: ready,
  close: close,
  approve: approve,
  decline: decline,
  redirect: redirect,
  onMessageFromFCL: onMessageFromFCL,
  encodeMessageFromSignable: sdk.encodeMessageFromSignable,
  CompositeSignature: CompositeSignature,
  encodeAccountProof: encodeAccountProof,
  injectExtService: injectExtService
});

var ACCOUNT_PROOF = "ACCOUNT_PROOF";
var USER_SIGNATURE = "USER_SIGNATURE";
var validateArgs = function validateArgs(args) {
  if (args.appIdentifier) {
    var appIdentifier = args.appIdentifier,
        address = args.address,
        nonce = args.nonce,
        signatures = args.signatures;
    utilInvariant.invariant(isString(appIdentifier), "verifyAccountProof({ appIdentifier }) -- appIdentifier must be a string");
    utilInvariant.invariant(isString(address) && utilAddress.sansPrefix(address).length === 16, "verifyAccountProof({ address }) -- address must be a valid address");
    utilInvariant.invariant(/^[0-9a-f]+$/i.test(nonce), "nonce must be a hex string");
    utilInvariant.invariant(Array.isArray(signatures) && signatures.every(function (sig, i, arr) {
      return sig.f_type === "CompositeSignature";
    }), "Must include an Array of CompositeSignatures to verify");
    utilInvariant.invariant(signatures.map(function (cs) {
      return cs.addr;
    }).every(function (addr, i, arr) {
      return addr === arr[0];
    }), "User signatures to be verified must be from a single account address");
    return true;
  } else {
    var message = args.message,
        _address = args.address,
        compSigs = args.compSigs;
    utilInvariant.invariant(/^[0-9a-f]+$/i.test(message), "Signed message must be a hex string");
    utilInvariant.invariant(isString(_address) && utilAddress.sansPrefix(_address).length === 16, "verifyUserSignatures({ address }) -- address must be a valid address");
    utilInvariant.invariant(Array.isArray(compSigs) && compSigs.every(function (sig, i, arr) {
      return sig.f_type === "CompositeSignature";
    }), "Must include an Array of CompositeSignatures to verify");
    utilInvariant.invariant(compSigs.map(function (cs) {
      return cs.addr;
    }).every(function (addr, i, arr) {
      return addr === arr[0];
    }), "User signatures to be verified must be from a single account address");
    return true;
  }
};

var getVerifySignaturesScript = /*#__PURE__*/function () {
  var _ref = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(sig, opts) {
    var verifyFunction, network, fclCryptoContract;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            verifyFunction = sig === "ACCOUNT_PROOF" ? "verifyAccountProofSignatures" : "verifyUserSignatures";
            _context.next = 3;
            return config.config.get("flow.network");

          case 3:
            network = _context.sent;

            if (network) {
              _context.next = 9;
              break;
            }

            _context.next = 7;
            return config.config.get("env");

          case 7:
            network = _context.sent;
            if (network) utilLogger.log.deprecate({
              pkg: "FCL",
              subject: 'Using the "env" configuration key for specifying the flow network',
              message: 'Please use "flow.network" instead.',
              transition: "https://github.com/onflow/flow-js-sdk/blob/master/packages/fcl/TRANSITIONS.md#0001-deprecate-env-config-key"
            });

          case 9:
            utilInvariant.invariant(opts.fclCryptoContract || network === "testnet" || network === "mainnet", "${verifyFunction}({ fclCryptoContract }) -- config.flow.network must be specified (testnet || mainnet) or contract address provided via opts.fclCryptoContract");

            if (opts.fclCryptoContract) {
              fclCryptoContract = opts.fclCryptoContract;
            } else {
              fclCryptoContract = network === "testnet" ? "0x74daa6f9c7ef24b1" : "0xb4b82a1c9d21d284";
            }

            return _context.abrupt("return", "\n      import FCLCrypto from ".concat(fclCryptoContract, "\n\n      pub fun main(\n          address: Address, \n          message: String, \n          keyIndices: [Int], \n          signatures: [String]\n      ): Bool {\n        return FCLCrypto.").concat(verifyFunction, "(address: address, message: message, keyIndices: keyIndices, signatures: signatures)\n      }\n    "));

          case 12:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));

  return function getVerifySignaturesScript(_x, _x2) {
    return _ref.apply(this, arguments);
  };
}();
/**
 * Verify a valid account proof signature or signatures for an account on Flow.
 *
 * @param {string} appIdentifier - A message string in hexadecimal format
 * @param {Object} accountProofData - An object consisting of address, nonce, and signatures
 * @param {string} accountProofData.address - A Flow account address
 * @param {string} accountProofData.nonce - A random string in hexadecimal format (minimum 32 bytes in total, i.e 64 hex characters)
 * @param {Object[]} accountProofData.signatures - An array of composite signatures to verify
 * @param {Object} [opts={}] - Options object
 * @param {string} opts.fclCryptoContract - An optional override Flow account address where the FCLCrypto contract is deployed
 * @return {bool}
 *
 * @example
 *
 *  const accountProofData = {
 *   address: "0x123",
 *   nonce: "F0123"
 *   signatures: [{f_type: "CompositeSignature", f_vsn: "1.0.0", addr: "0x123", keyId: 0, signature: "abc123"}],
 *  }
 *
 *  const isValid = await fcl.AppUtils.verifyAccountProof(
 *    "AwesomeAppId",
 *    accountProofData,
 *    {fclCryptoContract}
 *  )
 */


function verifyAccountProof(_x3, _x4) {
  return _verifyAccountProof.apply(this, arguments);
}
/**
 * Verify a valid signature/s for an account on Flow.
 *
 * @param {string} msg - A message string in hexadecimal format
 * @param {Array} compSigs - An array of Composite Signatures
 * @param {string} compSigs[].addr - The account address
 * @param {number} compSigs[].keyId - The account keyId
 * @param {string} compSigs[].signature - The signature to verify
 * @param {Object} [opts={}] - Options object
 * @param {string} opts.fclCryptoContract - An optional override of Flow account address where the FCLCrypto contract is deployed
 * @return {bool}
 *
 * @example
 *
 *  const isValid = await fcl.AppUtils.verifyUserSignatures(
 *    Buffer.from('FOO').toString("hex"),
 *    [{f_type: "CompositeSignature", f_vsn: "1.0.0", addr: "0x123", keyId: 0, signature: "abc123"}],
 *    {fclCryptoContract}
 *  )
 */

function _verifyAccountProof() {
  _verifyAccountProof = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(appIdentifier, _ref2) {
    var address,
        nonce,
        signatures,
        opts,
        message,
        signaturesArr,
        keyIndices,
        _iterator,
        _step,
        el,
        _args2 = arguments;

    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            address = _ref2.address, nonce = _ref2.nonce, signatures = _ref2.signatures;
            opts = _args2.length > 2 && _args2[2] !== undefined ? _args2[2] : {};
            validateArgs({
              appIdentifier: appIdentifier,
              address: address,
              nonce: nonce,
              signatures: signatures
            });
            message = encodeAccountProof({
              address: address,
              nonce: nonce,
              appIdentifier: appIdentifier
            }, false);
            signaturesArr = [];
            keyIndices = [];
            _iterator = _createForOfIteratorHelper__default["default"](signatures);

            try {
              for (_iterator.s(); !(_step = _iterator.n()).done;) {
                el = _step.value;
                signaturesArr.push(el.signature);
                keyIndices.push(el.keyId.toString());
              }
            } catch (err) {
              _iterator.e(err);
            } finally {
              _iterator.f();
            }

            _context2.t0 = query;
            _context2.next = 11;
            return getVerifySignaturesScript(ACCOUNT_PROOF, opts);

          case 11:
            _context2.t1 = _context2.sent;

            _context2.t2 = function args(arg, t) {
              return [arg(utilAddress.withPrefix(address), t.Address), arg(message, t.String), arg(keyIndices, t.Array(t.Int)), arg(signaturesArr, t.Array(t.String))];
            };

            _context2.t3 = {
              cadence: _context2.t1,
              args: _context2.t2
            };
            return _context2.abrupt("return", (0, _context2.t0)(_context2.t3));

          case 15:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _verifyAccountProof.apply(this, arguments);
}

function verifyUserSignatures$1(_x5, _x6) {
  return _verifyUserSignatures.apply(this, arguments);
}

function _verifyUserSignatures() {
  _verifyUserSignatures = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(message, compSigs) {
    var opts,
        address,
        signaturesArr,
        keyIndices,
        _iterator2,
        _step2,
        el,
        _args3 = arguments;

    return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
      while (1) {
        switch (_context3.prev = _context3.next) {
          case 0:
            opts = _args3.length > 2 && _args3[2] !== undefined ? _args3[2] : {};
            address = utilAddress.withPrefix(compSigs[0].addr);
            validateArgs({
              message: message,
              address: address,
              compSigs: compSigs
            });
            signaturesArr = [];
            keyIndices = [];
            _iterator2 = _createForOfIteratorHelper__default["default"](compSigs);

            try {
              for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
                el = _step2.value;
                signaturesArr.push(el.signature);
                keyIndices.push(el.keyId.toString());
              }
            } catch (err) {
              _iterator2.e(err);
            } finally {
              _iterator2.f();
            }

            _context3.t0 = query;
            _context3.next = 10;
            return getVerifySignaturesScript(USER_SIGNATURE, opts);

          case 10:
            _context3.t1 = _context3.sent;

            _context3.t2 = function args(arg, t) {
              return [arg(address, t.Address), arg(message, t.String), arg(keyIndices, t.Array(t.Int)), arg(signaturesArr, t.Array(t.String))];
            };

            _context3.t3 = {
              cadence: _context3.t1,
              args: _context3.t2
            };
            return _context3.abrupt("return", (0, _context3.t0)(_context3.t3));

          case 14:
          case "end":
            return _context3.stop();
        }
      }
    }, _callee3);
  }));
  return _verifyUserSignatures.apply(this, arguments);
}

var index$1 = /*#__PURE__*/Object.freeze({
  __proto__: null,
  verifyAccountProof: verifyAccountProof,
  verifyUserSignatures: verifyUserSignatures$1
});

/**
 * Verify a valid signature/s for an account on Flow.
 *
 * @deprecated since version '1.0.0-alpha.0', use AppUtils.verifyUserSignatures instead
 *
 */

var verifyUserSignatures = utilLogger.log.deprecate({
  pkg: "FCL",
  subject: "fcl.verifyUserSignatures()",
  message: "Please use fcl.AppUtils.verifyUserSignatures()",
  callback: function verifyUserSignatures(message, compSigs) {
    return verifyUserSignatures$1(message, compSigs);
  }
});

var serialize = /*#__PURE__*/function () {
  var _ref = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee() {
    var args,
        opts,
        resolveFunction,
        _args = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            args = _args.length > 0 && _args[0] !== undefined ? _args[0] : [];
            opts = _args.length > 1 && _args[1] !== undefined ? _args[1] : {};
            _context.next = 4;
            return sdk.config.first(["sdk.resolve"], opts.resolve || sdk.resolve);

          case 4:
            resolveFunction = _context.sent;

            if (!Array.isArray(args)) {
              _context.next = 9;
              break;
            }

            _context.next = 8;
            return sdk.pipe(sdk.interaction(), args);

          case 8:
            args = _context.sent;

          case 9:
            _context.t0 = JSON;
            _context.t1 = sdk.createSignableVoucher;
            _context.next = 13;
            return resolveFunction(args);

          case 13:
            _context.t2 = _context.sent;
            _context.t3 = (0, _context.t1)(_context.t2);
            return _context.abrupt("return", _context.t0.stringify.call(_context.t0, _context.t3, null, 2));

          case 16:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));

  return function serialize() {
    return _ref.apply(this, arguments);
  };
}();

var _HANDLERS$1;
var RATE$1 = 2500;
var POLL = "POLL";

var fetchTxStatus = /*#__PURE__*/function () {
  var _ref = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(transactionId) {
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            return _context.abrupt("return", sdk.send([sdk.getTransactionStatus(transactionId)]).then(sdk.decode));

          case 1:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));

  return function fetchTxStatus(_x) {
    return _ref.apply(this, arguments);
  };
}();

var isExpired = function isExpired(tx) {
  return tx.status === 5;
};

var isSealed = function isSealed(tx) {
  return tx.status >= 4;
};

var isExecuted = function isExecuted(tx) {
  return tx.status >= 3;
};

var isFinalized = function isFinalized(tx) {
  return tx.status >= 2;
};

var isPending = function isPending(tx) {
  return tx.status >= 1;
};

var isUnknown = function isUnknown(tx) {
  return tx.status >= 0;
};

var isDiff = function isDiff(cur, next) {
  return JSON.stringify(cur) !== JSON.stringify(next);
};

var HANDLERS$1 = (_HANDLERS$1 = {}, _defineProperty__default["default"](_HANDLERS$1, utilActor.INIT, function () {
  var _ref2 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(ctx) {
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            ctx.sendSelf(POLL);

          case 1:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));

  return function (_x2) {
    return _ref2.apply(this, arguments);
  };
}()), _defineProperty__default["default"](_HANDLERS$1, utilActor.SUBSCRIBE, function (ctx, letter) {
  ctx.subscribe(letter.from);
  ctx.send(letter.from, utilActor.UPDATED, ctx.all());
}), _defineProperty__default["default"](_HANDLERS$1, utilActor.UNSUBSCRIBE, function (ctx, letter) {
  ctx.unsubscribe(letter.from);
}), _defineProperty__default["default"](_HANDLERS$1, utilActor.SNAPSHOT, function () {
  var _ref3 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(ctx, letter) {
    return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
      while (1) {
        switch (_context3.prev = _context3.next) {
          case 0:
            letter.reply(ctx.all());

          case 1:
          case "end":
            return _context3.stop();
        }
      }
    }, _callee3);
  }));

  return function (_x3, _x4) {
    return _ref3.apply(this, arguments);
  };
}()), _defineProperty__default["default"](_HANDLERS$1, POLL, function () {
  var _ref4 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee4(ctx) {
    var tx;
    return _regeneratorRuntime__default["default"].wrap(function _callee4$(_context4) {
      while (1) {
        switch (_context4.prev = _context4.next) {
          case 0:
            _context4.prev = 0;
            _context4.next = 3;
            return fetchTxStatus(ctx.self());

          case 3:
            tx = _context4.sent;
            _context4.next = 9;
            break;

          case 6:
            _context4.prev = 6;
            _context4.t0 = _context4["catch"](0);
            return _context4.abrupt("return", ctx.fatalError(_context4.t0));

          case 9:
            if (!isSealed(tx)) setTimeout(function () {
              return ctx.sendSelf(POLL);
            }, RATE$1);
            if (isDiff(ctx.all(), tx)) ctx.broadcast(utilActor.UPDATED, tx);
            ctx.merge(tx);

          case 12:
          case "end":
            return _context4.stop();
        }
      }
    }, _callee4, null, [[0, 6]]);
  }));

  return function (_x5) {
    return _ref4.apply(this, arguments);
  };
}()), _HANDLERS$1);

var scoped = function scoped(transactionId) {
  if (_typeof__default["default"](transactionId) === "object") transactionId = transactionId.transactionId;
  if (transactionId == null) throw new Error("transactionId required");
  return transactionId;
};

var spawnTransaction = function spawnTransaction(transactionId) {
  return utilActor.spawn(HANDLERS$1, scoped(transactionId));
};

function transaction(transactionId) {
  function snapshot() {
    return utilActor.snapshoter(transactionId, spawnTransaction);
  }

  function subscribe(callback) {
    return utilActor.subscriber(scoped(transactionId), spawnTransaction, callback);
  }

  function once(predicate) {
    return function innerOnce() {
      var opts = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
      var suppress = opts.suppress || false;
      return new Promise(function (resolve, reject) {
        var unsub = subscribe(function (txStatus, error) {
          if ((error || txStatus.statusCode) && !suppress) {
            reject(error || txStatus.errorMessage);
            unsub();
          } else if (predicate(txStatus)) {
            resolve(txStatus);
            unsub();
          }
        });
      });
    };
  }

  return {
    snapshot: snapshot,
    subscribe: subscribe,
    onceFinalized: once(isFinalized),
    onceExecuted: once(isExecuted),
    onceSealed: once(isSealed)
  };
}
transaction.isUnknown = isUnknown;
transaction.isPending = isPending;
transaction.isFinalized = isFinalized;
transaction.isExecuted = isExecuted;
transaction.isSealed = isSealed;
transaction.isExpired = isExpired;

var _HANDLERS;
var RATE = 10000;
var UPDATED = "UPDATED";
var TICK = "TICK";
var HIGH_WATER_MARK = "hwm";

var scheduleTick = /*#__PURE__*/function () {
  var _ref = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ctx) {
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            _context.t0 = setTimeout;

            _context.t1 = function () {
              return ctx.sendSelf(TICK);
            };

            _context.next = 4;
            return sdk.config().get("fcl.eventPollRate", RATE);

          case 4:
            _context.t2 = _context.sent;
            return _context.abrupt("return", (0, _context.t0)(_context.t1, _context.t2));

          case 6:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));

  return function scheduleTick(_x) {
    return _ref.apply(this, arguments);
  };
}();

var HANDLERS = (_HANDLERS = {}, _defineProperty__default["default"](_HANDLERS, TICK, function () {
  var _ref2 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(ctx) {
    var hwm, next, data, _iterator, _step, d;

    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            if (ctx.hasSubs()) {
              _context2.next = 2;
              break;
            }

            return _context2.abrupt("return");

          case 2:
            hwm = ctx.get(HIGH_WATER_MARK);

            if (!(hwm == null)) {
              _context2.next = 18;
              break;
            }

            _context2.t0 = ctx;
            _context2.t1 = HIGH_WATER_MARK;
            _context2.next = 8;
            return sdk.block();

          case 8:
            _context2.t2 = _context2.sent;

            _context2.t0.put.call(_context2.t0, _context2.t1, _context2.t2);

            _context2.t3 = ctx;
            _context2.t4 = TICK;
            _context2.next = 14;
            return scheduleTick(ctx);

          case 14:
            _context2.t5 = _context2.sent;

            _context2.t3.put.call(_context2.t3, _context2.t4, _context2.t5);

            _context2.next = 34;
            break;

          case 18:
            _context2.next = 20;
            return sdk.block();

          case 20:
            next = _context2.sent;
            ctx.put(HIGH_WATER_MARK, next);

            if (!(hwm.height < next.height)) {
              _context2.next = 28;
              break;
            }

            _context2.next = 25;
            return sdk.send([sdk.getEventsAtBlockHeightRange(ctx.self(), hwm.height + 1, next.height)]).then(sdk.decode);

          case 25:
            data = _context2.sent;
            _iterator = _createForOfIteratorHelper__default["default"](data);

            try {
              for (_iterator.s(); !(_step = _iterator.n()).done;) {
                d = _step.value;
                ctx.broadcast(UPDATED, d.data);
              }
            } catch (err) {
              _iterator.e(err);
            } finally {
              _iterator.f();
            }

          case 28:
            _context2.t6 = ctx;
            _context2.t7 = TICK;
            _context2.next = 32;
            return scheduleTick(ctx);

          case 32:
            _context2.t8 = _context2.sent;

            _context2.t6.put.call(_context2.t6, _context2.t7, _context2.t8);

          case 34:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));

  return function (_x2) {
    return _ref2.apply(this, arguments);
  };
}()), _defineProperty__default["default"](_HANDLERS, utilActor.SUBSCRIBE, function () {
  var _ref3 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(ctx, letter) {
    return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
      while (1) {
        switch (_context3.prev = _context3.next) {
          case 0:
            if (ctx.hasSubs()) {
              _context3.next = 7;
              break;
            }

            _context3.t0 = ctx;
            _context3.t1 = TICK;
            _context3.next = 5;
            return scheduleTick(ctx);

          case 5:
            _context3.t2 = _context3.sent;

            _context3.t0.put.call(_context3.t0, _context3.t1, _context3.t2);

          case 7:
            ctx.subscribe(letter.from);

          case 8:
          case "end":
            return _context3.stop();
        }
      }
    }, _callee3);
  }));

  return function (_x3, _x4) {
    return _ref3.apply(this, arguments);
  };
}()), _defineProperty__default["default"](_HANDLERS, utilActor.UNSUBSCRIBE, function (ctx, letter) {
  ctx.unsubscribe(letter.from);

  if (!ctx.hasSubs()) {
    clearTimeout(ctx.get(TICK));
    ctx["delete"](TICK);
    ctx["delete"](HIGH_WATER_MARK);
  }
}), _HANDLERS);

var spawnEvents = function spawnEvents(key) {
  return utilActor.spawn(HANDLERS, key);
};

function events(key) {
  return {
    subscribe: function subscribe(callback) {
      return utilActor.subscriber(key, spawnEvents, callback);
    }
  };
}

var sha3 = {};

var sponge = {};

var permute = {};

var chi = {};

var copy = function copy(I, i) {
  return function (O, o) {
    var oi = o * 2;
    var ii = i * 2;
    O[oi] = I[ii];
    O[oi + 1] = I[ii + 1];
  };
};

var copy_1 = copy;

(function (exports) {

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports["default"] = void 0;

  var _copy = _interopRequireDefault(copy_1);

  function _interopRequireDefault(obj) {
    return obj && obj.__esModule ? obj : {
      "default": obj
    };
  }

  var chi = function chi(_ref) {
    var A = _ref.A,
        C = _ref.C;

    for (var y = 0; y < 25; y += 5) {
      for (var x = 0; x < 5; x++) {
        (0, _copy["default"])(A, y + x)(C, x);
      }

      for (var _x = 0; _x < 5; _x++) {
        var xy = (y + _x) * 2;
        var x1 = (_x + 1) % 5 * 2;
        var x2 = (_x + 2) % 5 * 2;
        A[xy] ^= ~C[x1] & C[x2];
        A[xy + 1] ^= ~C[x1 + 1] & C[x2 + 1];
      }
    }
  };

  var _default = chi;
  exports["default"] = _default;
})(chi);

var iota = {};

var roundConstants = {};

(function (exports) {

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports["default"] = void 0;
  var ROUND_CONSTANTS = new Uint32Array([0, 1, 0, 32898, 2147483648, 32906, 2147483648, 2147516416, 0, 32907, 0, 2147483649, 2147483648, 2147516545, 2147483648, 32777, 0, 138, 0, 136, 0, 2147516425, 0, 2147483658, 0, 2147516555, 2147483648, 139, 2147483648, 32905, 2147483648, 32771, 2147483648, 32770, 2147483648, 128, 0, 32778, 2147483648, 2147483658, 2147483648, 2147516545, 2147483648, 32896, 0, 2147483649, 2147483648, 2147516424]);
  var _default = ROUND_CONSTANTS;
  exports["default"] = _default;
})(roundConstants);

(function (exports) {

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports["default"] = void 0;

  var _roundConstants = _interopRequireDefault(roundConstants);

  function _interopRequireDefault(obj) {
    return obj && obj.__esModule ? obj : {
      "default": obj
    };
  }

  var iota = function iota(_ref) {
    var A = _ref.A,
        roundIndex = _ref.roundIndex;
    var i = roundIndex * 2;
    A[0] ^= _roundConstants["default"][i];
    A[1] ^= _roundConstants["default"][i + 1];
  };

  var _default = iota;
  exports["default"] = _default;
})(iota);

var rhoPi = {};

var piShuffles = {};

(function (exports) {

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports["default"] = void 0;
  var PI_SHUFFLES = [10, 7, 11, 17, 18, 3, 5, 16, 8, 21, 24, 4, 15, 23, 19, 13, 12, 2, 20, 14, 22, 9, 6, 1];
  var _default = PI_SHUFFLES;
  exports["default"] = _default;
})(piShuffles);

var rhoOffsets = {};

(function (exports) {

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports["default"] = void 0;
  var RHO_OFFSETS = [1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 2, 14, 27, 41, 56, 8, 25, 43, 62, 18, 39, 61, 20, 44];
  var _default = RHO_OFFSETS;
  exports["default"] = _default;
})(rhoOffsets);

(function (exports) {

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports["default"] = void 0;

  var _piShuffles = _interopRequireDefault(piShuffles);

  var _rhoOffsets = _interopRequireDefault(rhoOffsets);

  var _copy = _interopRequireDefault(copy_1);

  function _interopRequireDefault(obj) {
    return obj && obj.__esModule ? obj : {
      "default": obj
    };
  }

  var rhoPi = function rhoPi(_ref) {
    var A = _ref.A,
        C = _ref.C,
        W = _ref.W;
    (0, _copy["default"])(A, 1)(W, 0);
    var H = 0;
    var L = 0;
    var Wi = 0;
    var ri = 32;

    for (var i = 0; i < 24; i++) {
      var j = _piShuffles["default"][i];
      var r = _rhoOffsets["default"][i];
      (0, _copy["default"])(A, j)(C, 0);
      H = W[0];
      L = W[1];
      ri = 32 - r;
      Wi = r < 32 ? 0 : 1;
      W[Wi] = H << r | L >>> ri;
      W[(Wi + 1) % 2] = L << r | H >>> ri;
      (0, _copy["default"])(W, 0)(A, j);
      (0, _copy["default"])(C, 0)(W, 0);
    }
  };

  var _default = rhoPi;
  exports["default"] = _default;
})(rhoPi);

var theta = {};

(function (exports) {

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports["default"] = void 0;

  var _copy = _interopRequireDefault(copy_1);

  function _interopRequireDefault(obj) {
    return obj && obj.__esModule ? obj : {
      "default": obj
    };
  }

  var theta = function theta(_ref) {
    var A = _ref.A,
        C = _ref.C,
        D = _ref.D,
        W = _ref.W;
    var H = 0;
    var L = 0;

    for (var x = 0; x < 5; x++) {
      var x20 = x * 2;
      var x21 = (x + 5) * 2;
      var x22 = (x + 10) * 2;
      var x23 = (x + 15) * 2;
      var x24 = (x + 20) * 2;
      C[x20] = A[x20] ^ A[x21] ^ A[x22] ^ A[x23] ^ A[x24];
      C[x20 + 1] = A[x20 + 1] ^ A[x21 + 1] ^ A[x22 + 1] ^ A[x23 + 1] ^ A[x24 + 1];
    }

    for (var _x = 0; _x < 5; _x++) {
      (0, _copy["default"])(C, (_x + 1) % 5)(W, 0);
      H = W[0];
      L = W[1];
      W[0] = H << 1 | L >>> 31;
      W[1] = L << 1 | H >>> 31;
      D[_x * 2] = C[(_x + 4) % 5 * 2] ^ W[0];
      D[_x * 2 + 1] = C[(_x + 4) % 5 * 2 + 1] ^ W[1];

      for (var y = 0; y < 25; y += 5) {
        A[(y + _x) * 2] ^= D[_x * 2];
        A[(y + _x) * 2 + 1] ^= D[_x * 2 + 1];
      }
    }
  };

  var _default = theta;
  exports["default"] = _default;
})(theta);

(function (exports) {

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports["default"] = void 0;

  var _chi = _interopRequireDefault(chi);

  var _iota = _interopRequireDefault(iota);

  var _rhoPi = _interopRequireDefault(rhoPi);

  var _theta = _interopRequireDefault(theta);

  function _interopRequireDefault(obj) {
    return obj && obj.__esModule ? obj : {
      "default": obj
    };
  }

  var permute = function permute() {
    var C = new Uint32Array(10);
    var D = new Uint32Array(10);
    var W = new Uint32Array(2);
    return function (A) {
      for (var roundIndex = 0; roundIndex < 24; roundIndex++) {
        (0, _theta["default"])({
          A: A,
          C: C,
          D: D,
          W: W
        });
        (0, _rhoPi["default"])({
          A: A,
          C: C,
          W: W
        });
        (0, _chi["default"])({
          A: A,
          C: C
        });
        (0, _iota["default"])({
          A: A,
          roundIndex: roundIndex
        });
      }

      C.fill(0);
      D.fill(0);
      W.fill(0);
    };
  };

  var _default = permute;
  exports["default"] = _default;
})(permute);

(function (exports) {

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports["default"] = void 0;
  var _buffer = require$$0__default["default"];

  var _permute = _interopRequireDefault(permute);

  function _interopRequireDefault(obj) {
    return obj && obj.__esModule ? obj : {
      "default": obj
    };
  }

  var xorWords = function xorWords(I, O) {
    for (var i = 0; i < I.length; i += 8) {
      var o = i / 4;
      O[o] ^= I[i + 7] << 24 | I[i + 6] << 16 | I[i + 5] << 8 | I[i + 4];
      O[o + 1] ^= I[i + 3] << 24 | I[i + 2] << 16 | I[i + 1] << 8 | I[i];
    }

    return O;
  };

  var readWords = function readWords(I, O) {
    for (var o = 0; o < O.length; o += 8) {
      var i = o / 4;
      O[o] = I[i + 1];
      O[o + 1] = I[i + 1] >>> 8;
      O[o + 2] = I[i + 1] >>> 16;
      O[o + 3] = I[i + 1] >>> 24;
      O[o + 4] = I[i];
      O[o + 5] = I[i] >>> 8;
      O[o + 6] = I[i] >>> 16;
      O[o + 7] = I[i] >>> 24;
    }

    return O;
  };

  var Sponge = function Sponge(_ref) {
    var _this = this;

    var capacity = _ref.capacity,
        padding = _ref.padding;
    var keccak = (0, _permute["default"])();
    var stateSize = 200;
    var blockSize = capacity / 8;
    var queueSize = stateSize - capacity / 4;
    var queueOffset = 0;
    var state = new Uint32Array(stateSize / 4);

    var queue = _buffer.Buffer.allocUnsafe(queueSize);

    this.absorb = function (buffer) {
      for (var i = 0; i < buffer.length; i++) {
        queue[queueOffset] = buffer[i];
        queueOffset += 1;

        if (queueOffset >= queueSize) {
          xorWords(queue, state);
          keccak(state);
          queueOffset = 0;
        }
      }

      return _this;
    };

    this.squeeze = function () {
      var options = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
      var output = {
        buffer: options.buffer || _buffer.Buffer.allocUnsafe(blockSize),
        padding: options.padding || padding,
        queue: _buffer.Buffer.allocUnsafe(queue.length),
        state: new Uint32Array(state.length)
      };
      queue.copy(output.queue);

      for (var i = 0; i < state.length; i++) {
        output.state[i] = state[i];
      }

      output.queue.fill(0, queueOffset);
      output.queue[queueOffset] |= output.padding;
      output.queue[queueSize - 1] |= 128;
      xorWords(output.queue, output.state);

      for (var offset = 0; offset < output.buffer.length; offset += queueSize) {
        keccak(output.state);
        readWords(output.state, output.buffer.slice(offset, offset + queueSize));
      }

      return output.buffer;
    };

    this.reset = function () {
      queue.fill(0);
      state.fill(0);
      queueOffset = 0;
      return _this;
    };

    return this;
  };

  var _default = Sponge;
  exports["default"] = _default;
})(sponge);

(function (exports) {

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports["default"] = exports.SHAKE = exports.SHA3Hash = exports.SHA3 = exports.Keccak = void 0;
  var _buffer = require$$0__default["default"];

  var _sponge = _interopRequireDefault(sponge);

  function _interopRequireDefault(obj) {
    return obj && obj.__esModule ? obj : {
      "default": obj
    };
  }

  var createHash = function createHash(_ref) {
    var allowedSizes = _ref.allowedSizes,
        defaultSize = _ref.defaultSize,
        padding = _ref.padding;
    return function Hash() {
      var _this = this;

      var size = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : defaultSize;

      if (!this || this.constructor !== Hash) {
        return new Hash(size);
      }

      if (allowedSizes && !allowedSizes.includes(size)) {
        throw new Error("Unsupported hash length");
      }

      var sponge = new _sponge["default"]({
        capacity: size
      });

      this.update = function (input) {
        var encoding = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : "utf8";

        if (_buffer.Buffer.isBuffer(input)) {
          sponge.absorb(input);
          return _this;
        }

        if (typeof input === "string") {
          return _this.update(_buffer.Buffer.from(input, encoding));
        }

        throw new TypeError("Not a string or buffer");
      };

      this.digest = function () {
        var formatOrOptions = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : "binary";
        var options = typeof formatOrOptions === "string" ? {
          format: formatOrOptions
        } : formatOrOptions;
        var buffer = sponge.squeeze({
          buffer: options.buffer,
          padding: options.padding || padding
        });

        if (options.format && options.format !== "binary") {
          return buffer.toString(options.format);
        }

        return buffer;
      };

      this.reset = function () {
        sponge.reset();
        return _this;
      };

      return this;
    };
  };

  var Keccak = createHash({
    allowedSizes: [224, 256, 384, 512],
    defaultSize: 512,
    padding: 1
  });
  exports.Keccak = Keccak;
  var SHA3 = createHash({
    allowedSizes: [224, 256, 384, 512],
    defaultSize: 512,
    padding: 6
  });
  exports.SHA3 = SHA3;
  var SHAKE = createHash({
    allowedSizes: [128, 256],
    defaultSize: 256,
    padding: 31
  });
  exports.SHAKE = SHAKE;
  var SHA3Hash = Keccak;
  exports.SHA3Hash = SHA3Hash;
  SHA3.SHA3Hash = SHA3Hash;
  var _default = SHA3;
  exports["default"] = _default;
})(sha3);

function genHash(_x) {
  return _genHash.apply(this, arguments);
}

function _genHash() {
  _genHash = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(utf8String) {
    var sha;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            sha = new sha3.SHA3(256);
            sha.update(rlp.Buffer.from(utf8String, "utf8"));
            return _context.abrupt("return", sha.digest("hex"));

          case 3:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _genHash.apply(this, arguments);
}

function generateTemplateId(_x) {
  return _generateTemplateId.apply(this, arguments);
}

function _generateTemplateId() {
  _generateTemplateId = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee9(_ref) {
    var template, templateData, messages, dependencies, _arguments, encodedHex;

    return _regeneratorRuntime__default["default"].wrap(function _callee9$(_context9) {
      while (1) {
        switch (_context9.prev = _context9.next) {
          case 0:
            template = _ref.template;
            sdk.invariant(template != undefined, "generateTemplateId({ template }) -- template must be defined");
            sdk.invariant(_typeof__default["default"](template) === "object", "generateTemplateId({ template }) -- template must be an object");
            sdk.invariant(typeof template.f_type === "InteractionTemplate", "generateTemplateId({ template }) -- template object must be an InteractionTemplate");
            template = normalizeInteractionTemplate(template);
            _context9.t0 = template.f_version;
            _context9.next = _context9.t0 === "1.0.0" ? 8 : 40;
            break;

          case 8:
            templateData = template.data;
            _context9.next = 11;
            return Promise.all(Object.keys(templateData.messages).map( /*#__PURE__*/function () {
              var _ref2 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(messageKey) {
                var _templateData$message, _templateData$message2;

                return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
                  while (1) {
                    switch (_context2.prev = _context2.next) {
                      case 0:
                        _context2.next = 2;
                        return genHash(messageKey);

                      case 2:
                        _context2.t0 = _context2.sent;
                        _context2.next = 5;
                        return Promise.all(Object.keys((_templateData$message = templateData.messages) === null || _templateData$message === void 0 ? void 0 : (_templateData$message2 = _templateData$message[messageKey]) === null || _templateData$message2 === void 0 ? void 0 : _templateData$message2.i18n).map( /*#__PURE__*/function () {
                          var _ref3 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(i18nkeylanguage) {
                            var _templateData$message3, _templateData$message4, _templateData$message5;

                            return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
                              while (1) {
                                switch (_context.prev = _context.next) {
                                  case 0:
                                    _context.next = 2;
                                    return genHash(i18nkeylanguage);

                                  case 2:
                                    _context.t0 = _context.sent;
                                    _context.next = 5;
                                    return genHash((_templateData$message3 = templateData.messages) === null || _templateData$message3 === void 0 ? void 0 : (_templateData$message4 = _templateData$message3[messageKey]) === null || _templateData$message4 === void 0 ? void 0 : (_templateData$message5 = _templateData$message4.i18n) === null || _templateData$message5 === void 0 ? void 0 : _templateData$message5[i18nkeylanguage]);

                                  case 5:
                                    _context.t1 = _context.sent;
                                    return _context.abrupt("return", [_context.t0, _context.t1]);

                                  case 7:
                                  case "end":
                                    return _context.stop();
                                }
                              }
                            }, _callee);
                          }));

                          return function (_x3) {
                            return _ref3.apply(this, arguments);
                          };
                        }()));

                      case 5:
                        _context2.t1 = _context2.sent;
                        return _context2.abrupt("return", [_context2.t0, _context2.t1]);

                      case 7:
                      case "end":
                        return _context2.stop();
                    }
                  }
                }, _callee2);
              }));

              return function (_x2) {
                return _ref2.apply(this, arguments);
              };
            }()));

          case 11:
            messages = _context9.sent;
            _context9.next = 14;
            return Promise.all(Object.keys(templateData === null || templateData === void 0 ? void 0 : templateData.dependencies).map( /*#__PURE__*/function () {
              var _ref4 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee5(dependencyAddressPlaceholder) {
                var _templateData$depende;

                return _regeneratorRuntime__default["default"].wrap(function _callee5$(_context5) {
                  while (1) {
                    switch (_context5.prev = _context5.next) {
                      case 0:
                        _context5.next = 2;
                        return genHash(dependencyAddressPlaceholder);

                      case 2:
                        _context5.t0 = _context5.sent;
                        _context5.next = 5;
                        return Promise.all(Object.keys(templateData === null || templateData === void 0 ? void 0 : (_templateData$depende = templateData.dependencies) === null || _templateData$depende === void 0 ? void 0 : _templateData$depende[dependencyAddressPlaceholder]).map( /*#__PURE__*/function () {
                          var _ref5 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee4(dependencyContract) {
                            var _templateData$depende2, _templateData$depende3;

                            return _regeneratorRuntime__default["default"].wrap(function _callee4$(_context4) {
                              while (1) {
                                switch (_context4.prev = _context4.next) {
                                  case 0:
                                    _context4.next = 2;
                                    return genHash(dependencyContract);

                                  case 2:
                                    _context4.t0 = _context4.sent;
                                    _context4.next = 5;
                                    return Promise.all(Object.keys(templateData === null || templateData === void 0 ? void 0 : (_templateData$depende2 = templateData.dependencies) === null || _templateData$depende2 === void 0 ? void 0 : (_templateData$depende3 = _templateData$depende2[dependencyAddressPlaceholder]) === null || _templateData$depende3 === void 0 ? void 0 : _templateData$depende3[dependencyContract]).map( /*#__PURE__*/function () {
                                      var _ref6 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(dependencyContractNetwork) {
                                        var _templateData$depende4, _templateData$depende5, _templateData$depende6, _templateData$depende7, _templateData$depende8, _templateData$depende9, _templateData$depende10, _templateData$depende11, _templateData$depende12, _templateData$depende13, _templateData$depende14, _templateData$depende15, _templateData$depende16, _templateData$depende17, _templateData$depende18;

                                        return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
                                          while (1) {
                                            switch (_context3.prev = _context3.next) {
                                              case 0:
                                                _context3.next = 2;
                                                return genHash(dependencyContractNetwork);

                                              case 2:
                                                _context3.t0 = _context3.sent;
                                                _context3.next = 5;
                                                return genHash(templateData === null || templateData === void 0 ? void 0 : (_templateData$depende4 = templateData.dependencies) === null || _templateData$depende4 === void 0 ? void 0 : (_templateData$depende5 = _templateData$depende4[dependencyAddressPlaceholder]) === null || _templateData$depende5 === void 0 ? void 0 : (_templateData$depende6 = _templateData$depende5[dependencyContract]) === null || _templateData$depende6 === void 0 ? void 0 : _templateData$depende6[dependencyContractNetwork].address);

                                              case 5:
                                                _context3.t1 = _context3.sent;
                                                _context3.next = 8;
                                                return genHash(templateData === null || templateData === void 0 ? void 0 : (_templateData$depende7 = templateData.dependencies) === null || _templateData$depende7 === void 0 ? void 0 : (_templateData$depende8 = _templateData$depende7[dependencyAddressPlaceholder]) === null || _templateData$depende8 === void 0 ? void 0 : (_templateData$depende9 = _templateData$depende8[dependencyContract]) === null || _templateData$depende9 === void 0 ? void 0 : _templateData$depende9[dependencyContractNetwork].contract);

                                              case 8:
                                                _context3.t2 = _context3.sent;
                                                _context3.next = 11;
                                                return genHash(templateData === null || templateData === void 0 ? void 0 : (_templateData$depende10 = templateData.dependencies) === null || _templateData$depende10 === void 0 ? void 0 : (_templateData$depende11 = _templateData$depende10[dependencyAddressPlaceholder]) === null || _templateData$depende11 === void 0 ? void 0 : (_templateData$depende12 = _templateData$depende11[dependencyContract]) === null || _templateData$depende12 === void 0 ? void 0 : _templateData$depende12[dependencyContractNetwork].fq_address);

                                              case 11:
                                                _context3.t3 = _context3.sent;
                                                _context3.next = 14;
                                                return genHash(templateData === null || templateData === void 0 ? void 0 : (_templateData$depende13 = templateData.dependencies) === null || _templateData$depende13 === void 0 ? void 0 : (_templateData$depende14 = _templateData$depende13[dependencyAddressPlaceholder]) === null || _templateData$depende14 === void 0 ? void 0 : (_templateData$depende15 = _templateData$depende14[dependencyContract]) === null || _templateData$depende15 === void 0 ? void 0 : _templateData$depende15[dependencyContractNetwork].pin);

                                              case 14:
                                                _context3.t4 = _context3.sent;
                                                _context3.next = 17;
                                                return genHash(String(templateData === null || templateData === void 0 ? void 0 : (_templateData$depende16 = templateData.dependencies) === null || _templateData$depende16 === void 0 ? void 0 : (_templateData$depende17 = _templateData$depende16[dependencyAddressPlaceholder]) === null || _templateData$depende17 === void 0 ? void 0 : (_templateData$depende18 = _templateData$depende17[dependencyContract]) === null || _templateData$depende18 === void 0 ? void 0 : _templateData$depende18[dependencyContractNetwork].pin_block_height));

                                              case 17:
                                                _context3.t5 = _context3.sent;
                                                _context3.t6 = [_context3.t1, _context3.t2, _context3.t3, _context3.t4, _context3.t5];
                                                return _context3.abrupt("return", [_context3.t0, _context3.t6]);

                                              case 20:
                                              case "end":
                                                return _context3.stop();
                                            }
                                          }
                                        }, _callee3);
                                      }));

                                      return function (_x6) {
                                        return _ref6.apply(this, arguments);
                                      };
                                    }()));

                                  case 5:
                                    _context4.t1 = _context4.sent;
                                    return _context4.abrupt("return", [_context4.t0, _context4.t1]);

                                  case 7:
                                  case "end":
                                    return _context4.stop();
                                }
                              }
                            }, _callee4);
                          }));

                          return function (_x5) {
                            return _ref5.apply(this, arguments);
                          };
                        }()));

                      case 5:
                        _context5.t1 = _context5.sent;
                        return _context5.abrupt("return", [_context5.t0, _context5.t1]);

                      case 7:
                      case "end":
                        return _context5.stop();
                    }
                  }
                }, _callee5);
              }));

              return function (_x4) {
                return _ref4.apply(this, arguments);
              };
            }()));

          case 14:
            dependencies = _context9.sent;
            _context9.next = 17;
            return Promise.all(Object.keys(templateData === null || templateData === void 0 ? void 0 : templateData["arguments"]).map( /*#__PURE__*/function () {
              var _ref7 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee8(argumentLabel) {
                var _templateData$argumen, _templateData$argumen2, _templateData$argumen3, _templateData$argumen4;

                return _regeneratorRuntime__default["default"].wrap(function _callee8$(_context8) {
                  while (1) {
                    switch (_context8.prev = _context8.next) {
                      case 0:
                        _context8.next = 2;
                        return genHash(argumentLabel);

                      case 2:
                        _context8.t0 = _context8.sent;
                        _context8.next = 5;
                        return genHash(String(templateData === null || templateData === void 0 ? void 0 : (_templateData$argumen = templateData["arguments"]) === null || _templateData$argumen === void 0 ? void 0 : _templateData$argumen[argumentLabel].index));

                      case 5:
                        _context8.t1 = _context8.sent;
                        _context8.next = 8;
                        return genHash(templateData === null || templateData === void 0 ? void 0 : (_templateData$argumen2 = templateData["arguments"]) === null || _templateData$argumen2 === void 0 ? void 0 : _templateData$argumen2[argumentLabel].type);

                      case 8:
                        _context8.t2 = _context8.sent;
                        _context8.next = 11;
                        return genHash((templateData === null || templateData === void 0 ? void 0 : (_templateData$argumen3 = templateData["arguments"]) === null || _templateData$argumen3 === void 0 ? void 0 : _templateData$argumen3[argumentLabel].balance) || "");

                      case 11:
                        _context8.t3 = _context8.sent;
                        _context8.next = 14;
                        return Promise.all(Object.keys(templateData === null || templateData === void 0 ? void 0 : (_templateData$argumen4 = templateData["arguments"]) === null || _templateData$argumen4 === void 0 ? void 0 : _templateData$argumen4[argumentLabel].messages).map( /*#__PURE__*/function () {
                          var _ref8 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee7(argumentMessageKey) {
                            var _templateData$argumen5, _templateData$argumen6;

                            return _regeneratorRuntime__default["default"].wrap(function _callee7$(_context7) {
                              while (1) {
                                switch (_context7.prev = _context7.next) {
                                  case 0:
                                    _context7.next = 2;
                                    return genHash(argumentMessageKey);

                                  case 2:
                                    _context7.t0 = _context7.sent;
                                    _context7.next = 5;
                                    return Promise.all(Object.keys(templateData === null || templateData === void 0 ? void 0 : (_templateData$argumen5 = templateData["arguments"]) === null || _templateData$argumen5 === void 0 ? void 0 : (_templateData$argumen6 = _templateData$argumen5[argumentLabel].messages) === null || _templateData$argumen6 === void 0 ? void 0 : _templateData$argumen6[argumentMessageKey].i18n).map( /*#__PURE__*/function () {
                                      var _ref9 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee6(i18nkeylanguage) {
                                        var _templateData$argumen7, _templateData$argumen8, _templateData$argumen9;

                                        return _regeneratorRuntime__default["default"].wrap(function _callee6$(_context6) {
                                          while (1) {
                                            switch (_context6.prev = _context6.next) {
                                              case 0:
                                                _context6.next = 2;
                                                return genHash(i18nkeylanguage);

                                              case 2:
                                                _context6.t0 = _context6.sent;
                                                _context6.next = 5;
                                                return genHash(templateData === null || templateData === void 0 ? void 0 : (_templateData$argumen7 = templateData["arguments"]) === null || _templateData$argumen7 === void 0 ? void 0 : (_templateData$argumen8 = _templateData$argumen7[argumentLabel].messages) === null || _templateData$argumen8 === void 0 ? void 0 : (_templateData$argumen9 = _templateData$argumen8[argumentMessageKey].i18n) === null || _templateData$argumen9 === void 0 ? void 0 : _templateData$argumen9[i18nkeylanguage]);

                                              case 5:
                                                _context6.t1 = _context6.sent;
                                                return _context6.abrupt("return", [_context6.t0, _context6.t1]);

                                              case 7:
                                              case "end":
                                                return _context6.stop();
                                            }
                                          }
                                        }, _callee6);
                                      }));

                                      return function (_x9) {
                                        return _ref9.apply(this, arguments);
                                      };
                                    }()));

                                  case 5:
                                    _context7.t1 = _context7.sent;
                                    return _context7.abrupt("return", [_context7.t0, _context7.t1]);

                                  case 7:
                                  case "end":
                                    return _context7.stop();
                                }
                              }
                            }, _callee7);
                          }));

                          return function (_x8) {
                            return _ref8.apply(this, arguments);
                          };
                        }()));

                      case 14:
                        _context8.t4 = _context8.sent;
                        _context8.t5 = [_context8.t1, _context8.t2, _context8.t3, _context8.t4];
                        return _context8.abrupt("return", [_context8.t0, _context8.t5]);

                      case 17:
                      case "end":
                        return _context8.stop();
                    }
                  }
                }, _callee8);
              }));

              return function (_x7) {
                return _ref7.apply(this, arguments);
              };
            }()));

          case 17:
            _arguments = _context9.sent;
            _context9.t1 = rlp.encode;
            _context9.next = 21;
            return genHash("InteractionTemplate");

          case 21:
            _context9.t2 = _context9.sent;
            _context9.next = 24;
            return genHash("1.0.0");

          case 24:
            _context9.t3 = _context9.sent;
            _context9.next = 27;
            return genHash(templateData === null || templateData === void 0 ? void 0 : templateData.type);

          case 27:
            _context9.t4 = _context9.sent;
            _context9.next = 30;
            return genHash(templateData === null || templateData === void 0 ? void 0 : templateData["interface"]);

          case 30:
            _context9.t5 = _context9.sent;
            _context9.t6 = messages;
            _context9.next = 34;
            return genHash(templateData === null || templateData === void 0 ? void 0 : templateData.cadence);

          case 34:
            _context9.t7 = _context9.sent;
            _context9.t8 = dependencies;
            _context9.t9 = _arguments;
            _context9.t10 = [_context9.t2, _context9.t3, _context9.t4, _context9.t5, _context9.t6, _context9.t7, _context9.t8, _context9.t9];
            encodedHex = (0, _context9.t1)(_context9.t10).toString("hex");
            return _context9.abrupt("return", genHash(encodedHex));

          case 40:
            throw new Error("generateTemplateId Error: Unsupported template version");

          case 41:
          case "end":
            return _context9.stop();
        }
      }
    }, _callee9);
  }));
  return _generateTemplateId.apply(this, arguments);
}

function getInteractionTemplateAudits(_x) {
  return _getInteractionTemplateAudits.apply(this, arguments);
}

function _getInteractionTemplateAudits() {
  _getInteractionTemplateAudits = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(_ref) {
    var template,
        auditors,
        opts,
        recomputedTemplateID,
        _auditors,
        FlowInteractionAuditContract,
        fclNetwork,
        audits,
        _args = arguments;

    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            template = _ref.template, auditors = _ref.auditors;
            opts = _args.length > 1 && _args[1] !== undefined ? _args[1] : {};
            sdk.invariant(template != undefined, "getInteractionTemplateAudits({ template }) -- template must be defined");
            template = normalizeInteractionTemplate(template);
            sdk.invariant(template.f_type === "InteractionTemplate", "getInteractionTemplateAudits({ template }) -- template must be an InteractionTemplate"); // Recompute ID to be sure it matches

            _context.next = 7;
            return generateTemplateId({
              template: template
            });

          case 7:
            recomputedTemplateID = _context.sent;

            if (!(recomputedTemplateID !== template.id)) {
              _context.next = 11;
              break;
            }

            utilLogger.log({
              title: "getInteractionTemplateAudits Debug Error",
              message: "Could not recompute and match template ID\n                computed: ".concat(recomputedTemplateID, "\n                template: ").concat(template.id, "\n            "),
              level: utilLogger.LEVELS.debug
            });
            throw new Error("getInteractionTemplateAudits Error: Could not recompute and match template ID");

          case 11:
            _context.t0 = template.f_version;
            _context.next = _context.t0 === "1.0.0" ? 14 : 33;
            break;

          case 14:
            _context.t1 = auditors;

            if (_context.t1) {
              _context.next = 19;
              break;
            }

            _context.next = 18;
            return sdk.config().get("flow.auditors");

          case 18:
            _context.t1 = _context.sent;

          case 19:
            _auditors = _context.t1;
            sdk.invariant(_auditors, "getInteractionTemplateAudits Error: Required configuration for 'fcl.auditors' is not set");
            sdk.invariant(Array.isArray(_auditors), "getInteractionTemplateAudits Error: Required configuration for 'fcl.auditors' is not an array");
            FlowInteractionAuditContract = opts.flowInteractionAuditContract;

            if (FlowInteractionAuditContract) {
              _context.next = 29;
              break;
            }

            _context.next = 26;
            return sdk.config().get("flow.network");

          case 26:
            fclNetwork = _context.sent;
            sdk.invariant(fclNetwork === "mainnet" || fclNetwork === "testnet", "getInteractionTemplateAudits Error: Unable to determine address for FlowInteractionTemplateAudit contract. Set configuration for 'fcl.network' to 'mainnet' or 'testnet'");

            if (fclNetwork === "mainnet") {
              FlowInteractionAuditContract = "0xfd100e39d50a13e6";
            } else {
              FlowInteractionAuditContract = "0xf78bfc12d0a786dc";
            }

          case 29:
            _context.next = 31;
            return query({
              cadence: "\n        import FlowInteractionTemplateAudit from ".concat(FlowInteractionAuditContract, "\n        pub fun main(templateId: String, auditors: [Address]): {Address:Bool} {\n          return FlowInteractionTemplateAudit.getHasTemplateBeenAuditedByAuditors(templateId: templateId, auditors: auditors)\n        }\n        "),
              args: function args(arg, t) {
                return [arg(recomputedTemplateID, t.String), arg(_auditors, t.Array(t.Address))];
              }
            });

          case 31:
            audits = _context.sent;
            return _context.abrupt("return", audits);

          case 33:
            throw new Error("getInteractionTemplateAudits Error: Unsupported template version");

          case 34:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _getInteractionTemplateAudits.apply(this, arguments);
}

function generateImport(_ref) {
  var contractName = _ref.contractName,
      address = _ref.address;
  return {
    contractName: contractName,
    address: address,
    contract: ""
  };
}

function findImports(cadence) {
  var imports = [];
  var importsReg = /import ((\w|,| )+)* from 0x\w+/g;
  var fileImports = cadence.match(importsReg) || [];

  var _iterator = _createForOfIteratorHelper__default["default"](fileImports),
      _step;

  try {
    for (_iterator.s(); !(_step = _iterator.n()).done;) {
      var fileImport = _step.value;
      var importLineReg = /import ((\w+|, |)*) from (0x\w+)/g;
      var importLine = importLineReg.exec(fileImport);
      var contractsReg = /((?:\w+)+),?/g;
      var contracts = importLine[1].match(contractsReg) || [];

      var _iterator2 = _createForOfIteratorHelper__default["default"](contracts),
          _step2;

      try {
        for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
          var contract = _step2.value;
          imports.push(generateImport({
            address: importLine[3],
            contractName: contract.replace(/,/g, "")
          }));
        }
      } catch (err) {
        _iterator2.e(err);
      } finally {
        _iterator2.f();
      }
    }
  } catch (err) {
    _iterator.e(err);
  } finally {
    _iterator.f();
  }

  return imports;
}

function generateDependencyPin(_x) {
  return _generateDependencyPin.apply(this, arguments);
}

function _generateDependencyPin() {
  _generateDependencyPin = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(_ref) {
    var address,
        contractName,
        blockHeight,
        opts,
        horizon,
        _i,
        _horizon,
        _account$contracts,
        horizonImport,
        account,
        contractImports,
        contractHashes,
        contractHashesJoined,
        _args = arguments;

    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            address = _ref.address, contractName = _ref.contractName, blockHeight = _ref.blockHeight;
            opts = _args.length > 1 && _args[1] !== undefined ? _args[1] : {};
            sdk.invariant(address != undefined, "generateDependencyPin({ address }) -- address must be defined");
            sdk.invariant(contractName != undefined, "generateDependencyPin({ contractName }) -- contractName must be defined");
            sdk.invariant(blockHeight != undefined, "generateDependencyPin({ blockHeight }) -- blockHeight must be defined");
            sdk.invariant(typeof address === "string", "generateDependencyPin({ address }) -- address must be a string");
            sdk.invariant(typeof contractName === "string", "generateDependencyPin({ contractName }) -- contractName must be a string");
            sdk.invariant(typeof blockHeight === "number", "generateDependencyPin({ blockHeight }) -- blockHeight must be a number");
            horizon = [generateImport({
              contractName: contractName,
              address: address
            })];
            _i = 0, _horizon = horizon;

          case 10:
            if (!(_i < _horizon.length)) {
              _context.next = 33;
              break;
            }

            horizonImport = _horizon[_i];
            _context.t0 = sdk.send;
            _context.t1 = sdk.getAccount;
            _context.next = 16;
            return sdk.config().get(horizonImport.address, horizonImport.address);

          case 16:
            _context.t2 = _context.sent;
            _context.t3 = (0, _context.t1)(_context.t2);
            _context.t4 = sdk.atBlockHeight(blockHeight);
            _context.t5 = [_context.t3, _context.t4];
            _context.t6 = opts;
            _context.next = 23;
            return (0, _context.t0)(_context.t5, _context.t6).then(sdk.decode);

          case 23:
            account = _context.sent;
            horizonImport.contract = (_account$contracts = account.contracts) === null || _account$contracts === void 0 ? void 0 : _account$contracts[horizonImport.contractName];

            if (horizonImport.contract) {
              _context.next = 28;
              break;
            }

            console.error("Did not find expected contract", horizonImport, account);
            throw new Error("Did not find expected contract");

          case 28:
            contractImports = findImports(horizonImport.contract);
            horizon.push.apply(horizon, _toConsumableArray__default["default"](contractImports));

          case 30:
            _i++;
            _context.next = 10;
            break;

          case 33:
            contractHashes = horizon.map(function (iport) {
              return genHash(iport.contract);
            });
            contractHashesJoined = contractHashes.join("");
            return _context.abrupt("return", genHash(contractHashesJoined));

          case 36:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _generateDependencyPin.apply(this, arguments);
}

function generateDependencyPinAtLatestSealedBlock(_x2) {
  return _generateDependencyPinAtLatestSealedBlock.apply(this, arguments);
}

function _generateDependencyPinAtLatestSealedBlock() {
  _generateDependencyPinAtLatestSealedBlock = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(_ref2) {
    var address,
        contractName,
        opts,
        latestSealedBlock,
        latestSealedBlockHeight,
        _args2 = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            address = _ref2.address, contractName = _ref2.contractName;
            opts = _args2.length > 1 && _args2[1] !== undefined ? _args2[1] : {};
            _context2.next = 4;
            return sdk.block({
              sealed: true
            }, opts);

          case 4:
            latestSealedBlock = _context2.sent;
            latestSealedBlockHeight = latestSealedBlock === null || latestSealedBlock === void 0 ? void 0 : latestSealedBlock.height;
            return _context2.abrupt("return", generateDependencyPin({
              address: address,
              contractName: contractName,
              blockHeight: latestSealedBlockHeight
            }, opts));

          case 7:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _generateDependencyPinAtLatestSealedBlock.apply(this, arguments);
}

function normalizeInteractionTemplateInterface(templateInterface) {
  if (templateInterface == null) return null;

  switch (templateInterface["f_version"]) {
    case "1.0.0":
      return templateInterface;

    default:
      throw new Error("normalizeInteractionTemplateInterface Error: Invalid InteractionTemplateInterface");
  }
}

function generateTemplateInterfaceId(_x) {
  return _generateTemplateInterfaceId.apply(this, arguments);
}

function _generateTemplateInterfaceId() {
  _generateTemplateInterfaceId = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(_ref) {
    var templateInterface, interfaceData, encodedHex;
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            templateInterface = _ref.templateInterface;
            sdk.invariant(templateInterface != undefined, "generateTemplateInterfaceId({ templateInterface }) -- templateInterface must be defined");
            sdk.invariant(_typeof__default["default"](templateInterface) === "object", "generateTemplateInterfaceId({ templateInterface }) -- templateInterface must be an object");
            sdk.invariant(typeof templateInterface.f_type === "InteractionTemplateInterface", "generateTemplateInterfaceId({ templateInterface }) -- templateInterface object must be an InteractionTemplate");
            templateInterface = normalizeInteractionTemplateInterface(templateInterface);
            _context2.t0 = templateInterface.f_version;
            _context2.next = _context2.t0 === "1.0.0" ? 8 : 25;
            break;

          case 8:
            interfaceData = templateInterface.data;
            _context2.t1 = rlp.encode;
            _context2.next = 12;
            return genHash("InteractionTemplateInterface");

          case 12:
            _context2.t2 = _context2.sent;
            _context2.next = 15;
            return genHash("1.0.0");

          case 15:
            _context2.t3 = _context2.sent;
            _context2.next = 18;
            return genHash(interfaceData.flip);

          case 18:
            _context2.t4 = _context2.sent;
            _context2.next = 21;
            return Promise.all(Object.keys(interfaceData.arguments).map( /*#__PURE__*/function () {
              var _ref2 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(argumentLabel) {
                return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
                  while (1) {
                    switch (_context.prev = _context.next) {
                      case 0:
                        _context.next = 2;
                        return genHash(argumentLabel);

                      case 2:
                        _context.t0 = _context.sent;
                        _context.next = 5;
                        return genHash(String(interfaceData.arguments[argumentLabel].index));

                      case 5:
                        _context.t1 = _context.sent;
                        _context.next = 8;
                        return genHash(interfaceData.arguments[argumentLabel].type);

                      case 8:
                        _context.t2 = _context.sent;
                        return _context.abrupt("return", [_context.t0, _context.t1, _context.t2]);

                      case 10:
                      case "end":
                        return _context.stop();
                    }
                  }
                }, _callee);
              }));

              return function (_x2) {
                return _ref2.apply(this, arguments);
              };
            }()));

          case 21:
            _context2.t5 = _context2.sent;
            _context2.t6 = [_context2.t2, _context2.t3, _context2.t4, _context2.t5];
            encodedHex = (0, _context2.t1)(_context2.t6).toString("hex");
            return _context2.abrupt("return", genHash(encodedHex));

          case 25:
            throw new Error("generateTemplateInterfaceId Error: Unsupported templateInterface version");

          case 26:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _generateTemplateInterfaceId.apply(this, arguments);
}

function verifyDependencyPinsSame(_x) {
  return _verifyDependencyPinsSame.apply(this, arguments);
}

function _verifyDependencyPinsSame() {
  _verifyDependencyPinsSame = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(_ref) {
    var template,
        blockHeight,
        network,
        opts,
        templateDependenciesPlaceholderKeys,
        _i,
        _templateDependencies,
        templateDependencyPlaceholderKey,
        templateDependencyPlaceholder,
        templateDependencyPlaceholderContractNames,
        _i2,
        _templateDependencyPl,
        templateDependencyPlaceholderContractName,
        templateDependencyPlaceholderContractNetworks,
        templateDependency,
        pin,
        _args = arguments;

    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            template = _ref.template, blockHeight = _ref.blockHeight, network = _ref.network;
            opts = _args.length > 1 && _args[1] !== undefined ? _args[1] : {};
            sdk.invariant(template != undefined, "generateDependencyPin({ template }) -- template must be defined");
            sdk.invariant(_typeof__default["default"](template) === "object", "generateDependencyPin({ template }) -- template must be an object");
            sdk.invariant(template.f_type === "InteractionTemplate", "generateDependencyPin({ template }) -- template must be an InteractionTemplate");
            template = normalizeInteractionTemplate(template);
            sdk.invariant(network != undefined, "generateDependencyPin({ network }) network must be defined");
            sdk.invariant(blockHeight != undefined, "generateDependencyPin({ blockHeight }) blockHeight must be defined");
            sdk.invariant(typeof blockHeight === "number", "generateDependencyPin({ blockHeight }) blockHeight must be a number");
            _context.t0 = template.f_version;
            _context.next = _context.t0 === "1.0.0" ? 12 : 38;
            break;

          case 12:
            templateDependenciesPlaceholderKeys = Object.keys(template.data.dependencies);
            _i = 0, _templateDependencies = templateDependenciesPlaceholderKeys;

          case 14:
            if (!(_i < _templateDependencies.length)) {
              _context.next = 37;
              break;
            }

            templateDependencyPlaceholderKey = _templateDependencies[_i];
            templateDependencyPlaceholder = template.data.dependencies[templateDependencyPlaceholderKey];
            templateDependencyPlaceholderContractNames = Object.keys(templateDependencyPlaceholder);
            _i2 = 0, _templateDependencyPl = templateDependencyPlaceholderContractNames;

          case 19:
            if (!(_i2 < _templateDependencyPl.length)) {
              _context.next = 34;
              break;
            }

            templateDependencyPlaceholderContractName = _templateDependencyPl[_i2];
            templateDependencyPlaceholderContractNetworks = template.data.dependencies[templateDependencyPlaceholderKey][templateDependencyPlaceholderContractName];
            templateDependency = templateDependencyPlaceholderContractNetworks[network];

            if (!(typeof templateDependency === "undefined")) {
              _context.next = 25;
              break;
            }

            return _context.abrupt("continue", 31);

          case 25:
            _context.next = 27;
            return generateDependencyPin({
              address: templateDependency.address,
              contractName: templateDependency.contract,
              blockHeight: blockHeight
            }, opts);

          case 27:
            pin = _context.sent;

            if (!(pin !== templateDependency.pin)) {
              _context.next = 31;
              break;
            }

            utilLogger.log({
              title: "verifyDependencyPinsSame Debug Error",
              message: "Could not recompute and match dependency pin.\n                                address: ".concat(templateDependency.address, " | contract: ").concat(templateDependency.contract, "\n                                computed: ").concat(pin, "\n                                template: ").concat(templateDependency.pin, "\n                            "),
              level: utilLogger.LEVELS.debug
            });
            return _context.abrupt("return", false);

          case 31:
            _i2++;
            _context.next = 19;
            break;

          case 34:
            _i++;
            _context.next = 14;
            break;

          case 37:
            return _context.abrupt("return", true);

          case 38:
            throw new Error("verifyDependencyPinsSame Error: Unsupported template version");

          case 39:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _verifyDependencyPinsSame.apply(this, arguments);
}

function verifyDependencyPinsSameAtLatestSealedBlock(_x2) {
  return _verifyDependencyPinsSameAtLatestSealedBlock.apply(this, arguments);
}

function _verifyDependencyPinsSameAtLatestSealedBlock() {
  _verifyDependencyPinsSameAtLatestSealedBlock = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(_ref2) {
    var template,
        network,
        opts,
        latestSealedBlock,
        latestSealedBlockHeight,
        _args2 = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            template = _ref2.template, network = _ref2.network;
            opts = _args2.length > 1 && _args2[1] !== undefined ? _args2[1] : {};
            _context2.next = 4;
            return sdk.block({
              sealed: true
            });

          case 4:
            latestSealedBlock = _context2.sent;
            latestSealedBlockHeight = latestSealedBlock === null || latestSealedBlock === void 0 ? void 0 : latestSealedBlock.height;
            return _context2.abrupt("return", verifyDependencyPinsSame({
              template: template,
              network: network,
              blockHeight: latestSealedBlockHeight
            }, opts));

          case 7:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _verifyDependencyPinsSameAtLatestSealedBlock.apply(this, arguments);
}

function getTemplateMessage(_ref) {
  var _template$data, _messages$messageKey, _messages$messageKey$;

  var _ref$localization = _ref.localization,
      localization = _ref$localization === void 0 ? "en-US" : _ref$localization,
      messageKey = _ref.messageKey,
      template = _ref.template;
  sdk.invariant(messageKey, "getMessage({ messageKey }) -- messageKey must be defined");
  sdk.invariant(typeof messageKey === "stirng", "getMessage({ messageKey }) -- messageKey must be a string");
  sdk.invariant(localization, "getMessage({ localization }) -- localization must be defined");
  sdk.invariant(typeof localization === "stirng", "getMessage({ localization }) -- localization must be a string");
  sdk.invariant(template != undefined, "generateTemplateId({ template }) -- template must be defined");
  sdk.invariant(_typeof__default["default"](template) === "object", "generateTemplateId({ template }) -- template must be an object");
  sdk.invariant(typeof template.f_type === "InteractionTemplate", "generateTemplateId({ template }) -- template object must be an InteractionTemplate");
  var messages = template === null || template === void 0 ? void 0 : (_template$data = template.data) === null || _template$data === void 0 ? void 0 : _template$data.messages;
  return messages === null || messages === void 0 ? void 0 : (_messages$messageKey = messages[messageKey]) === null || _messages$messageKey === void 0 ? void 0 : (_messages$messageKey$ = _messages$messageKey.i18n) === null || _messages$messageKey$ === void 0 ? void 0 : _messages$messageKey$[localization];
}

function getTemplateArgumentMessage(_ref) {
  var _template$data, _args$argumentLabel, _args$argumentLabel$m, _args$argumentLabel$m2, _args$argumentLabel$m3;

  var _ref$localization = _ref.localization,
      localization = _ref$localization === void 0 ? "en-US" : _ref$localization,
      argumentLabel = _ref.argumentLabel,
      messageKey = _ref.messageKey,
      template = _ref.template;
  sdk.invariant(messageKey, "getMessage({ messageKey }) -- messageKey must be defined");
  sdk.invariant(typeof messageKey === "stirng", "getMessage({ messageKey }) -- messageKey must be a string");
  sdk.invariant(argumentLabel, "getMessage({ argumentLabel }) -- argumentLabel must be defined");
  sdk.invariant(typeof messageKey === "stirng", "getMessage({ argumentLabel }) -- argumentLabel must be a string");
  sdk.invariant(localization, "getMessage({ localization }) -- localization must be defined");
  sdk.invariant(typeof localization === "stirng", "getMessage({ localization }) -- localization must be a string");
  sdk.invariant(template != undefined, "generateTemplateId({ template }) -- template must be defined");
  sdk.invariant(_typeof__default["default"](template) === "object", "generateTemplateId({ template }) -- template must be an object");
  sdk.invariant(typeof template.f_type === "InteractionTemplate", "generateTemplateId({ template }) -- template object must be an InteractionTemplate");
  var args = template === null || template === void 0 ? void 0 : (_template$data = template.data) === null || _template$data === void 0 ? void 0 : _template$data.arguments;
  return args === null || args === void 0 ? void 0 : (_args$argumentLabel = args[argumentLabel]) === null || _args$argumentLabel === void 0 ? void 0 : (_args$argumentLabel$m = _args$argumentLabel.messages) === null || _args$argumentLabel$m === void 0 ? void 0 : (_args$argumentLabel$m2 = _args$argumentLabel$m[messageKey]) === null || _args$argumentLabel$m2 === void 0 ? void 0 : (_args$argumentLabel$m3 = _args$argumentLabel$m2.i18n) === null || _args$argumentLabel$m3 === void 0 ? void 0 : _args$argumentLabel$m3[localization];
}

var index = /*#__PURE__*/Object.freeze({
  __proto__: null,
  getInteractionTemplateAudits: getInteractionTemplateAudits,
  generateDependencyPin: generateDependencyPin,
  generateDependencyPinAtLatestSealedBlock: generateDependencyPinAtLatestSealedBlock,
  generateTemplateId: generateTemplateId,
  generateTemplateInterfaceId: generateTemplateInterfaceId,
  verifyDependencyPinsSame: verifyDependencyPinsSame,
  verifyDependencyPinsSameAtLatestSealedBlock: verifyDependencyPinsSameAtLatestSealedBlock,
  deriveCadenceByNetwork: deriveCadenceByNetwork,
  getTemplateMessage: getTemplateMessage,
  getTemplateArgumentMessage: getTemplateArgumentMessage
});

var authenticate = function authenticate() {
  var opts = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
  return currentUser().authenticate(opts);
};
var unauthenticate = function unauthenticate() {
  return currentUser().unauthenticate();
};
var reauthenticate = function reauthenticate() {
  var opts = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
  currentUser().unauthenticate();
  return currentUser().authenticate(opts);
};
var signUp = function signUp() {
  var opts = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
  return currentUser().authenticate(opts);
};
var logIn = function logIn() {
  var opts = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
  return currentUser().authenticate(opts);
};
var authz = currentUser().authorization;
var t = t__namespace;

Object.defineProperty(exports, 'config', {
  enumerable: true,
  get: function () { return config.config; }
});
Object.defineProperty(exports, 'TestUtils', {
  enumerable: true,
  get: function () { return sdk.TestUtils; }
});
Object.defineProperty(exports, 'account', {
  enumerable: true,
  get: function () { return sdk.account; }
});
Object.defineProperty(exports, 'arg', {
  enumerable: true,
  get: function () { return sdk.arg; }
});
Object.defineProperty(exports, 'args', {
  enumerable: true,
  get: function () { return sdk.args; }
});
Object.defineProperty(exports, 'atBlockHeight', {
  enumerable: true,
  get: function () { return sdk.atBlockHeight; }
});
Object.defineProperty(exports, 'atBlockId', {
  enumerable: true,
  get: function () { return sdk.atBlockId; }
});
Object.defineProperty(exports, 'authorization', {
  enumerable: true,
  get: function () { return sdk.authorization; }
});
Object.defineProperty(exports, 'authorizations', {
  enumerable: true,
  get: function () { return sdk.authorizations; }
});
Object.defineProperty(exports, 'block', {
  enumerable: true,
  get: function () { return sdk.block; }
});
Object.defineProperty(exports, 'build', {
  enumerable: true,
  get: function () { return sdk.build; }
});
Object.defineProperty(exports, 'createSignableVoucher', {
  enumerable: true,
  get: function () { return sdk.createSignableVoucher; }
});
Object.defineProperty(exports, 'decode', {
  enumerable: true,
  get: function () { return sdk.decode; }
});
Object.defineProperty(exports, 'getAccount', {
  enumerable: true,
  get: function () { return sdk.getAccount; }
});
Object.defineProperty(exports, 'getBlock', {
  enumerable: true,
  get: function () { return sdk.getBlock; }
});
Object.defineProperty(exports, 'getBlockHeader', {
  enumerable: true,
  get: function () { return sdk.getBlockHeader; }
});
Object.defineProperty(exports, 'getCollection', {
  enumerable: true,
  get: function () { return sdk.getCollection; }
});
Object.defineProperty(exports, 'getEvents', {
  enumerable: true,
  get: function () { return sdk.getEvents; }
});
Object.defineProperty(exports, 'getEventsAtBlockHeightRange', {
  enumerable: true,
  get: function () { return sdk.getEventsAtBlockHeightRange; }
});
Object.defineProperty(exports, 'getEventsAtBlockIds', {
  enumerable: true,
  get: function () { return sdk.getEventsAtBlockIds; }
});
Object.defineProperty(exports, 'getTransaction', {
  enumerable: true,
  get: function () { return sdk.getTransaction; }
});
Object.defineProperty(exports, 'getTransactionStatus', {
  enumerable: true,
  get: function () { return sdk.getTransactionStatus; }
});
Object.defineProperty(exports, 'invariant', {
  enumerable: true,
  get: function () { return sdk.invariant; }
});
Object.defineProperty(exports, 'isBad', {
  enumerable: true,
  get: function () { return sdk.isBad; }
});
Object.defineProperty(exports, 'isOk', {
  enumerable: true,
  get: function () { return sdk.isOk; }
});
Object.defineProperty(exports, 'limit', {
  enumerable: true,
  get: function () { return sdk.limit; }
});
Object.defineProperty(exports, 'param', {
  enumerable: true,
  get: function () { return sdk.param; }
});
Object.defineProperty(exports, 'params', {
  enumerable: true,
  get: function () { return sdk.params; }
});
Object.defineProperty(exports, 'payer', {
  enumerable: true,
  get: function () { return sdk.payer; }
});
Object.defineProperty(exports, 'ping', {
  enumerable: true,
  get: function () { return sdk.ping; }
});
Object.defineProperty(exports, 'pipe', {
  enumerable: true,
  get: function () { return sdk.pipe; }
});
Object.defineProperty(exports, 'proposer', {
  enumerable: true,
  get: function () { return sdk.proposer; }
});
Object.defineProperty(exports, 'ref', {
  enumerable: true,
  get: function () { return sdk.ref; }
});
Object.defineProperty(exports, 'script', {
  enumerable: true,
  get: function () { return sdk.script; }
});
Object.defineProperty(exports, 'send', {
  enumerable: true,
  get: function () { return sdk.send; }
});
Object.defineProperty(exports, 'transaction', {
  enumerable: true,
  get: function () { return sdk.transaction; }
});
Object.defineProperty(exports, 'validator', {
  enumerable: true,
  get: function () { return sdk.validator; }
});
Object.defineProperty(exports, 'voucherIntercept', {
  enumerable: true,
  get: function () { return sdk.voucherIntercept; }
});
Object.defineProperty(exports, 'voucherToTxId', {
  enumerable: true,
  get: function () { return sdk.voucherToTxId; }
});
Object.defineProperty(exports, 'why', {
  enumerable: true,
  get: function () { return sdk.why; }
});
Object.defineProperty(exports, 'display', {
  enumerable: true,
  get: function () { return utilAddress.display; }
});
Object.defineProperty(exports, 'sansPrefix', {
  enumerable: true,
  get: function () { return utilAddress.sansPrefix; }
});
Object.defineProperty(exports, 'withPrefix', {
  enumerable: true,
  get: function () { return utilAddress.withPrefix; }
});
Object.defineProperty(exports, 'cadence', {
  enumerable: true,
  get: function () { return utilTemplate.template; }
});
Object.defineProperty(exports, 'cdc', {
  enumerable: true,
  get: function () { return utilTemplate.template; }
});
exports.AppUtils = index$1;
exports.InteractionTemplateUtils = index;
exports.VERSION = VERSION;
exports.WalletUtils = index$2;
exports.authenticate = authenticate;
exports.authz = authz;
exports.currentUser = currentUser;
exports.discovery = discovery;
exports.events = events;
exports.logIn = logIn;
exports.mutate = mutate;
exports.pluginRegistry = pluginRegistry;
exports.query = query;
exports.reauthenticate = reauthenticate;
exports.serialize = serialize;
exports.signUp = signUp;
exports.t = t;
exports.tx = transaction;
exports.unauthenticate = unauthenticate;
exports.verifyUserSignatures = verifyUserSignatures;


},{"@babel/runtime/helpers/asyncToGenerator":6,"@babel/runtime/helpers/createForOfIteratorHelper":10,"@babel/runtime/helpers/defineProperty":12,"@babel/runtime/helpers/objectSpread2":21,"@babel/runtime/helpers/slicedToArray":27,"@babel/runtime/helpers/toConsumableArray":29,"@babel/runtime/helpers/typeof":32,"@babel/runtime/regenerator":35,"@onflow/config":36,"@onflow/rlp":38,"@onflow/sdk":39,"@onflow/types":41,"@onflow/util-actor":42,"@onflow/util-address":43,"@onflow/util-invariant":44,"@onflow/util-logger":45,"@onflow/util-template":46,"@onflow/util-uid":47,"buffer":49,"node-fetch":51}],38:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var buffer = require('buffer');

/**
 * Built on top of rlp library, removing the BN dependency for the flow.
 * Package : https://github.com/ethereumjs/rlp
 * RLP License : https://github.com/ethereumjs/rlp/blob/master/LICENSE
 *
 * ethereumjs/rlp is licensed under the
 * Mozilla Public License 2.0
 * Permissions of this weak copyleft license are conditioned on making available source code of licensed files and modifications of those files under the same license (or in certain cases, one of the GNU licenses). Copyright and license notices must be preserved. Contributors provide an express grant of patent rights. However, a larger work using the licensed work may be distributed under different terms and without source code for files added in the larger work.
 **/

/**
 * @param input - will be converted to buffer
 * @returns returns buffer of encoded data
 **/

function encode(input) {
  if (Array.isArray(input)) {
    var output = [];

    for (var i = 0; i < input.length; i++) {
      output.push(encode(input[i]));
    }

    var buf = buffer.Buffer.concat(output);
    return buffer.Buffer.concat([encodeLength(buf.length, 192), buf]);
  } else {
    var inputBuf = toBuffer(input);
    return inputBuf.length === 1 && inputBuf[0] < 128 ? inputBuf : buffer.Buffer.concat([encodeLength(inputBuf.length, 128), inputBuf]);
  }
}
/**
 * Parse integers. Check if there is no leading zeros
 * @param v The value to parse
 * @param base The base to parse the integer into
 */

function safeParseInt(v, base) {
  if (v.slice(0, 2) === "00") {
    throw new Error("invalid RLP: extra zeros");
  }

  return parseInt(v, base);
}

function encodeLength(len, offset) {
  if (len < 56) {
    return buffer.Buffer.from([len + offset]);
  } else {
    var hexLength = intToHex(len);
    var lLength = hexLength.length / 2;
    var firstByte = intToHex(offset + 55 + lLength);
    return buffer.Buffer.from(firstByte + hexLength, "hex");
  }
}
/**
 * Built on top of rlp library, removing the BN dependency for the flow.
 * Package : https://github.com/ethereumjs/rlp
 * RLP License : https://github.com/ethereumjs/rlp/blob/master/LICENSE
 *
 * ethereumjs/rlp is licensed under the
 * Mozilla Public License 2.0
 * Permissions of this weak copyleft license are conditioned on making available source code of licensed files and modifications of those files under the same license (or in certain cases, one of the GNU licenses). Copyright and license notices must be preserved. Contributors provide an express grant of patent rights. However, a larger work using the licensed work may be distributed under different terms and without source code for files added in the larger work.
 **/

/**
 * @param input - will be converted to buffer
 * @param stream Is the input a stream (false by default)
 * @returns returns buffer of encoded data
 **/


function decode(input, stream) {
  if (stream === void 0) {
    stream = false;
  }

  if (!input || input.length === 0) {
    return buffer.Buffer.from([]);
  }

  var inputBuffer = toBuffer(input);

  var decoded = _decode(inputBuffer);

  if (stream) {
    return decoded;
  }

  if (decoded.remainder.length !== 0) {
    throw new Error("invalid remainder");
  }

  return decoded.data;
}
/**
 * Get the length of the RLP input
 * @param input
 * @returns The length of the input or an empty Buffer if no input
 */

function getLength(input) {
  if (!input || input.length === 0) {
    return buffer.Buffer.from([]);
  }

  var inputBuffer = toBuffer(input);
  var firstByte = inputBuffer[0];

  if (firstByte <= 0x7f) {
    return inputBuffer.length;
  } else if (firstByte <= 0xb7) {
    return firstByte - 0x7f;
  } else if (firstByte <= 0xbf) {
    return firstByte - 0xb6;
  } else if (firstByte <= 0xf7) {
    // a list between  0-55 bytes long
    return firstByte - 0xbf;
  } else {
    // a list  over 55 bytes long
    var llength = firstByte - 0xf6;
    var length = safeParseInt(inputBuffer.slice(1, llength).toString("hex"), 16);
    return llength + length;
  }
}
/** Decode an input with RLP */

function _decode(input) {
  var length, llength, data, innerRemainder, d;
  var decoded = [];
  var firstByte = input[0];

  if (firstByte <= 0x7f) {
    // a single byte whose value is in the [0x00, 0x7f] range, that byte is its own RLP encoding.
    return {
      data: input.slice(0, 1),
      remainder: input.slice(1)
    };
  } else if (firstByte <= 0xb7) {
    // string is 0-55 bytes long. A single byte with value 0x80 plus the length of the string followed by the string
    // The range of the first byte is [0x80, 0xb7]
    length = firstByte - 0x7f; // set 0x80 null to 0

    if (firstByte === 0x80) {
      data = buffer.Buffer.from([]);
    } else {
      data = input.slice(1, length);
    }

    if (length === 2 && data[0] < 0x80) {
      throw new Error("invalid rlp encoding: byte must be less 0x80");
    }

    return {
      data: data,
      remainder: input.slice(length)
    };
  } else if (firstByte <= 0xbf) {
    llength = firstByte - 0xb6;
    length = safeParseInt(input.slice(1, llength).toString("hex"), 16);
    data = input.slice(llength, length + llength);

    if (data.length < length) {
      throw new Error("invalid RLP");
    }

    return {
      data: data,
      remainder: input.slice(length + llength)
    };
  } else if (firstByte <= 0xf7) {
    // a list between  0-55 bytes long
    length = firstByte - 0xbf;
    innerRemainder = input.slice(1, length);

    while (innerRemainder.length) {
      d = _decode(innerRemainder);
      decoded.push(d.data);
      innerRemainder = d.remainder;
    }

    return {
      data: decoded,
      remainder: input.slice(length)
    };
  } else {
    // a list  over 55 bytes long
    llength = firstByte - 0xf6;
    length = safeParseInt(input.slice(1, llength).toString("hex"), 16);
    var totalLength = llength + length;

    if (totalLength > input.length) {
      throw new Error("invalid rlp: total length is larger than the data");
    }

    innerRemainder = input.slice(llength, totalLength);

    if (innerRemainder.length === 0) {
      throw new Error("invalid rlp, List has a invalid length");
    }

    while (innerRemainder.length) {
      d = _decode(innerRemainder);
      decoded.push(d.data);
      innerRemainder = d.remainder;
    }

    return {
      data: decoded,
      remainder: input.slice(totalLength)
    };
  }
}
/** Check if a string is prefixed by 0x */


function isHexPrefixed(str) {
  return str.slice(0, 2) === "0x";
}
/** Removes 0x from a given String */


function stripHexPrefix(str) {
  if (typeof str !== "string") {
    return str;
  }

  return isHexPrefixed(str) ? str.slice(2) : str;
}
/** Transform an integer into its hexadecimal value */


function intToHex(integer) {
  if (integer < 0) {
    throw new Error("Invalid integer as argument, must be unsigned!");
  }

  var hex = integer.toString(16);
  return hex.length % 2 ? "0" + hex : hex;
}
/** Pad a string to be even */


function padToEven(a) {
  return a.length % 2 ? "0" + a : a;
}
/** Transform an integer into a Buffer */


function intToBuffer(integer) {
  var hex = intToHex(integer);
  return buffer.Buffer.from(hex, "hex");
}
/** Transform anything into a Buffer */


function toBuffer(v) {
  if (!buffer.Buffer.isBuffer(v)) {
    if (typeof v === "string") {
      if (isHexPrefixed(v)) {
        return buffer.Buffer.from(padToEven(stripHexPrefix(v)), "hex");
      } else {
        return buffer.Buffer.from(v);
      }
    } else if (typeof v === "number") {
      if (!v) {
        return buffer.Buffer.from([]);
      } else {
        return intToBuffer(v);
      }
    } else if (v === null || v === undefined) {
      return buffer.Buffer.from([]);
    } else if (v instanceof Uint8Array) {
      return buffer.Buffer.from(v);
    } else {
      throw new Error("invalid type");
    }
  }

  return v;
}

Object.defineProperty(exports, 'Buffer', {
  enumerable: true,
  get: function () { return buffer.Buffer; }
});
exports.decode = decode;
exports.encode = encode;
exports.getLength = getLength;
exports.toBuffer = toBuffer;


},{"buffer":49}],39:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var logger = require('@onflow/util-logger');
var _toArray = require('@babel/runtime/helpers/toArray');
var _defineProperty = require('@babel/runtime/helpers/defineProperty');
var _asyncToGenerator = require('@babel/runtime/helpers/asyncToGenerator');
var _objectSpread = require('@babel/runtime/helpers/objectSpread2');
var _createForOfIteratorHelper = require('@babel/runtime/helpers/createForOfIteratorHelper');
var _typeof = require('@babel/runtime/helpers/typeof');
var _regeneratorRuntime = require('@babel/runtime/regenerator');
var utilInvariant = require('@onflow/util-invariant');
var _toConsumableArray = require('@babel/runtime/helpers/toConsumableArray');
var config = require('@onflow/config');
var rlp = require('@onflow/rlp');
var transportHttp = require('@onflow/transport-http');
var utilAddress = require('@onflow/util-address');
var _slicedToArray = require('@babel/runtime/helpers/slicedToArray');
var sha3 = require('sha3');
var _createClass = require('@babel/runtime/helpers/createClass');
var _classCallCheck = require('@babel/runtime/helpers/classCallCheck');
var _inherits = require('@babel/runtime/helpers/inherits');
var _createSuper = require('@babel/runtime/helpers/createSuper');
var _wrapNativeSuper = require('@babel/runtime/helpers/wrapNativeSuper');
var utilTemplate = require('@onflow/util-template');
var _objectWithoutProperties = require('@babel/runtime/helpers/objectWithoutProperties');

function _interopDefaultLegacy (e) { return e && typeof e === 'object' && 'default' in e ? e : { 'default': e }; }

function _interopNamespace(e) {
  if (e && e.__esModule) return e;
  var n = Object.create(null);
  if (e) {
    Object.keys(e).forEach(function (k) {
      if (k !== 'default') {
        var d = Object.getOwnPropertyDescriptor(e, k);
        Object.defineProperty(n, k, d.get ? d : {
          enumerable: true,
          get: function () { return e[k]; }
        });
      }
    });
  }
  n["default"] = e;
  return Object.freeze(n);
}

var logger__namespace = /*#__PURE__*/_interopNamespace(logger);
var _toArray__default = /*#__PURE__*/_interopDefaultLegacy(_toArray);
var _defineProperty__default = /*#__PURE__*/_interopDefaultLegacy(_defineProperty);
var _asyncToGenerator__default = /*#__PURE__*/_interopDefaultLegacy(_asyncToGenerator);
var _objectSpread__default = /*#__PURE__*/_interopDefaultLegacy(_objectSpread);
var _createForOfIteratorHelper__default = /*#__PURE__*/_interopDefaultLegacy(_createForOfIteratorHelper);
var _typeof__default = /*#__PURE__*/_interopDefaultLegacy(_typeof);
var _regeneratorRuntime__default = /*#__PURE__*/_interopDefaultLegacy(_regeneratorRuntime);
var _toConsumableArray__default = /*#__PURE__*/_interopDefaultLegacy(_toConsumableArray);
var _slicedToArray__default = /*#__PURE__*/_interopDefaultLegacy(_slicedToArray);
var _createClass__default = /*#__PURE__*/_interopDefaultLegacy(_createClass);
var _classCallCheck__default = /*#__PURE__*/_interopDefaultLegacy(_classCallCheck);
var _inherits__default = /*#__PURE__*/_interopDefaultLegacy(_inherits);
var _createSuper__default = /*#__PURE__*/_interopDefaultLegacy(_createSuper);
var _wrapNativeSuper__default = /*#__PURE__*/_interopDefaultLegacy(_wrapNativeSuper);
var _objectWithoutProperties__default = /*#__PURE__*/_interopDefaultLegacy(_objectWithoutProperties);

var UNKNOWN
/*                       */
= "UNKNOWN";
var SCRIPT
/*                        */
= "SCRIPT";
var TRANSACTION
/*                   */
= "TRANSACTION";
var GET_TRANSACTION_STATUS
/*        */
= "GET_TRANSACTION_STATUS";
var GET_ACCOUNT
/*                   */
= "GET_ACCOUNT";
var GET_EVENTS
/*                    */
= "GET_EVENTS";
var PING
/*                          */
= "PING";
var GET_TRANSACTION
/*               */
= "GET_TRANSACTION";
var GET_BLOCK
/*                     */
= "GET_BLOCK";
var GET_BLOCK_HEADER
/*              */
= "GET_BLOCK_HEADER";
var GET_COLLECTION
/*                */
= "GET_COLLECTION";
var BAD
/* */
= "BAD";
var OK
/*  */
= "OK";
var ACCOUNT
/*  */
= "ACCOUNT";
var PARAM
/*    */
= "PARAM";
var ARGUMENT
/* */
= "ARGUMENT";
var AUTHORIZER
/* */
= "authorizer";
var PAYER
/*      */
= "payer";
var PROPOSER
/*   */
= "proposer";
var ACCT = "{\n  \"kind\":\"".concat(ACCOUNT, "\",\n  \"tempId\":null,\n  \"addr\":null,\n  \"keyId\":null,\n  \"sequenceNum\":null,\n  \"signature\":null,\n  \"signingFunction\":null,\n  \"resolve\":null,\n  \"role\": {\n    \"proposer\":false,\n    \"authorizer\":false,\n    \"payer\":false,\n    \"param\":false\n  }\n}");
var ARG = "{\n  \"kind\":\"".concat(ARGUMENT, "\",\n  \"tempId\":null,\n  \"value\":null,\n  \"asArgument\":null,\n  \"xform\":null,\n  \"resolve\": null,\n  \"resolveArgument\": null\n}");
var IX = "{\n  \"tag\":\"".concat(UNKNOWN, "\",\n  \"assigns\":{},\n  \"status\":\"").concat(OK, "\",\n  \"reason\":null,\n  \"accounts\":{},\n  \"params\":{},\n  \"arguments\":{},\n  \"message\": {\n    \"cadence\":null,\n    \"refBlock\":null,\n    \"computeLimit\":null,\n    \"proposer\":null,\n    \"payer\":null,\n    \"authorizations\":[],\n    \"params\":[],\n    \"arguments\":[]\n  },\n  \"proposer\":null,\n  \"authorizations\":[],\n  \"payer\":[],\n  \"events\": {\n    \"eventType\":null,\n    \"start\":null,\n    \"end\":null,\n    \"blockIds\":[]\n  },\n  \"transaction\": {\n    \"id\":null\n  },\n  \"block\": {\n    \"id\":null,\n    \"height\":null,\n    \"isSealed\":null\n  },\n  \"account\": {\n    \"addr\":null\n  },\n  \"collection\": {\n    \"id\":null\n  }\n}");
var KEYS = new Set(Object.keys(JSON.parse(IX)));
var interaction = function interaction() {
  return JSON.parse(IX);
};
var CHARS = "abcdefghijklmnopqrstuvwxyz0123456789".split("");

var randChar = function randChar() {
  return CHARS[~~(Math.random() * CHARS.length)];
};

var uuid = function uuid() {
  return Array.from({
    length: 10
  }, randChar).join("");
};
var isNumber$1 = function isNumber(d) {
  return typeof d === "number";
};
var isArray$1 = function isArray(d) {
  return Array.isArray(d);
};
var isObj = function isObj(d) {
  return d !== null && _typeof__default["default"](d) === "object";
};
var isNull = function isNull(d) {
  return d == null;
};
var isFn$3 = function isFn(d) {
  return typeof d === "function";
};
var isInteraction = function isInteraction(ix) {
  if (!isObj(ix) || isNull(ix) || isNumber$1(ix)) return false;

  var _iterator = _createForOfIteratorHelper__default["default"](KEYS),
      _step;

  try {
    for (_iterator.s(); !(_step = _iterator.n()).done;) {
      var key = _step.value;
      if (!ix.hasOwnProperty(key)) return false;
    }
  } catch (err) {
    _iterator.e(err);
  } finally {
    _iterator.f();
  }

  return true;
};
var Ok = function Ok(ix) {
  ix.status = OK;
  return ix;
};
var Bad = function Bad(ix, reason) {
  ix.status = BAD;
  ix.reason = reason;
  return ix;
};

var makeIx = function makeIx(wat) {
  return function (ix) {
    ix.tag = wat;
    return Ok(ix);
  };
};

var prepAccountKeyId = function prepAccountKeyId(acct) {
  if (acct.keyId == null) return acct;
  utilInvariant.invariant(!isNaN(parseInt(acct.keyId)), "account.keyId must be an integer");
  return _objectSpread__default["default"](_objectSpread__default["default"]({}, acct), {}, {
    keyId: parseInt(acct.keyId)
  });
};

var prepAccount = function prepAccount(acct) {
  var opts = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};
  return function (ix) {
    utilInvariant.invariant(typeof acct === "function" || _typeof__default["default"](acct) === "object", "prepAccount must be passed an authorization function or an account object");
    utilInvariant.invariant(opts.role != null, "Account must have a role");
    var ACCOUNT = JSON.parse(ACCT);
    var role = opts.role;
    var tempId = uuid();
    if (acct.authorization && isFn$3(acct.authorization)) acct = {
      resolve: acct.authorization
    };
    if (!acct.authorization && isFn$3(acct)) acct = {
      resolve: acct
    };
    var resolve = acct.resolve;
    if (resolve) acct.resolve = function (acct) {
      for (var _len = arguments.length, rest = new Array(_len > 1 ? _len - 1 : 0), _key = 1; _key < _len; _key++) {
        rest[_key - 1] = arguments[_key];
      }

      return [resolve, prepAccountKeyId].reduce( /*#__PURE__*/function () {
        var _ref = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(d, fn) {
          return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
            while (1) {
              switch (_context.prev = _context.next) {
                case 0:
                  _context.t0 = fn;
                  _context.t1 = void 0;
                  _context.next = 4;
                  return d;

                case 4:
                  _context.t2 = _context.sent;
                  _context.t3 = [_context.t2].concat(rest);
                  return _context.abrupt("return", _context.t0.apply.call(_context.t0, _context.t1, _context.t3));

                case 7:
                case "end":
                  return _context.stop();
              }
            }
          }, _callee);
        }));

        return function (_x, _x2) {
          return _ref.apply(this, arguments);
        };
      }(), acct);
    };
    acct = prepAccountKeyId(acct);
    ix.accounts[tempId] = _objectSpread__default["default"](_objectSpread__default["default"](_objectSpread__default["default"]({}, ACCOUNT), {}, {
      tempId: tempId
    }, acct), {}, {
      role: _objectSpread__default["default"](_objectSpread__default["default"](_objectSpread__default["default"]({}, ACCOUNT.role), _typeof__default["default"](acct.role) === "object" ? acct.role : {}), {}, _defineProperty__default["default"]({}, role, true))
    });

    if (role === AUTHORIZER) {
      ix.authorizations.push(tempId);
    } else if (role === PAYER) {
      ix.payer.push(tempId);
    } else {
      ix[role] = tempId;
    }

    return ix;
  };
};
var makeArgument = function makeArgument(arg) {
  return function (ix) {
    var tempId = uuid();
    ix.message.arguments.push(tempId);
    ix.arguments[tempId] = JSON.parse(ARG);
    ix.arguments[tempId].tempId = tempId;
    ix.arguments[tempId].value = arg.value;
    ix.arguments[tempId].asArgument = arg.asArgument;
    ix.arguments[tempId].xform = arg.xform;
    ix.arguments[tempId].resolve = arg.resolve;
    ix.arguments[tempId].resolveArgument = isFn$3(arg.resolveArgument) ? arg.resolveArgument.bind(arg) : arg.resolveArgument;
    return Ok(ix);
  };
};
var makeUnknown
/*                 */
= makeIx(UNKNOWN);
var makeScript
/*                  */
= makeIx(SCRIPT);
var makeTransaction
/*             */
= makeIx(TRANSACTION);
var makeGetTransactionStatus
/*    */
= makeIx(GET_TRANSACTION_STATUS);
var makeGetTransaction
/*          */
= makeIx(GET_TRANSACTION);
var makeGetAccount
/*              */
= makeIx(GET_ACCOUNT);
var makeGetEvents
/*               */
= makeIx(GET_EVENTS);
var makePing
/*                    */
= makeIx(PING);
var makeGetBlock
/*                */
= makeIx(GET_BLOCK);
var makeGetBlockHeader
/*          */
= makeIx(GET_BLOCK_HEADER);
var makeGetCollection
/*           */
= makeIx(GET_COLLECTION);

var is = function is(wat) {
  return function (ix) {
    return ix.tag === wat;
  };
};

var isUnknown
/*                 */
= is(UNKNOWN);
var isScript
/*                  */
= is(SCRIPT);
var isTransaction
/*             */
= is(TRANSACTION);
var isGetTransactionStatus
/*    */
= is(GET_TRANSACTION_STATUS);
var isGetTransaction
/*          */
= is(GET_TRANSACTION);
var isGetAccount
/*              */
= is(GET_ACCOUNT);
var isGetEvents
/*               */
= is(GET_EVENTS);
var isPing
/*                    */
= is(PING);
var isGetBlock
/*                */
= is(GET_BLOCK);
var isGetBlockHeader
/*          */
= is(GET_BLOCK_HEADER);
var isGetCollection
/*           */
= is(GET_COLLECTION);
var isOk
/*  */
= function isOk
/*  */
(ix) {
  return ix.status === OK;
};
var isBad
/* */
= function isBad
/* */
(ix) {
  return ix.status === BAD;
};
var why
/*   */
= function why
/*   */
(ix) {
  return ix.reason;
};
var isAccount
/*  */
= function isAccount
/*  */
(account) {
  return account.kind === ACCOUNT;
};
var isParam
/*    */
= function isParam
/*    */
(param) {
  return param.kind === PARAM;
};
var isArgument
/* */
= function isArgument
/* */
(argument) {
  return argument.kind === ARGUMENT;
};

var hardMode = function hardMode(ix) {
  for (var _i = 0, _Object$keys = Object.keys(ix); _i < _Object$keys.length; _i++) {
    var key = _Object$keys[_i];
    if (!KEYS.has(key)) throw new Error("\"".concat(key, "\" is an invalid root level Interaction property."));
  }

  return ix;
};

var recPipe = /*#__PURE__*/function () {
  var _ref2 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(ix) {
    var fns,
        _fns,
        hd,
        rest,
        cur,
        _args2 = arguments;

    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            fns = _args2.length > 1 && _args2[1] !== undefined ? _args2[1] : [];
            _context2.prev = 1;
            _context2.t0 = hardMode;
            _context2.next = 5;
            return ix;

          case 5:
            _context2.t1 = _context2.sent;
            ix = (0, _context2.t0)(_context2.t1);

            if (!isBad(ix)) {
              _context2.next = 9;
              break;
            }

            throw new Error("Interaction Error: ".concat(ix.reason));

          case 9:
            if (fns.length) {
              _context2.next = 11;
              break;
            }

            return _context2.abrupt("return", ix);

          case 11:
            _fns = _toArray__default["default"](fns), hd = _fns[0], rest = _fns.slice(1);
            _context2.next = 14;
            return hd;

          case 14:
            cur = _context2.sent;

            if (!isFn$3(cur)) {
              _context2.next = 17;
              break;
            }

            return _context2.abrupt("return", recPipe(cur(ix), rest));

          case 17:
            if (!(isNull(cur) || !cur)) {
              _context2.next = 19;
              break;
            }

            return _context2.abrupt("return", recPipe(ix, rest));

          case 19:
            if (!isInteraction(cur)) {
              _context2.next = 21;
              break;
            }

            return _context2.abrupt("return", recPipe(cur, rest));

          case 21:
            throw new Error("Invalid Interaction Composition");

          case 24:
            _context2.prev = 24;
            _context2.t2 = _context2["catch"](1);
            throw _context2.t2;

          case 27:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2, null, [[1, 24]]);
  }));

  return function recPipe(_x3) {
    return _ref2.apply(this, arguments);
  };
}();

var pipe = function pipe() {
  for (var _len2 = arguments.length, args = new Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
    args[_key2] = arguments[_key2];
  }

  var arg1 = args[0],
      arg2 = args[1];
  if (isArray$1(arg1) && arg2 == null) return function (d) {
    return pipe(d, arg1);
  };
  return recPipe(arg1, arg2);
};

var identity$1 = function identity(v) {
  return v;
};

var get = function get(ix, key, fallback) {
  return ix.assigns[key] == null ? fallback : ix.assigns[key];
};
var put = function put(key, value) {
  return function (ix) {
    ix.assigns[key] = value;
    return Ok(ix);
  };
};
var update = function update(key) {
  var fn = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : identity$1;
  return function (ix) {
    ix.assigns[key] = fn(ix.assigns[key], ix);
    return Ok(ix);
  };
};
var destroy = function destroy(key) {
  return function (ix) {
    delete ix.assigns[key];
    return Ok(ix);
  };
};

var ixModule = /*#__PURE__*/Object.freeze({
  __proto__: null,
  UNKNOWN: UNKNOWN,
  SCRIPT: SCRIPT,
  TRANSACTION: TRANSACTION,
  GET_TRANSACTION_STATUS: GET_TRANSACTION_STATUS,
  GET_ACCOUNT: GET_ACCOUNT,
  GET_EVENTS: GET_EVENTS,
  PING: PING,
  GET_TRANSACTION: GET_TRANSACTION,
  GET_BLOCK: GET_BLOCK,
  GET_BLOCK_HEADER: GET_BLOCK_HEADER,
  GET_COLLECTION: GET_COLLECTION,
  BAD: BAD,
  OK: OK,
  ACCOUNT: ACCOUNT,
  PARAM: PARAM,
  ARGUMENT: ARGUMENT,
  AUTHORIZER: AUTHORIZER,
  PAYER: PAYER,
  PROPOSER: PROPOSER,
  interaction: interaction,
  uuid: uuid,
  isNumber: isNumber$1,
  isArray: isArray$1,
  isObj: isObj,
  isNull: isNull,
  isFn: isFn$3,
  isInteraction: isInteraction,
  Ok: Ok,
  Bad: Bad,
  prepAccount: prepAccount,
  makeArgument: makeArgument,
  makeUnknown: makeUnknown,
  makeScript: makeScript,
  makeTransaction: makeTransaction,
  makeGetTransactionStatus: makeGetTransactionStatus,
  makeGetTransaction: makeGetTransaction,
  makeGetAccount: makeGetAccount,
  makeGetEvents: makeGetEvents,
  makePing: makePing,
  makeGetBlock: makeGetBlock,
  makeGetBlockHeader: makeGetBlockHeader,
  makeGetCollection: makeGetCollection,
  isUnknown: isUnknown,
  isScript: isScript,
  isTransaction: isTransaction,
  isGetTransactionStatus: isGetTransactionStatus,
  isGetTransaction: isGetTransaction,
  isGetAccount: isGetAccount,
  isGetEvents: isGetEvents,
  isPing: isPing,
  isGetBlock: isGetBlock,
  isGetBlockHeader: isGetBlockHeader,
  isGetCollection: isGetCollection,
  isOk: isOk,
  isBad: isBad,
  why: why,
  isAccount: isAccount,
  isParam: isParam,
  isArgument: isArgument,
  pipe: pipe,
  get: get,
  put: put,
  update: update,
  destroy: destroy
});

function build() {
  var fns = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : [];
  return pipe(interaction(), fns);
}

var DEFAULT_RESPONSE = "{\n    \"tag\":null,\n    \"transaction\":null,\n    \"transactionStatus\":null,\n    \"transactionId\":null,\n    \"encodedData\":null,\n    \"events\":null,\n    \"account\":null,\n    \"block\":null,\n    \"blockHeader\":null,\n    \"latestBlock\":null,\n    \"collection\":null\n}";
var response = function response() {
  return JSON.parse(DEFAULT_RESPONSE);
};

function getBlock() {
  var isSealed = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : null;
  return pipe([makeGetBlock, function (ix) {
    ix.block.isSealed = isSealed;
    return Ok(ix);
  }]);
}

function getAccount(addr) {
  return pipe([makeGetAccount, function (ix) {
    ix.account.addr = utilAddress.sansPrefix(addr);
    return Ok(ix);
  }]);
}

var latestBlockDeprecationNotice = function latestBlockDeprecationNotice() {
  logger.log.deprecate({
    pkg: "@onflow/decode",
    subject: "Operating upon data of the latestBlock field of the response object",
    transition: "https://github.com/onflow/flow-js-sdk/blob/master/packages/decode/WARNINGS.md#0001-Deprecating-latestBlock-field"
  });
};

var decodeImplicit = /*#__PURE__*/function () {
  var _ref2 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(i) {
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            return _context2.abrupt("return", i);

          case 1:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));

  return function decodeImplicit(_x4) {
    return _ref2.apply(this, arguments);
  };
}();

var decodeVoid = /*#__PURE__*/function () {
  var _ref3 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3() {
    return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
      while (1) {
        switch (_context3.prev = _context3.next) {
          case 0:
            return _context3.abrupt("return", null);

          case 1:
          case "end":
            return _context3.stop();
        }
      }
    }, _callee3);
  }));

  return function decodeVoid() {
    return _ref3.apply(this, arguments);
  };
}();

var decodeType = /*#__PURE__*/function () {
  var _ref4 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee4(type) {
    return _regeneratorRuntime__default["default"].wrap(function _callee4$(_context4) {
      while (1) {
        switch (_context4.prev = _context4.next) {
          case 0:
            return _context4.abrupt("return", type.staticType);

          case 1:
          case "end":
            return _context4.stop();
        }
      }
    }, _callee4);
  }));

  return function decodeType(_x5) {
    return _ref4.apply(this, arguments);
  };
}();

var decodePath = /*#__PURE__*/function () {
  var _ref5 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee5(path) {
    return _regeneratorRuntime__default["default"].wrap(function _callee5$(_context5) {
      while (1) {
        switch (_context5.prev = _context5.next) {
          case 0:
            return _context5.abrupt("return", {
              domain: path.domain,
              identifier: path.identifier
            });

          case 1:
          case "end":
            return _context5.stop();
        }
      }
    }, _callee5);
  }));

  return function decodePath(_x6) {
    return _ref5.apply(this, arguments);
  };
}();

var decodeCapability = /*#__PURE__*/function () {
  var _ref6 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee6(cap) {
    return _regeneratorRuntime__default["default"].wrap(function _callee6$(_context6) {
      while (1) {
        switch (_context6.prev = _context6.next) {
          case 0:
            return _context6.abrupt("return", {
              path: cap.path,
              address: cap.address,
              borrowType: cap.borrowType
            });

          case 1:
          case "end":
            return _context6.stop();
        }
      }
    }, _callee6);
  }));

  return function decodeCapability(_x7) {
    return _ref6.apply(this, arguments);
  };
}();

var decodeOptional = /*#__PURE__*/function () {
  var _ref7 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee7(optional, decoders, stack) {
    return _regeneratorRuntime__default["default"].wrap(function _callee7$(_context7) {
      while (1) {
        switch (_context7.prev = _context7.next) {
          case 0:
            if (!optional) {
              _context7.next = 6;
              break;
            }

            _context7.next = 3;
            return recurseDecode(optional, decoders, stack);

          case 3:
            _context7.t0 = _context7.sent;
            _context7.next = 7;
            break;

          case 6:
            _context7.t0 = null;

          case 7:
            return _context7.abrupt("return", _context7.t0);

          case 8:
          case "end":
            return _context7.stop();
        }
      }
    }, _callee7);
  }));

  return function decodeOptional(_x8, _x9, _x10) {
    return _ref7.apply(this, arguments);
  };
}();

var decodeReference = /*#__PURE__*/function () {
  var _ref8 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee8(v) {
    return _regeneratorRuntime__default["default"].wrap(function _callee8$(_context8) {
      while (1) {
        switch (_context8.prev = _context8.next) {
          case 0:
            return _context8.abrupt("return", {
              address: v.address,
              type: v.type
            });

          case 1:
          case "end":
            return _context8.stop();
        }
      }
    }, _callee8);
  }));

  return function decodeReference(_x11) {
    return _ref8.apply(this, arguments);
  };
}();

var decodeArray = /*#__PURE__*/function () {
  var _ref9 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee10(array, decoders, stack) {
    return _regeneratorRuntime__default["default"].wrap(function _callee10$(_context10) {
      while (1) {
        switch (_context10.prev = _context10.next) {
          case 0:
            _context10.next = 2;
            return Promise.all(array.map(function (v) {
              return new Promise( /*#__PURE__*/function () {
                var _ref10 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee9(res) {
                  return _regeneratorRuntime__default["default"].wrap(function _callee9$(_context9) {
                    while (1) {
                      switch (_context9.prev = _context9.next) {
                        case 0:
                          _context9.t0 = res;
                          _context9.next = 3;
                          return recurseDecode(v, decoders, [].concat(_toConsumableArray__default["default"](stack), [v.type]));

                        case 3:
                          _context9.t1 = _context9.sent;
                          return _context9.abrupt("return", (0, _context9.t0)(_context9.t1));

                        case 5:
                        case "end":
                          return _context9.stop();
                      }
                    }
                  }, _callee9);
                }));

                return function (_x15) {
                  return _ref10.apply(this, arguments);
                };
              }());
            }));

          case 2:
            return _context10.abrupt("return", _context10.sent);

          case 3:
          case "end":
            return _context10.stop();
        }
      }
    }, _callee10);
  }));

  return function decodeArray(_x12, _x13, _x14) {
    return _ref9.apply(this, arguments);
  };
}();

var decodeDictionary = /*#__PURE__*/function () {
  var _ref11 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee12(dictionary, decoders, stack) {
    return _regeneratorRuntime__default["default"].wrap(function _callee12$(_context12) {
      while (1) {
        switch (_context12.prev = _context12.next) {
          case 0:
            _context12.next = 2;
            return dictionary.reduce( /*#__PURE__*/function () {
              var _ref12 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee11(acc, v) {
                return _regeneratorRuntime__default["default"].wrap(function _callee11$(_context11) {
                  while (1) {
                    switch (_context11.prev = _context11.next) {
                      case 0:
                        _context11.next = 2;
                        return acc;

                      case 2:
                        acc = _context11.sent;
                        _context11.next = 5;
                        return recurseDecode(v.key, decoders, [].concat(_toConsumableArray__default["default"](stack), [v.key]));

                      case 5:
                        _context11.t0 = _context11.sent;
                        _context11.next = 8;
                        return recurseDecode(v.value, decoders, [].concat(_toConsumableArray__default["default"](stack), [v.key]));

                      case 8:
                        acc[_context11.t0] = _context11.sent;
                        return _context11.abrupt("return", acc);

                      case 10:
                      case "end":
                        return _context11.stop();
                    }
                  }
                }, _callee11);
              }));

              return function (_x19, _x20) {
                return _ref12.apply(this, arguments);
              };
            }(), Promise.resolve({}));

          case 2:
            return _context12.abrupt("return", _context12.sent);

          case 3:
          case "end":
            return _context12.stop();
        }
      }
    }, _callee12);
  }));

  return function decodeDictionary(_x16, _x17, _x18) {
    return _ref11.apply(this, arguments);
  };
}();

var decodeComposite = /*#__PURE__*/function () {
  var _ref13 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee14(composite, decoders, stack) {
    var decoded, decoder;
    return _regeneratorRuntime__default["default"].wrap(function _callee14$(_context14) {
      while (1) {
        switch (_context14.prev = _context14.next) {
          case 0:
            _context14.next = 2;
            return composite.fields.reduce( /*#__PURE__*/function () {
              var _ref14 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee13(acc, v) {
                return _regeneratorRuntime__default["default"].wrap(function _callee13$(_context13) {
                  while (1) {
                    switch (_context13.prev = _context13.next) {
                      case 0:
                        _context13.next = 2;
                        return acc;

                      case 2:
                        acc = _context13.sent;
                        _context13.next = 5;
                        return recurseDecode(v.value, decoders, [].concat(_toConsumableArray__default["default"](stack), [v.name]));

                      case 5:
                        acc[v.name] = _context13.sent;
                        return _context13.abrupt("return", acc);

                      case 7:
                      case "end":
                        return _context13.stop();
                    }
                  }
                }, _callee13);
              }));

              return function (_x24, _x25) {
                return _ref14.apply(this, arguments);
              };
            }(), Promise.resolve({}));

          case 2:
            decoded = _context14.sent;
            decoder = composite.id && decoderLookup(decoders, composite.id);

            if (!decoder) {
              _context14.next = 10;
              break;
            }

            _context14.next = 7;
            return decoder(decoded);

          case 7:
            _context14.t0 = _context14.sent;
            _context14.next = 11;
            break;

          case 10:
            _context14.t0 = decoded;

          case 11:
            return _context14.abrupt("return", _context14.t0);

          case 12:
          case "end":
            return _context14.stop();
        }
      }
    }, _callee14);
  }));

  return function decodeComposite(_x21, _x22, _x23) {
    return _ref13.apply(this, arguments);
  };
}();

var defaultDecoders = {
  UInt: decodeImplicit,
  Int: decodeImplicit,
  UInt8: decodeImplicit,
  Int8: decodeImplicit,
  UInt16: decodeImplicit,
  Int16: decodeImplicit,
  UInt32: decodeImplicit,
  Int32: decodeImplicit,
  UInt64: decodeImplicit,
  Int64: decodeImplicit,
  UInt128: decodeImplicit,
  Int128: decodeImplicit,
  UInt256: decodeImplicit,
  Int256: decodeImplicit,
  Word8: decodeImplicit,
  Word16: decodeImplicit,
  Word32: decodeImplicit,
  Word64: decodeImplicit,
  UFix64: decodeImplicit,
  Fix64: decodeImplicit,
  String: decodeImplicit,
  Character: decodeImplicit,
  Bool: decodeImplicit,
  Address: decodeImplicit,
  Void: decodeVoid,
  Optional: decodeOptional,
  Reference: decodeReference,
  Array: decodeArray,
  Dictionary: decodeDictionary,
  Event: decodeComposite,
  Resource: decodeComposite,
  Struct: decodeComposite,
  Enum: decodeComposite,
  Type: decodeType,
  Path: decodePath,
  Capability: decodeCapability
};

var decoderLookup = function decoderLookup(decoders, lookup) {
  var found = Object.keys(decoders).find(function (decoder) {
    if (/^\/.*\/$/.test(decoder)) {
      var reg = new RegExp(decoder.substring(1, decoder.length - 1));
      return reg.test(lookup);
    }

    return decoder === lookup;
  });
  return lookup && found && decoders[found];
};

var recurseDecode = /*#__PURE__*/function () {
  var _ref15 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee15(decodeInstructions, decoders, stack) {
    var decoder;
    return _regeneratorRuntime__default["default"].wrap(function _callee15$(_context15) {
      while (1) {
        switch (_context15.prev = _context15.next) {
          case 0:
            decoder = decoderLookup(decoders, decodeInstructions.type);

            if (decoder) {
              _context15.next = 3;
              break;
            }

            throw new Error("Undefined Decoder Error: ".concat(decodeInstructions.type, "@").concat(stack.join(".")));

          case 3:
            _context15.next = 5;
            return decoder(decodeInstructions.value, decoders, stack);

          case 5:
            return _context15.abrupt("return", _context15.sent);

          case 6:
          case "end":
            return _context15.stop();
        }
      }
    }, _callee15);
  }));

  return function recurseDecode(_x26, _x27, _x28) {
    return _ref15.apply(this, arguments);
  };
}();

var decode$1 = /*#__PURE__*/function () {
  var _ref16 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee16(decodeInstructions) {
    var customDecoders,
        stack,
        filteredDecoders,
        decoders,
        _args16 = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee16$(_context16) {
      while (1) {
        switch (_context16.prev = _context16.next) {
          case 0:
            customDecoders = _args16.length > 1 && _args16[1] !== undefined ? _args16[1] : {};
            stack = _args16.length > 2 && _args16[2] !== undefined ? _args16[2] : [];
            // Filter out all default decoders which are overridden by a custom decoder regex
            filteredDecoders = Object.keys(defaultDecoders).filter(function (decoder) {
              return !Object.keys(customDecoders).find(function (customDecoder) {
                return new RegExp(customDecoder).test(decoder);
              });
            }).reduce(function (decoders, decoderKey) {
              decoders[decoderKey] = defaultDecoders[decoderKey];
              return decoders;
            }, customDecoders);
            decoders = _objectSpread__default["default"](_objectSpread__default["default"]({}, filteredDecoders), customDecoders);
            return _context16.abrupt("return", recurseDecode(decodeInstructions, decoders, stack));

          case 5:
          case "end":
            return _context16.stop();
        }
      }
    }, _callee16);
  }));

  return function decode(_x29) {
    return _ref16.apply(this, arguments);
  };
}();
var decodeResponse = /*#__PURE__*/function () {
  var _ref17 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee19(response) {
    var customDecoders,
        _args19 = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee19$(_context19) {
      while (1) {
        switch (_context19.prev = _context19.next) {
          case 0:
            customDecoders = _args19.length > 1 && _args19[1] !== undefined ? _args19[1] : {};

            if (!response.encodedData) {
              _context19.next = 5;
              break;
            }

            return _context19.abrupt("return", decode$1(response.encodedData, customDecoders));

          case 5:
            if (!response.transactionStatus) {
              _context19.next = 16;
              break;
            }

            _context19.t0 = _objectSpread__default["default"];
            _context19.t1 = _objectSpread__default["default"]({}, response.transactionStatus);
            _context19.t2 = {};
            _context19.next = 11;
            return Promise.all(response.transactionStatus.events.map( /*#__PURE__*/function () {
              var _decodeEvents = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee17(e) {
                return _regeneratorRuntime__default["default"].wrap(function _callee17$(_context17) {
                  while (1) {
                    switch (_context17.prev = _context17.next) {
                      case 0:
                        _context17.t0 = e.type;
                        _context17.t1 = e.transactionId;
                        _context17.t2 = e.transactionIndex;
                        _context17.t3 = e.eventIndex;
                        _context17.next = 6;
                        return decode$1(e.payload, customDecoders);

                      case 6:
                        _context17.t4 = _context17.sent;
                        return _context17.abrupt("return", {
                          type: _context17.t0,
                          transactionId: _context17.t1,
                          transactionIndex: _context17.t2,
                          eventIndex: _context17.t3,
                          data: _context17.t4
                        });

                      case 8:
                      case "end":
                        return _context17.stop();
                    }
                  }
                }, _callee17);
              }));

              function decodeEvents(_x31) {
                return _decodeEvents.apply(this, arguments);
              }

              return decodeEvents;
            }()));

          case 11:
            _context19.t3 = _context19.sent;
            _context19.t4 = {
              events: _context19.t3
            };
            return _context19.abrupt("return", (0, _context19.t0)(_context19.t1, _context19.t2, _context19.t4));

          case 16:
            if (!response.transaction) {
              _context19.next = 20;
              break;
            }

            return _context19.abrupt("return", response.transaction);

          case 20:
            if (!response.events) {
              _context19.next = 26;
              break;
            }

            _context19.next = 23;
            return Promise.all(response.events.map( /*#__PURE__*/function () {
              var _decodeEvents2 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee18(e) {
                return _regeneratorRuntime__default["default"].wrap(function _callee18$(_context18) {
                  while (1) {
                    switch (_context18.prev = _context18.next) {
                      case 0:
                        _context18.t0 = e.blockId;
                        _context18.t1 = e.blockHeight;
                        _context18.t2 = e.blockTimestamp;
                        _context18.t3 = e.type;
                        _context18.t4 = e.transactionId;
                        _context18.t5 = e.transactionIndex;
                        _context18.t6 = e.eventIndex;
                        _context18.next = 9;
                        return decode$1(e.payload, customDecoders);

                      case 9:
                        _context18.t7 = _context18.sent;
                        return _context18.abrupt("return", {
                          blockId: _context18.t0,
                          blockHeight: _context18.t1,
                          blockTimestamp: _context18.t2,
                          type: _context18.t3,
                          transactionId: _context18.t4,
                          transactionIndex: _context18.t5,
                          eventIndex: _context18.t6,
                          data: _context18.t7
                        });

                      case 11:
                      case "end":
                        return _context18.stop();
                    }
                  }
                }, _callee18);
              }));

              function decodeEvents(_x32) {
                return _decodeEvents2.apply(this, arguments);
              }

              return decodeEvents;
            }()));

          case 23:
            return _context19.abrupt("return", _context19.sent);

          case 26:
            if (!response.account) {
              _context19.next = 30;
              break;
            }

            return _context19.abrupt("return", response.account);

          case 30:
            if (!response.block) {
              _context19.next = 34;
              break;
            }

            return _context19.abrupt("return", response.block);

          case 34:
            if (!response.blockHeader) {
              _context19.next = 38;
              break;
            }

            return _context19.abrupt("return", response.blockHeader);

          case 38:
            if (!response.latestBlock) {
              _context19.next = 43;
              break;
            }

            latestBlockDeprecationNotice();
            return _context19.abrupt("return", response.latestBlock);

          case 43:
            if (!response.transactionId) {
              _context19.next = 47;
              break;
            }

            return _context19.abrupt("return", response.transactionId);

          case 47:
            if (!response.collection) {
              _context19.next = 49;
              break;
            }

            return _context19.abrupt("return", response.collection);

          case 49:
            return _context19.abrupt("return", null);

          case 50:
          case "end":
            return _context19.stop();
        }
      }
    }, _callee19);
  }));

  return function decodeResponse(_x30) {
    return _ref17.apply(this, arguments);
  };
}();

function getRefId(_x) {
  return _getRefId.apply(this, arguments);
}

function _getRefId() {
  _getRefId = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(opts) {
    var node, sendFn, ix;
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            _context2.next = 2;
            return config.config().get("accessNode.api");

          case 2:
            node = _context2.sent;
            _context2.next = 5;
            return config.config.first(["sdk.transport", "sdk.send"], transportHttp.send);

          case 5:
            sendFn = _context2.sent;
            utilInvariant.invariant(sendFn, "Required value for sdk.transport is not defined in config. See: ".concat("https://github.com/onflow/fcl-js/blob/master/packages/sdk/CHANGELOG.md#0057-alpha1----2022-01-21"));
            _context2.next = 9;
            return pipe(interaction(), [getBlock()]);

          case 9:
            ix = _context2.sent;
            _context2.next = 12;
            return sendFn(ix, {
              config: config.config,
              response: response,
              Buffer: rlp.Buffer,
              ix: ixModule
            }, {
              node: node
            });

          case 12:
            ix = _context2.sent;
            _context2.next = 15;
            return decodeResponse(ix);

          case 15:
            ix = _context2.sent;
            return _context2.abrupt("return", ix.id);

          case 17:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _getRefId.apply(this, arguments);
}

function resolveRefBlockId(opts) {
  return /*#__PURE__*/function () {
    var _ref = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix) {
      return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
        while (1) {
          switch (_context.prev = _context.next) {
            case 0:
              if (isTransaction(ix)) {
                _context.next = 2;
                break;
              }

              return _context.abrupt("return", Ok(ix));

            case 2:
              if (!ix.message.refBlock) {
                _context.next = 4;
                break;
              }

              return _context.abrupt("return", Ok(ix));

            case 4:
              _context.next = 6;
              return getRefId(opts);

            case 6:
              ix.message.refBlock = _context.sent;
              return _context.abrupt("return", Ok(ix));

            case 8:
            case "end":
              return _context.stop();
          }
        }
      }, _callee);
    }));

    return function (_x2) {
      return _ref.apply(this, arguments);
    };
  }();
}

var isFn$2 = function isFn(v) {
  return typeof v === "function";
};

var isString$1 = function isString(v) {
  return typeof v === "string";
};

function resolveCadence(_x) {
  return _resolveCadence.apply(this, arguments);
}

function _resolveCadence() {
  _resolveCadence = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix) {
    var cadence;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            if (!(isTransaction(ix) || isScript(ix))) {
              _context.next = 11;
              break;
            }

            cadence = get(ix, "ix.cadence");
            utilInvariant.invariant(isFn$2(cadence) || isString$1(cadence), "Cadence needs to be a function or a string.");

            if (!isFn$2(cadence)) {
              _context.next = 7;
              break;
            }

            _context.next = 6;
            return cadence({});

          case 6:
            cadence = _context.sent;

          case 7:
            utilInvariant.invariant(isString$1(cadence), "Cadence needs to be a string at this point.");
            _context.next = 10;
            return config.config().where(/^0x/).then(function (d) {
              return Object.entries(d).reduce(function (cadence, _ref) {
                var _ref2 = _slicedToArray__default["default"](_ref, 2),
                    key = _ref2[0],
                    value = _ref2[1];

                var regex = new RegExp("(\\b" + key + "\\b)", "g");
                return cadence.replace(regex, value);
              }, cadence);
            });

          case 10:
            ix.message.cadence = _context.sent;

          case 11:
            return _context.abrupt("return", ix);

          case 12:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _resolveCadence.apply(this, arguments);
}

var isFn$1 = function isFn(v) {
  return typeof v === "function";
};

function cast(arg) {
  // prettier-ignore
  utilInvariant.invariant(_typeof__default["default"](arg.xform) != null, "No type specified for argument: ".concat(arg.value));
  if (isFn$1(arg.xform)) return arg.xform(arg.value);
  if (isFn$1(arg.xform.asArgument)) return arg.xform.asArgument(arg.value); // prettier-ignore

  utilInvariant.invariant(false, "Invalid Argument", arg);
}

function handleArgResolution(_x) {
  return _handleArgResolution.apply(this, arguments);
}

function _handleArgResolution() {
  _handleArgResolution = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(arg) {
    var depth,
        resolvedArg,
        _args = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            depth = _args.length > 1 && _args[1] !== undefined ? _args[1] : 3;
            utilInvariant.invariant(depth > 0, "Argument Resolve Recursion Limit Exceeded for Arg: ".concat(arg.tempId));

            if (!isFn$1(arg.resolveArgument)) {
              _context.next = 9;
              break;
            }

            _context.next = 5;
            return arg.resolveArgument();

          case 5:
            resolvedArg = _context.sent;
            return _context.abrupt("return", handleArgResolution(resolvedArg, depth - 1));

          case 9:
            return _context.abrupt("return", arg);

          case 10:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _handleArgResolution.apply(this, arguments);
}

function resolveArguments(_x2) {
  return _resolveArguments.apply(this, arguments);
}

function _resolveArguments() {
  _resolveArguments = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(ix) {
    var _i, _Object$entries, _Object$entries$_i, id, arg, res;

    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            if (!(isTransaction(ix) || isScript(ix))) {
              _context2.next = 11;
              break;
            }

            _i = 0, _Object$entries = Object.entries(ix.arguments);

          case 2:
            if (!(_i < _Object$entries.length)) {
              _context2.next = 11;
              break;
            }

            _Object$entries$_i = _slicedToArray__default["default"](_Object$entries[_i], 2), id = _Object$entries$_i[0], arg = _Object$entries$_i[1];
            _context2.next = 6;
            return handleArgResolution(arg);

          case 6:
            res = _context2.sent;
            ix.arguments[id].asArgument = cast(res);

          case 8:
            _i++;
            _context2.next = 2;
            break;

          case 11:
            return _context2.abrupt("return", ix);

          case 12:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _resolveArguments.apply(this, arguments);
}

var encodeTransactionPayload = function encodeTransactionPayload(tx) {
  return prependTransactionDomainTag(rlpEncode(preparePayload(tx)));
};
var encodeTransactionEnvelope = function encodeTransactionEnvelope(tx) {
  return prependTransactionDomainTag(rlpEncode(prepareEnvelope(tx)));
};
var encodeTxIdFromVoucher = function encodeTxIdFromVoucher(voucher) {
  return sha3_256(rlpEncode(prepareVoucher(voucher)));
};

var rightPaddedHexBuffer = function rightPaddedHexBuffer(value, pad) {
  return rlp.Buffer.from(value.padEnd(pad * 2, 0), "hex");
};

var leftPaddedHexBuffer = function leftPaddedHexBuffer(value, pad) {
  return rlp.Buffer.from(value.padStart(pad * 2, 0), "hex");
};

var TRANSACTION_DOMAIN_TAG = rightPaddedHexBuffer(rlp.Buffer.from("FLOW-V0.0-transaction").toString("hex"), 32).toString("hex");

var prependTransactionDomainTag = function prependTransactionDomainTag(tx) {
  return TRANSACTION_DOMAIN_TAG + tx;
};

var addressBuffer = function addressBuffer(addr) {
  return leftPaddedHexBuffer(addr, 8);
};

var blockBuffer = function blockBuffer(block) {
  return leftPaddedHexBuffer(block, 32);
};

var argumentToString = function argumentToString(arg) {
  return rlp.Buffer.from(JSON.stringify(arg), "utf8");
};

var scriptBuffer = function scriptBuffer(script) {
  return rlp.Buffer.from(script, "utf8");
};

var signatureBuffer = function signatureBuffer(signature) {
  return rlp.Buffer.from(signature, "hex");
};

var rlpEncode = function rlpEncode(v) {
  return rlp.encode(v).toString("hex");
};

var sha3_256 = function sha3_256(msg) {
  var sha = new sha3.SHA3(256);
  sha.update(rlp.Buffer.from(msg, "hex"));
  return sha.digest().toString("hex");
};

var preparePayload = function preparePayload(tx) {
  validatePayload(tx);
  return [scriptBuffer(tx.cadence), tx.arguments.map(argumentToString), blockBuffer(tx.refBlock), tx.computeLimit, addressBuffer(utilAddress.sansPrefix(tx.proposalKey.address)), tx.proposalKey.keyId, tx.proposalKey.sequenceNum, addressBuffer(utilAddress.sansPrefix(tx.payer)), tx.authorizers.map(function (authorizer) {
    return addressBuffer(utilAddress.sansPrefix(authorizer));
  })];
};

var prepareEnvelope = function prepareEnvelope(tx) {
  validateEnvelope(tx);
  return [preparePayload(tx), preparePayloadSignatures(tx)];
};

var preparePayloadSignatures = function preparePayloadSignatures(tx) {
  var signers = collectSigners(tx);
  return tx.payloadSigs.map(function (sig) {
    return {
      signerIndex: signers.get(sig.address),
      keyId: sig.keyId,
      sig: sig.sig
    };
  }).sort(function (a, b) {
    if (a.signerIndex > b.signerIndex) return 1;
    if (a.signerIndex < b.signerIndex) return -1;
    if (a.keyId > b.keyId) return 1;
    if (a.keyId < b.keyId) return -1;
  }).map(function (sig) {
    return [sig.signerIndex, sig.keyId, signatureBuffer(sig.sig)];
  });
};

var collectSigners = function collectSigners(tx) {
  var signers = new Map();
  var i = 0;

  var addSigner = function addSigner(addr) {
    if (!signers.has(addr)) {
      signers.set(addr, i);
      i++;
    }
  };

  addSigner(tx.proposalKey.address);
  addSigner(tx.payer);
  tx.authorizers.forEach(addSigner);
  return signers;
};

var prepareVoucher = function prepareVoucher(voucher) {
  validateVoucher(voucher);
  var signers = collectSigners(voucher);

  var prepareSigs = function prepareSigs(sigs) {
    return sigs.map(function (_ref) {
      var address = _ref.address,
          keyId = _ref.keyId,
          sig = _ref.sig;
      return {
        signerIndex: signers.get(address),
        keyId: keyId,
        sig: sig
      };
    }).sort(function (a, b) {
      if (a.signerIndex > b.signerIndex) return 1;
      if (a.signerIndex < b.signerIndex) return -1;
      if (a.keyId > b.keyId) return 1;
      if (a.keyId < b.keyId) return -1;
    }).map(function (sig) {
      return [sig.signerIndex, sig.keyId, signatureBuffer(sig.sig)];
    });
  };

  return [[scriptBuffer(voucher.cadence), voucher.arguments.map(argumentToString), blockBuffer(voucher.refBlock), voucher.computeLimit, addressBuffer(utilAddress.sansPrefix(voucher.proposalKey.address)), voucher.proposalKey.keyId, voucher.proposalKey.sequenceNum, addressBuffer(utilAddress.sansPrefix(voucher.payer)), voucher.authorizers.map(function (authorizer) {
    return addressBuffer(utilAddress.sansPrefix(authorizer));
  })], prepareSigs(voucher.payloadSigs), prepareSigs(voucher.envelopeSigs)];
};

var validatePayload = function validatePayload(tx) {
  payloadFields.forEach(function (field) {
    return checkField(tx, field);
  });
  proposalKeyFields.forEach(function (field) {
    return checkField(tx.proposalKey, field, "proposalKey");
  });
};

var validateEnvelope = function validateEnvelope(tx) {
  payloadSigsFields.forEach(function (field) {
    return checkField(tx, field);
  });
  tx.payloadSigs.forEach(function (sig, index) {
    payloadSigFields.forEach(function (field) {
      return checkField(sig, field, "payloadSigs", index);
    });
  });
};

var validateVoucher = function validateVoucher(voucher) {
  payloadFields.forEach(function (field) {
    return checkField(voucher, field);
  });
  proposalKeyFields.forEach(function (field) {
    return checkField(voucher.proposalKey, field, "proposalKey");
  });
  payloadSigsFields.forEach(function (field) {
    return checkField(voucher, field);
  });
  voucher.payloadSigs.forEach(function (sig, index) {
    payloadSigFields.forEach(function (field) {
      return checkField(sig, field, "payloadSigs", index);
    });
  });
  envelopeSigsFields.forEach(function (field) {
    return checkField(voucher, field);
  });
  voucher.envelopeSigs.forEach(function (sig, index) {
    envelopeSigFields.forEach(function (field) {
      return checkField(sig, field, "envelopeSigs", index);
    });
  });
};

var isNumber = function isNumber(v) {
  return typeof v === "number";
};

var isString = function isString(v) {
  return typeof v === "string";
};

var isObject = function isObject(v) {
  return v !== null && _typeof__default["default"](v) === "object";
};

var isArray = function isArray(v) {
  return isObject(v) && v instanceof Array;
};

var payloadFields = [{
  name: "cadence",
  check: isString
}, {
  name: "arguments",
  check: isArray
}, {
  name: "refBlock",
  check: isString,
  defaultVal: "0"
}, {
  name: "computeLimit",
  check: isNumber
}, {
  name: "proposalKey",
  check: isObject
}, {
  name: "payer",
  check: isString
}, {
  name: "authorizers",
  check: isArray
}];
var proposalKeyFields = [{
  name: "address",
  check: isString
}, {
  name: "keyId",
  check: isNumber
}, {
  name: "sequenceNum",
  check: isNumber
}];
var payloadSigsFields = [{
  name: "payloadSigs",
  check: isArray
}];
var payloadSigFields = [{
  name: "address",
  check: isString
}, {
  name: "keyId",
  check: isNumber
}, {
  name: "sig",
  check: isString
}];
var envelopeSigsFields = [{
  name: "envelopeSigs",
  check: isArray
}];
var envelopeSigFields = [{
  name: "address",
  check: isString
}, {
  name: "keyId",
  check: isNumber
}, {
  name: "sig",
  check: isString
}];

var checkField = function checkField(obj, field, base, index) {
  var name = field.name,
      check = field.check,
      defaultVal = field.defaultVal;
  if (obj[name] == null && defaultVal != null) obj[name] = defaultVal;
  if (obj[name] == null) throw missingFieldError(name, base, index);
  if (!check(obj[name])) throw invalidFieldError(name, base, index);
};

var printFieldName = function printFieldName(field, base, index) {
  if (!!base) return index == null ? "".concat(base, ".").concat(field) : "".concat(base, ".").concat(index, ".").concat(field);
  return field;
};

var missingFieldError = function missingFieldError(field, base, index) {
  return new Error("Missing field ".concat(printFieldName(field, base, index)));
};

var invalidFieldError = function invalidFieldError(field, base, index) {
  return new Error("Invalid field ".concat(printFieldName(field, base, index)));
};

function findInsideSigners(ix) {
  // Inside Signers Are: (authorizers + proposer) - payer
  var inside = new Set(ix.authorizations);
  inside.add(ix.proposer);

  if (Array.isArray(ix.payer)) {
    ix.payer.forEach(function (p) {
      return inside["delete"](p);
    });
  } else {
    inside["delete"](ix.payer);
  }

  return Array.from(inside);
}
function findOutsideSigners(ix) {
  // Outside Signers Are: (payer)
  var outside = new Set(Array.isArray(ix.payer) ? ix.payer : [ix.payer]);
  return Array.from(outside);
}
var createSignableVoucher = function createSignableVoucher(ix) {
  var buildAuthorizers = function buildAuthorizers() {
    var authorizations = ix.authorizations.map(function (cid) {
      return utilAddress.withPrefix(ix.accounts[cid].addr);
    }).reduce(function (prev, current) {
      return prev.find(function (item) {
        return item === current;
      }) ? prev : [].concat(_toConsumableArray__default["default"](prev), [current]);
    }, []);
    return authorizations[0] ? authorizations : [];
  };

  var buildInsideSigners = function buildInsideSigners() {
    return findInsideSigners(ix).map(function (id) {
      return {
        address: utilAddress.withPrefix(ix.accounts[id].addr),
        keyId: ix.accounts[id].keyId,
        sig: ix.accounts[id].signature
      };
    });
  };

  var buildOutsideSigners = function buildOutsideSigners() {
    return findOutsideSigners(ix).map(function (id) {
      return {
        address: utilAddress.withPrefix(ix.accounts[id].addr),
        keyId: ix.accounts[id].keyId,
        sig: ix.accounts[id].signature
      };
    });
  };

  return {
    cadence: ix.message.cadence,
    refBlock: ix.message.refBlock || null,
    computeLimit: ix.message.computeLimit,
    arguments: ix.message.arguments.map(function (id) {
      return ix.arguments[id].asArgument;
    }),
    proposalKey: {
      address: utilAddress.withPrefix(ix.accounts[ix.proposer].addr),
      keyId: ix.accounts[ix.proposer].keyId,
      sequenceNum: ix.accounts[ix.proposer].sequenceNum
    },
    payer: utilAddress.withPrefix(ix.accounts[Array.isArray(ix.payer) ? ix.payer[0] : ix.payer].addr),
    authorizers: buildAuthorizers(),
    payloadSigs: buildInsideSigners(),
    envelopeSigs: buildOutsideSigners()
  };
};
var voucherToTxId = function voucherToTxId(voucher) {
  return encodeTxIdFromVoucher(voucher);
};

var idof$1 = function idof(acct) {
  return "".concat(utilAddress.withPrefix(acct.addr), "-").concat(acct.keyId);
};

var isFn = function isFn(v) {
  return typeof v === "function";
};

function buildPreSignable(acct, ix) {
  try {
    return {
      f_type: "PreSignable",
      f_vsn: "1.0.1",
      roles: acct.role,
      cadence: ix.message.cadence,
      args: ix.message.arguments.map(function (d) {
        return ix.arguments[d].asArgument;
      }),
      data: {},
      interaction: ix,
      voucher: createSignableVoucher(ix)
    };
  } catch (error) {
    console.error("buildPreSignable", error);
    throw error;
  }
}

function collectAccounts(_x, _x2, _x3) {
  return _collectAccounts.apply(this, arguments);
}

function _collectAccounts() {
  _collectAccounts = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix, accounts, last) {
    var depth,
        authorizations,
        _iterator,
        _step,
        _loop,
        old,
        _args2 = arguments;

    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            depth = _args2.length > 3 && _args2[3] !== undefined ? _args2[3] : 3;
            utilInvariant.invariant(depth, "Account Resolve Recursion Limit Exceeded", {
              ix: ix,
              accounts: accounts
            });
            authorizations = [];
            _iterator = _createForOfIteratorHelper__default["default"](accounts);
            _context2.prev = 4;
            _loop = /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _loop() {
              var ax, resolve, dupList, payerAccts, multiAccts;
              return _regeneratorRuntime__default["default"].wrap(function _loop$(_context) {
                while (1) {
                  switch (_context.prev = _context.next) {
                    case 0:
                      ax = _step.value;
                      resolve = ax.resolve;
                      ax.resolve = null;
                      old = last || ax;

                      if (!isFn(resolve)) {
                        _context.next = 8;
                        break;
                      }

                      _context.next = 7;
                      return resolve(ax, buildPreSignable(ax, ix));

                    case 7:
                      ax = _context.sent;

                    case 8:
                      if (!Array.isArray(ax)) {
                        _context.next = 13;
                        break;
                      }

                      _context.next = 11;
                      return collectAccounts(ix, ax, old, depth - 1);

                    case 11:
                      _context.next = 30;
                      break;

                    case 13:
                      if (ax.addr) {
                        ax.addr = utilAddress.sansPrefix(ax.addr);
                      }

                      if (ax.addr != null && ax.keyId != null) {
                        ax.tempId = idof$1(ax);
                      }

                      ix.accounts[ax.tempId] = ix.accounts[ax.tempId] || ax;
                      ix.accounts[ax.tempId].role.proposer = ix.accounts[ax.tempId].role.proposer || ax.role.proposer;
                      ix.accounts[ax.tempId].role.payer = ix.accounts[ax.tempId].role.payer || ax.role.payer;
                      ix.accounts[ax.tempId].role.authorizer = ix.accounts[ax.tempId].role.authorizer || ax.role.authorizer;

                      if (ix.accounts[ax.tempId].role.proposer && ix.proposer === old.tempId) {
                        ix.proposer = ax.tempId;
                      }

                      if (!ix.accounts[ax.tempId].role.payer) {
                        _context.next = 29;
                        break;
                      }

                      if (Array.isArray(ix.payer)) {
                        ix.payer = Array.from(new Set([].concat(_toConsumableArray__default["default"](ix.payer), [ax.tempId]).map(function (d) {
                          return d === old.tempId ? ax.tempId : d;
                        })));
                      } else {
                        ix.payer = Array.from(new Set([ix.payer, ax.tempId].map(function (d) {
                          return d === old.tempId ? ax.tempId : d;
                        })));
                      }

                      if (!(ix.payer.length > 1)) {
                        _context.next = 29;
                        break;
                      }

                      // remove payer dups based on addr and keyId
                      dupList = [];
                      payerAccts = [];
                      ix.payer = ix.payer.reduce(function (g, tempId) {
                        var addr = ix.accounts[tempId].addr;
                        var key = idof$1(ix.accounts[tempId]);
                        payerAccts.push(addr);
                        if (dupList.includes(key)) return g;
                        dupList.push(key);
                        return [].concat(_toConsumableArray__default["default"](g), [tempId]);
                      }, []);
                      multiAccts = Array.from(new Set(payerAccts));

                      if (!(multiAccts.length > 1)) {
                        _context.next = 29;
                        break;
                      }

                      throw new Error("Payer can not be different accounts");

                    case 29:
                      if (ix.accounts[ax.tempId].role.authorizer) {
                        if (last) {
                          // do group replacement
                          authorizations = Array.from(new Set([].concat(_toConsumableArray__default["default"](authorizations), [ax.tempId])));
                        } else {
                          // do 1-1 replacement
                          ix.authorizations = ix.authorizations.map(function (d) {
                            return d === old.tempId ? ax.tempId : d;
                          });
                        }
                      }

                    case 30:
                      if (old.tempId != ax.tempId) delete ix.accounts[old.tempId];

                    case 31:
                    case "end":
                      return _context.stop();
                  }
                }
              }, _loop);
            });

            _iterator.s();

          case 7:
            if ((_step = _iterator.n()).done) {
              _context2.next = 11;
              break;
            }

            return _context2.delegateYield(_loop(), "t0", 9);

          case 9:
            _context2.next = 7;
            break;

          case 11:
            _context2.next = 16;
            break;

          case 13:
            _context2.prev = 13;
            _context2.t1 = _context2["catch"](4);

            _iterator.e(_context2.t1);

          case 16:
            _context2.prev = 16;

            _iterator.f();

            return _context2.finish(16);

          case 19:
            if (last) {
              // complete (flatmap) group replacement
              ix.authorizations = ix.authorizations.map(function (d) {
                return d === last.tempId ? authorizations : d;
              }).reduce(function (prev, curr) {
                return Array.isArray(curr) ? [].concat(_toConsumableArray__default["default"](prev), _toConsumableArray__default["default"](curr)) : [].concat(_toConsumableArray__default["default"](prev), [curr]);
              }, []);
            }

          case 20:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee, null, [[4, 13, 16, 19]]);
  }));
  return _collectAccounts.apply(this, arguments);
}

function resolveAccounts(_x4) {
  return _resolveAccounts.apply(this, arguments);
}

function _resolveAccounts() {
  _resolveAccounts = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(ix) {
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context3) {
      while (1) {
        switch (_context3.prev = _context3.next) {
          case 0:
            if (!isTransaction(ix)) {
              _context3.next = 13;
              break;
            }

            if (!Array.isArray(ix.payer)) {
              logger.log.deprecate({
                pkg: "FCL",
                subject: '"ix.payer" must be an array. Support for ix.payer as a singular',
                message: "See changelog for more info."
              });
            }

            _context3.prev = 2;
            _context3.next = 5;
            return collectAccounts(ix, Object.values(ix.accounts));

          case 5:
            _context3.next = 7;
            return collectAccounts(ix, Object.values(ix.accounts));

          case 7:
            _context3.next = 13;
            break;

          case 9:
            _context3.prev = 9;
            _context3.t0 = _context3["catch"](2);
            console.error("=== SAD PANDA ===\n\n", _context3.t0, "\n\n=== SAD PANDA ===");
            throw _context3.t0;

          case 13:
            return _context3.abrupt("return", ix);

          case 14:
          case "end":
            return _context3.stop();
        }
      }
    }, _callee2, null, [[2, 9]]);
  }));
  return _resolveAccounts.apply(this, arguments);
}

function resolveSignatures(_x) {
  return _resolveSignatures.apply(this, arguments);
}

function _resolveSignatures() {
  _resolveSignatures = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(ix) {
    var insideSigners, insidePayload, outsideSigners, outsidePayload;
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            if (!isTransaction(ix)) {
              _context2.next = 16;
              break;
            }

            _context2.prev = 1;
            insideSigners = findInsideSigners(ix);
            insidePayload = encodeTransactionPayload(prepForEncoding(ix));
            _context2.next = 6;
            return Promise.all(insideSigners.map(fetchSignature(ix, insidePayload)));

          case 6:
            outsideSigners = findOutsideSigners(ix);
            outsidePayload = encodeTransactionEnvelope(_objectSpread__default["default"](_objectSpread__default["default"]({}, prepForEncoding(ix)), {}, {
              payloadSigs: insideSigners.map(function (id) {
                return {
                  address: ix.accounts[id].addr,
                  keyId: ix.accounts[id].keyId,
                  sig: ix.accounts[id].signature
                };
              })
            }));
            _context2.next = 10;
            return Promise.all(outsideSigners.map(fetchSignature(ix, outsidePayload)));

          case 10:
            _context2.next = 16;
            break;

          case 12:
            _context2.prev = 12;
            _context2.t0 = _context2["catch"](1);
            console.error("Signatures", _context2.t0, {
              ix: ix
            });
            throw _context2.t0;

          case 16:
            return _context2.abrupt("return", ix);

          case 17:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2, null, [[1, 12]]);
  }));
  return _resolveSignatures.apply(this, arguments);
}

function fetchSignature(ix, payload) {
  return /*#__PURE__*/function () {
    var _innerFetchSignature = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(id) {
      var acct, _yield$acct$signingFu, signature;

      return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
        while (1) {
          switch (_context.prev = _context.next) {
            case 0:
              acct = ix.accounts[id];

              if (!(acct.signature != null)) {
                _context.next = 3;
                break;
              }

              return _context.abrupt("return");

            case 3:
              _context.next = 5;
              return acct.signingFunction(buildSignable(acct, payload, ix));

            case 5:
              _yield$acct$signingFu = _context.sent;
              signature = _yield$acct$signingFu.signature;
              ix.accounts[id].signature = signature;

            case 8:
            case "end":
              return _context.stop();
          }
        }
      }, _callee);
    }));

    function innerFetchSignature(_x2) {
      return _innerFetchSignature.apply(this, arguments);
    }

    return innerFetchSignature;
  }();
}

function buildSignable(acct, message, ix) {
  try {
    return {
      f_type: "Signable",
      f_vsn: "1.0.1",
      message: message,
      addr: utilAddress.sansPrefix(acct.addr),
      keyId: acct.keyId,
      roles: acct.role,
      cadence: ix.message.cadence,
      args: ix.message.arguments.map(function (d) {
        return ix.arguments[d].asArgument;
      }),
      data: {},
      interaction: ix,
      voucher: createSignableVoucher(ix)
    };
  } catch (error) {
    console.error("buildSignable", error);
    throw error;
  }
}

function prepForEncoding(ix) {
  var payerAddress = utilAddress.sansPrefix((Array.isArray(ix.payer) ? ix.accounts[ix.payer[0]] : ix.accounts[ix.payer]).addr);
  return {
    cadence: ix.message.cadence,
    refBlock: ix.message.refBlock || null,
    computeLimit: ix.message.computeLimit,
    arguments: ix.message.arguments.map(function (id) {
      return ix.arguments[id].asArgument;
    }),
    proposalKey: {
      address: utilAddress.sansPrefix(ix.accounts[ix.proposer].addr),
      keyId: ix.accounts[ix.proposer].keyId,
      sequenceNum: ix.accounts[ix.proposer].sequenceNum
    },
    payer: payerAddress,
    authorizers: ix.authorizations.map(function (cid) {
      return utilAddress.sansPrefix(ix.accounts[cid].addr);
    }).reduce(function (prev, current) {
      return prev.find(function (item) {
        return item === current;
      }) ? prev : [].concat(_toConsumableArray__default["default"](prev), [current]);
    }, [])
  };
}

function resolveValidators(_x) {
  return _resolveValidators.apply(this, arguments);
}

function _resolveValidators() {
  _resolveValidators = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix) {
    var validators;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            validators = get(ix, "ix.validators", []);
            return _context.abrupt("return", pipe(ix, validators.map(function (cb) {
              return function (ix) {
                return cb(ix, {
                  Ok: Ok,
                  Bad: Bad
                });
              };
            })));

          case 2:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _resolveValidators.apply(this, arguments);
}

function resolveFinalNormalization(_x) {
  return _resolveFinalNormalization.apply(this, arguments);
}

function _resolveFinalNormalization() {
  _resolveFinalNormalization = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix) {
    var _i, _Object$keys, key;

    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            for (_i = 0, _Object$keys = Object.keys(ix.accounts); _i < _Object$keys.length; _i++) {
              key = _Object$keys[_i];
              ix.accounts[key].addr = utilAddress.sansPrefix(ix.accounts[key].addr);
            }

            return _context.abrupt("return", ix);

          case 2:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _resolveFinalNormalization.apply(this, arguments);
}

function resolveVoucherIntercept(_x) {
  return _resolveVoucherIntercept.apply(this, arguments);
}

function _resolveVoucherIntercept() {
  _resolveVoucherIntercept = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix) {
    var fn;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            fn = get(ix, "ix.voucher-intercept");

            if (!isFn$3(fn)) {
              _context.next = 4;
              break;
            }

            _context.next = 4;
            return fn(createSignableVoucher(ix));

          case 4:
            return _context.abrupt("return", ix);

          case 5:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _resolveVoucherIntercept.apply(this, arguments);
}

var DEFAULT_COMPUTE_LIMIT = 100;
function resolveComputeLimit(_x) {
  return _resolveComputeLimit.apply(this, arguments);
}

function _resolveComputeLimit() {
  _resolveComputeLimit = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix) {
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            if (!isTransaction(ix)) {
              _context.next = 8;
              break;
            }

            _context.t0 = ix.message.computeLimit;

            if (_context.t0) {
              _context.next = 6;
              break;
            }

            _context.next = 5;
            return config.config.get("fcl.limit");

          case 5:
            _context.t0 = _context.sent;

          case 6:
            ix.message.computeLimit = _context.t0;

            if (!ix.message.computeLimit) {
              logger__namespace.log.deprecate({
                pkg: "FCL/SDK",
                subject: "The built-in default compute limit (DEFAULT_COMPUTE_LIMIT=10)",
                transition: "https://github.com/onflow/flow-js-sdk/blob/master/packages/sdk/TRANSITIONS.md#0009-deprecate-default-compute-limit"
              });
              ix.message.computeLimit = DEFAULT_COMPUTE_LIMIT;
            }

          case 8:
            return _context.abrupt("return", ix);

          case 9:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _resolveComputeLimit.apply(this, arguments);
}

var noop = function noop(v) {
  return v;
};

var debug = function debug(key) {
  var fn = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : noop;
  return /*#__PURE__*/function () {
    var _ref = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix) {
      var accts, log;
      return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
        while (1) {
          switch (_context.prev = _context.next) {
            case 0:

              accts = function accts(ix) {
                return ["\nAccounts:", {
                  proposer: ix.proposer,
                  authorizations: ix.authorizations,
                  payer: ix.payer
                }, "\n\nDetails:", ix.accounts].filter(Boolean);
              };

              log = function log() {
                var _console;

                for (var _len = arguments.length, msg = new Array(_len), _key = 0; _key < _len; _key++) {
                  msg[_key] = arguments[_key];
                }

                (_console = console).log.apply(_console, ["debug[".concat(key, "] ---\n")].concat(msg, ["\n\n\n---"]));
              };

              _context.next = 5;
              return config.config.get("debug.".concat(key));

            case 5:
              if (!_context.sent) {
                _context.next = 8;
                break;
              }

              _context.next = 8;
              return fn(ix, log, accts);

            case 8:
              return _context.abrupt("return", ix);

            case 9:
            case "end":
              return _context.stop();
          }
        }
      }, _callee);
    }));

    return function (_x) {
      return _ref.apply(this, arguments);
    };
  }();
};

var resolve = pipe([resolveCadence, debug("cadence", function (ix, log) {
  return log(ix.message.cadence);
}), resolveComputeLimit, debug("compute limit", function (ix, log) {
  return log(ix.message.computeLimit);
}), resolveArguments, debug("arguments", function (ix, log) {
  return log(ix.message.arguments, ix.message);
}), resolveAccounts, debug("accounts", function (ix, log, accts) {
  return log.apply(void 0, _toConsumableArray__default["default"](accts(ix)));
}),
/* special */
execFetchRef,
/* special */
execFetchSequenceNumber, resolveSignatures, debug("signatures", function (ix, log, accts) {
  return log.apply(void 0, _toConsumableArray__default["default"](accts(ix)));
}), resolveFinalNormalization, resolveValidators, resolveVoucherIntercept, debug("resolved", function (ix, log) {
  return log(ix);
})]);

function execFetchRef(_x2) {
  return _execFetchRef.apply(this, arguments);
}

function _execFetchRef() {
  _execFetchRef = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(ix) {
    var node, sendFn;
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            if (!(isTransaction(ix) && ix.message.refBlock == null)) {
              _context2.next = 11;
              break;
            }

            _context2.next = 3;
            return config.config().get("accessNode.api");

          case 3:
            node = _context2.sent;
            _context2.next = 6;
            return config.config.first(["sdk.transport", "sdk.send"], transportHttp.send);

          case 6:
            sendFn = _context2.sent;
            utilInvariant.invariant(sendFn, "Required value for sdk.transport is not defined in config. See: ".concat("https://github.com/onflow/fcl-js/blob/master/packages/sdk/CHANGELOG.md#0057-alpha1----2022-01-21"));
            _context2.next = 10;
            return sendFn(build([getBlock()]), {
              config: config.config,
              response: response,
              Buffer: rlp.Buffer,
              ix: ixModule
            }, {
              node: node
            }).then(decodeResponse);

          case 10:
            ix.message.refBlock = _context2.sent.id;

          case 11:
            return _context2.abrupt("return", ix);

          case 12:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _execFetchRef.apply(this, arguments);
}

function execFetchSequenceNumber(_x3) {
  return _execFetchSequenceNumber.apply(this, arguments);
}

function _execFetchSequenceNumber() {
  _execFetchSequenceNumber = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(ix) {
    var acct, node, sendFn;
    return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
      while (1) {
        switch (_context3.prev = _context3.next) {
          case 0:
            if (!isTransaction(ix)) {
              _context3.next = 20;
              break;
            }

            acct = Object.values(ix.accounts).find(function (a) {
              return a.role.proposer;
            });
            utilInvariant.invariant(acct, "Transactions require a proposer");

            if (!(acct.sequenceNum == null)) {
              _context3.next = 20;
              break;
            }

            _context3.next = 6;
            return config.config().get("accessNode.api");

          case 6:
            node = _context3.sent;
            _context3.next = 9;
            return config.config.first(["sdk.transport", "sdk.send"], transportHttp.send);

          case 9:
            sendFn = _context3.sent;
            utilInvariant.invariant(sendFn, "Required value for sdk.transport is not defined in config. See: ".concat("https://github.com/onflow/fcl-js/blob/master/packages/sdk/CHANGELOG.md#0057-alpha1----2022-01-21"));
            _context3.t0 = sendFn;
            _context3.next = 14;
            return build([getAccount(acct.addr)]);

          case 14:
            _context3.t1 = _context3.sent;
            _context3.t2 = {
              config: config.config,
              response: response,
              Buffer: rlp.Buffer,
              ix: ixModule
            };
            _context3.t3 = {
              node: node
            };
            _context3.next = 19;
            return (0, _context3.t0)(_context3.t1, _context3.t2, _context3.t3).then(decodeResponse).then(function (acct) {
              return acct.keys;
            }).then(function (keys) {
              return keys.find(function (key) {
                return key.index === acct.keyId;
              });
            }).then(function (key) {
              return key.sequenceNumber;
            });

          case 19:
            ix.accounts[acct.tempId].sequenceNum = _context3.sent;

          case 20:
            return _context3.abrupt("return", ix);

          case 21:
          case "end":
            return _context3.stop();
        }
      }
    }, _callee3);
  }));
  return _execFetchSequenceNumber.apply(this, arguments);
}

function invariant() {
  for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
    args[_key] = arguments[_key];
  }

  if (args.length > 1) {
    var predicate = args[0],
        message = args[1];
    return invariant(function (ix, _ref) {
      var Ok = _ref.Ok,
          Bad = _ref.Bad;
      return predicate ? Ok(ix) : Bad(ix, message);
    });
  }

  var fn = args[0];
  return function (ix) {
    return fn(ix, {
      Ok: Ok,
      Bad: Bad
    });
  };
}

var send = /*#__PURE__*/function () {
  var _ref = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee() {
    var args,
        opts,
        sendFn,
        resolveFn,
        _args = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            args = _args.length > 0 && _args[0] !== undefined ? _args[0] : [];
            opts = _args.length > 1 && _args[1] !== undefined ? _args[1] : {};
            _context.next = 4;
            return config.config.first(["sdk.transport", "sdk.send"], opts.send || transportHttp.send);

          case 4:
            sendFn = _context.sent;
            invariant(sendFn, "Required value for sdk.transport is not defined in config. See: ".concat("https://github.com/onflow/fcl-js/blob/master/packages/sdk/CHANGELOG.md#0057-alpha1----2022-01-21"));
            _context.next = 8;
            return config.config.first(["sdk.resolve"], opts.resolve || resolve);

          case 8:
            resolveFn = _context.sent;
            _context.t0 = opts.node;

            if (_context.t0) {
              _context.next = 14;
              break;
            }

            _context.next = 13;
            return config.config().get("accessNode.api");

          case 13:
            _context.t0 = _context.sent;

          case 14:
            opts.node = _context.t0;
            if (Array.isArray(args)) args = pipe(interaction(), args);
            _context.t1 = sendFn;
            _context.next = 19;
            return resolveFn(args);

          case 19:
            _context.t2 = _context.sent;
            _context.t3 = {
              config: config.config,
              response: response,
              ix: ixModule,
              Buffer: rlp.Buffer
            };
            _context.t4 = opts;
            return _context.abrupt("return", (0, _context.t1)(_context.t2, _context.t3, _context.t4));

          case 23:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));

  return function send() {
    return _ref.apply(this, arguments);
  };
}();

function decode(_x) {
  return _decode.apply(this, arguments);
}

function _decode() {
  _decode = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(response) {
    var decodersFromConfig, decoders;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            _context.next = 2;
            return config.config().where(/^decoder\./);

          case 2:
            decodersFromConfig = _context.sent;
            decoders = Object.entries(decodersFromConfig).map(function (_ref) {
              var _ref2 = _slicedToArray__default["default"](_ref, 2),
                  pattern = _ref2[0],
                  xform = _ref2[1];

              pattern = "/".concat(pattern.replace(/^decoder\./, ""), "$/");
              return [pattern, xform];
            });
            return _context.abrupt("return", decodeResponse(response, Object.fromEntries(decoders)));

          case 5:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _decode.apply(this, arguments);
}

var findPayloadSigners = function findPayloadSigners(voucher) {
  // Payload Signers Are: (authorizers + proposer) - payer
  var payload = new Set(voucher.authorizers);
  payload.add(voucher.proposalKey.address);
  payload["delete"](voucher.payer);
  return Array.from(payload).map(utilAddress.withPrefix);
};

var findEnvelopeSigners = function findEnvelopeSigners(voucher) {
  // Envelope Signers Are: (payer)
  var envelope = new Set([voucher.payer]);
  return Array.from(envelope).map(utilAddress.withPrefix);
};

var UnableToDetermineMessageEncodingTypeForSignerAddress = /*#__PURE__*/function (_Error) {
  _inherits__default["default"](UnableToDetermineMessageEncodingTypeForSignerAddress, _Error);

  var _super = _createSuper__default["default"](UnableToDetermineMessageEncodingTypeForSignerAddress);

  function UnableToDetermineMessageEncodingTypeForSignerAddress(signerAddress) {
    var _this;

    _classCallCheck__default["default"](this, UnableToDetermineMessageEncodingTypeForSignerAddress);

    var msg = "\n        Encode Message From Signable Error: Unable to determine message encoding for signer addresss: ".concat(signerAddress, ". \n        Please ensure the address: ").concat(signerAddress, " is intended to sign the given transaction as specified by the transaction signable.\n      ").trim();
    _this = _super.call(this, msg);
    _this.name = "Unable To Determine Message Encoding For Signer Addresss";
    return _this;
  }

  return _createClass__default["default"](UnableToDetermineMessageEncodingTypeForSignerAddress);
}( /*#__PURE__*/_wrapNativeSuper__default["default"](Error));
var encodeMessageFromSignable = function encodeMessageFromSignable(signable, signerAddress) {
  var payloadSigners = findPayloadSigners(signable.voucher);
  var envelopeSigners = findEnvelopeSigners(signable.voucher);
  var isPayloadSigner = payloadSigners.includes(utilAddress.withPrefix(signerAddress));
  var isEnvelopeSigner = envelopeSigners.includes(utilAddress.withPrefix(signerAddress));

  if (!isPayloadSigner && !isEnvelopeSigner) {
    throw new UnableToDetermineMessageEncodingTypeForSignerAddress(signerAddress);
  }

  var message = {
    cadence: signable.voucher.cadence,
    refBlock: signable.voucher.refBlock,
    computeLimit: signable.voucher.computeLimit,
    arguments: signable.voucher.arguments,
    proposalKey: _objectSpread__default["default"](_objectSpread__default["default"]({}, signable.voucher.proposalKey), {}, {
      address: utilAddress.sansPrefix(signable.voucher.proposalKey.address)
    }),
    payer: utilAddress.sansPrefix(signable.voucher.payer),
    authorizers: signable.voucher.authorizers.map(utilAddress.sansPrefix),
    payloadSigs: signable.voucher.payloadSigs.map(function (ps) {
      return _objectSpread__default["default"](_objectSpread__default["default"]({}, ps), {}, {
        address: utilAddress.sansPrefix(ps.address)
      });
    })
  };
  return isPayloadSigner ? encodeTransactionPayload(message) : encodeTransactionEnvelope(message);
};

function validator(cb) {
  return update("ix.validators", function (validators) {
    return Array.isArray(validators) ? validators.push(cb) : [cb];
  });
}

function atBlockHeight(height) {
  return pipe([function (ix) {
    ix.block.height = height;
    return ix;
  }, validator(function (ix) {
    if (typeof ix.block.isSealed === "boolean") throw new Error("Unable to specify both block height and isSealed.");
    if (ix.block.id) throw new Error("Unable to specify both block height and block id.");
    return ix;
  })]);
}

function atBlockId(id) {
  return pipe([function (ix) {
    ix.block.id = id;
    return Ok(ix);
  }, validator(function (ix, _ref) {
    var Ok = _ref.Ok,
        Bad = _ref.Bad;
    if (isGetAccount(ix)) return Bad(ix, "Unable to specify a block id with a Get Account interaction.");
    if (typeof ix.block.isSealed === "boolean") return Bad(ix, "Unable to specify both block id and isSealed.");
    if (ix.block.height) return Bad(ix, "Unable to specify both block id and block height.");
    return Ok(ix);
  })]);
}

function account(address) {
  var _ref = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {},
      height = _ref.height,
      id = _ref.id;

  var opts = arguments.length > 2 ? arguments[2] : undefined;
  utilInvariant.invariant(!(id && height), "Method: account -- Cannot pass \"id\" and \"height\" simultaneously"); // Get account by ID

  if (id) return send([getAccount(address), atBlockId(id)], opts).then(decodeResponse); // Get account by height

  if (height) return send([getAccount(address), atBlockHeight(height)], opts).then(decodeResponse);
  return send([getAccount(address)], opts).then(decodeResponse);
}

function block() {
  var _ref = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {},
      _ref$sealed = _ref.sealed,
      sealed = _ref$sealed === void 0 ? false : _ref$sealed,
      id = _ref.id,
      height = _ref.height;

  var opts = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};
  utilInvariant.invariant(!(sealed && id || sealed && height), "Method: block -- Cannot pass \"sealed\" with \"id\" or \"height\"");
  utilInvariant.invariant(!(id && height), "Method: block -- Cannot pass \"id\" and \"height\" simultaneously"); // Get block by ID

  if (id) return send([getBlock(), atBlockId(id)], opts).then(decodeResponse); // Get block by height

  if (height) return send([getBlock(), atBlockHeight(height)], opts).then(decodeResponse); // Get latest block

  return send([getBlock(sealed)], opts).then(decodeResponse);
}

function authorizations() {
  var ax = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : [];
  return pipe(ax.map(function (authz) {
    return prepAccount(authz, {
      role: AUTHORIZER
    });
  }));
}
function authorization(addr, signingFunction, keyId, sequenceNum) {
  return {
    addr: addr,
    signingFunction: signingFunction,
    keyId: keyId,
    sequenceNum: sequenceNum
  };
}

function getEvents(eventType, start, end) {
  if (typeof start !== "undefined" || typeof end !== "undefined") {
    logger__namespace.log.deprecate({
      pkg: "FCL/SDK",
      subject: "Passing a start and end into getEvents",
      transition: "https://github.com/onflow/flow-js-sdk/blob/master/packages/sdk/TRANSITIONS.md#0005-deprecate-start-end-get-events-builder"
    });
  }

  return pipe([makeGetEvents, function (ix) {
    ix.events.eventType = eventType;
    ix.events.start = start;
    ix.events.end = end;
    return Ok(ix);
  }]);
}

function getEventsAtBlockHeightRange(eventType, start, end) {
  return pipe([makeGetEvents, function (ix) {
    ix.events.eventType = eventType;
    ix.events.start = start;
    ix.events.end = end;
    return Ok(ix);
  }]);
}

function getEventsAtBlockIds(eventType) {
  var blockIds = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : [];
  return pipe([makeGetEvents, function (ix) {
    ix.events.eventType = eventType;
    ix.events.blockIds = blockIds;
    return Ok(ix);
  }]);
}

function getBlockHeader() {
  var isSealed = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : null;
  return pipe([makeGetBlockHeader, function (ix) {
    ix.block.isSealed = isSealed;
    return Ok(ix);
  }]);
}

function getCollection() {
  var id = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : null;
  return pipe([makeGetCollection, function (ix) {
    ix.collection.id = id;
    return ix;
  }]);
}

function getTransactionStatus(transactionId) {
  return pipe([makeGetTransactionStatus, function (ix) {
    ix.transaction.id = transactionId;
    return Ok(ix);
  }]);
}

function getTransaction(transactionId) {
  return pipe([makeGetTransaction, function (ix) {
    ix.transaction.id = transactionId;
    return Ok(ix);
  }]);
}

function limit(computeLimit) {
  return function (ix) {
    ix.message.computeLimit = computeLimit;
    return ix;
  };
}

function args() {
  var ax = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : [];
  return pipe(ax.map(makeArgument));
}
function arg(value, xform) {
  return {
    value: value,
    xform: xform
  };
}

function proposer(_x) {
  return _proposer.apply(this, arguments);
}

function _proposer() {
  _proposer = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(authz) {
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            return _context.abrupt("return", prepAccount(authz, {
              role: PROPOSER
            }));

          case 1:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _proposer.apply(this, arguments);
}

function payer(_x) {
  return _payer.apply(this, arguments);
}

function _payer() {
  _payer = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(authz) {
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            return _context.abrupt("return", prepAccount(authz, {
              role: PAYER
            }));

          case 1:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _payer.apply(this, arguments);
}

function ping() {
  return makePing;
}

function ref(refBlock) {
  return pipe([function (ix) {
    ix.message.refBlock = refBlock;
    return Ok(ix);
  }]);
}

function script() {
  return pipe([makeScript, put("ix.cadence", utilTemplate.template.apply(void 0, arguments))]);
}

var DEFAULT_SCRIPT_ACCOUNTS = [];
var DEFUALT_REF = null;
function transaction() {
  return pipe([makeTransaction, put("ix.cadence", utilTemplate.template.apply(void 0, arguments)), function (ix) {
    ix.message.refBlock = ix.message.refBlock || DEFUALT_REF;
    ix.authorizations = ix.authorizations || DEFAULT_SCRIPT_ACCOUNTS;
    return Ok(ix);
  }]);
}

function voucherIntercept(fn) {
  return put("ix.voucher-intercept", fn);
}

var resolveProposerSequenceNumber = function resolveProposerSequenceNumber(_ref) {
  var node = _ref.node;
  return /*#__PURE__*/function () {
    var _ref2 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix) {
      var sendFn, response$1, decoded;
      return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
        while (1) {
          switch (_context.prev = _context.next) {
            case 0:
              if (isTransaction(ix)) {
                _context.next = 2;
                break;
              }

              return _context.abrupt("return", Ok(ix));

            case 2:
              if (!ix.accounts[ix.proposer].sequenceNum) {
                _context.next = 4;
                break;
              }

              return _context.abrupt("return", Ok(ix));

            case 4:
              _context.next = 6;
              return config.config.first(["sdk.transport", "sdk.send"], transportHttp.send);

            case 6:
              sendFn = _context.sent;
              utilInvariant.invariant(sendFn, "Required value for sdk.transport is not defined in config. See: ".concat("https://github.com/onflow/fcl-js/blob/master/packages/sdk/CHANGELOG.md#0057-alpha1----2022-01-21"));
              _context.t0 = sendFn;
              _context.next = 11;
              return build([getAccount(ix.accounts[ix.proposer].addr)]);

            case 11:
              _context.t1 = _context.sent;
              _context.t2 = {
                config: config.config,
                response: response,
                Buffer: rlp.Buffer,
                ix: ixModule
              };
              _context.t3 = {
                node: node
              };
              _context.next = 16;
              return (0, _context.t0)(_context.t1, _context.t2, _context.t3);

            case 16:
              response$1 = _context.sent;
              _context.next = 19;
              return decodeResponse(response$1);

            case 19:
              decoded = _context.sent;
              ix.accounts[ix.proposer].sequenceNum = decoded.keys[ix.accounts[ix.proposer].keyId].sequenceNumber;
              return _context.abrupt("return", Ok(ix));

            case 22:
            case "end":
              return _context.stop();
          }
        }
      }, _callee);
    }));

    return function (_x) {
      return _ref2.apply(this, arguments);
    };
  }();
};

function mockAccountResponse(ix) {
  var numberOfKeys = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : 5;
  // prettier-ignore
  utilInvariant.invariant(ix.account, "mockAccountResponse(ix) -- ix.account is missing", ix); // prettier-ignore

  utilInvariant.invariant(ix.account.addr, "mockAccountResponse(ix) -- ix.account.addr is missing", ix);
  var address = ix.account.addr;
  return {
    account: {
      addr: address,
      keys: Array.from({
        length: numberOfKeys
      }, function (_, i) {
        return {
          index: i,
          sequenceNumber: 42
        };
      })
    }
  };
}
function mockGetBlockResponse(ix) {
  return {
    tag: "GET_BLOCK",
    block: {
      id: "32"
    }
  };
}

var identity = function identity(v) {
  return v;
};

function mockSend() {
  var fallback = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : identity;
  return /*#__PURE__*/function () {
    var _execSend = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix) {
      return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
        while (1) {
          switch (_context.prev = _context.next) {
            case 0:
              _context.next = 2;
              return ix;

            case 2:
              ix = _context.sent;
              _context.t0 = true;
              _context.next = _context.t0 === isGetAccount(ix) ? 6 : _context.t0 === isGetBlock(ix) ? 7 : 8;
              break;

            case 6:
              return _context.abrupt("return", mockAccountResponse(ix));

            case 7:
              return _context.abrupt("return", mockGetBlockResponse());

            case 8:
              return _context.abrupt("return", fallback(ix));

            case 9:
            case "end":
              return _context.stop();
          }
        }
      }, _callee);
    }));

    function execSend(_x) {
      return _execSend.apply(this, arguments);
    }

    return execSend;
  }();
}

var _excluded = ["tempId"];
var idof = function idof(acct) {
  return "".concat(utilAddress.withPrefix(acct.addr), "-").concat(acct.keyId);
};
function sig(opts) {
  return ["SIGNATURE", opts.addr, opts.keyId].join(".");
}
function authzFn() {
  var opts = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
  return function (account) {
    var acct = _objectSpread__default["default"](_objectSpread__default["default"](_objectSpread__default["default"]({}, account), opts), {}, {
      signingFunction: opts.signingFunction || account.signingFunction || fallbackSigningFunction
    });

    return acct;

    function fallbackSigningFunction(signable) {
      return {
        addr: acct.addr,
        keyId: acct.keyId,
        signature: sig(acct)
      };
    }
  };
}
function authzResolve() {
  var opts = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
  return function (account) {
    var tempId = opts.tempId,
        rest = _objectWithoutProperties__default["default"](opts, _excluded);

    return _objectSpread__default["default"](_objectSpread__default["default"]({}, account), {}, {
      tempId: tempId || "WITH_RESOLVE",
      resolve: authzFn(rest)
    });
  };
}
var ROLE = {
  proposer: false,
  authorizer: false,
  payer: false
};

function authzResolveMany() {
  var opts = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
  return function (account) {
    var tempId = opts.tempId || "AUTHZ_RESOLVE_MANY";
    return _objectSpread__default["default"](_objectSpread__default["default"]({}, account), {}, {
      tempId: tempId,
      resolve: function resolve() {
        return [opts.proposer && authzFn(opts.proposer)({
          role: _objectSpread__default["default"](_objectSpread__default["default"]({}, ROLE), {}, {
            proposer: true
          })
        })].concat(_toConsumableArray__default["default"](opts.authorizations.map(authzFn).map(function (d) {
          return d({
            role: _objectSpread__default["default"](_objectSpread__default["default"]({}, ROLE), {}, {
              authorizer: true
            })
          });
        })), [opts.payer && authzFn(opts.payer)({
          role: _objectSpread__default["default"](_objectSpread__default["default"]({}, ROLE), {}, {
            payer: true
          })
        })]).filter(Boolean);
      }
    });
  };
}

var run = function run() {
  var fns = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : [];
  return build([ref("123")].concat(_toConsumableArray__default["default"](fns))).then(resolve);
};

var index = /*#__PURE__*/Object.freeze({
  __proto__: null,
  mockSend: mockSend,
  authzFn: authzFn,
  authzResolve: authzResolve,
  authzResolveMany: authzResolveMany,
  sig: sig,
  idof: idof,
  run: run
});

var VERSION = "1.1.2" ;

var params = function params(_params) {
  return logger__namespace.log.deprecate({
    pkg: "FCL/SDK",
    message: "The params builder has been removed from the Flow JS-SDK/FCL.",
    transition: "https://github.com/onflow/flow-js-sdk/blob/master/packages/sdk/TRANSITIONS.md#0001-deprecate-params",
    level: logger__namespace.LEVELS.error
  });
};
var param = function param(params) {
  return logger__namespace.log.deprecate({
    pkg: "FCL/SDK",
    message: "The param builder has been removed from the Flow JS-SDK/FCL.",
    transition: "https://github.com/onflow/flow-js-sdk/blob/master/packages/sdk/TRANSITIONS.md#0001-deprecate-params",
    level: logger__namespace.LEVELS.error
  });
};

Object.defineProperty(exports, 'config', {
  enumerable: true,
  get: function () { return config.config; }
});
Object.defineProperty(exports, 'cadence', {
  enumerable: true,
  get: function () { return utilTemplate.template; }
});
Object.defineProperty(exports, 'cdc', {
  enumerable: true,
  get: function () { return utilTemplate.template; }
});
exports.TestUtils = index;
exports.VERSION = VERSION;
exports.account = account;
exports.arg = arg;
exports.args = args;
exports.atBlockHeight = atBlockHeight;
exports.atBlockId = atBlockId;
exports.authorization = authorization;
exports.authorizations = authorizations;
exports.block = block;
exports.build = build;
exports.createSignableVoucher = createSignableVoucher;
exports.decode = decode;
exports.destroy = destroy;
exports.encodeMessageFromSignable = encodeMessageFromSignable;
exports.encodeTransactionEnvelope = encodeTransactionEnvelope;
exports.encodeTransactionPayload = encodeTransactionPayload;
exports.encodeTxIdFromVoucher = encodeTxIdFromVoucher;
exports.get = get;
exports.getAccount = getAccount;
exports.getBlock = getBlock;
exports.getBlockHeader = getBlockHeader;
exports.getCollection = getCollection;
exports.getEvents = getEvents;
exports.getEventsAtBlockHeightRange = getEventsAtBlockHeightRange;
exports.getEventsAtBlockIds = getEventsAtBlockIds;
exports.getTransaction = getTransaction;
exports.getTransactionStatus = getTransactionStatus;
exports.interaction = interaction;
exports.invariant = invariant;
exports.isBad = isBad;
exports.isGetAccount = isGetAccount;
exports.isGetBlock = isGetBlock;
exports.isGetBlockHeader = isGetBlockHeader;
exports.isGetCollection = isGetCollection;
exports.isGetEvents = isGetEvents;
exports.isGetTransaction = isGetTransaction;
exports.isGetTransactionStatus = isGetTransactionStatus;
exports.isOk = isOk;
exports.isPing = isPing;
exports.isScript = isScript;
exports.isTransaction = isTransaction;
exports.isUnknown = isUnknown;
exports.limit = limit;
exports.param = param;
exports.params = params;
exports.payer = payer;
exports.ping = ping;
exports.pipe = pipe;
exports.proposer = proposer;
exports.put = put;
exports.ref = ref;
exports.resolve = resolve;
exports.resolveAccounts = resolveAccounts;
exports.resolveArguments = resolveArguments;
exports.resolveCadence = resolveCadence;
exports.resolveFinalNormalization = resolveFinalNormalization;
exports.resolveProposerSequenceNumber = resolveProposerSequenceNumber;
exports.resolveRefBlockId = resolveRefBlockId;
exports.resolveSignatures = resolveSignatures;
exports.resolveValidators = resolveValidators;
exports.resolveVoucherIntercept = resolveVoucherIntercept;
exports.script = script;
exports.send = send;
exports.transaction = transaction;
exports.update = update;
exports.validator = validator;
exports.voucherIntercept = voucherIntercept;
exports.voucherToTxId = voucherToTxId;
exports.why = why;


},{"@babel/runtime/helpers/asyncToGenerator":6,"@babel/runtime/helpers/classCallCheck":7,"@babel/runtime/helpers/createClass":9,"@babel/runtime/helpers/createForOfIteratorHelper":10,"@babel/runtime/helpers/createSuper":11,"@babel/runtime/helpers/defineProperty":12,"@babel/runtime/helpers/inherits":14,"@babel/runtime/helpers/objectSpread2":21,"@babel/runtime/helpers/objectWithoutProperties":22,"@babel/runtime/helpers/slicedToArray":27,"@babel/runtime/helpers/toArray":28,"@babel/runtime/helpers/toConsumableArray":29,"@babel/runtime/helpers/typeof":32,"@babel/runtime/helpers/wrapNativeSuper":34,"@babel/runtime/regenerator":35,"@onflow/config":36,"@onflow/rlp":38,"@onflow/transport-http":40,"@onflow/util-address":43,"@onflow/util-invariant":44,"@onflow/util-logger":45,"@onflow/util-template":46,"sha3":53}],40:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var _asyncToGenerator = require('@babel/runtime/helpers/asyncToGenerator');
var _regeneratorRuntime = require('@babel/runtime/regenerator');
var utilInvariant = require('@onflow/util-invariant');
require('buffer');
var _createClass = require('@babel/runtime/helpers/createClass');
var _classCallCheck = require('@babel/runtime/helpers/classCallCheck');
var _inherits = require('@babel/runtime/helpers/inherits');
var _createSuper = require('@babel/runtime/helpers/createSuper');
var _wrapNativeSuper = require('@babel/runtime/helpers/wrapNativeSuper');
var logger = require('@onflow/util-logger');
var fetchTransport = require('node-fetch');
var _toConsumableArray = require('@babel/runtime/helpers/toConsumableArray');
var utilAddress = require('@onflow/util-address');

function _interopDefaultLegacy (e) { return e && typeof e === 'object' && 'default' in e ? e : { 'default': e }; }

function _interopNamespace(e) {
  if (e && e.__esModule) return e;
  var n = Object.create(null);
  if (e) {
    Object.keys(e).forEach(function (k) {
      if (k !== 'default') {
        var d = Object.getOwnPropertyDescriptor(e, k);
        Object.defineProperty(n, k, d.get ? d : {
          enumerable: true,
          get: function () { return e[k]; }
        });
      }
    });
  }
  n["default"] = e;
  return Object.freeze(n);
}

var _asyncToGenerator__default = /*#__PURE__*/_interopDefaultLegacy(_asyncToGenerator);
var _regeneratorRuntime__default = /*#__PURE__*/_interopDefaultLegacy(_regeneratorRuntime);
var _createClass__default = /*#__PURE__*/_interopDefaultLegacy(_createClass);
var _classCallCheck__default = /*#__PURE__*/_interopDefaultLegacy(_classCallCheck);
var _inherits__default = /*#__PURE__*/_interopDefaultLegacy(_inherits);
var _createSuper__default = /*#__PURE__*/_interopDefaultLegacy(_createSuper);
var _wrapNativeSuper__default = /*#__PURE__*/_interopDefaultLegacy(_wrapNativeSuper);
var logger__namespace = /*#__PURE__*/_interopNamespace(logger);
var fetchTransport__default = /*#__PURE__*/_interopDefaultLegacy(fetchTransport);
var _toConsumableArray__default = /*#__PURE__*/_interopDefaultLegacy(_toConsumableArray);

var HTTPRequestError = /*#__PURE__*/function (_Error) {
  _inherits__default["default"](HTTPRequestError, _Error);

  var _super = _createSuper__default["default"](HTTPRequestError);

  function HTTPRequestError(_ref) {
    var _this;

    var error = _ref.error,
        hostname = _ref.hostname,
        path = _ref.path,
        method = _ref.method,
        requestBody = _ref.requestBody,
        responseBody = _ref.responseBody,
        responseStatusText = _ref.responseStatusText,
        statusCode = _ref.statusCode;

    _classCallCheck__default["default"](this, HTTPRequestError);

    var msg = "\n      HTTP Request Error: An error occurred when interacting with the Access API.\n      ".concat(error ? "error=".concat(error) : "", "\n      ").concat(hostname ? "hostname=".concat(hostname) : "", "\n      ").concat(path ? "path=".concat(path) : "", "\n      ").concat(method ? "method=".concat(method) : "", "\n      ").concat(requestBody ? "requestBody=".concat(requestBody) : "", "\n      ").concat(responseBody ? "responseBody=".concat(responseBody) : "", "\n      ").concat(responseStatusText ? "responseStatusText=".concat(responseStatusText) : "", "\n      ").concat(statusCode ? "statusCode=".concat(statusCode) : "", "\n    ");
    _this = _super.call(this, msg);
    _this.name = "HTTP Request Error";
    _this.statusCode = statusCode;
    _this.errorMessage = error;
    return _this;
  }

  return _createClass__default["default"](HTTPRequestError);
}( /*#__PURE__*/_wrapNativeSuper__default["default"](Error));
/**
 * Creates an HTTP Request to be sent to a REST Access API via Fetch API.
 *
 * @param {Object} options - Options for the HTTP Request
 * @param {String} options.hostname - Access API Hostname
 * @param {String} options.path - Path to the resource on the Access API
 * @param {String} options.method - HTTP Method
 * @param {Object} options.body - HTTP Request Body
 * @param {Object | Headers} [options.headers] - HTTP Request Headers
 *
 * @returns JSON object response from Access API.
 */


function httpRequest(_x) {
  return _httpRequest.apply(this, arguments);
}

function _httpRequest() {
  _httpRequest = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee4(_ref2) {
    var hostname, path, method, body, headers, _ref2$retryLimit, retryLimit, _ref2$retryIntervalMs, retryIntervalMs, bodyJSON, makeRequest, requestLoop, _requestLoop;

    return _regeneratorRuntime__default["default"].wrap(function _callee4$(_context4) {
      while (1) {
        switch (_context4.prev = _context4.next) {
          case 0:
            _requestLoop = function _requestLoop3() {
              _requestLoop = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3() {
                var retryAttempt,
                    resp,
                    retryStatusCodes,
                    _args3 = arguments;
                return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
                  while (1) {
                    switch (_context3.prev = _context3.next) {
                      case 0:
                        retryAttempt = _args3.length > 0 && _args3[0] !== undefined ? _args3[0] : 0;
                        _context3.prev = 1;
                        _context3.next = 4;
                        return makeRequest();

                      case 4:
                        resp = _context3.sent;
                        return _context3.abrupt("return", resp);

                      case 8:
                        _context3.prev = 8;
                        _context3.t0 = _context3["catch"](1);
                        retryStatusCodes = [408, 429, 500, 502, 503, 504];

                        if (!retryStatusCodes.includes(_context3.t0.statusCode)) {
                          _context3.next = 17;
                          break;
                        }

                        _context3.next = 14;
                        return new Promise(function (resolve, reject) {
                          if (retryAttempt < retryLimit) {
                            console.warn("Access node unavailable, retrying in ".concat(retryIntervalMs, " ms..."));
                            setTimeout(function () {
                              resolve(requestLoop(retryAttempt + 1));
                            }, retryIntervalMs);
                          } else {
                            reject(_context3.t0);
                          }
                        });

                      case 14:
                        return _context3.abrupt("return", _context3.sent);

                      case 17:
                        throw _context3.t0;

                      case 18:
                      case "end":
                        return _context3.stop();
                    }
                  }
                }, _callee3, null, [[1, 8]]);
              }));
              return _requestLoop.apply(this, arguments);
            };

            requestLoop = function _requestLoop2() {
              return _requestLoop.apply(this, arguments);
            };

            makeRequest = function _makeRequest() {
              const fetchT = fetchTransport__default["default"];
              return fetchT("".concat(hostname).concat(path), {
                method: method,
                body: bodyJSON,
                headers: headers
              }).then( /*#__PURE__*/function () {
                var _ref3 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(res) {
                  var responseText, response;
                  return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
                    while (1) {
                      switch (_context.prev = _context.next) {
                        case 0:
                          if (!res.ok) {
                            _context.next = 2;
                            break;
                          }

                          return _context.abrupt("return", res.json());

                        case 2:
                          if (!res.body) {
                            _context.next = 8;
                            break;
                          }

                          _context.next = 5;
                          return res.text();

                        case 5:
                          _context.t0 = _context.sent;
                          _context.next = 9;
                          break;

                        case 8:
                          _context.t0 = null;

                        case 9:
                          responseText = _context.t0;
                          response = safeParseJSON(responseText);
                          throw new HTTPRequestError({
                            error: response === null || response === void 0 ? void 0 : response.message,
                            hostname: hostname,
                            path: path,
                            method: method,
                            requestBody: bodyJSON,
                            responseBody: responseText,
                            responseStatusText: res.statusText,
                            statusCode: res.status
                          });

                        case 12:
                        case "end":
                          return _context.stop();
                      }
                    }
                  }, _callee);
                }));

                return function (_x2) {
                  return _ref3.apply(this, arguments);
                };
              }())["catch"]( /*#__PURE__*/function () {
                var _ref4 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(e) {
                  return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
                    while (1) {
                      switch (_context2.prev = _context2.next) {
                        case 0:
                          if (!(e instanceof HTTPRequestError)) {
                            _context2.next = 2;
                            break;
                          }

                          throw e;

                        case 2:
                          _context2.next = 4;
                          return logger__namespace.log({
                            title: "Access Node Error",
                            message: "The provided access node ".concat(hostname, " does not appear to be a valid REST/HTTP access node.\nPlease verify that you are not unintentionally using a GRPC access node.\nSee more here: https://docs.onflow.org/fcl/reference/sdk-guidelines/#connect"),
                            level: logger__namespace.LEVELS.error
                          });

                        case 4:
                          throw new HTTPRequestError({
                            error: e === null || e === void 0 ? void 0 : e.message,
                            hostname: hostname,
                            path: path,
                            method: method,
                            requestBody: bodyJSON
                          });

                        case 5:
                        case "end":
                          return _context2.stop();
                      }
                    }
                  }, _callee2);
                }));

                return function (_x3) {
                  return _ref4.apply(this, arguments);
                };
              }());
            };

            hostname = _ref2.hostname, path = _ref2.path, method = _ref2.method, body = _ref2.body, headers = _ref2.headers, _ref2$retryLimit = _ref2.retryLimit, retryLimit = _ref2$retryLimit === void 0 ? 5 : _ref2$retryLimit, _ref2$retryIntervalMs = _ref2.retryIntervalMs, retryIntervalMs = _ref2$retryIntervalMs === void 0 ? 1000 : _ref2$retryIntervalMs;
            bodyJSON = body ? JSON.stringify(body) : null;
            _context4.next = 7;
            return requestLoop();

          case 7:
            return _context4.abrupt("return", _context4.sent);

          case 8:
          case "end":
            return _context4.stop();
        }
      }
    }, _callee4);
  }));
  return _httpRequest.apply(this, arguments);
}

function safeParseJSON(data) {
  try {
    return JSON.parse(data);
  } catch (_unused) {
    return null;
  }
}

function sendExecuteScriptAtBlockIDRequest(_x, _x2, _x3) {
  return _sendExecuteScriptAtBlockIDRequest.apply(this, arguments);
}

function _sendExecuteScriptAtBlockIDRequest() {
  _sendExecuteScriptAtBlockIDRequest = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix, context, opts) {
    var httpRequest$1, res;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            httpRequest$1 = opts.httpRequest || httpRequest;
            _context.next = 3;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/scripts?block_id=".concat(ix.block.id),
              method: "POST",
              body: {
                script: context.Buffer.from(ix.message.cadence).toString("base64"),
                arguments: ix.message.arguments.map(function (arg) {
                  return context.Buffer.from(JSON.stringify(ix.arguments[arg].asArgument)).toString("base64");
                })
              }
            });

          case 3:
            res = _context.sent;
            return _context.abrupt("return", constructResponse$4(ix, context, res));

          case 5:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _sendExecuteScriptAtBlockIDRequest.apply(this, arguments);
}

function sendExecuteScriptAtBlockHeightRequest(_x4, _x5, _x6) {
  return _sendExecuteScriptAtBlockHeightRequest.apply(this, arguments);
}

function _sendExecuteScriptAtBlockHeightRequest() {
  _sendExecuteScriptAtBlockHeightRequest = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(ix, context, opts) {
    var httpRequest$1, res;
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            httpRequest$1 = opts.httpRequest || httpRequest;
            _context2.next = 3;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/scripts?block_height=".concat(ix.block.height),
              method: "POST",
              body: {
                script: context.Buffer.from(ix.message.cadence).toString("base64"),
                arguments: ix.message.arguments.map(function (arg) {
                  return context.Buffer.from(JSON.stringify(ix.arguments[arg].asArgument)).toString("base64");
                })
              }
            });

          case 3:
            res = _context2.sent;
            return _context2.abrupt("return", constructResponse$4(ix, context, res));

          case 5:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _sendExecuteScriptAtBlockHeightRequest.apply(this, arguments);
}

function sendExecuteScriptAtLatestBlockRequest(_x7, _x8, _x9) {
  return _sendExecuteScriptAtLatestBlockRequest.apply(this, arguments);
}

function _sendExecuteScriptAtLatestBlockRequest() {
  _sendExecuteScriptAtLatestBlockRequest = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(ix, context, opts) {
    var httpRequest$1, res;
    return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
      while (1) {
        switch (_context3.prev = _context3.next) {
          case 0:
            httpRequest$1 = opts.httpRequest || httpRequest;
            _context3.next = 3;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/scripts?block_height=sealed",
              method: "POST",
              body: {
                script: context.Buffer.from(ix.message.cadence).toString("base64"),
                arguments: ix.message.arguments.map(function (arg) {
                  return context.Buffer.from(JSON.stringify(ix.arguments[arg].asArgument)).toString("base64");
                })
              }
            });

          case 3:
            res = _context3.sent;
            return _context3.abrupt("return", constructResponse$4(ix, context, res));

          case 5:
          case "end":
            return _context3.stop();
        }
      }
    }, _callee3);
  }));
  return _sendExecuteScriptAtLatestBlockRequest.apply(this, arguments);
}

function constructResponse$4(ix, context, res) {
  var ret = context.response();
  ret.tag = ix.tag;
  ret.encodedData = JSON.parse(context.Buffer.from(res, "base64").toString());
  return ret;
}

function sendExecuteScript(_x10) {
  return _sendExecuteScript.apply(this, arguments);
}

function _sendExecuteScript() {
  _sendExecuteScript = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee4(ix) {
    var context,
        opts,
        _args4 = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee4$(_context4) {
      while (1) {
        switch (_context4.prev = _context4.next) {
          case 0:
            context = _args4.length > 1 && _args4[1] !== undefined ? _args4[1] : {};
            opts = _args4.length > 2 && _args4[2] !== undefined ? _args4[2] : {};
            utilInvariant.invariant(opts.node, "SDK Send Execute Script Error: opts.node must be defined.");
            utilInvariant.invariant(context.response, "SDK Send Execute Script Error: context.response must be defined.");
            utilInvariant.invariant(context.Buffer, "SDK Send Execute Script Error: context.Buffer must be defined.");
            _context4.next = 7;
            return ix;

          case 7:
            ix = _context4.sent;

            if (!ix.block.id) {
              _context4.next = 14;
              break;
            }

            _context4.next = 11;
            return sendExecuteScriptAtBlockIDRequest(ix, context, opts);

          case 11:
            return _context4.abrupt("return", _context4.sent);

          case 14:
            if (!ix.block.height) {
              _context4.next = 20;
              break;
            }

            _context4.next = 17;
            return sendExecuteScriptAtBlockHeightRequest(ix, context, opts);

          case 17:
            return _context4.abrupt("return", _context4.sent);

          case 20:
            _context4.next = 22;
            return sendExecuteScriptAtLatestBlockRequest(ix, context, opts);

          case 22:
            return _context4.abrupt("return", _context4.sent);

          case 23:
          case "end":
            return _context4.stop();
        }
      }
    }, _callee4);
  }));
  return _sendExecuteScript.apply(this, arguments);
}

var HashAlgorithmIDs = {
  SHA2_256: 1,
  SHA2_384: 2,
  SHA3_256: 3,
  SHA3_384: 4,
  KMAC128_BLS_BLS12_381: 5
};
var SignatureAlgorithmIDs = {
  ECDSA_P256: 1,
  ECDSA_secp256k1: 2,
  BLS_BLS12_381: 3
};

function sendGetAccountAtBlockHeightRequest(_x, _x2, _x3) {
  return _sendGetAccountAtBlockHeightRequest.apply(this, arguments);
}

function _sendGetAccountAtBlockHeightRequest() {
  _sendGetAccountAtBlockHeightRequest = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix, context, opts) {
    var httpRequest$1, res;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            httpRequest$1 = opts.httpRequest || httpRequest;
            _context.next = 3;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/accounts/".concat(ix.account.addr, "?block_height=").concat(ix.block.height, "&expand=contracts,keys"),
              method: "GET",
              body: null
            });

          case 3:
            res = _context.sent;
            return _context.abrupt("return", constructResponse$3(ix, context, res));

          case 5:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _sendGetAccountAtBlockHeightRequest.apply(this, arguments);
}

function sendGetAccountAtLatestBlockRequest(_x4, _x5, _x6) {
  return _sendGetAccountAtLatestBlockRequest.apply(this, arguments);
}

function _sendGetAccountAtLatestBlockRequest() {
  _sendGetAccountAtLatestBlockRequest = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(ix, context, opts) {
    var httpRequest$1, res;
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            httpRequest$1 = opts.httpRequest || httpRequest;
            _context2.next = 3;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/accounts/".concat(ix.account.addr, "?block_height=sealed&expand=contracts,keys"),
              method: "GET",
              body: null
            });

          case 3:
            res = _context2.sent;
            return _context2.abrupt("return", constructResponse$3(ix, context, res));

          case 5:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _sendGetAccountAtLatestBlockRequest.apply(this, arguments);
}

function constructResponse$3(ix, context, res) {
  var _res$keys$map, _res$keys;

  var ret = context.response();
  ret.tag = ix.tag;

  var unwrapContracts = function unwrapContracts(contracts) {
    var c = {};
    if (!contracts) return c;

    for (var _i = 0, _Object$keys = Object.keys(contracts); _i < _Object$keys.length; _i++) {
      var key = _Object$keys[_i];
      c[key] = context.Buffer.from(contracts[key], "base64").toString();
    }

    return c;
  };

  ret.account = {
    address: res.address,
    balance: Number(res.balance),
    code: "",
    contracts: unwrapContracts(res.contracts),
    keys: (_res$keys$map = (_res$keys = res.keys) === null || _res$keys === void 0 ? void 0 : _res$keys.map(function (key) {
      return {
        index: Number(key.index),
        publicKey: key.public_key.replace(/^0x/, ""),
        signAlgo: SignatureAlgorithmIDs[key.signing_algorithm],
        signAlgoString: key.signing_algorithm,
        hashAlgo: HashAlgorithmIDs[key.hashing_algorithm],
        hashAlgoString: key.hashing_algorithm,
        sequenceNumber: Number(key.sequence_number),
        weight: Number(key.weight),
        revoked: key.revoked
      };
    })) !== null && _res$keys$map !== void 0 ? _res$keys$map : []
  };
  return ret;
}

function sendGetAccount(_x7) {
  return _sendGetAccount.apply(this, arguments);
}

function _sendGetAccount() {
  _sendGetAccount = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(ix) {
    var context,
        opts,
        _args3 = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
      while (1) {
        switch (_context3.prev = _context3.next) {
          case 0:
            context = _args3.length > 1 && _args3[1] !== undefined ? _args3[1] : {};
            opts = _args3.length > 2 && _args3[2] !== undefined ? _args3[2] : {};
            utilInvariant.invariant(opts.node, "SDK Send Get Account Error: opts.node must be defined.");
            utilInvariant.invariant(context.response, "SDK Send Get Account Error: context.response must be defined.");
            utilInvariant.invariant(context.Buffer, "SDK Send Get Account Error: context.Buffer must be defined.");
            _context3.next = 7;
            return ix;

          case 7:
            ix = _context3.sent;

            if (!(ix.block.height !== null)) {
              _context3.next = 14;
              break;
            }

            _context3.next = 11;
            return sendGetAccountAtBlockHeightRequest(ix, context, opts);

          case 11:
            return _context3.abrupt("return", _context3.sent);

          case 14:
            _context3.next = 16;
            return sendGetAccountAtLatestBlockRequest(ix, context, opts);

          case 16:
            return _context3.abrupt("return", _context3.sent);

          case 17:
          case "end":
            return _context3.stop();
        }
      }
    }, _callee3);
  }));
  return _sendGetAccount.apply(this, arguments);
}

function sendGetBlockHeaderByIDRequest(_x, _x2, _x3) {
  return _sendGetBlockHeaderByIDRequest.apply(this, arguments);
}

function _sendGetBlockHeaderByIDRequest() {
  _sendGetBlockHeaderByIDRequest = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix, context, opts) {
    var httpRequest$1, res;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            httpRequest$1 = opts.httpRequest || httpRequest;
            _context.next = 3;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/blocks/".concat(ix.block.id),
              method: "GET",
              body: null
            });

          case 3:
            res = _context.sent;
            return _context.abrupt("return", constructResponse$2(ix, context, res));

          case 5:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _sendGetBlockHeaderByIDRequest.apply(this, arguments);
}

function sendGetBlockHeaderByHeightRequest(_x4, _x5, _x6) {
  return _sendGetBlockHeaderByHeightRequest.apply(this, arguments);
}

function _sendGetBlockHeaderByHeightRequest() {
  _sendGetBlockHeaderByHeightRequest = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(ix, context, opts) {
    var httpRequest$1, res;
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            httpRequest$1 = opts.httpRequest || httpRequest;
            _context2.next = 3;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/blocks?height=".concat(ix.block.height),
              method: "GET",
              body: null
            });

          case 3:
            res = _context2.sent;
            return _context2.abrupt("return", constructResponse$2(ix, context, res));

          case 5:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _sendGetBlockHeaderByHeightRequest.apply(this, arguments);
}

function sendGetLatestBlockHeaderRequest(_x7, _x8, _x9) {
  return _sendGetLatestBlockHeaderRequest.apply(this, arguments);
}

function _sendGetLatestBlockHeaderRequest() {
  _sendGetLatestBlockHeaderRequest = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(ix, context, opts) {
    var _ix$block;

    var httpRequest$1, height, res;
    return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
      while (1) {
        switch (_context3.prev = _context3.next) {
          case 0:
            httpRequest$1 = opts.httpRequest || httpRequest;
            height = (_ix$block = ix.block) !== null && _ix$block !== void 0 && _ix$block.isSealed ? "sealed" : "finalized";
            _context3.next = 4;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/blocks?height=".concat(height),
              method: "GET",
              body: null
            });

          case 4:
            res = _context3.sent;
            return _context3.abrupt("return", constructResponse$2(ix, context, res));

          case 6:
          case "end":
            return _context3.stop();
        }
      }
    }, _callee3);
  }));
  return _sendGetLatestBlockHeaderRequest.apply(this, arguments);
}

function constructResponse$2(ix, context, res) {
  var block = res.length ? res[0] : null;
  var ret = context.response();
  ret.tag = ix.tag;
  ret.blockHeader = {
    id: block.header.id,
    parentId: block.header.parent_id,
    height: Number(block.header.height),
    timestamp: block.header.timestamp
  };
  return ret;
}

function sendGetBlockHeader(_x10) {
  return _sendGetBlockHeader.apply(this, arguments);
}

function _sendGetBlockHeader() {
  _sendGetBlockHeader = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee4(ix) {
    var context,
        opts,
        interactionHasBlockID,
        interactionHasBlockHeight,
        _args4 = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee4$(_context4) {
      while (1) {
        switch (_context4.prev = _context4.next) {
          case 0:
            context = _args4.length > 1 && _args4[1] !== undefined ? _args4[1] : {};
            opts = _args4.length > 2 && _args4[2] !== undefined ? _args4[2] : {};
            utilInvariant.invariant(opts.node, "SDK Send Get Block Header Error: opts.node must be defined.");
            utilInvariant.invariant(context.response, "SDK Send Get Block Header Error: context.response must be defined.");
            _context4.next = 6;
            return ix;

          case 6:
            ix = _context4.sent;
            interactionHasBlockID = ix.block.id !== null;
            interactionHasBlockHeight = ix.block.height !== null;

            if (!interactionHasBlockID) {
              _context4.next = 15;
              break;
            }

            _context4.next = 12;
            return sendGetBlockHeaderByIDRequest(ix, context, opts);

          case 12:
            return _context4.abrupt("return", _context4.sent);

          case 15:
            if (!interactionHasBlockHeight) {
              _context4.next = 21;
              break;
            }

            _context4.next = 18;
            return sendGetBlockHeaderByHeightRequest(ix, context, opts);

          case 18:
            return _context4.abrupt("return", _context4.sent);

          case 21:
            _context4.next = 23;
            return sendGetLatestBlockHeaderRequest(ix, context, opts);

          case 23:
            return _context4.abrupt("return", _context4.sent);

          case 24:
          case "end":
            return _context4.stop();
        }
      }
    }, _callee4);
  }));
  return _sendGetBlockHeader.apply(this, arguments);
}

function sendGetBlockByIDRequest(_x, _x2, _x3) {
  return _sendGetBlockByIDRequest.apply(this, arguments);
}

function _sendGetBlockByIDRequest() {
  _sendGetBlockByIDRequest = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix, context, opts) {
    var httpRequest$1, res;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            httpRequest$1 = opts.httpRequest || httpRequest;
            _context.next = 3;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/blocks/".concat(ix.block.id, "?expand=payload"),
              method: "GET",
              body: null
            });

          case 3:
            res = _context.sent;
            return _context.abrupt("return", constructResponse$1(ix, context, res));

          case 5:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _sendGetBlockByIDRequest.apply(this, arguments);
}

function sendGetBlockByHeightRequest(_x4, _x5, _x6) {
  return _sendGetBlockByHeightRequest.apply(this, arguments);
}

function _sendGetBlockByHeightRequest() {
  _sendGetBlockByHeightRequest = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(ix, context, opts) {
    var httpRequest$1, res;
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            httpRequest$1 = opts.httpRequest || httpRequest;
            _context2.next = 3;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/blocks?height=".concat(ix.block.height, "&expand=payload"),
              method: "GET",
              body: null
            });

          case 3:
            res = _context2.sent;
            return _context2.abrupt("return", constructResponse$1(ix, context, res));

          case 5:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _sendGetBlockByHeightRequest.apply(this, arguments);
}

function sendGetBlockRequest(_x7, _x8, _x9) {
  return _sendGetBlockRequest.apply(this, arguments);
}

function _sendGetBlockRequest() {
  _sendGetBlockRequest = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(ix, context, opts) {
    var _ix$block;

    var httpRequest$1, height, res;
    return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
      while (1) {
        switch (_context3.prev = _context3.next) {
          case 0:
            httpRequest$1 = opts.httpRequest || httpRequest;
            height = (_ix$block = ix.block) !== null && _ix$block !== void 0 && _ix$block.isSealed ? "sealed" : "final";
            _context3.next = 4;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/blocks?height=".concat(height, "&expand=payload"),
              method: "GET",
              body: null
            });

          case 4:
            res = _context3.sent;
            return _context3.abrupt("return", constructResponse$1(ix, context, res));

          case 6:
          case "end":
            return _context3.stop();
        }
      }
    }, _callee3);
  }));
  return _sendGetBlockRequest.apply(this, arguments);
}

function constructResponse$1(ix, context, res) {
  var block = res.length ? res[0] : null;
  var ret = context.response();
  ret.tag = ix.tag;
  ret.block = {
    id: block.header.id,
    parentId: block.header.parent_id,
    height: Number(block.header.height),
    timestamp: block.header.timestamp,
    collectionGuarantees: block.payload.collection_guarantees.map(function (collectionGuarantee) {
      return {
        collectionId: collectionGuarantee.collection_id,
        signerIds: collectionGuarantee.signer_ids
      };
    }),
    blockSeals: block.payload.block_seals.map(function (blockSeal) {
      return {
        blockId: blockSeal.block_id,
        executionReceiptId: blockSeal.result_id
      };
    })
  };
  return ret;
}

function sendGetBlock(_x10) {
  return _sendGetBlock.apply(this, arguments);
}

function _sendGetBlock() {
  _sendGetBlock = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee4(ix) {
    var context,
        opts,
        interactionHasBlockID,
        interactionHasBlockHeight,
        _args4 = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee4$(_context4) {
      while (1) {
        switch (_context4.prev = _context4.next) {
          case 0:
            context = _args4.length > 1 && _args4[1] !== undefined ? _args4[1] : {};
            opts = _args4.length > 2 && _args4[2] !== undefined ? _args4[2] : {};
            utilInvariant.invariant(opts.node, "SDK Send Get Block Error: opts.node must be defined.");
            utilInvariant.invariant(context.response, "SDK Send Get Block Error: context.response must be defined.");
            _context4.next = 6;
            return ix;

          case 6:
            ix = _context4.sent;
            interactionHasBlockID = ix.block.id !== null;
            interactionHasBlockHeight = ix.block.height !== null;

            if (!interactionHasBlockID) {
              _context4.next = 15;
              break;
            }

            _context4.next = 12;
            return sendGetBlockByIDRequest(ix, context, opts);

          case 12:
            return _context4.abrupt("return", _context4.sent);

          case 15:
            if (!interactionHasBlockHeight) {
              _context4.next = 21;
              break;
            }

            _context4.next = 18;
            return sendGetBlockByHeightRequest(ix, context, opts);

          case 18:
            return _context4.abrupt("return", _context4.sent);

          case 21:
            _context4.next = 23;
            return sendGetBlockRequest(ix, context, opts);

          case 23:
            return _context4.abrupt("return", _context4.sent);

          case 24:
          case "end":
            return _context4.stop();
        }
      }
    }, _callee4);
  }));
  return _sendGetBlock.apply(this, arguments);
}

function sendGetCollection(_x) {
  return _sendGetCollection.apply(this, arguments);
}

function _sendGetCollection() {
  _sendGetCollection = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix) {
    var context,
        opts,
        httpRequest$1,
        res,
        ret,
        _args = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            context = _args.length > 1 && _args[1] !== undefined ? _args[1] : {};
            opts = _args.length > 2 && _args[2] !== undefined ? _args[2] : {};
            utilInvariant.invariant(opts.node, "SDK Send Get Collection Error: opts.node must be defined.");
            utilInvariant.invariant(context.response, "SDK Send Get Collection Error: context.response must be defined.");
            httpRequest$1 = opts.httpRequest || httpRequest;
            _context.next = 7;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/collections/".concat(ix.collection.id, "?expand=transactions"),
              method: "GET",
              body: null
            });

          case 7:
            res = _context.sent;
            ret = context.response();
            ret.tag = ix.tag;
            ret.collection = {
              id: res.id,
              transactionIds: res.transactions.map(function (transaction) {
                return transaction.id;
              })
            };
            return _context.abrupt("return", ret);

          case 12:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _sendGetCollection.apply(this, arguments);
}

function sendGetEventsForHeightRangeRequest(_x, _x2, _x3) {
  return _sendGetEventsForHeightRangeRequest.apply(this, arguments);
}

function _sendGetEventsForHeightRangeRequest() {
  _sendGetEventsForHeightRangeRequest = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix, context, opts) {
    var httpRequest$1, res;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            httpRequest$1 = opts.httpRequest || httpRequest;
            _context.next = 3;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/events?type=".concat(ix.events.eventType, "&start_height=").concat(ix.events.start, "&end_height=").concat(ix.events.end),
              method: "GET",
              body: null
            });

          case 3:
            res = _context.sent;
            return _context.abrupt("return", constructResponse(ix, context, res));

          case 5:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _sendGetEventsForHeightRangeRequest.apply(this, arguments);
}

function sendGetEventsForBlockIDsRequest(_x4, _x5, _x6) {
  return _sendGetEventsForBlockIDsRequest.apply(this, arguments);
}

function _sendGetEventsForBlockIDsRequest() {
  _sendGetEventsForBlockIDsRequest = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2(ix, context, opts) {
    var httpRequest$1, res;
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            httpRequest$1 = opts.httpRequest || httpRequest;
            _context2.next = 3;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/events?type=".concat(ix.events.eventType, "&block_ids=").concat(ix.events.blockIds.join(",")),
              method: "GET",
              body: null
            });

          case 3:
            res = _context2.sent;
            return _context2.abrupt("return", constructResponse(ix, context, res));

          case 5:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _sendGetEventsForBlockIDsRequest.apply(this, arguments);
}

function constructResponse(ix, context, res) {
  var ret = context.response();
  ret.tag = ix.tag;
  ret.events = [];
  res.forEach(function (block) {
    return block.events ? block.events.forEach(function (event) {
      return ret.events.push({
        blockId: block.block_id,
        blockHeight: Number(block.block_height),
        blockTimestamp: block.block_timestamp,
        type: event.type,
        transactionId: event.transaction_id,
        transactionIndex: Number(event.transaction_index),
        eventIndex: Number(event.event_index),
        payload: JSON.parse(context.Buffer.from(event.payload, "base64").toString())
      });
    }) : null;
  });
  return ret;
}

function sendGetEvents(_x7) {
  return _sendGetEvents.apply(this, arguments);
}

function _sendGetEvents() {
  _sendGetEvents = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(ix) {
    var context,
        opts,
        interactionContainsBlockHeightRange,
        interactionContainsBlockIDsList,
        _args3 = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
      while (1) {
        switch (_context3.prev = _context3.next) {
          case 0:
            context = _args3.length > 1 && _args3[1] !== undefined ? _args3[1] : {};
            opts = _args3.length > 2 && _args3[2] !== undefined ? _args3[2] : {};
            utilInvariant.invariant(opts.node, "SDK Send Get Events Error: opts.node must be defined.");
            utilInvariant.invariant(context.response, "SDK Send Get Events Error: context.response must be defined.");
            utilInvariant.invariant(context.Buffer, "SDK Send Get Events Error: context.Buffer must be defined.");
            _context3.next = 7;
            return ix;

          case 7:
            ix = _context3.sent;
            interactionContainsBlockHeightRange = ix.events.start !== null;
            interactionContainsBlockIDsList = Array.isArray(ix.events.blockIds) && ix.events.blockIds.length > 0;
            utilInvariant.invariant(interactionContainsBlockHeightRange || interactionContainsBlockIDsList, "SendGetEventsError: Unable to determine which get events request to send. Either a block height range, or block IDs must be specified.");

            if (!interactionContainsBlockHeightRange) {
              _context3.next = 17;
              break;
            }

            _context3.next = 14;
            return sendGetEventsForHeightRangeRequest(ix, context, opts);

          case 14:
            return _context3.abrupt("return", _context3.sent);

          case 17:
            _context3.next = 19;
            return sendGetEventsForBlockIDsRequest(ix, context, opts);

          case 19:
            return _context3.abrupt("return", _context3.sent);

          case 20:
          case "end":
            return _context3.stop();
        }
      }
    }, _callee3);
  }));
  return _sendGetEvents.apply(this, arguments);
}

function sendGetTransaction(_x) {
  return _sendGetTransaction.apply(this, arguments);
}

function _sendGetTransaction() {
  _sendGetTransaction = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix) {
    var context,
        opts,
        httpRequest$1,
        res,
        unwrapKey,
        unwrapSignature,
        unwrapArg,
        ret,
        _args = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            context = _args.length > 1 && _args[1] !== undefined ? _args[1] : {};
            opts = _args.length > 2 && _args[2] !== undefined ? _args[2] : {};
            utilInvariant.invariant(opts.node, "SDK Send Get Transaction Error: opts.node must be defined.");
            utilInvariant.invariant(context.response, "SDK Send Get Transaction Error: context.response must be defined.");
            utilInvariant.invariant(context.Buffer, "SDK Send Get Transaction Error: context.Buffer must be defined.");
            httpRequest$1 = opts.httpRequest || httpRequest;
            _context.next = 8;
            return ix;

          case 8:
            ix = _context.sent;
            _context.next = 11;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/transactions/".concat(ix.transaction.id),
              method: "GET",
              body: null
            });

          case 11:
            res = _context.sent;

            unwrapKey = function unwrapKey(key) {
              return {
                address: key.address,
                keyId: Number(key.key_id),
                sequenceNumber: Number(key.sequence_number)
              };
            };

            unwrapSignature = function unwrapSignature(sig) {
              return {
                address: sig.address,
                keyId: Number(sig.key_index),
                signature: sig.signature
              };
            };

            unwrapArg = function unwrapArg(arg) {
              return JSON.parse(context.Buffer.from(arg, "base64").toString());
            };

            ret = context.response();
            ret.tag = ix.tag;
            ret.transaction = {
              script: context.Buffer.from(res.script, "base64").toString(),
              args: _toConsumableArray__default["default"](res.arguments.map(unwrapArg)),
              referenceBlockId: res.reference_block_id,
              gasLimit: Number(res.gas_limit),
              payer: res.payer,
              proposalKey: res.proposal_key ? unwrapKey(res.proposal_key) : res.proposal_key,
              authorizers: res.authorizers,
              payloadSignatures: _toConsumableArray__default["default"](res.payload_signatures.map(unwrapSignature)),
              envelopeSignatures: _toConsumableArray__default["default"](res.envelope_signatures.map(unwrapSignature))
            };
            return _context.abrupt("return", ret);

          case 19:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _sendGetTransaction.apply(this, arguments);
}

var STATUS_MAP = {
  UNKNOWN: 0,
  PENDING: 1,
  FINALIZED: 2,
  EXECUTED: 3,
  SEALED: 4,
  EXPIRED: 5
};
function sendGetTransactionStatus(_x) {
  return _sendGetTransactionStatus.apply(this, arguments);
}

function _sendGetTransactionStatus() {
  _sendGetTransactionStatus = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix) {
    var context,
        opts,
        httpRequest$1,
        res,
        ret,
        _args = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            context = _args.length > 1 && _args[1] !== undefined ? _args[1] : {};
            opts = _args.length > 2 && _args[2] !== undefined ? _args[2] : {};
            utilInvariant.invariant(opts.node, "SDK Send Get Transaction Status Error: opts.node must be defined.");
            utilInvariant.invariant(context.response, "SDK Send Get Transaction Status Error: context.response must be defined.");
            utilInvariant.invariant(context.Buffer, "SDK Send Get Transaction Status Error: context.Buffer must be defined.");
            httpRequest$1 = opts.httpRequest || httpRequest;
            _context.next = 8;
            return ix;

          case 8:
            ix = _context.sent;
            _context.next = 11;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/transaction_results/".concat(ix.transaction.id),
              method: "GET",
              body: null
            });

          case 11:
            res = _context.sent;
            ret = context.response();
            ret.tag = ix.tag;
            ret.transactionStatus = {
              blockId: res.block_id,
              status: STATUS_MAP[res.status.toUpperCase()] || "",
              statusString: res.status.toUpperCase(),
              statusCode: res.status_code,
              errorMessage: res.error_message,
              events: res.events.map(function (event) {
                return {
                  type: event.type,
                  transactionId: event.transaction_id,
                  transactionIndex: Number(event.transaction_index),
                  eventIndex: Number(event.event_index),
                  payload: JSON.parse(context.Buffer.from(event.payload, "base64").toString())
                };
              })
            };
            return _context.abrupt("return", ret);

          case 16:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _sendGetTransactionStatus.apply(this, arguments);
}

function sendPing(_x) {
  return _sendPing.apply(this, arguments);
}

function _sendPing() {
  _sendPing = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix) {
    var context,
        opts,
        httpRequest$1,
        ret,
        _args = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            context = _args.length > 1 && _args[1] !== undefined ? _args[1] : {};
            opts = _args.length > 2 && _args[2] !== undefined ? _args[2] : {};
            utilInvariant.invariant(opts.node, "SDK Send Ping Error: opts.node must be defined.");
            utilInvariant.invariant(context.response, "SDK Send Ping Error: context.response must be defined.");
            httpRequest$1 = opts.httpRequest || httpRequest;
            _context.next = 7;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/blocks?height=sealed",
              method: "GET",
              body: null
            });

          case 7:
            ret = context.response();
            ret.tag = ix.tag;
            return _context.abrupt("return", ret);

          case 10:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));
  return _sendPing.apply(this, arguments);
}

var idof = function idof(acct) {
  return "".concat(withPrefix(acct.addr), "-").concat(acct.keyId);
};

function sendTransaction(_x) {
  return _sendTransaction.apply(this, arguments);
}

function _sendTransaction() {
  _sendTransaction = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix) {
    var context,
        opts,
        httpRequest$1,
        payloadSignatures,
        _i,
        _Object$values,
        acct,
        envelopeSignatures,
        _i2,
        _Object$values2,
        _acct,
        id,
        t1,
        res,
        t2,
        ret,
        _args = arguments;

    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            context = _args.length > 1 && _args[1] !== undefined ? _args[1] : {};
            opts = _args.length > 2 && _args[2] !== undefined ? _args[2] : {};
            utilInvariant.invariant(opts.node, "SDK Send Transaction Error: opts.node must be defined.");
            utilInvariant.invariant(context.response, "SDK Send Transaction Error: context.response must be defined.");
            utilInvariant.invariant(context.Buffer, "SDK Send Transaction Error: context.Buffer must be defined.");
            httpRequest$1 = opts.httpRequest || httpRequest;
            _context.next = 8;
            return ix;

          case 8:
            ix = _context.sent;
            // Apply Non Payer Signatures to Payload Signatures
            payloadSignatures = [];
            _i = 0, _Object$values = Object.values(ix.accounts);

          case 11:
            if (!(_i < _Object$values.length)) {
              _context.next = 24;
              break;
            }

            acct = _Object$values[_i];
            _context.prev = 13;

            if (!acct.role.payer && acct.signature != null) {
              payloadSignatures.push({
                address: utilAddress.sansPrefix(acct.addr),
                key_index: String(acct.keyId),
                signature: context.Buffer.from(acct.signature, "hex").toString("base64")
              });
            }

            _context.next = 21;
            break;

          case 17:
            _context.prev = 17;
            _context.t0 = _context["catch"](13);
            console.error("SDK HTTP Send Error: Trouble applying payload signature", {
              acct: acct,
              ix: ix
            });
            throw _context.t0;

          case 21:
            _i++;
            _context.next = 11;
            break;

          case 24:
            // Apply Payer Signatures to Envelope Signatures
            envelopeSignatures = {};
            _i2 = 0, _Object$values2 = Object.values(ix.accounts);

          case 26:
            if (!(_i2 < _Object$values2.length)) {
              _context.next = 39;
              break;
            }

            _acct = _Object$values2[_i2];
            _context.prev = 28;

            if (_acct.role.payer && _acct.signature != null) {
              id = _acct.tempId || idof(_acct);
              envelopeSignatures[id] = envelopeSignatures[id] || {
                address: utilAddress.sansPrefix(_acct.addr),
                key_index: String(_acct.keyId),
                signature: context.Buffer.from(_acct.signature, "hex").toString("base64")
              };
            }

            _context.next = 36;
            break;

          case 32:
            _context.prev = 32;
            _context.t1 = _context["catch"](28);
            console.error("SDK HTTP Send Error: Trouble applying envelope signature", {
              acct: _acct,
              ix: ix
            });
            throw _context.t1;

          case 36:
            _i2++;
            _context.next = 26;
            break;

          case 39:
            envelopeSignatures = Object.values(envelopeSignatures);
            t1 = Date.now();
            _context.next = 43;
            return httpRequest$1({
              hostname: opts.node,
              path: "/v1/transactions",
              method: "POST",
              body: {
                script: context.Buffer.from(ix.message.cadence).toString("base64"),
                arguments: _toConsumableArray__default["default"](ix.message.arguments.map(function (arg) {
                  return context.Buffer.from(JSON.stringify(ix.arguments[arg].asArgument)).toString("base64");
                })),
                reference_block_id: ix.message.refBlock ? ix.message.refBlock : null,
                gas_limit: String(ix.message.computeLimit),
                payer: utilAddress.sansPrefix(ix.accounts[Array.isArray(ix.payer) ? ix.payer[0] : ix.payer].addr),
                proposal_key: {
                  address: utilAddress.sansPrefix(ix.accounts[ix.proposer].addr),
                  key_index: String(ix.accounts[ix.proposer].keyId),
                  sequence_number: String(ix.accounts[ix.proposer].sequenceNum)
                },
                authorizers: ix.authorizations.map(function (tempId) {
                  return ix.accounts[tempId].addr;
                }).reduce(function (prev, current) {
                  return prev.find(function (item) {
                    return item === current;
                  }) ? prev : [].concat(_toConsumableArray__default["default"](prev), [current]);
                }, []).map(utilAddress.sansPrefix),
                payload_signatures: payloadSignatures,
                envelope_signatures: envelopeSignatures
              }
            });

          case 43:
            res = _context.sent;
            t2 = Date.now();
            ret = context.response();
            ret.tag = ix.tag;
            ret.transactionId = res.id;

            if (typeof window !== "undefined") {
              window.dispatchEvent(new CustomEvent("FLOW::TX", {
                detail: {
                  txId: ret.transactionId,
                  delta: t2 - t1
                }
              }));
            }

            return _context.abrupt("return", ret);

          case 50:
          case "end":
            return _context.stop();
        }
      }
    }, _callee, null, [[13, 17], [28, 32]]);
  }));
  return _sendTransaction.apply(this, arguments);
}

var send = /*#__PURE__*/function () {
  var _ref = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ix) {
    var context,
        opts,
        _args = arguments;
    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            context = _args.length > 1 && _args[1] !== undefined ? _args[1] : {};
            opts = _args.length > 2 && _args[2] !== undefined ? _args[2] : {};
            utilInvariant.invariant(opts.node, "SDK Send Error: Either opts.node or \"accessNode.api\" in config must be defined.");
            utilInvariant.invariant(context.ix, "SDK Send Error: context.ix must be defined.");
            _context.next = 6;
            return ix;

          case 6:
            ix = _context.sent;
            _context.t0 = true;
            _context.next = _context.t0 === context.ix.isTransaction(ix) ? 10 : _context.t0 === context.ix.isGetTransactionStatus(ix) ? 11 : _context.t0 === context.ix.isGetTransaction(ix) ? 12 : _context.t0 === context.ix.isScript(ix) ? 13 : _context.t0 === context.ix.isGetAccount(ix) ? 14 : _context.t0 === context.ix.isGetEvents(ix) ? 15 : _context.t0 === context.ix.isGetBlock(ix) ? 16 : _context.t0 === context.ix.isGetBlockHeader(ix) ? 17 : _context.t0 === context.ix.isGetCollection(ix) ? 18 : _context.t0 === context.ix.isPing(ix) ? 19 : 20;
            break;

          case 10:
            return _context.abrupt("return", opts.sendTransaction ? opts.sendTransaction(ix, context, opts) : sendTransaction(ix, context, opts));

          case 11:
            return _context.abrupt("return", opts.sendGetTransactionStatus ? opts.sendGetTransactionStatus(ix, context, opts) : sendGetTransactionStatus(ix, context, opts));

          case 12:
            return _context.abrupt("return", opts.sendGetTransaction ? opts.sendGetTransaction(ix, context, opts) : sendGetTransaction(ix, context, opts));

          case 13:
            return _context.abrupt("return", opts.sendExecuteScript ? opts.sendExecuteScript(ix, context, opts) : sendExecuteScript(ix, context, opts));

          case 14:
            return _context.abrupt("return", opts.sendGetAccount ? opts.sendGetAccount(ix, context, opts) : sendGetAccount(ix, context, opts));

          case 15:
            return _context.abrupt("return", opts.sendGetEvents ? opts.sendGetEvents(ix, context, opts) : sendGetEvents(ix, context, opts));

          case 16:
            return _context.abrupt("return", opts.sendGetBlock ? opts.sendGetBlock(ix, context, opts) : sendGetBlock(ix, context, opts));

          case 17:
            return _context.abrupt("return", opts.sendGetBlockHeader ? opts.sendGetBlockHeader(ix, context, opts) : sendGetBlockHeader(ix, context, opts));

          case 18:
            return _context.abrupt("return", opts.sendGetCollection ? opts.sendGetCollection(ix, context, opts) : sendGetCollection(ix, context, opts));

          case 19:
            return _context.abrupt("return", opts.sendPing ? opts.sendPing(ix, context, opts) : sendPing(ix, context, opts));

          case 20:
            return _context.abrupt("return", ix);

          case 21:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));

  return function send(_x) {
    return _ref.apply(this, arguments);
  };
}();

exports.send = send;
exports.sendExecuteScript = sendExecuteScript;
exports.sendGetAccount = sendGetAccount;
exports.sendGetBlock = sendGetBlock;
exports.sendGetBlockHeader = sendGetBlockHeader;
exports.sendGetCollection = sendGetCollection;
exports.sendGetEvents = sendGetEvents;
exports.sendGetTransaction = sendGetTransaction;
exports.sendGetTransactionStatus = sendGetTransactionStatus;
exports.sendPing = sendPing;
exports.sendTransaction = sendTransaction;


},{"@babel/runtime/helpers/asyncToGenerator":6,"@babel/runtime/helpers/classCallCheck":7,"@babel/runtime/helpers/createClass":9,"@babel/runtime/helpers/createSuper":11,"@babel/runtime/helpers/inherits":14,"@babel/runtime/helpers/toConsumableArray":29,"@babel/runtime/helpers/wrapNativeSuper":34,"@babel/runtime/regenerator":35,"@onflow/util-address":43,"@onflow/util-invariant":44,"@onflow/util-logger":45,"buffer":49,"node-fetch":51}],41:[function(require,module,exports){
(function (global){(function (){
'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var _typeof = require('@babel/runtime/helpers/typeof');
var _toConsumableArray = require('@babel/runtime/helpers/toConsumableArray');
var _asyncToGenerator = require('@babel/runtime/helpers/asyncToGenerator');
var _regeneratorRuntime = require('@babel/runtime/regenerator');
var _toArray = require('@babel/runtime/helpers/toArray');
var _defineProperty = require('@babel/runtime/helpers/defineProperty');
var _objectSpread = require('@babel/runtime/helpers/objectSpread2');
var _createForOfIteratorHelper = require('@babel/runtime/helpers/createForOfIteratorHelper');

function _interopDefaultLegacy (e) { return e && typeof e === 'object' && 'default' in e ? e : { 'default': e }; }

var _typeof__default = /*#__PURE__*/_interopDefaultLegacy(_typeof);
var _toConsumableArray__default = /*#__PURE__*/_interopDefaultLegacy(_toConsumableArray);
var _asyncToGenerator__default = /*#__PURE__*/_interopDefaultLegacy(_asyncToGenerator);
var _regeneratorRuntime__default = /*#__PURE__*/_interopDefaultLegacy(_regeneratorRuntime);
var _toArray__default = /*#__PURE__*/_interopDefaultLegacy(_toArray);
var _defineProperty__default = /*#__PURE__*/_interopDefaultLegacy(_defineProperty);
var _objectSpread__default = /*#__PURE__*/_interopDefaultLegacy(_objectSpread);
var _createForOfIteratorHelper__default = /*#__PURE__*/_interopDefaultLegacy(_createForOfIteratorHelper);

var promise;
var queueMicrotask_1 = typeof queueMicrotask === 'function' ? queueMicrotask // reuse resolved promise, and allocate it lazily
: function (cb) {
  return (promise || (promise = Promise.resolve())).then(cb)["catch"](function (err) {
    return setTimeout(function () {
      throw err;
    }, 0);
  });
};

var mailbox = function mailbox() {
  var queue = [];
  var next;
  return {
    deliver: function deliver(msg) {
      return _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee() {
        return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
          while (1) {
            switch (_context.prev = _context.next) {
              case 0:
                queue.push(msg);

                if (next) {
                  next(queue.shift());
                  next = undefined;
                }

              case 2:
              case "end":
                return _context.stop();
            }
          }
        }, _callee);
      }))();
    },
    receive: function receive() {
      return new Promise(function innerReceive(resolve) {
        var msg = queue.shift();
        if (msg) return resolve(msg);
        next = resolve;
      });
    }
  };
};

var INIT = "INIT";
var SUBSCRIBE = "SUBSCRIBE";
var UNSUBSCRIBE = "UNSUBSCRIBE";
var UPDATED$1 = "UPDATED";
var EXIT = "EXIT";
var TERMINATE = "TERMINATE";
var root = (typeof self === "undefined" ? "undefined" : _typeof__default["default"](self)) === "object" && self.self === self && self || (typeof global === "undefined" ? "undefined" : _typeof__default["default"](global)) === "object" && global.global === global && global || (typeof window === "undefined" ? "undefined" : _typeof__default["default"](window)) === "object" && window.window === window && window;
root.FCL_REGISTRY = root.FCL_REGISTRY == null ? {} : root.FCL_REGISTRY;
var pid = 0;
var DEFAULT_TIMEOUT = 5000;

var _send = function send(addr, tag, data) {
  var opts = arguments.length > 3 && arguments[3] !== undefined ? arguments[3] : {};
  return new Promise(function (reply, reject) {
    var expectReply = opts.expectReply || false;
    var timeout = opts.timeout != null ? opts.timeout : DEFAULT_TIMEOUT;

    if (expectReply && timeout) {
      setTimeout(function () {
        return reject(new Error("Timeout: ".concat(timeout, "ms passed without a response.")));
      }, timeout);
    }

    var payload = {
      to: addr,
      from: opts.from,
      tag: tag,
      data: data,
      timeout: timeout,
      reply: reply,
      reject: reject
    };

    try {
      root.FCL_REGISTRY[addr] && root.FCL_REGISTRY[addr].mailbox.deliver(payload);
      if (!expectReply) reply(true);
    } catch (error) {
      console.error("FCL.Actor -- Could Not Deliver Message", payload, root.FCL_REGISTRY[addr], error);
    }
  });
};

var kill = function kill(addr) {
  delete root.FCL_REGISTRY[addr];
};

var fromHandlers = function fromHandlers() {
  var handlers = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
  return /*#__PURE__*/function () {
    var _ref = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ctx) {
      var letter;
      return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
        while (1) {
          switch (_context.prev = _context.next) {
            case 0:
              if (!(typeof handlers[INIT] === "function")) {
                _context.next = 3;
                break;
              }

              _context.next = 3;
              return handlers[INIT](ctx);

            case 3:
              _context.next = 6;
              return ctx.receive();

            case 6:
              letter = _context.sent;
              _context.prev = 7;

              if (!(letter.tag === EXIT)) {
                _context.next = 13;
                break;
              }

              if (!(typeof handlers[TERMINATE] === "function")) {
                _context.next = 12;
                break;
              }

              _context.next = 12;
              return handlers[TERMINATE](ctx, letter, letter.data || {});

            case 12:
              return _context.abrupt("break", 25);

            case 13:
              _context.next = 15;
              return handlers[letter.tag](ctx, letter, letter.data || {});

            case 15:
              _context.next = 20;
              break;

            case 17:
              _context.prev = 17;
              _context.t0 = _context["catch"](7);
              console.error("".concat(ctx.self(), " Error"), letter, _context.t0);

            case 20:
              _context.prev = 20;
              return _context.abrupt("continue", 3);

            case 23:
              _context.next = 3;
              break;

            case 25:
            case "end":
              return _context.stop();
          }
        }
      }, _callee, null, [[7, 17, 20, 23]]);
    }));

    return function (_x) {
      return _ref.apply(this, arguments);
    };
  }();
};

var spawn = function spawn(fn) {
  var addr = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : null;
  if (addr == null) addr = ++pid;
  if (root.FCL_REGISTRY[addr] != null) return addr;
  root.FCL_REGISTRY[addr] = {
    addr: addr,
    mailbox: mailbox(),
    subs: new Set(),
    kvs: {},
    error: null
  };
  var ctx = {
    self: function self() {
      return addr;
    },
    receive: function receive() {
      return root.FCL_REGISTRY[addr].mailbox.receive();
    },
    send: function send(to, tag, data) {
      var opts = arguments.length > 3 && arguments[3] !== undefined ? arguments[3] : {};
      opts.from = addr;
      return _send(to, tag, data, opts);
    },
    sendSelf: function sendSelf(tag, data, opts) {
      if (root.FCL_REGISTRY[addr]) _send(addr, tag, data, opts);
    },
    broadcast: function broadcast(tag, data) {
      var opts = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : {};
      opts.from = addr;

      var _iterator = _createForOfIteratorHelper__default["default"](root.FCL_REGISTRY[addr].subs),
          _step;

      try {
        for (_iterator.s(); !(_step = _iterator.n()).done;) {
          var to = _step.value;

          _send(to, tag, data, opts);
        }
      } catch (err) {
        _iterator.e(err);
      } finally {
        _iterator.f();
      }
    },
    subscribe: function subscribe(sub) {
      return sub != null && root.FCL_REGISTRY[addr].subs.add(sub);
    },
    unsubscribe: function unsubscribe(sub) {
      return sub != null && root.FCL_REGISTRY[addr].subs["delete"](sub);
    },
    subscriberCount: function subscriberCount() {
      return root.FCL_REGISTRY[addr].subs.size;
    },
    hasSubs: function hasSubs() {
      return !!root.FCL_REGISTRY[addr].subs.size;
    },
    put: function put(key, value) {
      if (key != null) root.FCL_REGISTRY[addr].kvs[key] = value;
    },
    get: function get(key, fallback) {
      var value = root.FCL_REGISTRY[addr].kvs[key];
      return value == null ? fallback : value;
    },
    "delete": function _delete(key) {
      delete root.FCL_REGISTRY[addr].kvs[key];
    },
    update: function update(key, fn) {
      if (key != null) root.FCL_REGISTRY[addr].kvs[key] = fn(root.FCL_REGISTRY[addr].kvs[key]);
    },
    keys: function keys() {
      return Object.keys(root.FCL_REGISTRY[addr].kvs);
    },
    all: function all() {
      return root.FCL_REGISTRY[addr].kvs;
    },
    where: function where(pattern) {
      return Object.keys(root.FCL_REGISTRY[addr].kvs).reduce(function (acc, key) {
        return pattern.test(key) ? _objectSpread__default["default"](_objectSpread__default["default"]({}, acc), {}, _defineProperty__default["default"]({}, key, root.FCL_REGISTRY[addr].kvs[key])) : acc;
      }, {});
    },
    merge: function merge() {
      var data = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
      Object.keys(data).forEach(function (key) {
        return root.FCL_REGISTRY[addr].kvs[key] = data[key];
      });
    },
    fatalError: function fatalError(error) {
      root.FCL_REGISTRY[addr].error = error;

      var _iterator2 = _createForOfIteratorHelper__default["default"](root.FCL_REGISTRY[addr].subs),
          _step2;

      try {
        for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
          var to = _step2.value;

          _send(to, UPDATED$1);
        }
      } catch (err) {
        _iterator2.e(err);
      } finally {
        _iterator2.f();
      }
    }
  };
  if (_typeof__default["default"](fn) === "object") fn = fromHandlers(fn);
  queueMicrotask_1( /*#__PURE__*/_asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2() {
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            _context2.next = 2;
            return fn(ctx);

          case 2:
            kill(addr);

          case 3:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  })));
  return addr;
}; // Returns an unsubscribe function
// A SUBSCRIBE handler will need to be created to handle the subscription event
//
//  [SUBSCRIBE]: (ctx, letter) => {
//    ctx.subscribe(letter.from)
//    ctx.send(letter.from, UPDATED, ctx.all())
//  }
//


function subscriber(address, spawnFn, callback) {
  spawnFn(address);
  var EXIT = "@EXIT";
  var self = spawn( /*#__PURE__*/function () {
    var _ref3 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(ctx) {
      var letter, error;
      return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
        while (1) {
          switch (_context3.prev = _context3.next) {
            case 0:
              ctx.send(address, SUBSCRIBE);

            case 1:
              _context3.next = 4;
              return ctx.receive();

            case 4:
              letter = _context3.sent;
              error = root.FCL_REGISTRY[address].error;

              if (!(letter.tag === EXIT)) {
                _context3.next = 9;
                break;
              }

              ctx.send(address, UNSUBSCRIBE);
              return _context3.abrupt("return");

            case 9:
              if (!error) {
                _context3.next = 13;
                break;
              }

              callback(null, error);
              ctx.send(address, UNSUBSCRIBE);
              return _context3.abrupt("return");

            case 13:
              callback(letter.data, null);
              _context3.next = 1;
              break;

            case 16:
            case "end":
              return _context3.stop();
          }
        }
      }, _callee3);
    }));

    return function (_x2) {
      return _ref3.apply(this, arguments);
    };
  }());
  return function () {
    return _send(self, EXIT);
  };
} // Returns a promise that returns a result

var _HANDLERS;

var NAME = "config";
var PUT = "PUT_CONFIG";
var GET = "GET_CONFIG";
var GET_ALL = "GET_ALL_CONFIG";
var UPDATE = "UPDATE_CONFIG";
var DELETE = "DELETE_CONFIG";
var CLEAR = "CLEAR_CONFIG";
var WHERE = "WHERE_CONFIG";
var UPDATED = "CONFIG/UPDATED";

var identity = function identity(v) {
  return v;
};

var HANDLERS = (_HANDLERS = {}, _defineProperty__default["default"](_HANDLERS, PUT, function (ctx, _letter, _ref) {
  var key = _ref.key,
      value = _ref.value;
  if (key == null) throw new Error("Missing 'key' for config/put.");
  ctx.put(key, value);
  ctx.broadcast(UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, GET, function (ctx, letter, _ref2) {
  var key = _ref2.key,
      fallback = _ref2.fallback;
  if (key == null) throw new Error("Missing 'key' for config/get");
  letter.reply(ctx.get(key, fallback));
}), _defineProperty__default["default"](_HANDLERS, GET_ALL, function (ctx, letter) {
  letter.reply(_objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, UPDATE, function (ctx, letter, _ref3) {
  var key = _ref3.key,
      fn = _ref3.fn;
  if (key == null) throw new Error("Missing 'key' for config/update");
  ctx.update(key, fn || identity);
  ctx.broadcast(UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, DELETE, function (ctx, letter, _ref4) {
  var key = _ref4.key;
  if (key == null) throw new Error("Missing 'key' for config/delete");
  ctx["delete"](key);
  ctx.broadcast(UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, CLEAR, function (ctx, letter) {
  var keys = Object.keys(ctx.all());

  for (var _i = 0, _keys = keys; _i < _keys.length; _i++) {
    var key = _keys[_i];
    ctx["delete"](key);
  }

  ctx.broadcast(UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, WHERE, function (ctx, letter, _ref5) {
  var pattern = _ref5.pattern;
  if (pattern == null) throw new Error("Missing 'pattern' for config/where");
  letter.reply(ctx.where(pattern));
}), _defineProperty__default["default"](_HANDLERS, SUBSCRIBE, function (ctx, letter) {
  ctx.subscribe(letter.from);
  ctx.send(letter.from, UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, UNSUBSCRIBE, function (ctx, letter) {
  ctx.unsubscribe(letter.from);
}), _HANDLERS);
spawn(HANDLERS, NAME);

function put(key, value) {
  _send(NAME, PUT, {
    key: key,
    value: value
  });
  return config();
}

function get(key, fallback) {
  return _send(NAME, GET, {
    key: key,
    fallback: fallback
  }, {
    expectReply: true,
    timeout: 10
  });
}

function first() {
  return _first.apply(this, arguments);
}

function _first() {
  _first = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2() {
    var wants,
        fallback,
        _wants,
        head,
        rest,
        ret,
        _args2 = arguments;

    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            wants = _args2.length > 0 && _args2[0] !== undefined ? _args2[0] : [];
            fallback = _args2.length > 1 ? _args2[1] : undefined;

            if (wants.length) {
              _context2.next = 4;
              break;
            }

            return _context2.abrupt("return", fallback);

          case 4:
            _wants = _toArray__default["default"](wants), head = _wants[0], rest = _wants.slice(1);
            _context2.next = 7;
            return get(head);

          case 7:
            ret = _context2.sent;

            if (!(ret == null)) {
              _context2.next = 10;
              break;
            }

            return _context2.abrupt("return", first(rest, fallback));

          case 10:
            return _context2.abrupt("return", ret);

          case 11:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _first.apply(this, arguments);
}

function all() {
  return _send(NAME, GET_ALL, null, {
    expectReply: true,
    timeout: 10
  });
}

function update(key) {
  var fn = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : identity;
  _send(NAME, UPDATE, {
    key: key,
    fn: fn
  });
  return config();
}

function _delete(key) {
  _send(NAME, DELETE, {
    key: key
  });
  return config();
}

function where(pattern) {
  return _send(NAME, WHERE, {
    pattern: pattern
  }, {
    expectReply: true,
    timeout: 10
  });
}

function subscribe(callback) {
  return subscriber(NAME, function () {
    return spawn(HANDLERS, NAME);
  }, callback);
}

function clearConfig() {
  return _send(NAME, CLEAR);
}

function resetConfig(oldConfig) {
  return clearConfig().then(config(oldConfig));
}

function config(values) {
  if (values != null && _typeof__default["default"](values) === "object") {
    Object.keys(values).map(function (d) {
      return put(d, values[d]);
    });
  }

  return {
    put: put,
    get: get,
    all: all,
    first: first,
    update: update,
    "delete": _delete,
    where: where,
    subscribe: subscribe,
    overload: overload
  };
}

config.put = put;
config.get = get;
config.all = all;
config.first = first;
config.update = update;
config["delete"] = _delete;
config.where = where;
config.subscribe = subscribe;
config.overload = overload;

var noop = function noop(v) {
  return v;
};

function overload() {
  var opts = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
  var callback = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : noop;
  return new Promise( /*#__PURE__*/function () {
    var _ref6 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(resolve, reject) {
      var oldConfig, result;
      return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
        while (1) {
          switch (_context.prev = _context.next) {
            case 0:
              _context.next = 2;
              return all();

            case 2:
              oldConfig = _context.sent;
              _context.prev = 3;
              config(opts);
              _context.t0 = callback;
              _context.next = 8;
              return all();

            case 8:
              _context.t1 = _context.sent;
              _context.next = 11;
              return (0, _context.t0)(_context.t1);

            case 11:
              result = _context.sent;
              _context.next = 14;
              return resetConfig(oldConfig);

            case 14:
              resolve(result);
              _context.next = 22;
              break;

            case 17:
              _context.prev = 17;
              _context.t2 = _context["catch"](3);
              _context.next = 21;
              return resetConfig(oldConfig);

            case 21:
              reject(_context.t2);

            case 22:
            case "end":
              return _context.stop();
          }
        }
      }, _callee, null, [[3, 17]]);
    }));

    return function (_x, _x2) {
      return _ref6.apply(this, arguments);
    };
  }());
}

var LEVELS = Object.freeze({
  debug: 5,
  info: 4,
  log: 3,
  warn: 2,
  error: 1
});

var buildLoggerMessageArgs = function buildLoggerMessageArgs(_ref) {
  var title = _ref.title,
      message = _ref.message;
  return ["\n    %c".concat(title, "\n    ============================\n\n    ").concat(message, "\n\n    ============================\n    ").replace(/\n[^\S\r\n]+/g, "\n").trim(),, "font-weight:bold;font-family:monospace;"];
};

var log = /*#__PURE__*/function () {
  var _ref3 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(_ref2) {
    var _console, _console2, _console3, _console4, _console5;

    var title, message, level, _ref2$always, always, configLoggerLevel, loggerMessageArgs;

    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            title = _ref2.title, message = _ref2.message, level = _ref2.level, _ref2$always = _ref2.always, always = _ref2$always === void 0 ? false : _ref2$always;
            _context.next = 3;
            return config.get("logger.level", LEVELS.warn);

          case 3:
            configLoggerLevel = _context.sent;

            if (!(!always && configLoggerLevel < level)) {
              _context.next = 6;
              break;
            }

            return _context.abrupt("return");

          case 6:
            loggerMessageArgs = buildLoggerMessageArgs({
              title: title,
              message: message
            });
            _context.t0 = level;
            _context.next = _context.t0 === LEVELS.debug ? 10 : _context.t0 === LEVELS.info ? 12 : _context.t0 === LEVELS.warn ? 14 : _context.t0 === LEVELS.error ? 16 : 18;
            break;

          case 10:
            (_console = console).debug.apply(_console, _toConsumableArray__default["default"](loggerMessageArgs));

            return _context.abrupt("break", 19);

          case 12:
            (_console2 = console).info.apply(_console2, _toConsumableArray__default["default"](loggerMessageArgs));

            return _context.abrupt("break", 19);

          case 14:
            (_console3 = console).warn.apply(_console3, _toConsumableArray__default["default"](loggerMessageArgs));

            return _context.abrupt("break", 19);

          case 16:
            (_console4 = console).error.apply(_console4, _toConsumableArray__default["default"](loggerMessageArgs));

            return _context.abrupt("break", 19);

          case 18:
            (_console5 = console).log.apply(_console5, _toConsumableArray__default["default"](loggerMessageArgs));

          case 19:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));

  return function log(_x) {
    return _ref3.apply(this, arguments);
  };
}();

log.deprecate = function (_ref4) {
  var pkg = _ref4.pkg,
      subject = _ref4.subject,
      transition = _ref4.transition,
      _ref4$level = _ref4.level,
      level = _ref4$level === void 0 ? LEVELS.warn : _ref4$level,
      _ref4$message = _ref4.message,
      message = _ref4$message === void 0 ? "" : _ref4$message,
      _ref4$callback = _ref4.callback,
      callback = _ref4$callback === void 0 ? null : _ref4$callback;

  var capitalizeFirstLetter = function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  };

  var logMessage = function logMessage() {
    return log({
      title: "".concat(pkg ? pkg + " " : "", "Deprecation Notice"),
      message: "\n      ".concat(subject ? "".concat(capitalizeFirstLetter(subject), " is deprecated and will cease to work in future releases").concat(pkg ? " of " + pkg : "", ".") : "").concat(message ? "\n" + message : "").concat(transition ? "\nYou can learn more (including a guide on common transition paths) here: ".concat(transition) : "", "\n    ").trim(),
      level: level
    });
  };

  if (typeof callback === "function") {
    return /*#__PURE__*/_asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2() {
      var _args2 = arguments;
      return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
        while (1) {
          switch (_context2.prev = _context2.next) {
            case 0:
              _context2.next = 2;
              return logMessage();

            case 2:
              _context2.next = 4;
              return callback.apply(void 0, _args2);

            case 4:
              return _context2.abrupt("return", _context2.sent);

            case 5:
            case "end":
              return _context2.stop();
          }
        }
      }, _callee2);
    }));
  }

  return logMessage();
};

var type = function type(label, asArgument, asInjection) {
  return {
    label: label,
    asArgument: asArgument,
    asInjection: asInjection
  };
};

var isArray = function isArray(d) {
  return Array.isArray(d);
};

var isObj = function isObj(d) {
  return _typeof__default["default"](d) === "object";
};

var isNull = function isNull(d) {
  return d == null;
};

var isBoolean = function isBoolean(d) {
  return typeof d === "boolean";
};

var isNumber = function isNumber(d) {
  return typeof d === "number";
};

var isInteger = function isInteger(d) {
  return Number.isInteger(d);
};

var isString = function isString(d) {
  return typeof d === "string";
};

var throwTypeError = function throwTypeError(msg) {
  throw new Error("Type Error: " + msg);
};

var numberValuesDeprecationNotice = function numberValuesDeprecationNotice(type) {
  log.deprecate({
    pkg: "@onflow/types",
    subject: "Passing in Number as value for ".concat(type),
    message: "Going forward, use String as value for ".concat(type, "."),
    transition: "https://github.com/onflow/flow-js-sdk/blob/master/packages/types/WARNINGS.md#0002-[U]Int*-and-Word*-as-Number"
  });
};

var Identity = type("Identity", function (v) {
  return v;
}, function (v) {
  return v;
});
var UInt = type("UInt", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("UInt");
    return {
      type: "UInt",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "UInt",
      value: v
    };
  }

  throwTypeError("Expected Positive Integer for type Unsigned Int");
}, function (v) {
  return v;
});
var Int = type("Int", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("Int");
    return {
      type: "Int",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "Int",
      value: v
    };
  }

  throwTypeError("Expected Integer for type Int");
}, function (v) {
  return v;
});
var UInt8 = type("UInt8", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("UInt8");
    return {
      type: "UInt8",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "UInt8",
      value: v
    };
  }

  throwTypeError("Expected integer for UInt8");
}, function (v) {
  return v;
});
var Int8 = type("Int8", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("Int8");
    return {
      type: "Int8",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "Int8",
      value: v
    };
  }

  throwTypeError("Expected positive integer for Int8");
}, function (v) {
  return v;
});
var UInt16 = type("UInt16", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("UInt16");
    return {
      type: "UInt16",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "UInt16",
      value: v
    };
  }

  throwTypeError("Expected integer for UInt16");
}, function (v) {
  return v;
});
var Int16 = type("Int16", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("Int16");
    return {
      type: "Int16",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "Int16",
      value: v
    };
  }

  throwTypeError("Expected positive integer for Int16");
}, function (v) {
  return v;
});
var UInt32 = type("UInt32", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("UInt32");
    return {
      type: "UInt32",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "UInt32",
      value: v
    };
  }

  throwTypeError("Expected integer for UInt32");
}, function (v) {
  return v;
});
var Int32 = type("Int32", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("Int32");
    return {
      type: "Int32",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "Int32",
      value: v
    };
  }

  throwTypeError("Expected positive integer for Int32");
}, function (v) {
  return v;
});
var UInt64 = type("UInt64", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("UInt64");
    return {
      type: "UInt64",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "UInt64",
      value: v
    };
  }

  throwTypeError("Expected integer for UInt64");
}, function (v) {
  return v;
});
var Int64 = type("Int64", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("Int64");
    return {
      type: "Int64",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "Int64",
      value: v
    };
  }

  throwTypeError("Expected positive integer for Int64");
}, function (v) {
  return v;
});
var UInt128 = type("UInt128", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("UInt128");
    return {
      type: "UInt128",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "UInt128",
      value: v
    };
  }

  throwTypeError("Expected integer for UInt128");
}, function (v) {
  return v;
});
var Int128 = type("Int128", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("Int128");
    return {
      type: "Int128",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "Int128",
      value: v
    };
  }

  throwTypeError("Expected positive integer for Int128");
}, function (v) {
  return v;
});
var UInt256 = type("UInt256", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("UInt256");
    return {
      type: "UInt256",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "UInt256",
      value: v
    };
  }

  throwTypeError("Expected integer for UInt256");
}, function (v) {
  return v;
});
var Int256 = type("Int256", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("Int256");
    return {
      type: "Int256",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "Int256",
      value: v
    };
  }

  throwTypeError("Expected integer for Int256");
}, function (v) {
  return v;
});
var Word8 = type("Word8", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("Word8");
    return {
      type: "Word8",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "Word8",
      value: v
    };
  }

  throwTypeError("Expected positive number for Word8");
}, function (v) {
  return v;
});
var Word16 = type("Word16", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("Word16");
    return {
      type: "Word16",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "Word16",
      value: v
    };
  }

  throwTypeError("Expected positive number for Word16");
}, function (v) {
  return v;
});
var Word32 = type("Word32", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("Word32");
    return {
      type: "Word32",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "Word32",
      value: v
    };
  }

  throwTypeError("Expected positive number for Word32");
}, function (v) {
  return v;
});
var Word64 = type("Word64", function (v) {
  if (isNumber(v) && isInteger(v)) {
    numberValuesDeprecationNotice("Word64");
    return {
      type: "Word64",
      value: v.toString()
    };
  }

  if (isString(v)) {
    return {
      type: "Word64",
      value: v
    };
  }

  throwTypeError("Expected positive number for Word64");
}, function (v) {
  return v;
});

var UFix64AndFix64NumberDeprecationNotice = function UFix64AndFix64NumberDeprecationNotice() {
  log.deprecate({
    subject: "Passing in Numbers as values for Fix64 and UFix64 types",
    pkg: "@onflow/types",
    transition: "https://github.com/onflow/flow-js-sdk/blob/master/packages/types/WARNINGS.md#0001-[U]Fix64-as-Number"
  });
};

var UFix64 = type("UFix64", function (v) {
  if (isString(v)) {
    var vParts = v.split(".");

    if (vParts.length !== 2) {
      throwTypeError("Expected one decimal but found ".concat(vParts.length, " in the [U]Fix64 value. Find out more about [U]Fix64 types here: https://docs.onflow.org/cadence/json-cadence-spec/#fixed-point-numbers"));
    }

    if (vParts[1].length == 0 || vParts[1].length > 8) {
      throwTypeError("Expected at least one digit, and at most 8 digits following the decimal of the [U]Fix64 value but found ".concat(vParts[1].length, " digits. Find out more about [U]Fix64 types here: https://docs.onflow.org/cadence/json-cadence-spec/#fixed-point-numbers"));
    } // make sure the number is extended to 8 decimal places so it matches cadence encoding of UFix values


    vParts[1] = vParts[1].padEnd(8, "0");
    v = vParts.join(".");
    return {
      type: "UFix64",
      value: v
    };
  } else if (isNumber(v)) {
    UFix64AndFix64NumberDeprecationNotice();
    return {
      type: "UFix64",
      value: v.toString()
    };
  }

  throwTypeError("Expected String for UFix64");
}, function (v) {
  return v;
});
var Fix64 = type("Fix64", function (v) {
  if (isString(v)) {
    var vParts = v.split(".");

    if (vParts.length !== 2) {
      throwTypeError("Expected one decimal but found ".concat(vParts.length, " in the [U]Fix64 value. Find out more about [U]Fix64 types here: https://docs.onflow.org/cadence/json-cadence-spec/#fixed-point-numbers"));
    }

    if (vParts[1].length == 0 || vParts[1].length > 8) {
      throwTypeError("Expected at least one digit, and at most 8 digits following the decimal of the [U]Fix64 value but found ".concat(vParts[1].length, " digits. Find out more about [U]Fix64 types here: https://docs.onflow.org/cadence/json-cadence-spec/#fixed-point-numbers"));
    } // make sure the number is extended to 8 decimal places so it matches cadence encoding of Fix64 values


    vParts[1] = vParts[1].padEnd(8, "0");
    v = vParts.join(".");
    return {
      type: "Fix64",
      value: v
    };
  } else if (isNumber(v)) {
    UFix64AndFix64NumberDeprecationNotice();
    return {
      type: "Fix64",
      value: v.toString()
    };
  }

  throwTypeError("Expected String for Fix64");
}, function (v) {
  return v;
});
var String = type("String", function (v) {
  if (isString(v)) return {
    type: "String",
    value: v
  };
  throwTypeError("Expected String for type String");
}, function (v) {
  return v;
});
var Character = type("Character", function (v) {
  if (isString(v)) return {
    type: "Character",
    value: v
  };
  throwTypeError("Expected Character for type Character");
}, function (v) {
  return v;
});
var Bool = type("Bool", function (v) {
  if (isBoolean(v)) return {
    type: "Bool",
    value: v
  };
  throwTypeError("Expected Boolean for type Bool");
}, function (v) {
  return v;
});
var Address = type("Address", function (v) {
  if (isString(v)) return {
    type: "Address",
    value: v
  };
  throwTypeError("Expected Address for type Address");
}, function (v) {
  return v;
});
var Void = type("Void", function (v) {
  if (!v || isNull(v)) return {
    type: "Void"
  };
  throwTypeError("Expected Void for type Void");
}, function (v) {
  return v;
});
var Optional = function Optional(children) {
  return type("Optional", function (v) {
    return {
      type: "Optional",
      value: isNull(v) ? null : children.asArgument(v)
    };
  }, function (v) {
    return v;
  });
};
var Reference = type("Reference", function (v) {
  if (isObj(v)) return {
    type: "Reference",
    value: v
  };
  throwTypeError("Expected Object for type Reference");
}, function (v) {
  return v;
});
var _Array = function _Array() {
  var children = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : [];
  return type("Array", function (v) {
    return {
      type: "Array",
      value: isArray(children) ? children.map(function (c, i) {
        return c.asArgument(v[i]);
      }) : v.map(function (x) {
        return children.asArgument(x);
      })
    };
  }, function (v) {
    return v;
  });
};
var Dictionary = function Dictionary() {
  var children = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : [];
  return type("Dictionary", function (v) {
    if (isObj(v)) return {
      type: "Dictionary",
      value: isArray(children) ? children.map(function (c, i) {
        return {
          key: c.key.asArgument(v[i].key),
          value: c.value.asArgument(v[i].value)
        };
      }) : isArray(v) ? v.map(function (x) {
        return {
          key: children.key.asArgument(x.key),
          value: children.value.asArgument(x.value)
        };
      }) : [{
        key: children.key.asArgument(v.key),
        value: children.value.asArgument(v.value)
      }]
    };
    throwTypeError("Expected Object for type Dictionary");
  }, function (v) {
    return v;
  });
};
var Event = function Event(id) {
  var fields = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : [];
  return type("Event", function (v) {
    if (isObj(v)) return {
      type: "Event",
      value: {
        id: id,
        fields: isArray(fields) ? fields.map(function (c, i) {
          return {
            name: v.fields[i].name,
            value: c.value.asArgument(v.fields[i].value)
          };
        }) : v.fields.map(function (x) {
          return {
            name: x.name,
            value: fields.value.asArgument(x.value)
          };
        })
      }
    };
    throwTypeError("Expected Object for type Event");
  }, function (v) {
    return v;
  });
};
var Resource = function Resource(id) {
  var fields = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : [];
  return type("Resource", function (v) {
    if (isObj(v)) return {
      type: "Resource",
      value: {
        id: id,
        fields: isArray(fields) ? fields.map(function (c, i) {
          return {
            name: v.fields[i].name,
            value: c.value.asArgument(v.fields[i].value)
          };
        }) : v.fields.map(function (x) {
          return {
            name: x.name,
            value: fields.value.asArgument(x.value)
          };
        })
      }
    };
    throwTypeError("Expected Object for type Resource");
  }, function (v) {
    return v;
  });
};
var Struct = function Struct(id) {
  var fields = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : [];
  return type("Struct", function (v) {
    if (isObj(v)) return {
      type: "Struct",
      value: {
        id: id,
        fields: isArray(fields) ? fields.map(function (c, i) {
          return {
            name: v.fields[i].name,
            value: c.value.asArgument(v.fields[i].value)
          };
        }) : v.fields.map(function (x) {
          return {
            name: x.name,
            value: fields.value.asArgument(x.value)
          };
        })
      }
    };
    throwTypeError("Expected Object for type Struct");
  }, function (v) {
    return v;
  });
};
var Enum = function Enum(id) {
  var fields = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : [];
  return type("Enum", function (v) {
    if (isObj(v)) return {
      type: "Enum",
      value: {
        id: id,
        fields: isArray(fields) ? fields.map(function (c, i) {
          return {
            name: v.fields[i].name,
            value: c.value.asArgument(v.fields[i].value)
          };
        }) : v.fields.map(function (x) {
          return {
            name: x.name,
            value: fields.value.asArgument(x.value)
          };
        })
      }
    };
    throwTypeError("Expected Object for type Enum");
  }, function (v) {
    return v;
  });
};
var Path = type("Path", function (v) {
  if (isObj(v)) {
    if (!isString(v.domain)) {
      throwTypeError("Expected a string for the Path domain but found ".concat(v.domain, ". Find out more about the Path type here: https://docs.onflow.org/cadence/json-cadence-spec/#path"));
    }

    if (!(v.domain === "storage" || v.domain === "private" || v.domain === "public")) {
      throwTypeError("Expected either \"storage\", \"private\" or \"public\" as the Path domain but found ".concat(v.domain, ". Find out more about the Path type here: https://docs.onflow.org/cadence/json-cadence-spec/#path"));
    }

    if (!isString(v.identifier)) {
      throwTypeError("Expected a string for the Path identifier but found ".concat(v.identifier, ". Find out more about the Path type here: https://docs.onflow.org/cadence/json-cadence-spec/#path"));
    }

    return {
      type: "Path",
      value: {
        domain: v.domain,
        identifier: v.identifier
      }
    };
  }

  throwTypeError("Expected Object for type Path");
}, function (v) {
  return v;
});

exports.Address = Address;
exports.Array = _Array;
exports.Bool = Bool;
exports.Character = Character;
exports.Dictionary = Dictionary;
exports.Enum = Enum;
exports.Event = Event;
exports.Fix64 = Fix64;
exports.Identity = Identity;
exports.Int = Int;
exports.Int128 = Int128;
exports.Int16 = Int16;
exports.Int256 = Int256;
exports.Int32 = Int32;
exports.Int64 = Int64;
exports.Int8 = Int8;
exports.Optional = Optional;
exports.Path = Path;
exports.Reference = Reference;
exports.Resource = Resource;
exports.String = String;
exports.Struct = Struct;
exports.UFix64 = UFix64;
exports.UInt = UInt;
exports.UInt128 = UInt128;
exports.UInt16 = UInt16;
exports.UInt256 = UInt256;
exports.UInt32 = UInt32;
exports.UInt64 = UInt64;
exports.UInt8 = UInt8;
exports.Void = Void;
exports.Word16 = Word16;
exports.Word32 = Word32;
exports.Word64 = Word64;
exports.Word8 = Word8;
exports._Array = _Array;


}).call(this)}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"@babel/runtime/helpers/asyncToGenerator":6,"@babel/runtime/helpers/createForOfIteratorHelper":10,"@babel/runtime/helpers/defineProperty":12,"@babel/runtime/helpers/objectSpread2":21,"@babel/runtime/helpers/toArray":28,"@babel/runtime/helpers/toConsumableArray":29,"@babel/runtime/helpers/typeof":32,"@babel/runtime/regenerator":35}],42:[function(require,module,exports){
(function (global){(function (){
'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var _defineProperty = require('@babel/runtime/helpers/defineProperty');
var _objectSpread = require('@babel/runtime/helpers/objectSpread2');
var _createForOfIteratorHelper = require('@babel/runtime/helpers/createForOfIteratorHelper');
var _asyncToGenerator = require('@babel/runtime/helpers/asyncToGenerator');
var _typeof = require('@babel/runtime/helpers/typeof');
var _regeneratorRuntime = require('@babel/runtime/regenerator');
var queueMicrotask = require('queue-microtask');

function _interopDefaultLegacy (e) { return e && typeof e === 'object' && 'default' in e ? e : { 'default': e }; }

var _defineProperty__default = /*#__PURE__*/_interopDefaultLegacy(_defineProperty);
var _objectSpread__default = /*#__PURE__*/_interopDefaultLegacy(_objectSpread);
var _createForOfIteratorHelper__default = /*#__PURE__*/_interopDefaultLegacy(_createForOfIteratorHelper);
var _asyncToGenerator__default = /*#__PURE__*/_interopDefaultLegacy(_asyncToGenerator);
var _typeof__default = /*#__PURE__*/_interopDefaultLegacy(_typeof);
var _regeneratorRuntime__default = /*#__PURE__*/_interopDefaultLegacy(_regeneratorRuntime);
var queueMicrotask__default = /*#__PURE__*/_interopDefaultLegacy(queueMicrotask);

var mailbox = function mailbox() {
  var queue = [];
  var next;
  return {
    deliver: function deliver(msg) {
      return _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee() {
        return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
          while (1) {
            switch (_context.prev = _context.next) {
              case 0:
                queue.push(msg);

                if (next) {
                  next(queue.shift());
                  next = undefined;
                }

              case 2:
              case "end":
                return _context.stop();
            }
          }
        }, _callee);
      }))();
    },
    receive: function receive() {
      return new Promise(function innerReceive(resolve) {
        var msg = queue.shift();
        if (msg) return resolve(msg);
        next = resolve;
      });
    }
  };
};

var INIT = "INIT";
var SUBSCRIBE = "SUBSCRIBE";
var UNSUBSCRIBE = "UNSUBSCRIBE";
var UPDATED = "UPDATED";
var SNAPSHOT = "SNAPSHOT";
var EXIT = "EXIT";
var TERMINATE = "TERMINATE";
var root = (typeof self === "undefined" ? "undefined" : _typeof__default["default"](self)) === "object" && self.self === self && self || (typeof global === "undefined" ? "undefined" : _typeof__default["default"](global)) === "object" && global.global === global && global || (typeof window === "undefined" ? "undefined" : _typeof__default["default"](window)) === "object" && window.window === window && window;
root.FCL_REGISTRY = root.FCL_REGISTRY == null ? {} : root.FCL_REGISTRY;
var pid = 0;
var DEFAULT_TIMEOUT = 5000;

var _send = function send(addr, tag, data) {
  var opts = arguments.length > 3 && arguments[3] !== undefined ? arguments[3] : {};
  return new Promise(function (reply, reject) {
    var expectReply = opts.expectReply || false;
    var timeout = opts.timeout != null ? opts.timeout : DEFAULT_TIMEOUT;

    if (expectReply && timeout) {
      setTimeout(function () {
        return reject(new Error("Timeout: ".concat(timeout, "ms passed without a response.")));
      }, timeout);
    }

    var payload = {
      to: addr,
      from: opts.from,
      tag: tag,
      data: data,
      timeout: timeout,
      reply: reply,
      reject: reject
    };

    try {
      root.FCL_REGISTRY[addr] && root.FCL_REGISTRY[addr].mailbox.deliver(payload);
      if (!expectReply) reply(true);
    } catch (error) {
      console.error("FCL.Actor -- Could Not Deliver Message", payload, root.FCL_REGISTRY[addr], error);
    }
  });
};
var kill = function kill(addr) {
  delete root.FCL_REGISTRY[addr];
};

var fromHandlers = function fromHandlers() {
  var handlers = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
  return /*#__PURE__*/function () {
    var _ref = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ctx) {
      var letter;
      return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
        while (1) {
          switch (_context.prev = _context.next) {
            case 0:
              if (!(typeof handlers[INIT] === "function")) {
                _context.next = 3;
                break;
              }

              _context.next = 3;
              return handlers[INIT](ctx);

            case 3:

              _context.next = 6;
              return ctx.receive();

            case 6:
              letter = _context.sent;
              _context.prev = 7;

              if (!(letter.tag === EXIT)) {
                _context.next = 13;
                break;
              }

              if (!(typeof handlers[TERMINATE] === "function")) {
                _context.next = 12;
                break;
              }

              _context.next = 12;
              return handlers[TERMINATE](ctx, letter, letter.data || {});

            case 12:
              return _context.abrupt("break", 25);

            case 13:
              _context.next = 15;
              return handlers[letter.tag](ctx, letter, letter.data || {});

            case 15:
              _context.next = 20;
              break;

            case 17:
              _context.prev = 17;
              _context.t0 = _context["catch"](7);
              console.error("".concat(ctx.self(), " Error"), letter, _context.t0);

            case 20:
              _context.prev = 20;
              return _context.abrupt("continue", 3);

            case 23:
              _context.next = 3;
              break;

            case 25:
            case "end":
              return _context.stop();
          }
        }
      }, _callee, null, [[7, 17, 20, 23]]);
    }));

    return function (_x) {
      return _ref.apply(this, arguments);
    };
  }();
};

var spawn = function spawn(fn) {
  var addr = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : null;
  if (addr == null) addr = ++pid;
  if (root.FCL_REGISTRY[addr] != null) return addr;
  root.FCL_REGISTRY[addr] = {
    addr: addr,
    mailbox: mailbox(),
    subs: new Set(),
    kvs: {},
    error: null
  };
  var ctx = {
    self: function self() {
      return addr;
    },
    receive: function receive() {
      return root.FCL_REGISTRY[addr].mailbox.receive();
    },
    send: function send(to, tag, data) {
      var opts = arguments.length > 3 && arguments[3] !== undefined ? arguments[3] : {};
      opts.from = addr;
      return _send(to, tag, data, opts);
    },
    sendSelf: function sendSelf(tag, data, opts) {
      if (root.FCL_REGISTRY[addr]) _send(addr, tag, data, opts);
    },
    broadcast: function broadcast(tag, data) {
      var opts = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : {};
      opts.from = addr;

      var _iterator = _createForOfIteratorHelper__default["default"](root.FCL_REGISTRY[addr].subs),
          _step;

      try {
        for (_iterator.s(); !(_step = _iterator.n()).done;) {
          var to = _step.value;

          _send(to, tag, data, opts);
        }
      } catch (err) {
        _iterator.e(err);
      } finally {
        _iterator.f();
      }
    },
    subscribe: function subscribe(sub) {
      return sub != null && root.FCL_REGISTRY[addr].subs.add(sub);
    },
    unsubscribe: function unsubscribe(sub) {
      return sub != null && root.FCL_REGISTRY[addr].subs["delete"](sub);
    },
    subscriberCount: function subscriberCount() {
      return root.FCL_REGISTRY[addr].subs.size;
    },
    hasSubs: function hasSubs() {
      return !!root.FCL_REGISTRY[addr].subs.size;
    },
    put: function put(key, value) {
      if (key != null) root.FCL_REGISTRY[addr].kvs[key] = value;
    },
    get: function get(key, fallback) {
      var value = root.FCL_REGISTRY[addr].kvs[key];
      return value == null ? fallback : value;
    },
    "delete": function _delete(key) {
      delete root.FCL_REGISTRY[addr].kvs[key];
    },
    update: function update(key, fn) {
      if (key != null) root.FCL_REGISTRY[addr].kvs[key] = fn(root.FCL_REGISTRY[addr].kvs[key]);
    },
    keys: function keys() {
      return Object.keys(root.FCL_REGISTRY[addr].kvs);
    },
    all: function all() {
      return root.FCL_REGISTRY[addr].kvs;
    },
    where: function where(pattern) {
      return Object.keys(root.FCL_REGISTRY[addr].kvs).reduce(function (acc, key) {
        return pattern.test(key) ? _objectSpread__default["default"](_objectSpread__default["default"]({}, acc), {}, _defineProperty__default["default"]({}, key, root.FCL_REGISTRY[addr].kvs[key])) : acc;
      }, {});
    },
    merge: function merge() {
      var data = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
      Object.keys(data).forEach(function (key) {
        return root.FCL_REGISTRY[addr].kvs[key] = data[key];
      });
    },
    fatalError: function fatalError(error) {
      root.FCL_REGISTRY[addr].error = error;

      var _iterator2 = _createForOfIteratorHelper__default["default"](root.FCL_REGISTRY[addr].subs),
          _step2;

      try {
        for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
          var to = _step2.value;

          _send(to, UPDATED);
        }
      } catch (err) {
        _iterator2.e(err);
      } finally {
        _iterator2.f();
      }
    }
  };
  if (_typeof__default["default"](fn) === "object") fn = fromHandlers(fn);
  const queueMicrotask = queueMicrotask__default["default"];
  queueMicrotask( /*#__PURE__*/_asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2() {
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            _context2.next = 2;
            return fn(ctx);

          case 2:
            kill(addr);

          case 3:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  })));
  return addr;
}; // Returns an unsubscribe function
// A SUBSCRIBE handler will need to be created to handle the subscription event
//
//  [SUBSCRIBE]: (ctx, letter) => {
//    ctx.subscribe(letter.from)
//    ctx.send(letter.from, UPDATED, ctx.all())
//  }
//

function subscriber(address, spawnFn, callback) {
  spawnFn(address);
  var EXIT = "@EXIT";
  var self = spawn( /*#__PURE__*/function () {
    var _ref3 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(ctx) {
      var letter, error;
      return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
        while (1) {
          switch (_context3.prev = _context3.next) {
            case 0:
              ctx.send(address, SUBSCRIBE);

            case 1:

              _context3.next = 4;
              return ctx.receive();

            case 4:
              letter = _context3.sent;
              error = root.FCL_REGISTRY[address].error;

              if (!(letter.tag === EXIT)) {
                _context3.next = 9;
                break;
              }

              ctx.send(address, UNSUBSCRIBE);
              return _context3.abrupt("return");

            case 9:
              if (!error) {
                _context3.next = 13;
                break;
              }

              callback(null, error);
              ctx.send(address, UNSUBSCRIBE);
              return _context3.abrupt("return");

            case 13:
              callback(letter.data, null);
              _context3.next = 1;
              break;

            case 16:
            case "end":
              return _context3.stop();
          }
        }
      }, _callee3);
    }));

    return function (_x2) {
      return _ref3.apply(this, arguments);
    };
  }());
  return function () {
    return _send(self, EXIT);
  };
} // Returns a promise that returns a result
// A SNAPSHOT handler will need to be created to handle the snapshot event
//
//  [SNAPSHOT]: (ctx, letter) => {
//    letter.reply(ctx.all())
//  }
//

function snapshoter(address, spawnFn) {
  spawnFn(address);
  return _send(address, SNAPSHOT, null, {
    expectReply: true,
    timeout: 0
  });
}

exports.EXIT = EXIT;
exports.INIT = INIT;
exports.SNAPSHOT = SNAPSHOT;
exports.SUBSCRIBE = SUBSCRIBE;
exports.TERMINATE = TERMINATE;
exports.UNSUBSCRIBE = UNSUBSCRIBE;
exports.UPDATED = UPDATED;
exports.kill = kill;
exports.send = _send;
exports.snapshoter = snapshoter;
exports.spawn = spawn;
exports.subscriber = subscriber;


}).call(this)}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"@babel/runtime/helpers/asyncToGenerator":6,"@babel/runtime/helpers/createForOfIteratorHelper":10,"@babel/runtime/helpers/defineProperty":12,"@babel/runtime/helpers/objectSpread2":21,"@babel/runtime/helpers/typeof":32,"@babel/runtime/regenerator":35,"queue-microtask":52}],43:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

function sansPrefix(address) {
  if (address == null) return null;
  return address.replace(/^0x/, "").replace(/^Fx/, "");
}
function withPrefix(address) {
  if (address == null) return null;
  return "0x" + sansPrefix(address);
}
function display(address) {
  return withPrefix(address);
}

exports.display = display;
exports.sansPrefix = sansPrefix;
exports.withPrefix = withPrefix;


},{}],44:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

function invariant(fact, msg) {
  if (!fact) {
    var _console;

    var error = new Error("INVARIANT ".concat(msg));
    error.stack = error.stack.split("\n").filter(function (d) {
      return !/at invariant/.test(d);
    }).join("\n");

    for (var _len = arguments.length, rest = new Array(_len > 2 ? _len - 2 : 0), _key = 2; _key < _len; _key++) {
      rest[_key - 2] = arguments[_key];
    }

    (_console = console).error.apply(_console, ["\n\n---\n\n", error, "\n\n"].concat(rest, ["\n\n---\n\n"]));

    throw error;
  }
}

exports.invariant = invariant;


},{}],45:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var _toConsumableArray = require('@babel/runtime/helpers/toConsumableArray');
var _asyncToGenerator = require('@babel/runtime/helpers/asyncToGenerator');
var _regeneratorRuntime = require('@babel/runtime/regenerator');
var config = require('@onflow/config');

function _interopDefaultLegacy (e) { return e && typeof e === 'object' && 'default' in e ? e : { 'default': e }; }

var _toConsumableArray__default = /*#__PURE__*/_interopDefaultLegacy(_toConsumableArray);
var _asyncToGenerator__default = /*#__PURE__*/_interopDefaultLegacy(_asyncToGenerator);
var _regeneratorRuntime__default = /*#__PURE__*/_interopDefaultLegacy(_regeneratorRuntime);

var LEVELS = Object.freeze({
  debug: 5,
  info: 4,
  log: 3,
  warn: 2,
  error: 1
});

var buildLoggerMessageArgs = function buildLoggerMessageArgs(_ref) {
  var title = _ref.title,
      message = _ref.message;
  return ["\n    %c".concat(title, "\n    ============================\n\n    ").concat(message, "\n\n    ============================\n    ").replace(/\n[^\S\r\n]+/g, "\n").trim(),, "font-weight:bold;font-family:monospace;"];
};

var log = /*#__PURE__*/function () {
  var _ref3 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(_ref2) {
    var _console, _console2, _console3, _console4, _console5;

    var title, message, level, _ref2$always, always, configLoggerLevel, loggerMessageArgs;

    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            title = _ref2.title, message = _ref2.message, level = _ref2.level, _ref2$always = _ref2.always, always = _ref2$always === void 0 ? false : _ref2$always;
            _context.next = 3;
            return config.config.get("logger.level", LEVELS.warn);

          case 3:
            configLoggerLevel = _context.sent;

            if (!(!always && configLoggerLevel < level)) {
              _context.next = 6;
              break;
            }

            return _context.abrupt("return");

          case 6:
            loggerMessageArgs = buildLoggerMessageArgs({
              title: title,
              message: message
            });
            _context.t0 = level;
            _context.next = _context.t0 === LEVELS.debug ? 10 : _context.t0 === LEVELS.info ? 12 : _context.t0 === LEVELS.warn ? 14 : _context.t0 === LEVELS.error ? 16 : 18;
            break;

          case 10:
            (_console = console).debug.apply(_console, _toConsumableArray__default["default"](loggerMessageArgs));

            return _context.abrupt("break", 19);

          case 12:
            (_console2 = console).info.apply(_console2, _toConsumableArray__default["default"](loggerMessageArgs));

            return _context.abrupt("break", 19);

          case 14:
            (_console3 = console).warn.apply(_console3, _toConsumableArray__default["default"](loggerMessageArgs));

            return _context.abrupt("break", 19);

          case 16:
            (_console4 = console).error.apply(_console4, _toConsumableArray__default["default"](loggerMessageArgs));

            return _context.abrupt("break", 19);

          case 18:
            (_console5 = console).log.apply(_console5, _toConsumableArray__default["default"](loggerMessageArgs));

          case 19:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));

  return function log(_x) {
    return _ref3.apply(this, arguments);
  };
}();

log.deprecate = function (_ref4) {
  var pkg = _ref4.pkg,
      subject = _ref4.subject,
      transition = _ref4.transition,
      _ref4$level = _ref4.level,
      level = _ref4$level === void 0 ? LEVELS.warn : _ref4$level,
      _ref4$message = _ref4.message,
      message = _ref4$message === void 0 ? "" : _ref4$message,
      _ref4$callback = _ref4.callback,
      callback = _ref4$callback === void 0 ? null : _ref4$callback;

  var capitalizeFirstLetter = function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  };

  var logMessage = function logMessage() {
    return log({
      title: "".concat(pkg ? pkg + " " : "", "Deprecation Notice"),
      message: "\n      ".concat(subject ? "".concat(capitalizeFirstLetter(subject), " is deprecated and will cease to work in future releases").concat(pkg ? " of " + pkg : "", ".") : "").concat(message ? "\n" + message : "").concat(transition ? "\nYou can learn more (including a guide on common transition paths) here: ".concat(transition) : "", "\n    ").trim(),
      level: level
    });
  };

  if (typeof callback === "function") {
    return /*#__PURE__*/_asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2() {
      var _args2 = arguments;
      return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
        while (1) {
          switch (_context2.prev = _context2.next) {
            case 0:
              _context2.next = 2;
              return logMessage();

            case 2:
              _context2.next = 4;
              return callback.apply(void 0, _args2);

            case 4:
              return _context2.abrupt("return", _context2.sent);

            case 5:
            case "end":
              return _context2.stop();
          }
        }
      }, _callee2);
    }));
  }

  return logMessage();
};

exports.LEVELS = LEVELS;
exports.log = log;


},{"@babel/runtime/helpers/asyncToGenerator":6,"@babel/runtime/helpers/toConsumableArray":29,"@babel/runtime/regenerator":35,"@onflow/config":36}],46:[function(require,module,exports){
(function (global){(function (){
'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var _toArray = require('@babel/runtime/helpers/toArray');
var _toConsumableArray = require('@babel/runtime/helpers/toConsumableArray');
var _asyncToGenerator = require('@babel/runtime/helpers/asyncToGenerator');
var _regeneratorRuntime = require('@babel/runtime/regenerator');
var _typeof = require('@babel/runtime/helpers/typeof');
var _defineProperty = require('@babel/runtime/helpers/defineProperty');
var _objectSpread = require('@babel/runtime/helpers/objectSpread2');
var _createForOfIteratorHelper = require('@babel/runtime/helpers/createForOfIteratorHelper');

function _interopDefaultLegacy (e) { return e && typeof e === 'object' && 'default' in e ? e : { 'default': e }; }

var _toArray__default = /*#__PURE__*/_interopDefaultLegacy(_toArray);
var _toConsumableArray__default = /*#__PURE__*/_interopDefaultLegacy(_toConsumableArray);
var _asyncToGenerator__default = /*#__PURE__*/_interopDefaultLegacy(_asyncToGenerator);
var _regeneratorRuntime__default = /*#__PURE__*/_interopDefaultLegacy(_regeneratorRuntime);
var _typeof__default = /*#__PURE__*/_interopDefaultLegacy(_typeof);
var _defineProperty__default = /*#__PURE__*/_interopDefaultLegacy(_defineProperty);
var _objectSpread__default = /*#__PURE__*/_interopDefaultLegacy(_objectSpread);
var _createForOfIteratorHelper__default = /*#__PURE__*/_interopDefaultLegacy(_createForOfIteratorHelper);

var promise;
var queueMicrotask_1 = typeof queueMicrotask === 'function' ? queueMicrotask // reuse resolved promise, and allocate it lazily
: function (cb) {
  return (promise || (promise = Promise.resolve())).then(cb)["catch"](function (err) {
    return setTimeout(function () {
      throw err;
    }, 0);
  });
};

var mailbox = function mailbox() {
  var queue = [];
  var next;
  return {
    deliver: function deliver(msg) {
      return _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee() {
        return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
          while (1) {
            switch (_context.prev = _context.next) {
              case 0:
                queue.push(msg);

                if (next) {
                  next(queue.shift());
                  next = undefined;
                }

              case 2:
              case "end":
                return _context.stop();
            }
          }
        }, _callee);
      }))();
    },
    receive: function receive() {
      return new Promise(function innerReceive(resolve) {
        var msg = queue.shift();
        if (msg) return resolve(msg);
        next = resolve;
      });
    }
  };
};

var INIT = "INIT";
var SUBSCRIBE = "SUBSCRIBE";
var UNSUBSCRIBE = "UNSUBSCRIBE";
var UPDATED$1 = "UPDATED";
var EXIT = "EXIT";
var TERMINATE = "TERMINATE";
var root = (typeof self === "undefined" ? "undefined" : _typeof__default["default"](self)) === "object" && self.self === self && self || (typeof global === "undefined" ? "undefined" : _typeof__default["default"](global)) === "object" && global.global === global && global || (typeof window === "undefined" ? "undefined" : _typeof__default["default"](window)) === "object" && window.window === window && window;
root.FCL_REGISTRY = root.FCL_REGISTRY == null ? {} : root.FCL_REGISTRY;
var pid = 0;
var DEFAULT_TIMEOUT = 5000;

var _send = function send(addr, tag, data) {
  var opts = arguments.length > 3 && arguments[3] !== undefined ? arguments[3] : {};
  return new Promise(function (reply, reject) {
    var expectReply = opts.expectReply || false;
    var timeout = opts.timeout != null ? opts.timeout : DEFAULT_TIMEOUT;

    if (expectReply && timeout) {
      setTimeout(function () {
        return reject(new Error("Timeout: ".concat(timeout, "ms passed without a response.")));
      }, timeout);
    }

    var payload = {
      to: addr,
      from: opts.from,
      tag: tag,
      data: data,
      timeout: timeout,
      reply: reply,
      reject: reject
    };

    try {
      root.FCL_REGISTRY[addr] && root.FCL_REGISTRY[addr].mailbox.deliver(payload);
      if (!expectReply) reply(true);
    } catch (error) {
      console.error("FCL.Actor -- Could Not Deliver Message", payload, root.FCL_REGISTRY[addr], error);
    }
  });
};

var kill = function kill(addr) {
  delete root.FCL_REGISTRY[addr];
};

var fromHandlers = function fromHandlers() {
  var handlers = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
  return /*#__PURE__*/function () {
    var _ref = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(ctx) {
      var letter;
      return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
        while (1) {
          switch (_context.prev = _context.next) {
            case 0:
              if (!(typeof handlers[INIT] === "function")) {
                _context.next = 3;
                break;
              }

              _context.next = 3;
              return handlers[INIT](ctx);

            case 3:
              _context.next = 6;
              return ctx.receive();

            case 6:
              letter = _context.sent;
              _context.prev = 7;

              if (!(letter.tag === EXIT)) {
                _context.next = 13;
                break;
              }

              if (!(typeof handlers[TERMINATE] === "function")) {
                _context.next = 12;
                break;
              }

              _context.next = 12;
              return handlers[TERMINATE](ctx, letter, letter.data || {});

            case 12:
              return _context.abrupt("break", 25);

            case 13:
              _context.next = 15;
              return handlers[letter.tag](ctx, letter, letter.data || {});

            case 15:
              _context.next = 20;
              break;

            case 17:
              _context.prev = 17;
              _context.t0 = _context["catch"](7);
              console.error("".concat(ctx.self(), " Error"), letter, _context.t0);

            case 20:
              _context.prev = 20;
              return _context.abrupt("continue", 3);

            case 23:
              _context.next = 3;
              break;

            case 25:
            case "end":
              return _context.stop();
          }
        }
      }, _callee, null, [[7, 17, 20, 23]]);
    }));

    return function (_x) {
      return _ref.apply(this, arguments);
    };
  }();
};

var spawn = function spawn(fn) {
  var addr = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : null;
  if (addr == null) addr = ++pid;
  if (root.FCL_REGISTRY[addr] != null) return addr;
  root.FCL_REGISTRY[addr] = {
    addr: addr,
    mailbox: mailbox(),
    subs: new Set(),
    kvs: {},
    error: null
  };
  var ctx = {
    self: function self() {
      return addr;
    },
    receive: function receive() {
      return root.FCL_REGISTRY[addr].mailbox.receive();
    },
    send: function send(to, tag, data) {
      var opts = arguments.length > 3 && arguments[3] !== undefined ? arguments[3] : {};
      opts.from = addr;
      return _send(to, tag, data, opts);
    },
    sendSelf: function sendSelf(tag, data, opts) {
      if (root.FCL_REGISTRY[addr]) _send(addr, tag, data, opts);
    },
    broadcast: function broadcast(tag, data) {
      var opts = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : {};
      opts.from = addr;

      var _iterator = _createForOfIteratorHelper__default["default"](root.FCL_REGISTRY[addr].subs),
          _step;

      try {
        for (_iterator.s(); !(_step = _iterator.n()).done;) {
          var to = _step.value;

          _send(to, tag, data, opts);
        }
      } catch (err) {
        _iterator.e(err);
      } finally {
        _iterator.f();
      }
    },
    subscribe: function subscribe(sub) {
      return sub != null && root.FCL_REGISTRY[addr].subs.add(sub);
    },
    unsubscribe: function unsubscribe(sub) {
      return sub != null && root.FCL_REGISTRY[addr].subs["delete"](sub);
    },
    subscriberCount: function subscriberCount() {
      return root.FCL_REGISTRY[addr].subs.size;
    },
    hasSubs: function hasSubs() {
      return !!root.FCL_REGISTRY[addr].subs.size;
    },
    put: function put(key, value) {
      if (key != null) root.FCL_REGISTRY[addr].kvs[key] = value;
    },
    get: function get(key, fallback) {
      var value = root.FCL_REGISTRY[addr].kvs[key];
      return value == null ? fallback : value;
    },
    "delete": function _delete(key) {
      delete root.FCL_REGISTRY[addr].kvs[key];
    },
    update: function update(key, fn) {
      if (key != null) root.FCL_REGISTRY[addr].kvs[key] = fn(root.FCL_REGISTRY[addr].kvs[key]);
    },
    keys: function keys() {
      return Object.keys(root.FCL_REGISTRY[addr].kvs);
    },
    all: function all() {
      return root.FCL_REGISTRY[addr].kvs;
    },
    where: function where(pattern) {
      return Object.keys(root.FCL_REGISTRY[addr].kvs).reduce(function (acc, key) {
        return pattern.test(key) ? _objectSpread__default["default"](_objectSpread__default["default"]({}, acc), {}, _defineProperty__default["default"]({}, key, root.FCL_REGISTRY[addr].kvs[key])) : acc;
      }, {});
    },
    merge: function merge() {
      var data = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
      Object.keys(data).forEach(function (key) {
        return root.FCL_REGISTRY[addr].kvs[key] = data[key];
      });
    },
    fatalError: function fatalError(error) {
      root.FCL_REGISTRY[addr].error = error;

      var _iterator2 = _createForOfIteratorHelper__default["default"](root.FCL_REGISTRY[addr].subs),
          _step2;

      try {
        for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
          var to = _step2.value;

          _send(to, UPDATED$1);
        }
      } catch (err) {
        _iterator2.e(err);
      } finally {
        _iterator2.f();
      }
    }
  };
  if (_typeof__default["default"](fn) === "object") fn = fromHandlers(fn);
  queueMicrotask_1( /*#__PURE__*/_asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2() {
    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            _context2.next = 2;
            return fn(ctx);

          case 2:
            kill(addr);

          case 3:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  })));
  return addr;
}; // Returns an unsubscribe function
// A SUBSCRIBE handler will need to be created to handle the subscription event
//
//  [SUBSCRIBE]: (ctx, letter) => {
//    ctx.subscribe(letter.from)
//    ctx.send(letter.from, UPDATED, ctx.all())
//  }
//


function subscriber(address, spawnFn, callback) {
  spawnFn(address);
  var EXIT = "@EXIT";
  var self = spawn( /*#__PURE__*/function () {
    var _ref3 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee3(ctx) {
      var letter, error;
      return _regeneratorRuntime__default["default"].wrap(function _callee3$(_context3) {
        while (1) {
          switch (_context3.prev = _context3.next) {
            case 0:
              ctx.send(address, SUBSCRIBE);

            case 1:
              _context3.next = 4;
              return ctx.receive();

            case 4:
              letter = _context3.sent;
              error = root.FCL_REGISTRY[address].error;

              if (!(letter.tag === EXIT)) {
                _context3.next = 9;
                break;
              }

              ctx.send(address, UNSUBSCRIBE);
              return _context3.abrupt("return");

            case 9:
              if (!error) {
                _context3.next = 13;
                break;
              }

              callback(null, error);
              ctx.send(address, UNSUBSCRIBE);
              return _context3.abrupt("return");

            case 13:
              callback(letter.data, null);
              _context3.next = 1;
              break;

            case 16:
            case "end":
              return _context3.stop();
          }
        }
      }, _callee3);
    }));

    return function (_x2) {
      return _ref3.apply(this, arguments);
    };
  }());
  return function () {
    return _send(self, EXIT);
  };
} // Returns a promise that returns a result

var _HANDLERS;

var NAME = "config";
var PUT = "PUT_CONFIG";
var GET = "GET_CONFIG";
var GET_ALL = "GET_ALL_CONFIG";
var UPDATE = "UPDATE_CONFIG";
var DELETE = "DELETE_CONFIG";
var CLEAR = "CLEAR_CONFIG";
var WHERE = "WHERE_CONFIG";
var UPDATED = "CONFIG/UPDATED";

var identity = function identity(v) {
  return v;
};

var HANDLERS = (_HANDLERS = {}, _defineProperty__default["default"](_HANDLERS, PUT, function (ctx, _letter, _ref) {
  var key = _ref.key,
      value = _ref.value;
  if (key == null) throw new Error("Missing 'key' for config/put.");
  ctx.put(key, value);
  ctx.broadcast(UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, GET, function (ctx, letter, _ref2) {
  var key = _ref2.key,
      fallback = _ref2.fallback;
  if (key == null) throw new Error("Missing 'key' for config/get");
  letter.reply(ctx.get(key, fallback));
}), _defineProperty__default["default"](_HANDLERS, GET_ALL, function (ctx, letter) {
  letter.reply(_objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, UPDATE, function (ctx, letter, _ref3) {
  var key = _ref3.key,
      fn = _ref3.fn;
  if (key == null) throw new Error("Missing 'key' for config/update");
  ctx.update(key, fn || identity);
  ctx.broadcast(UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, DELETE, function (ctx, letter, _ref4) {
  var key = _ref4.key;
  if (key == null) throw new Error("Missing 'key' for config/delete");
  ctx["delete"](key);
  ctx.broadcast(UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, CLEAR, function (ctx, letter) {
  var keys = Object.keys(ctx.all());

  for (var _i = 0, _keys = keys; _i < _keys.length; _i++) {
    var key = _keys[_i];
    ctx["delete"](key);
  }

  ctx.broadcast(UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, WHERE, function (ctx, letter, _ref5) {
  var pattern = _ref5.pattern;
  if (pattern == null) throw new Error("Missing 'pattern' for config/where");
  letter.reply(ctx.where(pattern));
}), _defineProperty__default["default"](_HANDLERS, SUBSCRIBE, function (ctx, letter) {
  ctx.subscribe(letter.from);
  ctx.send(letter.from, UPDATED, _objectSpread__default["default"]({}, ctx.all()));
}), _defineProperty__default["default"](_HANDLERS, UNSUBSCRIBE, function (ctx, letter) {
  ctx.unsubscribe(letter.from);
}), _HANDLERS);
spawn(HANDLERS, NAME);

function put(key, value) {
  _send(NAME, PUT, {
    key: key,
    value: value
  });
  return config();
}

function get(key, fallback) {
  return _send(NAME, GET, {
    key: key,
    fallback: fallback
  }, {
    expectReply: true,
    timeout: 10
  });
}

function first() {
  return _first.apply(this, arguments);
}

function _first() {
  _first = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2() {
    var wants,
        fallback,
        _wants,
        head,
        rest,
        ret,
        _args2 = arguments;

    return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            wants = _args2.length > 0 && _args2[0] !== undefined ? _args2[0] : [];
            fallback = _args2.length > 1 ? _args2[1] : undefined;

            if (wants.length) {
              _context2.next = 4;
              break;
            }

            return _context2.abrupt("return", fallback);

          case 4:
            _wants = _toArray__default["default"](wants), head = _wants[0], rest = _wants.slice(1);
            _context2.next = 7;
            return get(head);

          case 7:
            ret = _context2.sent;

            if (!(ret == null)) {
              _context2.next = 10;
              break;
            }

            return _context2.abrupt("return", first(rest, fallback));

          case 10:
            return _context2.abrupt("return", ret);

          case 11:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2);
  }));
  return _first.apply(this, arguments);
}

function all() {
  return _send(NAME, GET_ALL, null, {
    expectReply: true,
    timeout: 10
  });
}

function update(key) {
  var fn = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : identity;
  _send(NAME, UPDATE, {
    key: key,
    fn: fn
  });
  return config();
}

function _delete(key) {
  _send(NAME, DELETE, {
    key: key
  });
  return config();
}

function where(pattern) {
  return _send(NAME, WHERE, {
    pattern: pattern
  }, {
    expectReply: true,
    timeout: 10
  });
}

function subscribe(callback) {
  return subscriber(NAME, function () {
    return spawn(HANDLERS, NAME);
  }, callback);
}

function clearConfig() {
  return _send(NAME, CLEAR);
}

function config(values) {
  if (values != null && _typeof__default["default"](values) === "object") {
    Object.keys(values).map(function (d) {
      return put(d, values[d]);
    });
  }

  return {
    put: put,
    get: get,
    all: all,
    first: first,
    update: update,
    "delete": _delete,
    where: where,
    subscribe: subscribe,
    overload: overload
  };
}

config.put = put;
config.get = get;
config.all = all;
config.first = first;
config.update = update;
config["delete"] = _delete;
config.where = where;
config.subscribe = subscribe;
config.overload = overload;

var noop = function noop(v) {
  return v;
};

function overload() {
  var opts = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
  var callback = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : noop;
  return new Promise( /*#__PURE__*/function () {
    var _ref6 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(resolve, reject) {
      var oldConfig, result;
      return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
        while (1) {
          switch (_context.prev = _context.next) {
            case 0:
              _context.next = 2;
              return all();

            case 2:
              oldConfig = _context.sent;
              _context.prev = 3;
              config(opts);
              _context.t0 = callback;
              _context.next = 8;
              return all();

            case 8:
              _context.t1 = _context.sent;
              _context.next = 11;
              return (0, _context.t0)(_context.t1);

            case 11:
              result = _context.sent;
              _context.next = 14;
              return clearConfig();

            case 14:
              _context.next = 16;
              return config(oldConfig);

            case 16:
              resolve(result);
              _context.next = 26;
              break;

            case 19:
              _context.prev = 19;
              _context.t2 = _context["catch"](3);
              _context.next = 23;
              return clearConfig();

            case 23:
              _context.next = 25;
              return config(oldConfig);

            case 25:
              reject(_context.t2);

            case 26:
            case "end":
              return _context.stop();
          }
        }
      }, _callee, null, [[3, 19]]);
    }));

    return function (_x, _x2) {
      return _ref6.apply(this, arguments);
    };
  }());
}

var LEVELS = Object.freeze({
  debug: 5,
  info: 4,
  log: 3,
  warn: 2,
  error: 1
});

var buildLoggerMessageArgs = function buildLoggerMessageArgs(_ref) {
  var title = _ref.title,
      message = _ref.message;
  return ["\n    %c".concat(title, "\n    ============================\n\n    ").concat(message, "\n\n    ============================\n    ").replace(/\n[^\S\r\n]+/g, "\n").trim(),, "font-weight:bold;font-family:monospace;"];
};

var log = /*#__PURE__*/function () {
  var _ref3 = _asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee(_ref2) {
    var _console, _console2, _console3, _console4, _console5;

    var title, message, level, _ref2$always, always, configLoggerLevel, loggerMessageArgs;

    return _regeneratorRuntime__default["default"].wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            title = _ref2.title, message = _ref2.message, level = _ref2.level, _ref2$always = _ref2.always, always = _ref2$always === void 0 ? false : _ref2$always;
            _context.next = 3;
            return config.get("logger.level", LEVELS.warn);

          case 3:
            configLoggerLevel = _context.sent;

            if (!(!always && configLoggerLevel < level)) {
              _context.next = 6;
              break;
            }

            return _context.abrupt("return");

          case 6:
            loggerMessageArgs = buildLoggerMessageArgs({
              title: title,
              message: message
            });
            _context.t0 = level;
            _context.next = _context.t0 === LEVELS.debug ? 10 : _context.t0 === LEVELS.info ? 12 : _context.t0 === LEVELS.warn ? 14 : _context.t0 === LEVELS.error ? 16 : 18;
            break;

          case 10:
            (_console = console).debug.apply(_console, _toConsumableArray__default["default"](loggerMessageArgs));

            return _context.abrupt("break", 19);

          case 12:
            (_console2 = console).info.apply(_console2, _toConsumableArray__default["default"](loggerMessageArgs));

            return _context.abrupt("break", 19);

          case 14:
            (_console3 = console).warn.apply(_console3, _toConsumableArray__default["default"](loggerMessageArgs));

            return _context.abrupt("break", 19);

          case 16:
            (_console4 = console).error.apply(_console4, _toConsumableArray__default["default"](loggerMessageArgs));

            return _context.abrupt("break", 19);

          case 18:
            (_console5 = console).log.apply(_console5, _toConsumableArray__default["default"](loggerMessageArgs));

          case 19:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));

  return function log(_x) {
    return _ref3.apply(this, arguments);
  };
}();

log.deprecate = function (_ref4) {
  var pkg = _ref4.pkg,
      subject = _ref4.subject,
      transition = _ref4.transition,
      _ref4$level = _ref4.level,
      level = _ref4$level === void 0 ? LEVELS.warn : _ref4$level,
      _ref4$message = _ref4.message,
      message = _ref4$message === void 0 ? "" : _ref4$message,
      _ref4$callback = _ref4.callback,
      callback = _ref4$callback === void 0 ? null : _ref4$callback;

  var capitalizeFirstLetter = function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  };

  var logMessage = function logMessage() {
    return log({
      title: "".concat(pkg ? pkg + " " : "", "Deprecation Notice"),
      message: "\n      ".concat(subject ? "".concat(capitalizeFirstLetter(subject), " is deprecated and will cease to work in future releases").concat(pkg ? " of " + pkg : "", ".") : "").concat(message ? "\n" + message : "").concat(transition ? "\nYou can learn more (including a guide on common transition paths) here: ".concat(transition) : "", "\n    ").trim(),
      level: level
    });
  };

  if (typeof callback === "function") {
    return /*#__PURE__*/_asyncToGenerator__default["default"]( /*#__PURE__*/_regeneratorRuntime__default["default"].mark(function _callee2() {
      var _args2 = arguments;
      return _regeneratorRuntime__default["default"].wrap(function _callee2$(_context2) {
        while (1) {
          switch (_context2.prev = _context2.next) {
            case 0:
              _context2.next = 2;
              return logMessage();

            case 2:
              _context2.next = 4;
              return callback.apply(void 0, _args2);

            case 4:
              return _context2.abrupt("return", _context2.sent);

            case 5:
            case "end":
              return _context2.stop();
          }
        }
      }, _callee2);
    }));
  }

  return logMessage();
};

function interleave() {
  var a = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : [];
  var b = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : [];
  var c = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : [];
  if (!a.length && !b.length) return c;
  if (!a.length) return c;
  if (!b.length) return [].concat(_toConsumableArray__default["default"](c), [a[0]]);

  var _a = _toArray__default["default"](a),
      aHead = _a[0],
      aRest = _a.slice(1);

  var _b = _toArray__default["default"](b),
      bHead = _b[0],
      bRest = _b.slice(1);

  if (aHead !== undefined) c.push(aHead);
  if (bHead !== undefined) c.push(bHead);
  return interleave(aRest, bRest, c);
}

function recApply(d) {
  return function (arg1) {
    if (typeof arg1 === "function") {
      log.deprecate({
        pkg: "FCL/SDK",
        subject: "Interopolation of functions into template literals",
        transition: "https://github.com/onflow/flow-js-sdk/blob/master/packages/sdk/TRANSITIONS.md#0001-deprecate-params"
      });
      return recApply(d)(arg1(d));
    }

    return String(arg1);
  };
}

function template(head) {
  for (var _len = arguments.length, rest = new Array(_len > 1 ? _len - 1 : 0), _key = 1; _key < _len; _key++) {
    rest[_key - 1] = arguments[_key];
  }

  if (typeof head === "string") return function () {
    return head;
  };

  if (Array.isArray(head)) {
    return function (d) {
      return interleave(head, rest.map(recApply(d))).join("").trim();
    };
  }

  return head;
}

exports.interleave = interleave;
exports.template = template;


}).call(this)}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"@babel/runtime/helpers/asyncToGenerator":6,"@babel/runtime/helpers/createForOfIteratorHelper":10,"@babel/runtime/helpers/defineProperty":12,"@babel/runtime/helpers/objectSpread2":21,"@babel/runtime/helpers/toArray":28,"@babel/runtime/helpers/toConsumableArray":29,"@babel/runtime/helpers/typeof":32,"@babel/runtime/regenerator":35}],47:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

// Inspired by: https://github.com/lukeed/uid/blob/master/src/index.js , thank you Luke! https://github.com/lukeed
var HEX = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
var T = HEX.length;
function uid() {
  var str = "",
      num = 32;

  while (num--) {
    str += HEX[Math.random() * T | 0];
  }

  return str;
}

exports.uid = uid;


},{}],48:[function(require,module,exports){
'use strict'

exports.byteLength = byteLength
exports.toByteArray = toByteArray
exports.fromByteArray = fromByteArray

var lookup = []
var revLookup = []
var Arr = typeof Uint8Array !== 'undefined' ? Uint8Array : Array

var code = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
for (var i = 0, len = code.length; i < len; ++i) {
  lookup[i] = code[i]
  revLookup[code.charCodeAt(i)] = i
}

// Support decoding URL-safe base64 strings, as Node.js does.
// See: https://en.wikipedia.org/wiki/Base64#URL_applications
revLookup['-'.charCodeAt(0)] = 62
revLookup['_'.charCodeAt(0)] = 63

function getLens (b64) {
  var len = b64.length

  if (len % 4 > 0) {
    throw new Error('Invalid string. Length must be a multiple of 4')
  }

  // Trim off extra bytes after placeholder bytes are found
  // See: https://github.com/beatgammit/base64-js/issues/42
  var validLen = b64.indexOf('=')
  if (validLen === -1) validLen = len

  var placeHoldersLen = validLen === len
    ? 0
    : 4 - (validLen % 4)

  return [validLen, placeHoldersLen]
}

// base64 is 4/3 + up to two characters of the original data
function byteLength (b64) {
  var lens = getLens(b64)
  var validLen = lens[0]
  var placeHoldersLen = lens[1]
  return ((validLen + placeHoldersLen) * 3 / 4) - placeHoldersLen
}

function _byteLength (b64, validLen, placeHoldersLen) {
  return ((validLen + placeHoldersLen) * 3 / 4) - placeHoldersLen
}

function toByteArray (b64) {
  var tmp
  var lens = getLens(b64)
  var validLen = lens[0]
  var placeHoldersLen = lens[1]

  var arr = new Arr(_byteLength(b64, validLen, placeHoldersLen))

  var curByte = 0

  // if there are placeholders, only get up to the last complete 4 chars
  var len = placeHoldersLen > 0
    ? validLen - 4
    : validLen

  var i
  for (i = 0; i < len; i += 4) {
    tmp =
      (revLookup[b64.charCodeAt(i)] << 18) |
      (revLookup[b64.charCodeAt(i + 1)] << 12) |
      (revLookup[b64.charCodeAt(i + 2)] << 6) |
      revLookup[b64.charCodeAt(i + 3)]
    arr[curByte++] = (tmp >> 16) & 0xFF
    arr[curByte++] = (tmp >> 8) & 0xFF
    arr[curByte++] = tmp & 0xFF
  }

  if (placeHoldersLen === 2) {
    tmp =
      (revLookup[b64.charCodeAt(i)] << 2) |
      (revLookup[b64.charCodeAt(i + 1)] >> 4)
    arr[curByte++] = tmp & 0xFF
  }

  if (placeHoldersLen === 1) {
    tmp =
      (revLookup[b64.charCodeAt(i)] << 10) |
      (revLookup[b64.charCodeAt(i + 1)] << 4) |
      (revLookup[b64.charCodeAt(i + 2)] >> 2)
    arr[curByte++] = (tmp >> 8) & 0xFF
    arr[curByte++] = tmp & 0xFF
  }

  return arr
}

function tripletToBase64 (num) {
  return lookup[num >> 18 & 0x3F] +
    lookup[num >> 12 & 0x3F] +
    lookup[num >> 6 & 0x3F] +
    lookup[num & 0x3F]
}

function encodeChunk (uint8, start, end) {
  var tmp
  var output = []
  for (var i = start; i < end; i += 3) {
    tmp =
      ((uint8[i] << 16) & 0xFF0000) +
      ((uint8[i + 1] << 8) & 0xFF00) +
      (uint8[i + 2] & 0xFF)
    output.push(tripletToBase64(tmp))
  }
  return output.join('')
}

function fromByteArray (uint8) {
  var tmp
  var len = uint8.length
  var extraBytes = len % 3 // if we have 1 byte left, pad 2 bytes
  var parts = []
  var maxChunkLength = 16383 // must be multiple of 3

  // go through the array every three bytes, we'll deal with trailing stuff later
  for (var i = 0, len2 = len - extraBytes; i < len2; i += maxChunkLength) {
    parts.push(encodeChunk(uint8, i, (i + maxChunkLength) > len2 ? len2 : (i + maxChunkLength)))
  }

  // pad the end with zeros, but make sure to not forget the extra bytes
  if (extraBytes === 1) {
    tmp = uint8[len - 1]
    parts.push(
      lookup[tmp >> 2] +
      lookup[(tmp << 4) & 0x3F] +
      '=='
    )
  } else if (extraBytes === 2) {
    tmp = (uint8[len - 2] << 8) + uint8[len - 1]
    parts.push(
      lookup[tmp >> 10] +
      lookup[(tmp >> 4) & 0x3F] +
      lookup[(tmp << 2) & 0x3F] +
      '='
    )
  }

  return parts.join('')
}

},{}],49:[function(require,module,exports){
(function (Buffer){(function (){
/*!
 * The buffer module from node.js, for the browser.
 *
 * @author   Feross Aboukhadijeh <https://feross.org>
 * @license  MIT
 */
/* eslint-disable no-proto */

'use strict'

var base64 = require('base64-js')
var ieee754 = require('ieee754')

exports.Buffer = Buffer
exports.SlowBuffer = SlowBuffer
exports.INSPECT_MAX_BYTES = 50

var K_MAX_LENGTH = 0x7fffffff
exports.kMaxLength = K_MAX_LENGTH

/**
 * If `Buffer.TYPED_ARRAY_SUPPORT`:
 *   === true    Use Uint8Array implementation (fastest)
 *   === false   Print warning and recommend using `buffer` v4.x which has an Object
 *               implementation (most compatible, even IE6)
 *
 * Browsers that support typed arrays are IE 10+, Firefox 4+, Chrome 7+, Safari 5.1+,
 * Opera 11.6+, iOS 4.2+.
 *
 * We report that the browser does not support typed arrays if the are not subclassable
 * using __proto__. Firefox 4-29 lacks support for adding new properties to `Uint8Array`
 * (See: https://bugzilla.mozilla.org/show_bug.cgi?id=695438). IE 10 lacks support
 * for __proto__ and has a buggy typed array implementation.
 */
Buffer.TYPED_ARRAY_SUPPORT = typedArraySupport()

if (!Buffer.TYPED_ARRAY_SUPPORT && typeof console !== 'undefined' &&
    typeof console.error === 'function') {
  console.error(
    'This browser lacks typed array (Uint8Array) support which is required by ' +
    '`buffer` v5.x. Use `buffer` v4.x if you require old browser support.'
  )
}

function typedArraySupport () {
  // Can typed array instances can be augmented?
  try {
    var arr = new Uint8Array(1)
    arr.__proto__ = { __proto__: Uint8Array.prototype, foo: function () { return 42 } }
    return arr.foo() === 42
  } catch (e) {
    return false
  }
}

Object.defineProperty(Buffer.prototype, 'parent', {
  enumerable: true,
  get: function () {
    if (!Buffer.isBuffer(this)) return undefined
    return this.buffer
  }
})

Object.defineProperty(Buffer.prototype, 'offset', {
  enumerable: true,
  get: function () {
    if (!Buffer.isBuffer(this)) return undefined
    return this.byteOffset
  }
})

function createBuffer (length) {
  if (length > K_MAX_LENGTH) {
    throw new RangeError('The value "' + length + '" is invalid for option "size"')
  }
  // Return an augmented `Uint8Array` instance
  var buf = new Uint8Array(length)
  buf.__proto__ = Buffer.prototype
  return buf
}

/**
 * The Buffer constructor returns instances of `Uint8Array` that have their
 * prototype changed to `Buffer.prototype`. Furthermore, `Buffer` is a subclass of
 * `Uint8Array`, so the returned instances will have all the node `Buffer` methods
 * and the `Uint8Array` methods. Square bracket notation works as expected -- it
 * returns a single octet.
 *
 * The `Uint8Array` prototype remains unmodified.
 */

function Buffer (arg, encodingOrOffset, length) {
  // Common case.
  if (typeof arg === 'number') {
    if (typeof encodingOrOffset === 'string') {
      throw new TypeError(
        'The "string" argument must be of type string. Received type number'
      )
    }
    return allocUnsafe(arg)
  }
  return from(arg, encodingOrOffset, length)
}

// Fix subarray() in ES2016. See: https://github.com/feross/buffer/pull/97
if (typeof Symbol !== 'undefined' && Symbol.species != null &&
    Buffer[Symbol.species] === Buffer) {
  Object.defineProperty(Buffer, Symbol.species, {
    value: null,
    configurable: true,
    enumerable: false,
    writable: false
  })
}

Buffer.poolSize = 8192 // not used by this implementation

function from (value, encodingOrOffset, length) {
  if (typeof value === 'string') {
    return fromString(value, encodingOrOffset)
  }

  if (ArrayBuffer.isView(value)) {
    return fromArrayLike(value)
  }

  if (value == null) {
    throw TypeError(
      'The first argument must be one of type string, Buffer, ArrayBuffer, Array, ' +
      'or Array-like Object. Received type ' + (typeof value)
    )
  }

  if (isInstance(value, ArrayBuffer) ||
      (value && isInstance(value.buffer, ArrayBuffer))) {
    return fromArrayBuffer(value, encodingOrOffset, length)
  }

  if (typeof value === 'number') {
    throw new TypeError(
      'The "value" argument must not be of type number. Received type number'
    )
  }

  var valueOf = value.valueOf && value.valueOf()
  if (valueOf != null && valueOf !== value) {
    return Buffer.from(valueOf, encodingOrOffset, length)
  }

  var b = fromObject(value)
  if (b) return b

  if (typeof Symbol !== 'undefined' && Symbol.toPrimitive != null &&
      typeof value[Symbol.toPrimitive] === 'function') {
    return Buffer.from(
      value[Symbol.toPrimitive]('string'), encodingOrOffset, length
    )
  }

  throw new TypeError(
    'The first argument must be one of type string, Buffer, ArrayBuffer, Array, ' +
    'or Array-like Object. Received type ' + (typeof value)
  )
}

/**
 * Functionally equivalent to Buffer(arg, encoding) but throws a TypeError
 * if value is a number.
 * Buffer.from(str[, encoding])
 * Buffer.from(array)
 * Buffer.from(buffer)
 * Buffer.from(arrayBuffer[, byteOffset[, length]])
 **/
Buffer.from = function (value, encodingOrOffset, length) {
  return from(value, encodingOrOffset, length)
}

// Note: Change prototype *after* Buffer.from is defined to workaround Chrome bug:
// https://github.com/feross/buffer/pull/148
Buffer.prototype.__proto__ = Uint8Array.prototype
Buffer.__proto__ = Uint8Array

function assertSize (size) {
  if (typeof size !== 'number') {
    throw new TypeError('"size" argument must be of type number')
  } else if (size < 0) {
    throw new RangeError('The value "' + size + '" is invalid for option "size"')
  }
}

function alloc (size, fill, encoding) {
  assertSize(size)
  if (size <= 0) {
    return createBuffer(size)
  }
  if (fill !== undefined) {
    // Only pay attention to encoding if it's a string. This
    // prevents accidentally sending in a number that would
    // be interpretted as a start offset.
    return typeof encoding === 'string'
      ? createBuffer(size).fill(fill, encoding)
      : createBuffer(size).fill(fill)
  }
  return createBuffer(size)
}

/**
 * Creates a new filled Buffer instance.
 * alloc(size[, fill[, encoding]])
 **/
Buffer.alloc = function (size, fill, encoding) {
  return alloc(size, fill, encoding)
}

function allocUnsafe (size) {
  assertSize(size)
  return createBuffer(size < 0 ? 0 : checked(size) | 0)
}

/**
 * Equivalent to Buffer(num), by default creates a non-zero-filled Buffer instance.
 * */
Buffer.allocUnsafe = function (size) {
  return allocUnsafe(size)
}
/**
 * Equivalent to SlowBuffer(num), by default creates a non-zero-filled Buffer instance.
 */
Buffer.allocUnsafeSlow = function (size) {
  return allocUnsafe(size)
}

function fromString (string, encoding) {
  if (typeof encoding !== 'string' || encoding === '') {
    encoding = 'utf8'
  }

  if (!Buffer.isEncoding(encoding)) {
    throw new TypeError('Unknown encoding: ' + encoding)
  }

  var length = byteLength(string, encoding) | 0
  var buf = createBuffer(length)

  var actual = buf.write(string, encoding)

  if (actual !== length) {
    // Writing a hex string, for example, that contains invalid characters will
    // cause everything after the first invalid character to be ignored. (e.g.
    // 'abxxcd' will be treated as 'ab')
    buf = buf.slice(0, actual)
  }

  return buf
}

function fromArrayLike (array) {
  var length = array.length < 0 ? 0 : checked(array.length) | 0
  var buf = createBuffer(length)
  for (var i = 0; i < length; i += 1) {
    buf[i] = array[i] & 255
  }
  return buf
}

function fromArrayBuffer (array, byteOffset, length) {
  if (byteOffset < 0 || array.byteLength < byteOffset) {
    throw new RangeError('"offset" is outside of buffer bounds')
  }

  if (array.byteLength < byteOffset + (length || 0)) {
    throw new RangeError('"length" is outside of buffer bounds')
  }

  var buf
  if (byteOffset === undefined && length === undefined) {
    buf = new Uint8Array(array)
  } else if (length === undefined) {
    buf = new Uint8Array(array, byteOffset)
  } else {
    buf = new Uint8Array(array, byteOffset, length)
  }

  // Return an augmented `Uint8Array` instance
  buf.__proto__ = Buffer.prototype
  return buf
}

function fromObject (obj) {
  if (Buffer.isBuffer(obj)) {
    var len = checked(obj.length) | 0
    var buf = createBuffer(len)

    if (buf.length === 0) {
      return buf
    }

    obj.copy(buf, 0, 0, len)
    return buf
  }

  if (obj.length !== undefined) {
    if (typeof obj.length !== 'number' || numberIsNaN(obj.length)) {
      return createBuffer(0)
    }
    return fromArrayLike(obj)
  }

  if (obj.type === 'Buffer' && Array.isArray(obj.data)) {
    return fromArrayLike(obj.data)
  }
}

function checked (length) {
  // Note: cannot use `length < K_MAX_LENGTH` here because that fails when
  // length is NaN (which is otherwise coerced to zero.)
  if (length >= K_MAX_LENGTH) {
    throw new RangeError('Attempt to allocate Buffer larger than maximum ' +
                         'size: 0x' + K_MAX_LENGTH.toString(16) + ' bytes')
  }
  return length | 0
}

function SlowBuffer (length) {
  if (+length != length) { // eslint-disable-line eqeqeq
    length = 0
  }
  return Buffer.alloc(+length)
}

Buffer.isBuffer = function isBuffer (b) {
  return b != null && b._isBuffer === true &&
    b !== Buffer.prototype // so Buffer.isBuffer(Buffer.prototype) will be false
}

Buffer.compare = function compare (a, b) {
  if (isInstance(a, Uint8Array)) a = Buffer.from(a, a.offset, a.byteLength)
  if (isInstance(b, Uint8Array)) b = Buffer.from(b, b.offset, b.byteLength)
  if (!Buffer.isBuffer(a) || !Buffer.isBuffer(b)) {
    throw new TypeError(
      'The "buf1", "buf2" arguments must be one of type Buffer or Uint8Array'
    )
  }

  if (a === b) return 0

  var x = a.length
  var y = b.length

  for (var i = 0, len = Math.min(x, y); i < len; ++i) {
    if (a[i] !== b[i]) {
      x = a[i]
      y = b[i]
      break
    }
  }

  if (x < y) return -1
  if (y < x) return 1
  return 0
}

Buffer.isEncoding = function isEncoding (encoding) {
  switch (String(encoding).toLowerCase()) {
    case 'hex':
    case 'utf8':
    case 'utf-8':
    case 'ascii':
    case 'latin1':
    case 'binary':
    case 'base64':
    case 'ucs2':
    case 'ucs-2':
    case 'utf16le':
    case 'utf-16le':
      return true
    default:
      return false
  }
}

Buffer.concat = function concat (list, length) {
  if (!Array.isArray(list)) {
    throw new TypeError('"list" argument must be an Array of Buffers')
  }

  if (list.length === 0) {
    return Buffer.alloc(0)
  }

  var i
  if (length === undefined) {
    length = 0
    for (i = 0; i < list.length; ++i) {
      length += list[i].length
    }
  }

  var buffer = Buffer.allocUnsafe(length)
  var pos = 0
  for (i = 0; i < list.length; ++i) {
    var buf = list[i]
    if (isInstance(buf, Uint8Array)) {
      buf = Buffer.from(buf)
    }
    if (!Buffer.isBuffer(buf)) {
      throw new TypeError('"list" argument must be an Array of Buffers')
    }
    buf.copy(buffer, pos)
    pos += buf.length
  }
  return buffer
}

function byteLength (string, encoding) {
  if (Buffer.isBuffer(string)) {
    return string.length
  }
  if (ArrayBuffer.isView(string) || isInstance(string, ArrayBuffer)) {
    return string.byteLength
  }
  if (typeof string !== 'string') {
    throw new TypeError(
      'The "string" argument must be one of type string, Buffer, or ArrayBuffer. ' +
      'Received type ' + typeof string
    )
  }

  var len = string.length
  var mustMatch = (arguments.length > 2 && arguments[2] === true)
  if (!mustMatch && len === 0) return 0

  // Use a for loop to avoid recursion
  var loweredCase = false
  for (;;) {
    switch (encoding) {
      case 'ascii':
      case 'latin1':
      case 'binary':
        return len
      case 'utf8':
      case 'utf-8':
        return utf8ToBytes(string).length
      case 'ucs2':
      case 'ucs-2':
      case 'utf16le':
      case 'utf-16le':
        return len * 2
      case 'hex':
        return len >>> 1
      case 'base64':
        return base64ToBytes(string).length
      default:
        if (loweredCase) {
          return mustMatch ? -1 : utf8ToBytes(string).length // assume utf8
        }
        encoding = ('' + encoding).toLowerCase()
        loweredCase = true
    }
  }
}
Buffer.byteLength = byteLength

function slowToString (encoding, start, end) {
  var loweredCase = false

  // No need to verify that "this.length <= MAX_UINT32" since it's a read-only
  // property of a typed array.

  // This behaves neither like String nor Uint8Array in that we set start/end
  // to their upper/lower bounds if the value passed is out of range.
  // undefined is handled specially as per ECMA-262 6th Edition,
  // Section 13.3.3.7 Runtime Semantics: KeyedBindingInitialization.
  if (start === undefined || start < 0) {
    start = 0
  }
  // Return early if start > this.length. Done here to prevent potential uint32
  // coercion fail below.
  if (start > this.length) {
    return ''
  }

  if (end === undefined || end > this.length) {
    end = this.length
  }

  if (end <= 0) {
    return ''
  }

  // Force coersion to uint32. This will also coerce falsey/NaN values to 0.
  end >>>= 0
  start >>>= 0

  if (end <= start) {
    return ''
  }

  if (!encoding) encoding = 'utf8'

  while (true) {
    switch (encoding) {
      case 'hex':
        return hexSlice(this, start, end)

      case 'utf8':
      case 'utf-8':
        return utf8Slice(this, start, end)

      case 'ascii':
        return asciiSlice(this, start, end)

      case 'latin1':
      case 'binary':
        return latin1Slice(this, start, end)

      case 'base64':
        return base64Slice(this, start, end)

      case 'ucs2':
      case 'ucs-2':
      case 'utf16le':
      case 'utf-16le':
        return utf16leSlice(this, start, end)

      default:
        if (loweredCase) throw new TypeError('Unknown encoding: ' + encoding)
        encoding = (encoding + '').toLowerCase()
        loweredCase = true
    }
  }
}

// This property is used by `Buffer.isBuffer` (and the `is-buffer` npm package)
// to detect a Buffer instance. It's not possible to use `instanceof Buffer`
// reliably in a browserify context because there could be multiple different
// copies of the 'buffer' package in use. This method works even for Buffer
// instances that were created from another copy of the `buffer` package.
// See: https://github.com/feross/buffer/issues/154
Buffer.prototype._isBuffer = true

function swap (b, n, m) {
  var i = b[n]
  b[n] = b[m]
  b[m] = i
}

Buffer.prototype.swap16 = function swap16 () {
  var len = this.length
  if (len % 2 !== 0) {
    throw new RangeError('Buffer size must be a multiple of 16-bits')
  }
  for (var i = 0; i < len; i += 2) {
    swap(this, i, i + 1)
  }
  return this
}

Buffer.prototype.swap32 = function swap32 () {
  var len = this.length
  if (len % 4 !== 0) {
    throw new RangeError('Buffer size must be a multiple of 32-bits')
  }
  for (var i = 0; i < len; i += 4) {
    swap(this, i, i + 3)
    swap(this, i + 1, i + 2)
  }
  return this
}

Buffer.prototype.swap64 = function swap64 () {
  var len = this.length
  if (len % 8 !== 0) {
    throw new RangeError('Buffer size must be a multiple of 64-bits')
  }
  for (var i = 0; i < len; i += 8) {
    swap(this, i, i + 7)
    swap(this, i + 1, i + 6)
    swap(this, i + 2, i + 5)
    swap(this, i + 3, i + 4)
  }
  return this
}

Buffer.prototype.toString = function toString () {
  var length = this.length
  if (length === 0) return ''
  if (arguments.length === 0) return utf8Slice(this, 0, length)
  return slowToString.apply(this, arguments)
}

Buffer.prototype.toLocaleString = Buffer.prototype.toString

Buffer.prototype.equals = function equals (b) {
  if (!Buffer.isBuffer(b)) throw new TypeError('Argument must be a Buffer')
  if (this === b) return true
  return Buffer.compare(this, b) === 0
}

Buffer.prototype.inspect = function inspect () {
  var str = ''
  var max = exports.INSPECT_MAX_BYTES
  str = this.toString('hex', 0, max).replace(/(.{2})/g, '$1 ').trim()
  if (this.length > max) str += ' ... '
  return '<Buffer ' + str + '>'
}

Buffer.prototype.compare = function compare (target, start, end, thisStart, thisEnd) {
  if (isInstance(target, Uint8Array)) {
    target = Buffer.from(target, target.offset, target.byteLength)
  }
  if (!Buffer.isBuffer(target)) {
    throw new TypeError(
      'The "target" argument must be one of type Buffer or Uint8Array. ' +
      'Received type ' + (typeof target)
    )
  }

  if (start === undefined) {
    start = 0
  }
  if (end === undefined) {
    end = target ? target.length : 0
  }
  if (thisStart === undefined) {
    thisStart = 0
  }
  if (thisEnd === undefined) {
    thisEnd = this.length
  }

  if (start < 0 || end > target.length || thisStart < 0 || thisEnd > this.length) {
    throw new RangeError('out of range index')
  }

  if (thisStart >= thisEnd && start >= end) {
    return 0
  }
  if (thisStart >= thisEnd) {
    return -1
  }
  if (start >= end) {
    return 1
  }

  start >>>= 0
  end >>>= 0
  thisStart >>>= 0
  thisEnd >>>= 0

  if (this === target) return 0

  var x = thisEnd - thisStart
  var y = end - start
  var len = Math.min(x, y)

  var thisCopy = this.slice(thisStart, thisEnd)
  var targetCopy = target.slice(start, end)

  for (var i = 0; i < len; ++i) {
    if (thisCopy[i] !== targetCopy[i]) {
      x = thisCopy[i]
      y = targetCopy[i]
      break
    }
  }

  if (x < y) return -1
  if (y < x) return 1
  return 0
}

// Finds either the first index of `val` in `buffer` at offset >= `byteOffset`,
// OR the last index of `val` in `buffer` at offset <= `byteOffset`.
//
// Arguments:
// - buffer - a Buffer to search
// - val - a string, Buffer, or number
// - byteOffset - an index into `buffer`; will be clamped to an int32
// - encoding - an optional encoding, relevant is val is a string
// - dir - true for indexOf, false for lastIndexOf
function bidirectionalIndexOf (buffer, val, byteOffset, encoding, dir) {
  // Empty buffer means no match
  if (buffer.length === 0) return -1

  // Normalize byteOffset
  if (typeof byteOffset === 'string') {
    encoding = byteOffset
    byteOffset = 0
  } else if (byteOffset > 0x7fffffff) {
    byteOffset = 0x7fffffff
  } else if (byteOffset < -0x80000000) {
    byteOffset = -0x80000000
  }
  byteOffset = +byteOffset // Coerce to Number.
  if (numberIsNaN(byteOffset)) {
    // byteOffset: it it's undefined, null, NaN, "foo", etc, search whole buffer
    byteOffset = dir ? 0 : (buffer.length - 1)
  }

  // Normalize byteOffset: negative offsets start from the end of the buffer
  if (byteOffset < 0) byteOffset = buffer.length + byteOffset
  if (byteOffset >= buffer.length) {
    if (dir) return -1
    else byteOffset = buffer.length - 1
  } else if (byteOffset < 0) {
    if (dir) byteOffset = 0
    else return -1
  }

  // Normalize val
  if (typeof val === 'string') {
    val = Buffer.from(val, encoding)
  }

  // Finally, search either indexOf (if dir is true) or lastIndexOf
  if (Buffer.isBuffer(val)) {
    // Special case: looking for empty string/buffer always fails
    if (val.length === 0) {
      return -1
    }
    return arrayIndexOf(buffer, val, byteOffset, encoding, dir)
  } else if (typeof val === 'number') {
    val = val & 0xFF // Search for a byte value [0-255]
    if (typeof Uint8Array.prototype.indexOf === 'function') {
      if (dir) {
        return Uint8Array.prototype.indexOf.call(buffer, val, byteOffset)
      } else {
        return Uint8Array.prototype.lastIndexOf.call(buffer, val, byteOffset)
      }
    }
    return arrayIndexOf(buffer, [ val ], byteOffset, encoding, dir)
  }

  throw new TypeError('val must be string, number or Buffer')
}

function arrayIndexOf (arr, val, byteOffset, encoding, dir) {
  var indexSize = 1
  var arrLength = arr.length
  var valLength = val.length

  if (encoding !== undefined) {
    encoding = String(encoding).toLowerCase()
    if (encoding === 'ucs2' || encoding === 'ucs-2' ||
        encoding === 'utf16le' || encoding === 'utf-16le') {
      if (arr.length < 2 || val.length < 2) {
        return -1
      }
      indexSize = 2
      arrLength /= 2
      valLength /= 2
      byteOffset /= 2
    }
  }

  function read (buf, i) {
    if (indexSize === 1) {
      return buf[i]
    } else {
      return buf.readUInt16BE(i * indexSize)
    }
  }

  var i
  if (dir) {
    var foundIndex = -1
    for (i = byteOffset; i < arrLength; i++) {
      if (read(arr, i) === read(val, foundIndex === -1 ? 0 : i - foundIndex)) {
        if (foundIndex === -1) foundIndex = i
        if (i - foundIndex + 1 === valLength) return foundIndex * indexSize
      } else {
        if (foundIndex !== -1) i -= i - foundIndex
        foundIndex = -1
      }
    }
  } else {
    if (byteOffset + valLength > arrLength) byteOffset = arrLength - valLength
    for (i = byteOffset; i >= 0; i--) {
      var found = true
      for (var j = 0; j < valLength; j++) {
        if (read(arr, i + j) !== read(val, j)) {
          found = false
          break
        }
      }
      if (found) return i
    }
  }

  return -1
}

Buffer.prototype.includes = function includes (val, byteOffset, encoding) {
  return this.indexOf(val, byteOffset, encoding) !== -1
}

Buffer.prototype.indexOf = function indexOf (val, byteOffset, encoding) {
  return bidirectionalIndexOf(this, val, byteOffset, encoding, true)
}

Buffer.prototype.lastIndexOf = function lastIndexOf (val, byteOffset, encoding) {
  return bidirectionalIndexOf(this, val, byteOffset, encoding, false)
}

function hexWrite (buf, string, offset, length) {
  offset = Number(offset) || 0
  var remaining = buf.length - offset
  if (!length) {
    length = remaining
  } else {
    length = Number(length)
    if (length > remaining) {
      length = remaining
    }
  }

  var strLen = string.length

  if (length > strLen / 2) {
    length = strLen / 2
  }
  for (var i = 0; i < length; ++i) {
    var parsed = parseInt(string.substr(i * 2, 2), 16)
    if (numberIsNaN(parsed)) return i
    buf[offset + i] = parsed
  }
  return i
}

function utf8Write (buf, string, offset, length) {
  return blitBuffer(utf8ToBytes(string, buf.length - offset), buf, offset, length)
}

function asciiWrite (buf, string, offset, length) {
  return blitBuffer(asciiToBytes(string), buf, offset, length)
}

function latin1Write (buf, string, offset, length) {
  return asciiWrite(buf, string, offset, length)
}

function base64Write (buf, string, offset, length) {
  return blitBuffer(base64ToBytes(string), buf, offset, length)
}

function ucs2Write (buf, string, offset, length) {
  return blitBuffer(utf16leToBytes(string, buf.length - offset), buf, offset, length)
}

Buffer.prototype.write = function write (string, offset, length, encoding) {
  // Buffer#write(string)
  if (offset === undefined) {
    encoding = 'utf8'
    length = this.length
    offset = 0
  // Buffer#write(string, encoding)
  } else if (length === undefined && typeof offset === 'string') {
    encoding = offset
    length = this.length
    offset = 0
  // Buffer#write(string, offset[, length][, encoding])
  } else if (isFinite(offset)) {
    offset = offset >>> 0
    if (isFinite(length)) {
      length = length >>> 0
      if (encoding === undefined) encoding = 'utf8'
    } else {
      encoding = length
      length = undefined
    }
  } else {
    throw new Error(
      'Buffer.write(string, encoding, offset[, length]) is no longer supported'
    )
  }

  var remaining = this.length - offset
  if (length === undefined || length > remaining) length = remaining

  if ((string.length > 0 && (length < 0 || offset < 0)) || offset > this.length) {
    throw new RangeError('Attempt to write outside buffer bounds')
  }

  if (!encoding) encoding = 'utf8'

  var loweredCase = false
  for (;;) {
    switch (encoding) {
      case 'hex':
        return hexWrite(this, string, offset, length)

      case 'utf8':
      case 'utf-8':
        return utf8Write(this, string, offset, length)

      case 'ascii':
        return asciiWrite(this, string, offset, length)

      case 'latin1':
      case 'binary':
        return latin1Write(this, string, offset, length)

      case 'base64':
        // Warning: maxLength not taken into account in base64Write
        return base64Write(this, string, offset, length)

      case 'ucs2':
      case 'ucs-2':
      case 'utf16le':
      case 'utf-16le':
        return ucs2Write(this, string, offset, length)

      default:
        if (loweredCase) throw new TypeError('Unknown encoding: ' + encoding)
        encoding = ('' + encoding).toLowerCase()
        loweredCase = true
    }
  }
}

Buffer.prototype.toJSON = function toJSON () {
  return {
    type: 'Buffer',
    data: Array.prototype.slice.call(this._arr || this, 0)
  }
}

function base64Slice (buf, start, end) {
  if (start === 0 && end === buf.length) {
    return base64.fromByteArray(buf)
  } else {
    return base64.fromByteArray(buf.slice(start, end))
  }
}

function utf8Slice (buf, start, end) {
  end = Math.min(buf.length, end)
  var res = []

  var i = start
  while (i < end) {
    var firstByte = buf[i]
    var codePoint = null
    var bytesPerSequence = (firstByte > 0xEF) ? 4
      : (firstByte > 0xDF) ? 3
        : (firstByte > 0xBF) ? 2
          : 1

    if (i + bytesPerSequence <= end) {
      var secondByte, thirdByte, fourthByte, tempCodePoint

      switch (bytesPerSequence) {
        case 1:
          if (firstByte < 0x80) {
            codePoint = firstByte
          }
          break
        case 2:
          secondByte = buf[i + 1]
          if ((secondByte & 0xC0) === 0x80) {
            tempCodePoint = (firstByte & 0x1F) << 0x6 | (secondByte & 0x3F)
            if (tempCodePoint > 0x7F) {
              codePoint = tempCodePoint
            }
          }
          break
        case 3:
          secondByte = buf[i + 1]
          thirdByte = buf[i + 2]
          if ((secondByte & 0xC0) === 0x80 && (thirdByte & 0xC0) === 0x80) {
            tempCodePoint = (firstByte & 0xF) << 0xC | (secondByte & 0x3F) << 0x6 | (thirdByte & 0x3F)
            if (tempCodePoint > 0x7FF && (tempCodePoint < 0xD800 || tempCodePoint > 0xDFFF)) {
              codePoint = tempCodePoint
            }
          }
          break
        case 4:
          secondByte = buf[i + 1]
          thirdByte = buf[i + 2]
          fourthByte = buf[i + 3]
          if ((secondByte & 0xC0) === 0x80 && (thirdByte & 0xC0) === 0x80 && (fourthByte & 0xC0) === 0x80) {
            tempCodePoint = (firstByte & 0xF) << 0x12 | (secondByte & 0x3F) << 0xC | (thirdByte & 0x3F) << 0x6 | (fourthByte & 0x3F)
            if (tempCodePoint > 0xFFFF && tempCodePoint < 0x110000) {
              codePoint = tempCodePoint
            }
          }
      }
    }

    if (codePoint === null) {
      // we did not generate a valid codePoint so insert a
      // replacement char (U+FFFD) and advance only 1 byte
      codePoint = 0xFFFD
      bytesPerSequence = 1
    } else if (codePoint > 0xFFFF) {
      // encode to utf16 (surrogate pair dance)
      codePoint -= 0x10000
      res.push(codePoint >>> 10 & 0x3FF | 0xD800)
      codePoint = 0xDC00 | codePoint & 0x3FF
    }

    res.push(codePoint)
    i += bytesPerSequence
  }

  return decodeCodePointsArray(res)
}

// Based on http://stackoverflow.com/a/22747272/680742, the browser with
// the lowest limit is Chrome, with 0x10000 args.
// We go 1 magnitude less, for safety
var MAX_ARGUMENTS_LENGTH = 0x1000

function decodeCodePointsArray (codePoints) {
  var len = codePoints.length
  if (len <= MAX_ARGUMENTS_LENGTH) {
    return String.fromCharCode.apply(String, codePoints) // avoid extra slice()
  }

  // Decode in chunks to avoid "call stack size exceeded".
  var res = ''
  var i = 0
  while (i < len) {
    res += String.fromCharCode.apply(
      String,
      codePoints.slice(i, i += MAX_ARGUMENTS_LENGTH)
    )
  }
  return res
}

function asciiSlice (buf, start, end) {
  var ret = ''
  end = Math.min(buf.length, end)

  for (var i = start; i < end; ++i) {
    ret += String.fromCharCode(buf[i] & 0x7F)
  }
  return ret
}

function latin1Slice (buf, start, end) {
  var ret = ''
  end = Math.min(buf.length, end)

  for (var i = start; i < end; ++i) {
    ret += String.fromCharCode(buf[i])
  }
  return ret
}

function hexSlice (buf, start, end) {
  var len = buf.length

  if (!start || start < 0) start = 0
  if (!end || end < 0 || end > len) end = len

  var out = ''
  for (var i = start; i < end; ++i) {
    out += toHex(buf[i])
  }
  return out
}

function utf16leSlice (buf, start, end) {
  var bytes = buf.slice(start, end)
  var res = ''
  for (var i = 0; i < bytes.length; i += 2) {
    res += String.fromCharCode(bytes[i] + (bytes[i + 1] * 256))
  }
  return res
}

Buffer.prototype.slice = function slice (start, end) {
  var len = this.length
  start = ~~start
  end = end === undefined ? len : ~~end

  if (start < 0) {
    start += len
    if (start < 0) start = 0
  } else if (start > len) {
    start = len
  }

  if (end < 0) {
    end += len
    if (end < 0) end = 0
  } else if (end > len) {
    end = len
  }

  if (end < start) end = start

  var newBuf = this.subarray(start, end)
  // Return an augmented `Uint8Array` instance
  newBuf.__proto__ = Buffer.prototype
  return newBuf
}

/*
 * Need to make sure that buffer isn't trying to write out of bounds.
 */
function checkOffset (offset, ext, length) {
  if ((offset % 1) !== 0 || offset < 0) throw new RangeError('offset is not uint')
  if (offset + ext > length) throw new RangeError('Trying to access beyond buffer length')
}

Buffer.prototype.readUIntLE = function readUIntLE (offset, byteLength, noAssert) {
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  if (!noAssert) checkOffset(offset, byteLength, this.length)

  var val = this[offset]
  var mul = 1
  var i = 0
  while (++i < byteLength && (mul *= 0x100)) {
    val += this[offset + i] * mul
  }

  return val
}

Buffer.prototype.readUIntBE = function readUIntBE (offset, byteLength, noAssert) {
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  if (!noAssert) {
    checkOffset(offset, byteLength, this.length)
  }

  var val = this[offset + --byteLength]
  var mul = 1
  while (byteLength > 0 && (mul *= 0x100)) {
    val += this[offset + --byteLength] * mul
  }

  return val
}

Buffer.prototype.readUInt8 = function readUInt8 (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 1, this.length)
  return this[offset]
}

Buffer.prototype.readUInt16LE = function readUInt16LE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 2, this.length)
  return this[offset] | (this[offset + 1] << 8)
}

Buffer.prototype.readUInt16BE = function readUInt16BE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 2, this.length)
  return (this[offset] << 8) | this[offset + 1]
}

Buffer.prototype.readUInt32LE = function readUInt32LE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 4, this.length)

  return ((this[offset]) |
      (this[offset + 1] << 8) |
      (this[offset + 2] << 16)) +
      (this[offset + 3] * 0x1000000)
}

Buffer.prototype.readUInt32BE = function readUInt32BE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 4, this.length)

  return (this[offset] * 0x1000000) +
    ((this[offset + 1] << 16) |
    (this[offset + 2] << 8) |
    this[offset + 3])
}

Buffer.prototype.readIntLE = function readIntLE (offset, byteLength, noAssert) {
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  if (!noAssert) checkOffset(offset, byteLength, this.length)

  var val = this[offset]
  var mul = 1
  var i = 0
  while (++i < byteLength && (mul *= 0x100)) {
    val += this[offset + i] * mul
  }
  mul *= 0x80

  if (val >= mul) val -= Math.pow(2, 8 * byteLength)

  return val
}

Buffer.prototype.readIntBE = function readIntBE (offset, byteLength, noAssert) {
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  if (!noAssert) checkOffset(offset, byteLength, this.length)

  var i = byteLength
  var mul = 1
  var val = this[offset + --i]
  while (i > 0 && (mul *= 0x100)) {
    val += this[offset + --i] * mul
  }
  mul *= 0x80

  if (val >= mul) val -= Math.pow(2, 8 * byteLength)

  return val
}

Buffer.prototype.readInt8 = function readInt8 (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 1, this.length)
  if (!(this[offset] & 0x80)) return (this[offset])
  return ((0xff - this[offset] + 1) * -1)
}

Buffer.prototype.readInt16LE = function readInt16LE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 2, this.length)
  var val = this[offset] | (this[offset + 1] << 8)
  return (val & 0x8000) ? val | 0xFFFF0000 : val
}

Buffer.prototype.readInt16BE = function readInt16BE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 2, this.length)
  var val = this[offset + 1] | (this[offset] << 8)
  return (val & 0x8000) ? val | 0xFFFF0000 : val
}

Buffer.prototype.readInt32LE = function readInt32LE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 4, this.length)

  return (this[offset]) |
    (this[offset + 1] << 8) |
    (this[offset + 2] << 16) |
    (this[offset + 3] << 24)
}

Buffer.prototype.readInt32BE = function readInt32BE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 4, this.length)

  return (this[offset] << 24) |
    (this[offset + 1] << 16) |
    (this[offset + 2] << 8) |
    (this[offset + 3])
}

Buffer.prototype.readFloatLE = function readFloatLE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 4, this.length)
  return ieee754.read(this, offset, true, 23, 4)
}

Buffer.prototype.readFloatBE = function readFloatBE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 4, this.length)
  return ieee754.read(this, offset, false, 23, 4)
}

Buffer.prototype.readDoubleLE = function readDoubleLE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 8, this.length)
  return ieee754.read(this, offset, true, 52, 8)
}

Buffer.prototype.readDoubleBE = function readDoubleBE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 8, this.length)
  return ieee754.read(this, offset, false, 52, 8)
}

function checkInt (buf, value, offset, ext, max, min) {
  if (!Buffer.isBuffer(buf)) throw new TypeError('"buffer" argument must be a Buffer instance')
  if (value > max || value < min) throw new RangeError('"value" argument is out of bounds')
  if (offset + ext > buf.length) throw new RangeError('Index out of range')
}

Buffer.prototype.writeUIntLE = function writeUIntLE (value, offset, byteLength, noAssert) {
  value = +value
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  if (!noAssert) {
    var maxBytes = Math.pow(2, 8 * byteLength) - 1
    checkInt(this, value, offset, byteLength, maxBytes, 0)
  }

  var mul = 1
  var i = 0
  this[offset] = value & 0xFF
  while (++i < byteLength && (mul *= 0x100)) {
    this[offset + i] = (value / mul) & 0xFF
  }

  return offset + byteLength
}

Buffer.prototype.writeUIntBE = function writeUIntBE (value, offset, byteLength, noAssert) {
  value = +value
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  if (!noAssert) {
    var maxBytes = Math.pow(2, 8 * byteLength) - 1
    checkInt(this, value, offset, byteLength, maxBytes, 0)
  }

  var i = byteLength - 1
  var mul = 1
  this[offset + i] = value & 0xFF
  while (--i >= 0 && (mul *= 0x100)) {
    this[offset + i] = (value / mul) & 0xFF
  }

  return offset + byteLength
}

Buffer.prototype.writeUInt8 = function writeUInt8 (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 1, 0xff, 0)
  this[offset] = (value & 0xff)
  return offset + 1
}

Buffer.prototype.writeUInt16LE = function writeUInt16LE (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 2, 0xffff, 0)
  this[offset] = (value & 0xff)
  this[offset + 1] = (value >>> 8)
  return offset + 2
}

Buffer.prototype.writeUInt16BE = function writeUInt16BE (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 2, 0xffff, 0)
  this[offset] = (value >>> 8)
  this[offset + 1] = (value & 0xff)
  return offset + 2
}

Buffer.prototype.writeUInt32LE = function writeUInt32LE (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 4, 0xffffffff, 0)
  this[offset + 3] = (value >>> 24)
  this[offset + 2] = (value >>> 16)
  this[offset + 1] = (value >>> 8)
  this[offset] = (value & 0xff)
  return offset + 4
}

Buffer.prototype.writeUInt32BE = function writeUInt32BE (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 4, 0xffffffff, 0)
  this[offset] = (value >>> 24)
  this[offset + 1] = (value >>> 16)
  this[offset + 2] = (value >>> 8)
  this[offset + 3] = (value & 0xff)
  return offset + 4
}

Buffer.prototype.writeIntLE = function writeIntLE (value, offset, byteLength, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) {
    var limit = Math.pow(2, (8 * byteLength) - 1)

    checkInt(this, value, offset, byteLength, limit - 1, -limit)
  }

  var i = 0
  var mul = 1
  var sub = 0
  this[offset] = value & 0xFF
  while (++i < byteLength && (mul *= 0x100)) {
    if (value < 0 && sub === 0 && this[offset + i - 1] !== 0) {
      sub = 1
    }
    this[offset + i] = ((value / mul) >> 0) - sub & 0xFF
  }

  return offset + byteLength
}

Buffer.prototype.writeIntBE = function writeIntBE (value, offset, byteLength, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) {
    var limit = Math.pow(2, (8 * byteLength) - 1)

    checkInt(this, value, offset, byteLength, limit - 1, -limit)
  }

  var i = byteLength - 1
  var mul = 1
  var sub = 0
  this[offset + i] = value & 0xFF
  while (--i >= 0 && (mul *= 0x100)) {
    if (value < 0 && sub === 0 && this[offset + i + 1] !== 0) {
      sub = 1
    }
    this[offset + i] = ((value / mul) >> 0) - sub & 0xFF
  }

  return offset + byteLength
}

Buffer.prototype.writeInt8 = function writeInt8 (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 1, 0x7f, -0x80)
  if (value < 0) value = 0xff + value + 1
  this[offset] = (value & 0xff)
  return offset + 1
}

Buffer.prototype.writeInt16LE = function writeInt16LE (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 2, 0x7fff, -0x8000)
  this[offset] = (value & 0xff)
  this[offset + 1] = (value >>> 8)
  return offset + 2
}

Buffer.prototype.writeInt16BE = function writeInt16BE (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 2, 0x7fff, -0x8000)
  this[offset] = (value >>> 8)
  this[offset + 1] = (value & 0xff)
  return offset + 2
}

Buffer.prototype.writeInt32LE = function writeInt32LE (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 4, 0x7fffffff, -0x80000000)
  this[offset] = (value & 0xff)
  this[offset + 1] = (value >>> 8)
  this[offset + 2] = (value >>> 16)
  this[offset + 3] = (value >>> 24)
  return offset + 4
}

Buffer.prototype.writeInt32BE = function writeInt32BE (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 4, 0x7fffffff, -0x80000000)
  if (value < 0) value = 0xffffffff + value + 1
  this[offset] = (value >>> 24)
  this[offset + 1] = (value >>> 16)
  this[offset + 2] = (value >>> 8)
  this[offset + 3] = (value & 0xff)
  return offset + 4
}

function checkIEEE754 (buf, value, offset, ext, max, min) {
  if (offset + ext > buf.length) throw new RangeError('Index out of range')
  if (offset < 0) throw new RangeError('Index out of range')
}

function writeFloat (buf, value, offset, littleEndian, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) {
    checkIEEE754(buf, value, offset, 4, 3.4028234663852886e+38, -3.4028234663852886e+38)
  }
  ieee754.write(buf, value, offset, littleEndian, 23, 4)
  return offset + 4
}

Buffer.prototype.writeFloatLE = function writeFloatLE (value, offset, noAssert) {
  return writeFloat(this, value, offset, true, noAssert)
}

Buffer.prototype.writeFloatBE = function writeFloatBE (value, offset, noAssert) {
  return writeFloat(this, value, offset, false, noAssert)
}

function writeDouble (buf, value, offset, littleEndian, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) {
    checkIEEE754(buf, value, offset, 8, 1.7976931348623157E+308, -1.7976931348623157E+308)
  }
  ieee754.write(buf, value, offset, littleEndian, 52, 8)
  return offset + 8
}

Buffer.prototype.writeDoubleLE = function writeDoubleLE (value, offset, noAssert) {
  return writeDouble(this, value, offset, true, noAssert)
}

Buffer.prototype.writeDoubleBE = function writeDoubleBE (value, offset, noAssert) {
  return writeDouble(this, value, offset, false, noAssert)
}

// copy(targetBuffer, targetStart=0, sourceStart=0, sourceEnd=buffer.length)
Buffer.prototype.copy = function copy (target, targetStart, start, end) {
  if (!Buffer.isBuffer(target)) throw new TypeError('argument should be a Buffer')
  if (!start) start = 0
  if (!end && end !== 0) end = this.length
  if (targetStart >= target.length) targetStart = target.length
  if (!targetStart) targetStart = 0
  if (end > 0 && end < start) end = start

  // Copy 0 bytes; we're done
  if (end === start) return 0
  if (target.length === 0 || this.length === 0) return 0

  // Fatal error conditions
  if (targetStart < 0) {
    throw new RangeError('targetStart out of bounds')
  }
  if (start < 0 || start >= this.length) throw new RangeError('Index out of range')
  if (end < 0) throw new RangeError('sourceEnd out of bounds')

  // Are we oob?
  if (end > this.length) end = this.length
  if (target.length - targetStart < end - start) {
    end = target.length - targetStart + start
  }

  var len = end - start

  if (this === target && typeof Uint8Array.prototype.copyWithin === 'function') {
    // Use built-in when available, missing from IE11
    this.copyWithin(targetStart, start, end)
  } else if (this === target && start < targetStart && targetStart < end) {
    // descending copy from end
    for (var i = len - 1; i >= 0; --i) {
      target[i + targetStart] = this[i + start]
    }
  } else {
    Uint8Array.prototype.set.call(
      target,
      this.subarray(start, end),
      targetStart
    )
  }

  return len
}

// Usage:
//    buffer.fill(number[, offset[, end]])
//    buffer.fill(buffer[, offset[, end]])
//    buffer.fill(string[, offset[, end]][, encoding])
Buffer.prototype.fill = function fill (val, start, end, encoding) {
  // Handle string cases:
  if (typeof val === 'string') {
    if (typeof start === 'string') {
      encoding = start
      start = 0
      end = this.length
    } else if (typeof end === 'string') {
      encoding = end
      end = this.length
    }
    if (encoding !== undefined && typeof encoding !== 'string') {
      throw new TypeError('encoding must be a string')
    }
    if (typeof encoding === 'string' && !Buffer.isEncoding(encoding)) {
      throw new TypeError('Unknown encoding: ' + encoding)
    }
    if (val.length === 1) {
      var code = val.charCodeAt(0)
      if ((encoding === 'utf8' && code < 128) ||
          encoding === 'latin1') {
        // Fast path: If `val` fits into a single byte, use that numeric value.
        val = code
      }
    }
  } else if (typeof val === 'number') {
    val = val & 255
  }

  // Invalid ranges are not set to a default, so can range check early.
  if (start < 0 || this.length < start || this.length < end) {
    throw new RangeError('Out of range index')
  }

  if (end <= start) {
    return this
  }

  start = start >>> 0
  end = end === undefined ? this.length : end >>> 0

  if (!val) val = 0

  var i
  if (typeof val === 'number') {
    for (i = start; i < end; ++i) {
      this[i] = val
    }
  } else {
    var bytes = Buffer.isBuffer(val)
      ? val
      : Buffer.from(val, encoding)
    var len = bytes.length
    if (len === 0) {
      throw new TypeError('The value "' + val +
        '" is invalid for argument "value"')
    }
    for (i = 0; i < end - start; ++i) {
      this[i + start] = bytes[i % len]
    }
  }

  return this
}

// HELPER FUNCTIONS
// ================

var INVALID_BASE64_RE = /[^+/0-9A-Za-z-_]/g

function base64clean (str) {
  // Node takes equal signs as end of the Base64 encoding
  str = str.split('=')[0]
  // Node strips out invalid characters like \n and \t from the string, base64-js does not
  str = str.trim().replace(INVALID_BASE64_RE, '')
  // Node converts strings with length < 2 to ''
  if (str.length < 2) return ''
  // Node allows for non-padded base64 strings (missing trailing ===), base64-js does not
  while (str.length % 4 !== 0) {
    str = str + '='
  }
  return str
}

function toHex (n) {
  if (n < 16) return '0' + n.toString(16)
  return n.toString(16)
}

function utf8ToBytes (string, units) {
  units = units || Infinity
  var codePoint
  var length = string.length
  var leadSurrogate = null
  var bytes = []

  for (var i = 0; i < length; ++i) {
    codePoint = string.charCodeAt(i)

    // is surrogate component
    if (codePoint > 0xD7FF && codePoint < 0xE000) {
      // last char was a lead
      if (!leadSurrogate) {
        // no lead yet
        if (codePoint > 0xDBFF) {
          // unexpected trail
          if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD)
          continue
        } else if (i + 1 === length) {
          // unpaired lead
          if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD)
          continue
        }

        // valid lead
        leadSurrogate = codePoint

        continue
      }

      // 2 leads in a row
      if (codePoint < 0xDC00) {
        if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD)
        leadSurrogate = codePoint
        continue
      }

      // valid surrogate pair
      codePoint = (leadSurrogate - 0xD800 << 10 | codePoint - 0xDC00) + 0x10000
    } else if (leadSurrogate) {
      // valid bmp char, but last char was a lead
      if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD)
    }

    leadSurrogate = null

    // encode utf8
    if (codePoint < 0x80) {
      if ((units -= 1) < 0) break
      bytes.push(codePoint)
    } else if (codePoint < 0x800) {
      if ((units -= 2) < 0) break
      bytes.push(
        codePoint >> 0x6 | 0xC0,
        codePoint & 0x3F | 0x80
      )
    } else if (codePoint < 0x10000) {
      if ((units -= 3) < 0) break
      bytes.push(
        codePoint >> 0xC | 0xE0,
        codePoint >> 0x6 & 0x3F | 0x80,
        codePoint & 0x3F | 0x80
      )
    } else if (codePoint < 0x110000) {
      if ((units -= 4) < 0) break
      bytes.push(
        codePoint >> 0x12 | 0xF0,
        codePoint >> 0xC & 0x3F | 0x80,
        codePoint >> 0x6 & 0x3F | 0x80,
        codePoint & 0x3F | 0x80
      )
    } else {
      throw new Error('Invalid code point')
    }
  }

  return bytes
}

function asciiToBytes (str) {
  var byteArray = []
  for (var i = 0; i < str.length; ++i) {
    // Node's code seems to be doing this and not & 0x7F..
    byteArray.push(str.charCodeAt(i) & 0xFF)
  }
  return byteArray
}

function utf16leToBytes (str, units) {
  var c, hi, lo
  var byteArray = []
  for (var i = 0; i < str.length; ++i) {
    if ((units -= 2) < 0) break

    c = str.charCodeAt(i)
    hi = c >> 8
    lo = c % 256
    byteArray.push(lo)
    byteArray.push(hi)
  }

  return byteArray
}

function base64ToBytes (str) {
  return base64.toByteArray(base64clean(str))
}

function blitBuffer (src, dst, offset, length) {
  for (var i = 0; i < length; ++i) {
    if ((i + offset >= dst.length) || (i >= src.length)) break
    dst[i + offset] = src[i]
  }
  return i
}

// ArrayBuffer or Uint8Array objects from other contexts (i.e. iframes) do not pass
// the `instanceof` check but they should be treated as of that type.
// See: https://github.com/feross/buffer/issues/166
function isInstance (obj, type) {
  return obj instanceof type ||
    (obj != null && obj.constructor != null && obj.constructor.name != null &&
      obj.constructor.name === type.name)
}
function numberIsNaN (obj) {
  // For IE11 support
  return obj !== obj // eslint-disable-line no-self-compare
}

}).call(this)}).call(this,require("buffer").Buffer)
},{"base64-js":48,"buffer":49,"ieee754":50}],50:[function(require,module,exports){
/*! ieee754. BSD-3-Clause License. Feross Aboukhadijeh <https://feross.org/opensource> */
exports.read = function (buffer, offset, isLE, mLen, nBytes) {
  var e, m
  var eLen = (nBytes * 8) - mLen - 1
  var eMax = (1 << eLen) - 1
  var eBias = eMax >> 1
  var nBits = -7
  var i = isLE ? (nBytes - 1) : 0
  var d = isLE ? -1 : 1
  var s = buffer[offset + i]

  i += d

  e = s & ((1 << (-nBits)) - 1)
  s >>= (-nBits)
  nBits += eLen
  for (; nBits > 0; e = (e * 256) + buffer[offset + i], i += d, nBits -= 8) {}

  m = e & ((1 << (-nBits)) - 1)
  e >>= (-nBits)
  nBits += mLen
  for (; nBits > 0; m = (m * 256) + buffer[offset + i], i += d, nBits -= 8) {}

  if (e === 0) {
    e = 1 - eBias
  } else if (e === eMax) {
    return m ? NaN : ((s ? -1 : 1) * Infinity)
  } else {
    m = m + Math.pow(2, mLen)
    e = e - eBias
  }
  return (s ? -1 : 1) * m * Math.pow(2, e - mLen)
}

exports.write = function (buffer, value, offset, isLE, mLen, nBytes) {
  var e, m, c
  var eLen = (nBytes * 8) - mLen - 1
  var eMax = (1 << eLen) - 1
  var eBias = eMax >> 1
  var rt = (mLen === 23 ? Math.pow(2, -24) - Math.pow(2, -77) : 0)
  var i = isLE ? 0 : (nBytes - 1)
  var d = isLE ? 1 : -1
  var s = value < 0 || (value === 0 && 1 / value < 0) ? 1 : 0

  value = Math.abs(value)

  if (isNaN(value) || value === Infinity) {
    m = isNaN(value) ? 1 : 0
    e = eMax
  } else {
    e = Math.floor(Math.log(value) / Math.LN2)
    if (value * (c = Math.pow(2, -e)) < 1) {
      e--
      c *= 2
    }
    if (e + eBias >= 1) {
      value += rt / c
    } else {
      value += rt * Math.pow(2, 1 - eBias)
    }
    if (value * c >= 2) {
      e++
      c /= 2
    }

    if (e + eBias >= eMax) {
      m = 0
      e = eMax
    } else if (e + eBias >= 1) {
      m = ((value * c) - 1) * Math.pow(2, mLen)
      e = e + eBias
    } else {
      m = value * Math.pow(2, eBias - 1) * Math.pow(2, mLen)
      e = 0
    }
  }

  for (; mLen >= 8; buffer[offset + i] = m & 0xff, i += d, m /= 256, mLen -= 8) {}

  e = (e << mLen) | m
  eLen += mLen
  for (; eLen > 0; buffer[offset + i] = e & 0xff, i += d, e /= 256, eLen -= 8) {}

  buffer[offset + i - d] |= s * 128
}

},{}],51:[function(require,module,exports){
(function (global){(function (){
"use strict";

// ref: https://github.com/tc39/proposal-global
var getGlobal = function () {
	// the only reliable means to get the global object is
	// `Function('return this')()`
	// However, this causes CSP violations in Chrome apps.
	if (typeof self !== 'undefined') { return self; }
	if (typeof window !== 'undefined') { return window; }
	if (typeof global !== 'undefined') { return global; }
	throw new Error('unable to locate global object');
}

var globalObject = getGlobal();

module.exports = exports = globalObject.fetch;

// Needed for TypeScript and Webpack.
if (globalObject.fetch) {
	exports.default = globalObject.fetch.bind(globalObject);
}

exports.Headers = globalObject.Headers;
exports.Request = globalObject.Request;
exports.Response = globalObject.Response;

}).call(this)}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{}],52:[function(require,module,exports){
let promise

module.exports = typeof queueMicrotask === 'function'
  ? queueMicrotask
  // reuse resolved promise, and allocate it lazily
  : cb => (promise || (promise = Promise.resolve()))
    .then(cb)
    .catch(err => setTimeout(() => { throw err }, 0))

},{}],53:[function(require,module,exports){
"use strict";Object.defineProperty(exports,"__esModule",{value:true});exports["default"]=exports.SHAKE=exports.SHA3Hash=exports.SHA3=exports.Keccak=void 0;var _buffer=require("buffer");var _sponge=_interopRequireDefault(require("./sponge"));function _interopRequireDefault(obj){return obj&&obj.__esModule?obj:{"default":obj}}var createHash=function createHash(_ref){var allowedSizes=_ref.allowedSizes,defaultSize=_ref.defaultSize,padding=_ref.padding;return function Hash(){var _this=this;var size=arguments.length>0&&arguments[0]!==undefined?arguments[0]:defaultSize;if(!this||this.constructor!==Hash){return new Hash(size)}if(allowedSizes&&!allowedSizes.includes(size)){throw new Error("Unsupported hash length")}var sponge=new _sponge["default"]({capacity:size});this.update=function(input){var encoding=arguments.length>1&&arguments[1]!==undefined?arguments[1]:"utf8";if(_buffer.Buffer.isBuffer(input)){sponge.absorb(input);return _this}if(typeof input==="string"){return _this.update(_buffer.Buffer.from(input,encoding))}throw new TypeError("Not a string or buffer")};this.digest=function(){var formatOrOptions=arguments.length>0&&arguments[0]!==undefined?arguments[0]:"binary";var options=typeof formatOrOptions==="string"?{format:formatOrOptions}:formatOrOptions;var buffer=sponge.squeeze({buffer:options.buffer,padding:options.padding||padding});if(options.format&&options.format!=="binary"){return buffer.toString(options.format)}return buffer};this.reset=function(){sponge.reset();return _this};return this}};var Keccak=createHash({allowedSizes:[224,256,384,512],defaultSize:512,padding:1});exports.Keccak=Keccak;var SHA3=createHash({allowedSizes:[224,256,384,512],defaultSize:512,padding:6});exports.SHA3=SHA3;var SHAKE=createHash({allowedSizes:[128,256],defaultSize:256,padding:31});exports.SHAKE=SHAKE;var SHA3Hash=Keccak;exports.SHA3Hash=SHA3Hash;SHA3.SHA3Hash=SHA3Hash;var _default=SHA3;exports["default"]=_default;
},{"./sponge":54,"buffer":49}],54:[function(require,module,exports){
"use strict";Object.defineProperty(exports,"__esModule",{value:true});exports["default"]=void 0;var _buffer=require("buffer");var _permute=_interopRequireDefault(require("./permute"));function _interopRequireDefault(obj){return obj&&obj.__esModule?obj:{"default":obj}}var xorWords=function xorWords(I,O){for(var i=0;i<I.length;i+=8){var o=i/4;O[o]^=I[i+7]<<24|I[i+6]<<16|I[i+5]<<8|I[i+4];O[o+1]^=I[i+3]<<24|I[i+2]<<16|I[i+1]<<8|I[i]}return O};var readWords=function readWords(I,O){for(var o=0;o<O.length;o+=8){var i=o/4;O[o]=I[i+1];O[o+1]=I[i+1]>>>8;O[o+2]=I[i+1]>>>16;O[o+3]=I[i+1]>>>24;O[o+4]=I[i];O[o+5]=I[i]>>>8;O[o+6]=I[i]>>>16;O[o+7]=I[i]>>>24}return O};var Sponge=function Sponge(_ref){var _this=this;var capacity=_ref.capacity,padding=_ref.padding;var keccak=(0,_permute["default"])();var stateSize=200;var blockSize=capacity/8;var queueSize=stateSize-capacity/4;var queueOffset=0;var state=new Uint32Array(stateSize/4);var queue=_buffer.Buffer.allocUnsafe(queueSize);this.absorb=function(buffer){for(var i=0;i<buffer.length;i++){queue[queueOffset]=buffer[i];queueOffset+=1;if(queueOffset>=queueSize){xorWords(queue,state);keccak(state);queueOffset=0}}return _this};this.squeeze=function(){var options=arguments.length>0&&arguments[0]!==undefined?arguments[0]:{};var output={buffer:options.buffer||_buffer.Buffer.allocUnsafe(blockSize),padding:options.padding||padding,queue:_buffer.Buffer.allocUnsafe(queue.length),state:new Uint32Array(state.length)};queue.copy(output.queue);for(var i=0;i<state.length;i++){output.state[i]=state[i]}output.queue.fill(0,queueOffset);output.queue[queueOffset]|=output.padding;output.queue[queueSize-1]|=128;xorWords(output.queue,output.state);for(var offset=0;offset<output.buffer.length;offset+=queueSize){keccak(output.state);readWords(output.state,output.buffer.slice(offset,offset+queueSize))}return output.buffer};this.reset=function(){queue.fill(0);state.fill(0);queueOffset=0;return _this};return this};var _default=Sponge;exports["default"]=_default;
},{"./permute":57,"buffer":49}],55:[function(require,module,exports){
"use strict";Object.defineProperty(exports,"__esModule",{value:true});exports["default"]=void 0;var _copy=_interopRequireDefault(require("../copy"));function _interopRequireDefault(obj){return obj&&obj.__esModule?obj:{"default":obj}}var chi=function chi(_ref){var A=_ref.A,C=_ref.C;for(var y=0;y<25;y+=5){for(var x=0;x<5;x++){(0,_copy["default"])(A,y+x)(C,x)}for(var _x=0;_x<5;_x++){var xy=(y+_x)*2;var x1=(_x+1)%5*2;var x2=(_x+2)%5*2;A[xy]^=~C[x1]&C[x2];A[xy+1]^=~C[x1+1]&C[x2+1]}}};var _default=chi;exports["default"]=_default;
},{"../copy":56}],56:[function(require,module,exports){
"use strict";var copy=function copy(I,i){return function(O,o){var oi=o*2;var ii=i*2;O[oi]=I[ii];O[oi+1]=I[ii+1]}};module.exports=copy;
},{}],57:[function(require,module,exports){
"use strict";Object.defineProperty(exports,"__esModule",{value:true});exports["default"]=void 0;var _chi=_interopRequireDefault(require("./chi"));var _iota=_interopRequireDefault(require("./iota"));var _rhoPi=_interopRequireDefault(require("./rho-pi"));var _theta=_interopRequireDefault(require("./theta"));function _interopRequireDefault(obj){return obj&&obj.__esModule?obj:{"default":obj}}var permute=function permute(){var C=new Uint32Array(10);var D=new Uint32Array(10);var W=new Uint32Array(2);return function(A){for(var roundIndex=0;roundIndex<24;roundIndex++){(0,_theta["default"])({A:A,C:C,D:D,W:W});(0,_rhoPi["default"])({A:A,C:C,W:W});(0,_chi["default"])({A:A,C:C});(0,_iota["default"])({A:A,roundIndex:roundIndex})}C.fill(0);D.fill(0);W.fill(0)}};var _default=permute;exports["default"]=_default;
},{"./chi":55,"./iota":58,"./rho-pi":60,"./theta":63}],58:[function(require,module,exports){
"use strict";Object.defineProperty(exports,"__esModule",{value:true});exports["default"]=void 0;var _roundConstants=_interopRequireDefault(require("./round-constants"));function _interopRequireDefault(obj){return obj&&obj.__esModule?obj:{"default":obj}}var iota=function iota(_ref){var A=_ref.A,roundIndex=_ref.roundIndex;var i=roundIndex*2;A[0]^=_roundConstants["default"][i];A[1]^=_roundConstants["default"][i+1]};var _default=iota;exports["default"]=_default;
},{"./round-constants":59}],59:[function(require,module,exports){
"use strict";Object.defineProperty(exports,"__esModule",{value:true});exports["default"]=void 0;var ROUND_CONSTANTS=new Uint32Array([0,1,0,32898,2147483648,32906,2147483648,2147516416,0,32907,0,2147483649,2147483648,2147516545,2147483648,32777,0,138,0,136,0,2147516425,0,2147483658,0,2147516555,2147483648,139,2147483648,32905,2147483648,32771,2147483648,32770,2147483648,128,0,32778,2147483648,2147483658,2147483648,2147516545,2147483648,32896,0,2147483649,2147483648,2147516424]);var _default=ROUND_CONSTANTS;exports["default"]=_default;
},{}],60:[function(require,module,exports){
"use strict";Object.defineProperty(exports,"__esModule",{value:true});exports["default"]=void 0;var _piShuffles=_interopRequireDefault(require("./pi-shuffles"));var _rhoOffsets=_interopRequireDefault(require("./rho-offsets"));var _copy=_interopRequireDefault(require("../copy"));function _interopRequireDefault(obj){return obj&&obj.__esModule?obj:{"default":obj}}var rhoPi=function rhoPi(_ref){var A=_ref.A,C=_ref.C,W=_ref.W;(0,_copy["default"])(A,1)(W,0);var H=0;var L=0;var Wi=0;var ri=32;for(var i=0;i<24;i++){var j=_piShuffles["default"][i];var r=_rhoOffsets["default"][i];(0,_copy["default"])(A,j)(C,0);H=W[0];L=W[1];ri=32-r;Wi=r<32?0:1;W[Wi]=H<<r|L>>>ri;W[(Wi+1)%2]=L<<r|H>>>ri;(0,_copy["default"])(W,0)(A,j);(0,_copy["default"])(C,0)(W,0)}};var _default=rhoPi;exports["default"]=_default;
},{"../copy":56,"./pi-shuffles":61,"./rho-offsets":62}],61:[function(require,module,exports){
"use strict";Object.defineProperty(exports,"__esModule",{value:true});exports["default"]=void 0;var PI_SHUFFLES=[10,7,11,17,18,3,5,16,8,21,24,4,15,23,19,13,12,2,20,14,22,9,6,1];var _default=PI_SHUFFLES;exports["default"]=_default;
},{}],62:[function(require,module,exports){
"use strict";Object.defineProperty(exports,"__esModule",{value:true});exports["default"]=void 0;var RHO_OFFSETS=[1,3,6,10,15,21,28,36,45,55,2,14,27,41,56,8,25,43,62,18,39,61,20,44];var _default=RHO_OFFSETS;exports["default"]=_default;
},{}],63:[function(require,module,exports){
"use strict";Object.defineProperty(exports,"__esModule",{value:true});exports["default"]=void 0;var _copy=_interopRequireDefault(require("../copy"));function _interopRequireDefault(obj){return obj&&obj.__esModule?obj:{"default":obj}}var theta=function theta(_ref){var A=_ref.A,C=_ref.C,D=_ref.D,W=_ref.W;var H=0;var L=0;for(var x=0;x<5;x++){var x20=x*2;var x21=(x+5)*2;var x22=(x+10)*2;var x23=(x+15)*2;var x24=(x+20)*2;C[x20]=A[x20]^A[x21]^A[x22]^A[x23]^A[x24];C[x20+1]=A[x20+1]^A[x21+1]^A[x22+1]^A[x23+1]^A[x24+1]}for(var _x=0;_x<5;_x++){(0,_copy["default"])(C,(_x+1)%5)(W,0);H=W[0];L=W[1];W[0]=H<<1|L>>>31;W[1]=L<<1|H>>>31;D[_x*2]=C[(_x+4)%5*2]^W[0];D[_x*2+1]=C[(_x+4)%5*2+1]^W[1];for(var y=0;y<25;y+=5){A[(y+_x)*2]^=D[_x*2];A[(y+_x)*2+1]^=D[_x*2+1]}}};var _default=theta;exports["default"]=_default;
},{"../copy":56}]},{},[1]);
