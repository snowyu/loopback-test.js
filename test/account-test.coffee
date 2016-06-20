# set DEBUG=superagent //for windows
# export DEBUG=superagent //for linux
chai    = require 'chai'
expect  = chai.expect
# chai.use require 'chai-subset'

Promise = require 'bluebird'
faker   = require 'faker'
inherits= require 'inherits-ex/lib/inherits'
Request = require 'loopback-supertest'
API     = require './abstract-api'
extend  = require 'util-ex/lib/_extend'

#debugReq.startDebug()

genUser = ->
  username: faker.name.findName()
  password: faker.internet.password()
  mobile: faker.phone.phoneNumber()
  email: faker.internet.email()

class Account
  inherits Account, API

  constructor: ()->
    return super 'Accounts'
  register: (user, stCode = 200)->
    user = genUser() unless user
    @createItem user, stCode
    .then (response)->
      user.id = response.body.id if stCode is 200
      response
  delUser: (user, stCode = 200)->
    @delItem user, stCode

  getUser: (user, stCode = 200)->
    @getItem user, stCode

  editUser: (user, stCode = 200)->
    @editItem user, stCode

  loginUser: (user, stCode = 200)->
    self = @
    @post 'login'
    .send user
    .expect stCode
    .then (response)->
      if stCode is 200
        self.accessToken = response.body.id
        expect(response.body.id).to.have.length.of.at.least 64
      response


describe "Account", ->
  account = new Account()
  user =
    username: faker.name.findName()
    password: faker.internet.password()
    mobile: faker.phone.phoneNumber()
    email: faker.internet.email()

  before '创建新账号', ->
    account.register user
  after '删除新账号', ->
    if user.id
      if account.accessToken?
        result = account.delUser user
      else
        result = account.login user
        .then -> account.delUser user
    result

  it "应该可以登录新账号", -> account.loginUser user
  it "应该可以注册新账号", ->
    if account.accessToken?
      result = account.getUser user
    else
      result = account.login user
      .then -> account.getUser user
    result

  it "应该可以注销新账号", ->
    oldToken = account.accessToken
    Promise.resolve oldToken
    .then (hasToken)->
      if hasToken
        account.logout()
      else
        account.login user
        .then ->
          account.logout()
    .then ->
      expect(account.accessToken).to.be.null
      account.accessToken = oldToken
      account.getUser user, 401
      .then ->
        account.accessToken = null
