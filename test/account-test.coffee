chakram = require 'chakram'
debugReq= require 'chakram/lib/debug'
expect  = chakram.expect
faker   = require 'faker'
extend  = require 'util-ex/lib/_extend'
config  = require '../config'
rootUrl = config.URL
apiUrl  = rootUrl + config.apiPath + 'Accounts/'

#debugReq.startDebug()

genUser = ->
  username: faker.name.findName()
  password: faker.internet.password()
  mobile: faker.phone.phoneNumber()
  email: faker.internet.email()

register = (user, stCode = 200)->
  user = genUser() unless user

  chakram.post(apiUrl, user).then (response)->
    expect(response).to.have.status(stCode)
    expect(response).to.have.header("content-type", /application\/json/);
    user.id = response.body.id if stCode is 200

del = (user, stCode = 200)->
  url = apiUrl + user.id
  url = url + '/?access_token=' + user.accessToken if user.accessToken
  chakram.delete(url).then (response)->
    expect(response).to.have.status(stCode)

get = (user, stCode = 200)->
  url = apiUrl + user.id
  url = url + '/?access_token=' + user.accessToken if user.accessToken
  chakram.get(url).then (response)->
    expect(response).to.have.status(stCode)
    if stCode is 200
      usr = extend {}, user
      delete usr.password
      delete usr.accessToken
      expect(response).to.comprise.of.json usr

login = (user, stCode = 200)->
  chakram.post(apiUrl+'login', user).then (response)->
    expect(response).to.have.status(stCode)
    if stCode is 200
      user.accessToken = response.body.id
      expect(response.body.id).to.have.length.of.at.least 64

describe "Account", ->
  user =
    username: faker.name.findName()
    password: faker.internet.password()
    mobile: faker.phone.phoneNumber()
    email: faker.internet.email()

  before '创建新账号', -> register user
  after '删除新账号', -> del user if user.id

  it "应该可以登录新账号", -> login user

  it "应该可以注册新账号", ->
    if not user.accessToken
      login(user).then -> get user
    else
      get user

