process.env.DEBUG = "*"
{Who,LogStmt, Text } = require '../src/ver2'
assert = require 'assert'
util = require 'util'


debug = require('debug')('test')

describe 'simple toJsonML', ()->
  it 'who ', (done)->
    w = Who 'my-name'
    ml = w.toJsonML()
    expect ml
      .toEqual ['who', 'my-name']

    done()
  it 'who.sub', (done)->
    w = Who 'my-name'
    w = w.sub 'x'
    ml = w.toJsonML()
    expect ml
      .toEqual ['who', 'my-name', 'x']

    done()

  it 'LogStmt ', (done)->
    s = LogStmt 'code', 'it'
    ml = s.toJsonML()
    expect ml[0]
      .toEqual 'log_stmt'
    expect ml[1].pid
      .toBeTruthy()
    expect ml[1].when
      .toBeTruthy()
    expect ml[2...]
      .toEqual ['code', 'it']
    done()


  it 'Text', (done)->
    s = Text 'type', 'a text'
    ml = s.toJsonML()
    expect ml
      .toEqual ['text', 'type', 'a text']
    done()

describe 'Typed toJsonML', ()->
  it 'literals', (done)->
    s = Text null, undefined, 0, 1, false
    ml = s.toJsonML()
    expect ml
      .toEqual ['text', 'null', 'undefined', '0', '1', 'false']
    done()

  it 'date', (done)->
    d = new Date()
    moment = require 'moment'
    m = moment()
    s = Text d, m
    ml = s.toJsonML()
    expect ml
      .toEqual ['text', ['date', d.toISOString()] , ['date', m.toISOString()] ]
    done()

  it 'function', (done)->
    f = (x)-> x * x
    s = Text f
    ml = s.toJsonML()
    debug 'function', ml
    expect ml
      .toEqual ['text', Object.prototype.toString.call f  ]
    done()

  it 'array', (done)->
    f = [1,2,3,4]
    s = Text f
    ml = s.toJsonML()
    debug 'array', ml
    expect ml
      .toEqual ['text', Object.prototype.toString.call f  ]
    done()

  it 'Object', (done)->
    class X
    f = new X
    s = Text f
    ml = s.toJsonML()
    debug 'Object', ml
    expect ml
      .toEqual ['text', Object.prototype.toString.call f  ]
    done()

describe 'complex', ()->
  it 'nested text', (done)->
    s = Text 'type', 'a text', Text {color:'red'}, 'emphasized', 'red'
    ml = s.toJsonML()
    debug 'nested text', ml
    expect ml
      .toEqual ['text', 'type', 'a text', ['text', {color:'red'}, 'emphasized','red']]
    done()

  it 'from who', (done)->
    w = Who 'my-name'
    w = w.sub 'x'
    s = w.do 'type', 'a text', Text {color:'red'}, 'emphasized', 'red'
          .attr lv: 9
    ml = s.toJsonML()
    debug 'from who', ml
    expect ml[1].lv
      .toEqual 9
    expect ml[2]
      .toEqual ['who', 'my-name', 'x']
    expect ml[3...]
      .toEqual ['type', 'a text', ['text', {color:'red'}, 'emphasized','red']]
    done()

  it 'dump object', (done)->
    w = Who 'my-name'
    s = w.do 'dump test'
          .it obj: {name:'this is object'}
    ml = s.toJsonML()
    debug 'dump object', ml
    util = require 'util'
    inspect = (val)->
      util.inspect val, showHidden: false, depth: 10

    expect ml[ml.length - 1]
      .toEqual ['dump', {name: 'obj', type: 'object'}, inspect({name:'this is object'}) ]
    done()


  it 'dump object 2', (done)->
    w = Who 'my-name'
    s = w.do 'dump test'
          .it obj: {name:'this is object'}, who: w
    ml = s.toJsonML()
    debug 'dump object 2', ml
    util = require 'util'
    inspect = (val)->
      util.inspect val, showHidden: false, depth: 10

    expect ml[ml.length - 1]
      .toEqual ['dump', {name: 'who', type: 'object'}, inspect(w) ]
    done()

  it 'dump function', (done)->
    fn = (x)-> x * x
    w = Who 'my-name'
    s = w.do 'dump test'
          .it fn: fn
    ml = s.toJsonML()
    debug 'dump function', ml
    util = require 'util'
    inspect = (val)->
      util.inspect val, showHidden: false, depth: 10

    expect ml[ml.length - 1]
      .toEqual ['dump', {name: 'fn', type: 'function'}, fn.toString() ]
    done()


  it 'dump error', (done)->
    err = new Error
    w = Who 'my-name'
    s = w.do 'dump test'
          .it Error: err
    ml = s.toJsonML()
    debug 'dump error', ml
    util = require 'util'
    inspect = (val)->
      util.inspect val, showHidden: false, depth: 10

    expect ml[ml.length - 1]
      .toEqual ['dump', {name: 'Error', type: 'error'}, err.stack.toString() ]
    done()

  it 'dump literals', (done)-> 
    w = Who 'my-name'
    s = w.do 'dump test'
          .it a: null, b: undefined, c : true 
    ml = s.toJsonML()
    debug 'dump function', ml
    util = require 'util'
    inspect = (val)->
      util.inspect val, showHidden: false, depth: 10

    expect ml[ml.length - 3]
      .toEqual ['dump', {name: 'a'}, 'null' ]
    expect ml[ml.length - 2]
      .toEqual ['dump', {name: 'b'}, 'undefined' ]
    expect ml[ml.length - 1]
      .toEqual ['dump', {name: 'c'}, 'true' ]
    done()

describe 'toString', ()->
  it 'stringify', (done)->
    w = Who 'Jim'
    s = w.do 'write obj.'
          .it obj: {name:'this is object'}
    ml = s.toJsonML()
    str = s.toString()
    debug 'stringify', str
    expect str
      .toEqual "Jim write obj. { name: 'this is object' }" 
    done()



describe 'not purposed... but, working', ()->
  it 'who with attr', (done)->
    s = Who {color: 'red'}, 'my-name'
    ml = s.toJsonML()
    debug 'who with attr', ml
    expect ml
      .toEqual ['who', {color: 'red'}, 'my-name']
    done()

  it 'who, set attr later', (done)->
    s = Who 'my-name'
    debug 's=', s
    s.attr color: 'red'
    ml = s.toJsonML()
    debug 'who with attr', ml
    expect ml
      .toEqual ['who', {color: 'red'}, 'my-name']
    done()