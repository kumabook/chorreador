gulp          = require 'gulp'
webpack       = require 'gulp-webpack'
watchify      = require 'watchify'
webpackConfig = require('./webpack.config');

gulp.task 'webpack', ->
  gulp.src webpackConfig.entry
    .pipe webpack webpackConfig
    .pipe gulp.dest 'assets'

