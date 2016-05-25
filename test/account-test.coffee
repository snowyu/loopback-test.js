chakram = require('chakram')
faker   = require('faker')
extend  = require('util-ex/lib/_extend')
debugChakram = require('chakram/lib/debug')
expect  = chakram.expect
config  = require '../config'
rootUrl = config.URL
apiUrl  = config.apiUrl + 'Accounts/'

debugChakram.startDebug()
describe.only "Account", ->
  user =
    username: faker.name.findName()
    password: '12345'
    mobile: '12912345'
    email: faker.internet.email()
  before '创建新账号', ->
    chakram.post(apiUrl, user).then (response)->
      expect(response).to.have.status(200)
      expect(response).to.have.header("content-type", /application\/json/);
      # expect(response.body).to.have.username user.username
      # expect(response.body).to.have.mobile user.mobile
      # expect(response.body).to.have.email user.email
      # expect(response.body).to.have.created
      # expect(response.body).to.have.lastUpdated
      # expect(response.body).to.have.id
      user.id = response.body.id

  after '删除新账号', ->
    if user.id
      chakram.delete(apiUrl+user.id).then (response)->
        expect(response).to.have.status(200)

  it "应该可以注册新账号", ->
    chakram.get(apiUrl+user.id).then (response)->
      expect(response).to.have.status(200)
      u = extend {}, user
      delete u.password
      expect(response).to.comprise.of.json u


