expect  = require('chai').expect
request = require 'supertest-as-promised'
config  = require '../config'
rootUrl = config.server

describe "Status", ->
  it "API服务状态应该正常", ->
    request(config.server).get('')
    .expect 200
    .then (response)->
      expect(response.body).to.have.started
      expect(response.body).to.have.uptime
