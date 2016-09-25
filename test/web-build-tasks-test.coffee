# coffeelint: disable=max_line_length

(require 'chai').should()

webBuildTasks = require '../src/web-build-tasks'
class GulpMock
  constructor: -> @tasks = []
  task: (name, deps, fn) -> @tasks.push name
  src: (globs, options) ->
  dest: (path, options) ->

describe 'Web build tasks smoke tests', ->

  it 'check tasks are created', ->
    gulpMock = new GulpMock
    webBuildTasks.define gulpMock
    expectedTasks = [
      'lint','test','scripts','pug','html','copy','clean','build','default'
      'perf'
      'connect','watch','serve'
      'cdnize','deploy'
    ]
    gulpMock.tasks.should.contain task for task in expectedTasks
