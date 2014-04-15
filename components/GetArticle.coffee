noflo = require 'noflo'
diffbot = require 'diffbot'

class GetArticle extends noflo.AsyncComponent
  constructor: ->
    @token = null

    @inPorts =
      in: new noflo.Port
      token: new noflo.Port
    @outPorts =
      out: new noflo.Port
      error: new noflo.Port

    @inPorts.token.on 'data', (data) =>
      @token = data

    super()

  doAsync: (url, callback) ->
    bot = new diffbot.Diffbot @token
    @outPorts.out.connect()
    bot.article
      uri: url
      html: true
      stats: true
    , (err, article) =>
      if err
        @outPorts.out.disconnect()
        return callback err
      if article.errorCode is 401
        @outPorts.out.disconnect()
        return callback article
      @outPorts.out.beginGroup url
      @outPorts.out.send article
      @outPorts.out.endGroup()
      callback()

exports.getComponent = -> new GetArticle
