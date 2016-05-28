chakram = require('chakram')
expect  = chakram.expect
config  = require '../config'
rootUrl = config.URL
apiUrl  = config.apiUrl

describe "Status", ->
  it "API服务状态应该正常", ->
    chakram.get(rootUrl).then (response)->
      expect(response).to.have.status(200)
      expect(response.body).to.have.started
      expect(response.body).to.have.uptime
