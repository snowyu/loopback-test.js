var RequestCli  = require('loopback-supertest');
var chai        = require('chai');

chai.use(require('chai-subset'));
RequestCli.USERS = 'Accounts';
