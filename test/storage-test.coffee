chai    = require 'chai'
expect  = chai.expect
chai.use require 'chai-subset'

path    = require 'path'
fs      = require 'fs'
Promise = require 'bluebird'
faker   = require 'faker'
inherits= require 'inherits-ex/lib/inherits'
API     = require './abstract-api'


class Storage
  inherits Storage, API

  constructor: ->
    return super 'Storages'

  createFolder: (aName, stCode = 200)->
    @createItem {name: aName}, stCode
  getFolder: (aName, stCode = 200)->
    @getItem aName
  isExists: (aName, aIsExists = true)->
    # can not detect the file exists(test/1.txt) unless 'test\1.txt'
    super id:aName, aIsExists
  delFolder: (aName, stCode = 200)->
    @delItem id: aName, stCode
  listFolder: (stCode = 200)->
    @get()
    .expect stCode
    .then (res)->res.body
  uploadFile: (aFolder, aFilePath, stCode = 200)->
    @post aFolder+'/upload'
    .attach 'file', aFilePath #, path.baseName aFilePath
    .expect stCode
    .expect 'Content-Type', /application\/json/
  delFile: (aFolder, aFileName, stCode = 200)->
    @delete aFolder+ '/files/' + aFileName
    .expect stCode
  downloadFile: (aFolder, aFileName, stCode = 200)->
    @get aFolder+ '/download/' + aFileName
    .expect stCode
    .then (res)->
      res.text
  isFileExists: (aFolder, aFileName)->
    @get aFolder+ '/files/' + aFileName
    .then (res)->
      res.statusCode == 200


admin = username: 'admin', password: 'admiN123#'

describe "Storage", ->
  storageApi = null
  testFolder = 'test1'
  testFile   = 'cfg.js'

  before 'init api', ->
    storageApi = new Storage

  before 'login', ->
    storageApi.login admin


  describe "Container", ->
    describe ".create", ->
      it 'should not create a folder before login', ->
        storageApi.logout()
        .then ->
          storageApi.createFolder testFolder, 401
        .then ->
          storageApi.login admin
      it 'should create a folder container after login', ->
        storageApi.login username: 'admin', password: 'admiN123#'
        .then ->
          storageApi.createFolder testFolder
        .then ->
          storageApi.isExists testFolder
        .then ->
          storageApi.delFolder testFolder
      it 'should not list folders before login', ->
        storageApi.logout()
        .then ->
          storageApi.listFolder 401
        .then ->
          storageApi.login admin
      it 'should list folders after login', ->
        vFolders = (faker.system.fileName() for i in [1..5])
        Promise.map vFolders, (folder)->
          storageApi.createFolder folder
        .then ()->
          storageApi.listFolder()
        .then (folders)->
          folders = (folder.name for folder in folders)
          expect(folders).to.containSubset vFolders
        .then ->
          Promise.map vFolders, (folder)->
            storageApi.delFolder folder


  describe "File", ->
    before 'create folder', ->
      storageApi.createFolder testFolder
    after 'delete folder', ->
      storageApi.delFolder testFolder
    it 'should not upload a file before login', ->
      storageApi.logout()
      .then ->
        storageApi.uploadFile testFolder, path.join(__dirname, testFile), 401
      .then ->
        storageApi.login admin
    it 'should upload a file after login', ->
      vFilePath = path.join(__dirname, testFile)
      vText = fs.readFileSync vFilePath, 'utf8'
      storageApi.uploadFile testFolder, vFilePath
      .then ->
        storageApi.downloadFile testFolder, testFile
      .then (result)->
        expect(result).to.equal vText
    it 'should delete a file after login', ->
      vFilePath = path.join(__dirname, testFile)
      storageApi.isFileExists testFolder, testFile
      .then (aIsExists)->
        storageApi.uploadFile testFolder, vFilePath if !aIsExists
      .then ->
        storageApi.delFile testFolder, testFile
      .then ->
        storageApi.isFileExists testFolder, testFile
      .then (aIsExists)->
        expect(aIsExists).to.be.false

