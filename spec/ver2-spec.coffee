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
    ml = s.toJsonML() 
    debug 'from who', ml
    expect ml[2]
      .toEqual ['who', 'my-name', 'x']
    expect ml[3...]
      .toEqual ['type', 'a text', ['text', {color:'red'}, 'emphasized','red']]
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