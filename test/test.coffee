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
        name: 'a'
        ref: 1
      }, '#a'],
      ['variable', {
        name: 'b'
        ref: 2
      }, '#b']
    ]

  it 'prepend', ()->

    t = testify.prepend whodoit.ID('keygen'), 'system', whodoit.Text(9, color: 'red')
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
    dump = testify.decor dump: true

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
