loopback= require 'loopback'
chai    = require 'chai'
expect  = chai.expect
chai.use require 'chai-subset'

path    = require 'path'
fs      = require 'fs'
Promise = require 'bluebird'
faker   = require 'faker'
inherits= require 'inherits-ex/lib/inherits'
Api     = require './abstract-api'


admin = username: 'admin', password: 'admiN123#'

class AccountApi
  inherits AccountApi, Api
  constructor: -> return super 'Accounts'

describe "Internal fatal", ->
  API = null
  Service = null
  result = {}
  user =
    username: faker.name.findName()
    password: faker.internet.password()
    email: faker.internet.email()

  before 'init api', ->
    API = new AccountApi

  # before 'login', ->
  #   API.login admin

  before 'add a item', ->
    API.createItem user
    .then (result)->
      API.login user

  after 'delete a item', ->
    API.delItem user

  it.only 'should not crash the server', ->
    # API.editItem id:serviceName, obj: '', 400
    API.put data: id:user.id, obj: '', 400
