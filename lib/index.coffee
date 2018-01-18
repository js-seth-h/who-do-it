moment = require 'moment'
DEBUG = require('debug')

debug = DEBUG 'who-do-it'
###
  단순 디버그 대용으로 쓸수 이어야한다. => debug_ns를 따로 지정하고,
  statement를 만

  또한 파일 스트림, 네트워크등으로 의미성있게 전송이 가능해야한다.
  받는 놈은 단순하게하고, 보낼때 잘 보낼것.

  함수에 args...로 넣은 단위로 statement가 형성되고 자동 처리될것.


###
PROCESS_ID = undefined

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

GLOBAL_ATTR = {}

DUMPERS = [
  type: (val)-> 'error'
  test: (val)-> _isError val
  toDumpStr: (val)->
    val.stack.toString()
,
  type: (val)-> typeof val
  test: (val)-> _isFunction val
  toDumpStr: (val)->
    val.toString()
,
  type: (val)-> 'date'
  test: (val)-> val instanceof Date
  toDumpStr: (val)->
    val.toJSON()
,
  type: (val)-> typeof val
  test: (val)-> _isObject val
  toDumpStr: (val)->
    inspect val
,
  type: (val)-> typeof val
  test: (val)-> true
  toDumpStr: (val)->
    unless val
      str = String val
    else if val.toString?
      str = val.toString()
    else
      str = Object.prototype.toString.call val
    return str
]




class Meta
  constructor: (@attrs)->

_normalize = (arr)->
  attrs =
    when: moment().toISOString()
  Object.assign attrs, GLOBAL_ATTR
  childs = []
  for word in arr
    if word instanceof Meta
      Object.assign attrs, word.attrs
    else if _isPlainObject word
      for own k, val of word
        childs.push createVar k, val
    else
      childs. push word
  dumps = []
  if attrs.dump is true
    vars = childs.filter (ml)-> ml[0] is 'variable'
    dumps = vars.map (ml)->
      val = ml[1].ref 
      dumper = DUMPERS.find (item)-> item.test val
      type = dumper.type(val)
      dump_str = dumper.toDumpStr val
      return ['dump', {name: ml[1].name, type: type}, dump_str ]

  return ['testimony', attrs, childs..., dumps...]

decorable = (fn)->
  fn.decor = (attr)->
    _decord_fn = (args...)->
      fn new Meta(attr), args...
    return decorable _decord_fn
  return fn

createID = (label)->
  return ['id', "@"+label]
createVar = (varname, value)->
  return ['variable', {name: varname, ref : value} , '#'+ varname ]
createText = (text, attrs)->
  return ['text', attrs, text]

testify = (args...)->
  # formating & flushing
  ml_arr = _normalize args
  if !!DEBUG.load() and !!ml_arr[1].debug_ns
    # console.log 'ml_arr[1].debug_ns', ml_arr[1].debug_ns
    msg = convertString ml_arr
    # console.log msg
    DEBUG(ml_arr[1].debug_ns) msg

  if whodoit.write
    whodoit.write ml_arr
  return ml_arr
decorable testify

convertString = (arr)->
  childs = arr[2...]
  strs = childs.map (ml_item)->
    unless _isArray ml_item
      return ml_item
    start_inx = 1
    start_inx = 2 if _isPlainObject ml_item[1]
    tag = ml_item[0]
    items = ml_item[start_inx...]
    items.join ' '
  strs.join ' '

module.exports = whodoit =
  testify: testify
  Global : (attr)-> GLOBAL_ATTR = attr
  Meta : (attr)-> new Meta attr
  Who : createID
  ID : createID
  T : createText
  Text : createText
  Var : createVar
  write: null
