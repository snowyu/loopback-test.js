process.env.NODE_ENV = 'test' //TODO: BUG change to everything could not work!!

require('coffee-script/register');
require('require-yaml');

var debug       = require('debug')('superagent');
var path        = require('path');
var loopback    = require('loopback');
var boot        = require('loopback-boot');
var autoMigrate = require('loopback-component-auto-migrate/lib/auto-migrate-data');
var loadData    = require('loopback-component-auto-migrate/lib/auto-load-data');
var models      = require('./common/migrated-model-names');
var createDefaults = require('./common/create-defaults');

var app = module.exports = loopback();

app.start = function(done) {
  // Bootstrap the application, configure models, datasources and middleware.
  // Sub-apps like REST API are mounted via boot scripts.
  boot(app, __dirname, function(err) {
    if (err) throw err;
    var defaultFixtureFolder = path.resolve(__dirname, './data');
    var testFixtureFolder = path.resolve(__dirname, '../test/fixtures');
    autoMigrate(app, {fixtures:defaultFixtureFolder, models:models})
    .then(function(){
      return createDefaults();
    })
    .then(function(){
      debug('load test fixtures')
      return loadData(app, {fixtures:testFixtureFolder, models:models});
    })
    .then(function(){
      debug('autoMigrate successful')
      // start the web server
      var server = app.listen(function(err) {
        app.emit('started');
        if (done) done(err, server)
      });
    })
    .catch(function(err){done(err)});

  });
};


