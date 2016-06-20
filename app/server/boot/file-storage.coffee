'use strict'
path = require('path')

module.exports = (app) ->
  ds = app.dataSource 'files',
    connector: require('loopback-component-storage')
    provider: 'filesystem'
    root: path.join(__dirname, '../', '../', 'storage')
  container = ds.createModel 'Storage', null, base: 'Model', description: '文件存储'
  app.model container
  return
