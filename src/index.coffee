moment = require 'moment'

debug = require('debug')('ver2')

if !Array::find
  Array::find = (predicate) ->
    'use strict'
    if this is null
      throw new TypeError('Array.prototype.find called on null or undefined')
    if typeof predicate != 'function'
      throw new TypeError('predicate must be a function')
    list = Object(this)
    length = list.length >>> 0
    thisArg = arguments[1]
    value = undefined
    i = 0
    while i < length
      value = list[i]
      if predicate.call(thisArg, value, i, list)
        return value
      i++
    return undefined



inspect = (val)-> JSON.stringify(val, null, 2)
if (typeof process isnt 'undefined') and (process.release.name is 'node')
  util = require 'util'
  inspect = (val)->
    util.inspect val, showHidden: false, depth: 10

_isString = (obj)->
  typeof obj == 'string' || obj instanceof String
_isArray = Array.isArray or (obj) ->
  Object.prototype.toString.call(obj) is "[object Array]"
# _isDate = (obj)->
#   Object.prototype.toString.call(obj) is '[object Date]'
_isFunction = (obj)->
  Object.prototype.toString.call(obj) is '[object Function]'
_isObject = (obj)->
  return !!(typeof obj is 'object' and obj isnt null)
_isPlainObject= (obj)->
  return obj != null and typeof obj == 'object' and Object.getPrototypeOf(obj) == Object.prototype

_isError = (obj)->
  return obj instanceof Error

_randomScopeName = (size = 4)->
  CODE_SPACE = 'ABCDEFGHJKMNPQRSTVWXYZ1234567890'
  result = ''
  for inx in [0...size]
    at = Math.floor CODE_SPACE.length * Math.random()
    result += CODE_SPACE[at]
  return result

###
반환되는 것은 [tag, attr, childs...] 이거나  string
###
MLizers = [
  test: (val)->
    # if val
    #   debug 'test has toJsonML',val, val.toJsonML
    return val?.toJsonML?
  toJsonML: (val)->
    return val.toJsonML() # [ 'text', val.getAttr(), val.toString() ]
,
  test: (val)->
    # if val
    #   debug 'test is date',val, val.toISOString
    return val?.toISOString?
  toJsonML: (val, inx)->
    return [ 'date',  val.toISOString()]
,
  test: (val)-> _isArray val
  toJsonML: (val, inx)->
    Object.prototype.toString.call val
,
  test: (val)-> _isFunction val
  toJsonML: (val, inx)->
    Object.prototype.toString.call val
,
  test: (val)-> true
  toJsonML: (val)->
    unless val # null, undefined, false, '', 0 ...
      str = String val
    else if val.toString?
      str = val.toString()
    else
      str = Object.prototype.toString.call val
    return str

]

DUMPERS = [
  type: 'error'
  test: (val)-> _isError val
  toDumpStr: (val)->
    val.stack.toString()
  # toJsonML: (key, val)->
  #   return [ 'dump', {name: key, type: "error"},  val.stack.toString() ]
,
  type: 'function'
  test: (val)-> _isFunction val
  toDumpStr: (val)->
    val.toString()
  # toJsonML: (key, val)->
  #   return [ 'dump', {name: key, type: "function"},  val.toString() ]
,
  type: 'object'
  test: (val)-> _isObject val
  toDumpStr: (val)->
    inspect val
  # toJsonML: (key, val)->
  #   return [ 'dump', {name: key, type: "object"},  inspect(val) ]
,
  type: undefined
  # type: 'string'
  test: (val)-> true
  toDumpStr: (val)->
  # toJsonML: (key, val)->
    unless val
      str = String val
    else if val.toString?
      str = val.toString()
    else
      str = Object.prototype.toString.call val
    return str
    # return ['dump', {name: key}, str]
]



class _ML
  constructor: (@attrs, @childs...)->
    @tag = 'text'
    if not _isPlainObject @attrs
      @childs.unshift @attrs
      @attrs = null

    # debug '_ML', @attrs, @childs


  toJsonML: ()->
    jsonML = [@tag]
    jsonML.push @attrs if @attrs
    @childs.forEach (val)=>
      fmt = MLizers.find (fmt)-> fmt.test val
      if fmt
        ml = fmt.toJsonML val 
      else 
        ml = Object.prototype.toString.call val
      # debug 'MLizers', val, 'to', ml, 'by', fmt.toJsonML.toString()
      jsonML.push ml
    return jsonML

  toString: ()->
    ml = @toJsonML()

    _str = (ml_node)->
      txts = []
      ml_node[1...].forEach (child)->
        return if _isPlainObject child
        return txts.push _str(child) if _isArray child
        txts.push child
      txts.join ' '
    _str ml


  attr: (obj)->
    @attrs = {} unless @attrs
    for own key, val of obj
      @attrs[key] = val
    return this

  getAttr: (key)->
    return @attrs[key]



class _LogStmt extends _ML
  constructor: (args...)->
    super args...
    @tag = 'log_stmt'
    @attr
      pid : process.pid
      when: moment().toISOString()
    @_dump = {}

  do: (args...)->
    args.map (val)=>
      @childs.push val
    return this

  it: (obj)->
    for own key, val of obj
      @_dump[key] = val
    return this

  toJsonML: ()->
    jsonML = super()
    Object.keys(@_dump).forEach (key)=>
      val = @_dump[key]
      fmt = DUMPERS.find (fmt)-> fmt.test val
      if fmt
        dump_str = fmt.toDumpStr val
      else 
        dump_str = Object.prototype.toString.call val      
      # ml = fmt.toJsonML key, val
      jsonML.push ['dump', {name: key, type: fmt.type}, dump_str ]

    return jsonML

  flush: (fn)->
    fn this.toJsonML()
    return this

class _Who extends _ML
  constructor: (args...)->
    super args...
    @tag = 'who'

  sub: (sub_str = undefined)->
    sub_str = _randomScopeName() unless sub_str
    new _Who @childs..., sub_str

  do: (childs...)->
    log = new _LogStmt this, childs...
    return log


Who = (args...)->
  return new _Who args...
LogStmt = (args...)->
  return new _LogStmt args...

Text = (args...)->
  return new _ML args...

module.exports =
  Who: Who
  LogStmt: LogStmt
  Text: Text

  MLizers: MLizers
  Dumpers: DUMPERS