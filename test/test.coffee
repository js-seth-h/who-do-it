whodoit = require '../lib'
chai = require 'chai'
expect = chai.expect
debug = require('debug')('test')

{testify} = whodoit

describe 'testify', ()->
  it 'testify create ML', ()->

    plan = 'test'
    ml_arr = testify whodoit.Meta(lv: 9, about:'BT', debug_ns: 'test'), 'test', a: 1, b:2, 'tes2', plan: plan,
      'test', x: 'x',
      y: 'yy', 'tes2', plan: plan, ['id', '@who-do-it'], whodoit.Who 'Writer'

    delete ml_arr[1].when
    expect(ml_arr).eql ['testimony',
      {
        lv: 9,
        about: 'BT'
        debug_ns: 'test'
      },
      'test', ['variable', {
        ref: 1
      }, '#a'],
      ['variable', {
        ref: 2
      }, '#b'],
      'tes2', ['variable', {
        ref: 'test'
      }, '#plan'],
      'test', ['variable', {
        ref: 'x'
      }, '#x'],
      ['variable', {
        ref: 'yy'
      }, '#y'],
      'tes2', ['variable', {
        ref: 'test'
      }, '#plan'],
      ['id', '@who-do-it']
      ['id', '@Writer']
    ]

  it 'testify decorable to add meta data', ()->
    plan = 'test'
    t = testify.decor lv: 9, debug_ns: 'test'
    t = t.decor about:'BT'
    ml_arr = t 'test', a: 1, b:2

    delete ml_arr[1].when
    expect(ml_arr).eql ['testimony',
      {
        lv: 9,
        about: 'BT'
        debug_ns: 'test'
      },
      'test', ['variable', {
        ref: 1
      }, '#a'],
      ['variable', {
        ref: 2
      }, '#b']
    ]


  it 'extend write', (done)->
    whodoit.write = (log_ml)->
      delete log_ml[1].when
      expect(log_ml).eql ['testimony',
        { 
        },
        'test', ['variable', {
          ref: 1
        }, '#a'],
        ['variable', {
          ref: 2
        }, '#b']
      ]
      done()
    testify 'test', a: 1, b:2
