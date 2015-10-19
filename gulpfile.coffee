gulp          = require 'gulp'
webpack       = require 'gulp-webpack'
watchify      = require 'watchify'
webpackConfig = require './webpack.config'
babel         = require 'gulp-babel'

srcs = './src/**/*.js'

gulp.task 'build', ->
  gulp.src(srcs)
    .pipe babel()
    .pipe gulp.dest 'dist'

gulp.task 'default', ['build', 'webpack']

gulp.task 'watch', ->
  gulp.watch srcs, ['default']


gulp.task 'webpack', ->
  gulp.src webpackConfig.entry
    .pipe webpack webpackConfig
    .pipe gulp.dest 'assets'

