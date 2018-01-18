
debug = require('debug') 'who-do-it'
###
  단순 디버그 대용으로 쓸수 이어야한다.
  또한 파일 스트림, 네트워크등으로 의미성있게 전송이 가능해야한다.
  받는 놈은 단순하게하고, 보낼때 잘 보낼것.

  함수에 args...로 넣은 단위로 statement가 형성되고 자동 처리될것.


###


writer = (ns)->
  return (args...)->
    debug args...




module.exports = (ns)->
  return writer ns
