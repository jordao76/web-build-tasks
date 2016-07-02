# web-build-tasks [![npm](https://img.shields.io/npm/v/web-build-tasks.svg)](https://www.npmjs.com/package/web-build-tasks)

[![Build Status](https://travis-ci.org/jordao76/web-build-tasks.svg)](https://travis-ci.org/jordao76/web-build-tasks)
[![Dependency Status](https://david-dm.org/jordao76/web-build-tasks.svg)](https://david-dm.org/jordao76/web-build-tasks)
[![devDependency Status](https://david-dm.org/jordao76/web-build-tasks/dev-status.svg)](https://david-dm.org/jordao76/web-build-tasks#info=devDependencies)
[![License](http://img.shields.io/:license-mit-blue.svg)](https://github.com/jordao76/web-build-tasks/blob/master/LICENSE.txt)

Gulp build tasks for single-page web applications, using coffeescript, browserify, pug and mocha for testing.

This package was created to ease the build process of some simple static web apps I created and is not meant as a general-purpose package.

## Usage

To define the `web-build-tasks` tasks in your gulpfile:

``` javascript
var gulp = require('gulp');
var webBuildTasks = require('web-build-tasks');
var options = { /*web-build-tasks options*/ };

webBuildTasks.define(gulp, options);
```

## API

```
webBuildTasks.define(gulp, options?)
```

Defines all `web-build-tasks` gulp tasks using `gulp` and the given `options` object. `options` is optional. Available options are (with defaults, note the interpolation syntax from coffeescript):

* `srcPath = './app'`: path for the source files of the application
* `destPath = './dist'`: path where the target application files will be written to for applicable gulp tasks
* `scriptPath = '/src'`: sub-path for both `srcPath` and `destPath` where the coffeescript files are located
* `testPath = './test'`: path for the test coffeescript files
* `perfGlob = "#{testPath}/**/perf*.coffee"`: glob for the performance test coffeescript files
* `coffeeGlobs = ['./gulpfile.coffee', "#{srcPath}#{scriptPath}/**/*.coffee", "#{testPath}/**/*.coffee"]`: array of globs for coffeescript files
* `rootGlobs = ["#{srcPath}#{scriptPath}/main*.coffee"]`: globs for the root coffeescript files of the application
* `cdnEntries = []`: array of options for the `cdnize` task (see below)

## Tasks

The gulp tasks that are defined can be divided in 4 categories: __main build__, __performance tests__, __serve__ and __deploy__. Only the __main build__ tasks are run by default when not specifying a task for `gulp`.

Some tasks create separate temporary folders for generated and transformed files, and you might want to add them to your `.gitignore`:

```
# dist is the default for options.destPath, adapt it accordingly
dist
.tmp
.publish
```

### Main build tasks

These are the __main build__ gulp tasks provided:

* `lint`: runs `gulp-coffeelint` on the `options.coffeeGlobs` files.
* `test`, depends on `lint`: runs `gulp-mocha` on all coffeescript files found on `options.testPath`, _excluding_ all performance test files from `options.perfGlob`.
* `scripts`, depends on `test`: runs `browserify` on all files from `options.rootGlobs`, uglifying with source maps.
* `pug`: runs `gulp-pug` on all pug files found on `options.srcPath`. Writes the results to a temporary folder `.tmp`.
* `html`, depends on `pug`: optimizes CSS files and minifies HTML files.
* `clean`: deletes all generated folders
* `build`, tuns tasks `clean`, `scripts` and `html`, this is also the __default__ gulp task.

The ones more applicable to be run manually are `lint`, `test`, `clean` and the default (same as `build`):

```
$ gulp lint
$ gulp test
$ gulp clean
$ gulp
```

### Performance test task

Since performance tests can be a lot slower than functional tests, they're not executed as part of the main build `test` task. The `perf` task, which depends on the `lint` task, can be used to run `gulp-mocha` on all `options.perfGlob` files.

```
$ gulp perf
```

### Serve tasks

The serve tasks are for live development, serving the application with live-reload.

* `connect`, depends on `build`: starts a connect server for the application in port 9000. Also serves `/bower_components` accordingly.
* `watch`, depends on `connect`: sets up live-reload for all source files.
* `serve`: runs the `watch` task and launches the application in a browser.

```
$ gulp serve
```

### Deploy tasks

The application can be deployed to a [GitHub Pages](https://pages.github.com/) repository:

* `cdnize`, depends on `build`: uses `gulp-cdnizer` with the `options.cdnEntries` on all target HTML files.
* `deploy`, depends on `cdnize`: uses `gulp-gh-pages` to deploy the application to a GitHub Pages repository.

```
$ gulp deploy
```

## License

Licensed under the [MIT license](https://github.com/jordao76/web-build-tasks/blob/master/LICENSE.txt).
