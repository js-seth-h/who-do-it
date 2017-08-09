 moment = require 'moment'


_randomScopeName = (size = 4)->
  CODE_SPACE = 'ABCDEFGHJKMNPQRSTVWXYZ1234567890'
  result = ''
  for inx in [0...size]
    at = Math.floor CODE_SPACE.length * Math.random()
    result += CODE_SPACE[at]
  return result



class _LogStmt
  constructor: (args...)-> 
    # @pid = process.pid
    @actor = null
    @_do = [] 
    @_dump = {}

    @attrs = 
      pid: process.pid
      when: moment().toISOString() 

    if args.length > 0 
      @do args... 
  who: (@actor)->
  do: (args...)->
    args.map (val)=>
      @_do.push val
    return this 

  it: (obj)->
    for own key, val of obj
      @_dump[key] = val
    return this 

  attr: (obj)->
    for own key, val of obj
      @attrs[key] = val
    return this

  getAttr: (key)->
    return @attrs[key]

  toString : ()->
    ymd = @when.format("YYYYMMDD")
    dt = @when.format("hh:mm:ss.SSSS")
    "#{ymd} #{dt} #{@pid} #{@actor.toString()} #{@getDoString()}"

  toJsonML: ()->
    json_ml = [ 'log_stmt', @attrs ] 

    if @actor
      json_ml.push @actor.toJsonML()
      # json_ml.push ['subject', @actor.getNameSpaces()...]

    _.forEach @_do, (val)->
      fmt = _.find STRIZERS, (fmt)-> fmt.test val 
      json_ml.push fmt.toJsonML val

    # storiy_els = @_do.map (val)=>
    #   for fmt in STRIZERS
    #     if fmt.test val
    #       return fmt.toJsonML val 
    # # console.log 'storiy_els', storiy_els
    # json_ml.push storiy_els...
    # json_ml.push [ 'story', storiy_els...]
 
    _.forEach @_dump, (value, key)->
      fmt = _.find DUMPERS, (fmt)-> fmt.test val 
      json_ml.push fmt.toJsonML val

      
    # dump_keys = Object.keys(@_dump)
    # if dump_keys.length > 0 
    #   dump_els = dump_keys.map (key)=>
    #     val = @_dump[key]  
    #     for fmt in DUMPERS
    #       if fmt.test val
    #         return fmt.toJsonML key, val 
      # json_ml.push [ 'dump', dump_els...]
      # json_ml.push dump_els...
    # console.log 'json_ml =', json_ml
    return json_ml
  flush: (fn)->
    fn this.toJsonML()
    return this

class _Who 
  constructor: (@ns...) -> 
    if @ns.length is 0 
      @ns.push _randomScopeName()
    @_str = @ns.join(':')
    @_json_ml = ['who', @ns...]

  sub: (sub_str = undefined)->
    sub_str = _randomScopeName() unless sub_str
    return new _Who @ns..., sub_str 

  do: (strs...)->
    log = new _LogStmt
    log.who this
    log.do strs...
    return log
  toString : ()-> @_str
  toJsonML : ()-> @_json_ml

Who = (ns...)-> 
  return new _Who ns...
LogStmt = (ns...)-> 
  return new _LogStmt ns...


module.exports =
  Who: Who
  LogStmt: LogStmt
  Text: Text
  doParsers: STRIZERS