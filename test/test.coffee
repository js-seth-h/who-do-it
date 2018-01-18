debug = require '../lib'
chai = require 'chai'
expect = chai.expect
debug = require('debug')('test')

describe 'chain is a function', ()->
  it 'when create hyper-chain, then return a function', ()->

    dbg = debug('section')
    dbg debug.T 'TRACEABLE_NAME', 'make', msg: msg
    #
    # toString @TRACEABLE_NAME make %msg%
    # msg =>  {...}
    # in console. it colored...
