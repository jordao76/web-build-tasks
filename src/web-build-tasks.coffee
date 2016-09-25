# coffeelint: disable=max_line_length

defineTasks = (gulp, options = {}) ->

  # parameters

  srcPath = options.srcPath ? './app'
  destPath = options.destPath ? './dist'
  scriptPath = options.scriptPath ? '/src' # within srcPath and destPath
  testPath = options.testPath ? './test'
  perfGlob = options.perfGlob ? "#{testPath}/**/perf*.coffee"
  coffeeGlobs = options.coffeeGlobs ? ['./gulpfile.coffee', "#{srcPath}#{scriptPath}/**/*.coffee", "#{testPath}/**/*.coffee"]
  copyGlob = options.copyGlob ? "#{srcPath}/**/*.!(coffee|pug|html|css)"
  rootGlobs = options.rootGlobs ? ["#{srcPath}#{scriptPath}/main*.coffee"]
  cdnEntries = options.cdnEntries ? []

  $ = (require 'gulp-load-plugins')()
  run = require 'run-sequence'

  onError = (error) ->
    $.util.log error
    process.exit 1 # note: shouldn't exit on a live-reload/watch environment

  # build

  gulp.task 'lint', ->
    gulp.src coffeeGlobs
      .pipe $.coffeelint()
      .pipe $.coffeelint.reporter()
      .pipe $.coffeelint.reporter 'failOnWarning'

  gulp.task 'test', ['lint'], ->
    gulp.src ["#{testPath}/**/*.coffee", "!#{perfGlob}"]
      .pipe $.mocha()
      .on 'error', onError

  gulp.task 'scripts', ['test'], ->
    browserify = require 'browserify'
    coffeeify = require 'coffeeify'
    source = require 'vinyl-source-stream'
    buffer = require 'vinyl-buffer'
    es = require 'event-stream'
    glob = require 'glob'
    path = require 'path'

    files = rootGlobs
      .map (pattern) -> glob.sync pattern
      .reduce (a, b) -> a.concat b # flatten
    es.merge files.map (entry) ->
      browserify entries: [entry], extensions: ['.coffee'], debug: true
        .transform coffeeify
        .bundle()
        .pipe source path.basename entry
        .pipe buffer()
        .pipe $.rename extname: '.min.js'
        .pipe $.sourcemaps.init loadMaps: true
        .pipe $.uglify()
        .pipe $.sourcemaps.write './'
        .pipe gulp.dest "#{destPath}#{scriptPath}"

  gulp.task 'pug', ->
    gulp.src "#{srcPath}/**/*.pug"
      .pipe $.pug pretty: yes
      .pipe gulp.dest '.tmp'

  gulp.task 'html', ['pug'], ->
    gulp.src ["#{srcPath}/**/*.html", '.tmp/**/*.html']
      .pipe $.useref searchPath: srcPath
      .pipe $.if '*.css', $.csso()
      .pipe $.if '*.html', $.htmlmin collapseWhitespace: true
      .pipe gulp.dest destPath

  gulp.task 'copy', ->
    gulp.src copyGlob
      .pipe gulp.dest destPath

  gulp.task 'clean',
    require 'del'
      .bind null, [destPath, '.tmp', '.publish']

  gulp.task 'build', (done) ->
    run 'clean', ['scripts', 'html', 'copy'], done

  gulp.task 'default', ['build']

  # performance test

  gulp.task 'perf', ['lint'], ->
    gulp.src perfGlob
      .pipe $.mocha()
      .on 'error', onError

  # serve

  gulp.task 'connect', ['build'], ->
    connect = require 'connect'
    serveStatic = require 'serve-static'
    app = connect()
      .use (require 'connect-livereload') port: 35729
      .use serveStatic destPath
      .use '/bower_components', serveStatic './bower_components'

    require 'http'
      .createServer app
      .listen 9000
      .on 'listening', ->
        $.util.log 'Started connect web server on http://localhost:9000'

  gulp.task 'watch', ['connect'], ->
    gulp.watch ["#{srcPath}/**/*.coffee"], ['scripts']
    gulp.watch ["#{srcPath}/**/*.html", "#{srcPath}/**/*.pug", "#{srcPath}/**/*.css"], ['html']
    gulp.watch [copyGlob], ['copy']

    $.livereload.listen()
    gulp.watch ["#{destPath}/**/*"]
      .on 'change', $.livereload.changed

  gulp.task 'serve', ['watch'], ->
    (require 'opn') 'http://localhost:9000'

  # deploy

  gulp.task 'cdnize', ['build'], ->
    gulp.src "#{destPath}/**/*.html"
      .pipe $.cdnizer cdnEntries
      .pipe gulp.dest destPath

  gulp.task 'deploy', ['cdnize'], ->
    gulp.src "#{destPath}/**/*"
      .pipe $.ghPages()

module.exports = define: defineTasks
