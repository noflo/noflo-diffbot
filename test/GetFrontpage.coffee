readenv = require "../components/GetFrontpage"
socket = require('noflo').internalSocket

setupComponent = ->
  c = readenv.getComponent()
  ins = socket.createSocket()
  token = socket.createSocket()
  out = socket.createSocket()
  err = socket.createSocket()
  c.inPorts.in.attach ins
  c.inPorts.token.attach token
  c.outPorts.out.attach out
  c.outPorts.error.attach err
  [c, ins, token, out, err]

exports['test reading a URL without Token'] = (test) ->
  test.expect 3
  [c, ins, token, out, err] = setupComponent()
  err.once 'data', (data) ->
    test.ok data
    test.equal data.errorCode, 401
    test.ok data.error
    test.done()

  ins.send 'http://bergie.iki.fi/'

exports['test reading a URL'] = (test) ->
  unless process.env.DIFFBOT_TOKEN
    test.fail null, null, 'No DIFFBOT_TOKEN env variable set'
    test.done()
    return

  [c, ins, token, out, err] = setupComponent()

  validTypes = ['article', 'link', 'image']
  fetched = 0
  out.on 'data', (data) ->
    fetched++
    test.ok data, "We need to get an article object"
    test.ok data.description, "Article needs to contain text"
    test.ok data.link, "Article needs to contain a link"
    test.ok data.title, "Article needs to contain a title"
    test.ok data.type, "Article must have type"
    test.ok (validTypes.indexOf(data.type) isnt -1), "Article type must be 'article'"

  out.on 'disconnect', ->
    test.ok fetched >= 6
    test.done()

  token.send process.env.DIFFBOT_TOKEN
  ins.send 'http://bergie.iki.fi/'
  ins.disconnect()
