chai        = require 'chai'
expect      = chai.expect

LoopbackApi = require 'loopback-supertest/lib/abstract-api'
inherits    = require 'inherits-ex/lib/inherits'
extend      = require 'util-ex/lib/_extend'
isObject    = require 'util-ex/lib/is/type/object'
config      = require '../config'


module.exports = class AbstractApi
  inherits AbstractApi, LoopbackApi

  constructor: (aName)->
    return super config.server, config.rootApi, aName
