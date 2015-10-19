gulp          = require 'gulp'
webpack       = require 'gulp-webpack'
watchify      = require 'watchify'
webpackConfig = require './webpack.config'
babel         = require 'gulp-babel'
launcher      = require 'browser-launcher'

srcs = './src/**/*.js'

gulp.task 'build', ->
  gulp.src(srcs)
    .pipe babel()
    .pipe gulp.dest 'dist'

gulp.task 'default', ['build', 'webpack']

gulp.task 'watch:srcs', ->
  gulp.watch srcs, ['default']

gulp.task 'watch', ['webpack', 'watch:srcs']


gulp.task 'webpack', ->
  gulp.src webpackConfig.entry
    .pipe webpack webpackConfig
    .pipe gulp.dest 'assets'

gulp.task 'open', ->
  launcher (err, launch) ->
    return console.error err if err?

    console.log '# available browsers:'
    console.dir launch.browsers

    opts =
      headless : false,
      browser : 'chrome',
      options: [
        '--args',
        '--allow-file-access-from-files',
         '--disable-web-security']
    launch 'http://localhost:3000/', opts, (err, ps) ->
      return console.error(err) if err?
'open -a Google\ Chrome --args --allow-file-access-from-files'
