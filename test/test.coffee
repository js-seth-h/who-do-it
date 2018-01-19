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
        name: 'a'
        ref: 1
      }, '#a'],
      ['variable', {
        name: 'b'
        ref: 2
      }, '#b'],
      'tes2', ['variable', {
        name: 'plan'
        ref: 'test'
      }, '#plan'],
      'test', ['variable', {
        name: 'x'
        ref: 'x'
      }, '#x'],
      ['variable', {
        name: 'y'
        ref: 'yy'
      }, '#y'],
      'tes2', ['variable', {
        name: 'plan'
        ref: 'test'
      }, '#plan'],
      ['id', '@who-do-it']
      ['id', '@Writer']
    ]

  it 'testify with all type', ()->
    # Undefined	"undefined"
    # Null	"object" (see below)
    # Boolean	"boolean"
    # Number	"number"
    # String	"string"
    # Symbol (new in ECMAScript 2015)	"symbol"
    # Host object (provided by the JS environment)	Implementation-dependent
    # Function object (implements [[Call]] in ECMA-262 terms)	"function"
    # Any other object	"object"

    class X
      constructor: (@val = 'val')->
    class V
      constructor: (@val = 'val')->
      toString: ()->
        "class V(#{@val})"
    date = new Date
    ml_arr = testify undefined, null, true, Boolean(true), new Boolean(true), 1,
      Number(2), new Number(3), 'str', new String('new string'), {}, {a:1},
      new X(), new V(4), date
    # console.log ml_arr
    delete ml_arr[1].when
    expect(ml_arr).eql ['testimony',
      {
      },
      'undefined'
      'null'
      'true'
      'true'
      'true'
      '1'
      '2'
      '3'
      'str'
      'new string'
      ['variable', {name: 'a', ref: 1}, '#a']
      "[object Object]"
      'class V(4)'
      date.toJSON()
    ]
  it 'testify decorable to add meta data', ()->
    plan = 'test'
    t = testify.meta lv: 9, debug_ns: 'test'
    t = t.meta about:'BT'
    ml_arr = t 'test', a: 1, b:2

    delete ml_arr[1].when
    expect(ml_arr).eql ['testimony',
      {
        lv: 9,
        about: 'BT'
        debug_ns: 'test'
      },
      'test', ['variable', {
        name: 'a'
        ref: 1
      }, '#a'],
      ['variable', {
        name: 'b'
        ref: 2
      }, '#b']
    ]

  it 'prebind', ()->

    t = testify.prebind whodoit.ID('keygen'), 'system', whodoit.Text(9, color: 'red')
    ml_arr = t 're-activate', whodoit.Meta lv: 8

    delete ml_arr[1].when
    expect(ml_arr).eql ['testimony',
      {
        lv: 8
      },
      ['id', '@keygen']
      'system'
      ['text', {color: 'red'}, '9']
      're-activate'
    ]


  it 'extend write', (done)->
    whodoit.write = (log_ml)->
      delete log_ml[1].when
      expect(log_ml).eql ['testimony',
        {
        },
        'test', ['variable', {
          name: 'a'
          ref: 1
        }, '#a'],
        ['variable', {
          name: 'b'
          ref: 2
        }, '#b']
      ]
      whodoit.write = null
      done()
    testify 'test', a: 1, b:2

  it 'dump', ()->
    plan = 'test'
    dump = testify.dump()

    dt = new Date
    fn = (a)-> alert 1
    ml_arr = dump 'test', a: 1, b:2, dt: dt, fn: fn

    #
    delete ml_arr[1].when
    # console.log 'ml_arr dump', ml_arr
    #
    expect(ml_arr).eql [ 'testimony',
      { dump: true },
      'test',
      [ 'variable', { name: 'a', ref: 1 }, '#a' ],
      [ 'variable', { name: 'b', ref: 2 }, '#b' ],
      [ 'variable',
        { name: 'dt', ref: dt },
        '#dt' ],
      [ 'variable', { name: 'fn', ref: fn }, '#fn' ],
      [ 'dump', { name: 'a', type: 'number' }, '1' ],
      [ 'dump', { name: 'b', type: 'number' }, '2' ],
      [ 'dump',
        { name: 'dt', type: 'date' },
        dt.toJSON() ],
      [ 'dump',
        { name: 'fn', type: 'function' },
        fn.toString()] ]
