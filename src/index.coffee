moment = require 'moment'

###


[ "log_stmt", 
{
  pid = pid,
  when = ISODateString
  사용자 attrs...
}
["subject", "scope1", ... ]
["story", literal, ["string", attr, string ...], ... ] 
["dump", [key, value], [type, string, ...], ... ] 
]


###

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
_isError = (obj)->
  return obj instanceof Error

STRIZERS = [
  test: (val)-> val instanceof Wraped
  toJsonML: (val)->
    return [ 'text', val.getAttr(), val.toString() ] 
, 
  test: (val)-> val.toISOString?
  toJsonML: (val, inx)->
    return val.toISOString()
,
  test: (val)-> _isArray val
  toJsonML: (val, inx)->
    return Object.prototype.toString.call val 
,
  test: (val)-> _isFunction val
  toJsonML: (val, inx)->
    return Object.prototype.toString.call val 
, 
  test: (val)-> val is null
  toJsonML: (val)->
    return String(val) 
,
  test: (val)-> true
  toJsonML: (val)-> 
    if val.toString?
      str = val.toString()
    else
      str = Object.prototype.toString.call val
    return str 
]

DUMPERS = [
  test: (val)-> _isError val
  toJsonML: (key, val)-> 
    return [ 'var', {name: key, type: "error"},  val.stack.toString() ]
,
  test: (val)-> _isFunction val
  toJsonML: (key, val)-> 
    return [ 'var', {name: key, type: "function"},  val.toString() ]
,
  test: (val)-> _isObject val
  toJsonML: (key, val)-> 
    return [ 'var', {name: key, type: "object"},  JSON.stringify(val, null, 2) ] 
,
  test: (val)-> true
  toJsonML: (key, val)-> 
    if val.toString?
      str = val.toString()
    else
      str = Object.prototype.toString.call val
    return ['var', {name: key}, str]
]

_randomScopeName = (size = 4)->
  CODE_SPACE = 'ABCDEFGHJKMNPQRSTVWXYZ1234567890'
  result = ''
  for inx in [0...size]
    at = Math.floor CODE_SPACE.length * Math.random()
    result += CODE_SPACE[at]
  return result

class LogStmt
  constructor: (str = undefined)-> 
    # @pid = process.pid
    @actor = null
    @_do = []
    @_story = null
    @_dump = {}

    @tags = []
    @attrs = 
      pid: process.pid
      when: moment().toISOString() 

    if str 
      @do str


  who: (@actor)->
  do: (args...)->
    args.map (val)=>
      @_do.push val
    return this
  ln: ()->
    @_do.push "\n"
    return this
  hr: ()->
    @_do.push "\n" + _hr
    return this

  it: (obj)->
    for own key, val of obj
      @_dump[key] = val
    return this
  tag: (args...)->
    args.map (val)=>
      @tags.push val 
    return this
  attr: (obj)->
    for own key, val of obj
      @attrs[key] = val
    return this

  getAttr: (key)->
    return @attrs[key]
  # getStory: ()->
  #   return @_story if @_story 
  #   story = @_do.map (val)=>
  #     for fmt in STRIZERS
  #       if fmt.test val
  #         return fmt.toJsonML val 
  #   return @_story
    
  hasTag: (a_tag)->
    return @tags.indexOf(a_tag) >= 0 
  getDoString: ()->
    strs = @story.map (i)-> i.str
    strs.join ' '

  toString : ()->
    ymd = @when.format("YYYYMMDD")
    dt = @when.format("hh:mm:ss.SSSS")
    "#{ymd} #{dt} #{@pid} #{@actor.toString()} #{@getDoString()}"

  toJsonML: ()->
    json_ml = [ 'log_stmt', @attrs ] 

    if @actor
      json_ml.push ['subject', @actor.getNameSpaces()...]

    storiy_els = @_do.map (val)=>
      for fmt in STRIZERS
        if fmt.test val
          return fmt.toJsonML val 
    # console.log 'storiy_els', storiy_els
    json_ml.push storiy_els...
    # json_ml.push [ 'story', storiy_els...]
 
    dump_keys = Object.keys(@_dump)
    if dump_keys.length > 0 
      dump_els = dump_keys.map (key)=>
        val = @_dump[key]  
        for fmt in DUMPERS
          if fmt.test val
            return fmt.toJsonML key, val 
      # json_ml.push [ 'dump', dump_els...]
      json_ml.push dump_els...
    # console.log 'json_ml =', json_ml
    return json_ml
  flush: (fn)->
    fn this.toJsonML()
    return this
LogStmt.create = (str)->
  new LogStmt str

class Wraped
  constructor: (@value, @attrs = {})->
  toString: ()-> @value
  getAttr: ()-> @attrs
  totoJsonMLdDesc: ()->
    desc = []
    for own key, value of @attrs
      desc.push value
    desc.join ','
Wraped.create = (val, toJsonML)->
  new Wraped val, toJsonML

class Who
  ns: []
  constructor: (args...) ->
    @ns = args
    @_str = @ns.join(':')
  scope: (args...)->
    @sub args...
  sub: (sub_str = undefined)->
    sub_str = _randomScopeName() unless sub_str
    return new Who @ns..., sub_str
  getNameSpaces: ()-> @ns
  toString: ()->
    return "[#{@_str}]"
  # log: (section, args...)->
  #   EpicLog section, this, args...
  do: (args...)->
    log = new LogStmt
    log.who this
    log.do args...
    return log

Who.create = (args...)->
  new Who args...

module.exports =
  Who: Who
  LogStmt: LogStmt
  Wraped: Wraped
  doParsers: STRIZERS
  # BetterConsole: BetterConsole


