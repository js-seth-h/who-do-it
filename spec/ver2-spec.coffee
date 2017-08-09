process.env.DEBUG = "*"
{Who,LogStmt, Text } = require '../src/ver2'
assert = require 'assert'
util = require 'util'


debug = require('debug')('test')

describe 'simple ML', ()->
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
