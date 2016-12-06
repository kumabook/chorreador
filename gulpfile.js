const gulp          = require('gulp');
const webpack       = require('webpack-stream');
const webpackConfig = require('./webpack.config');
const babel         = require('gulp-babel');
const launcher      = require('browser-launcher');

const srcs = './src/**/*.js';

gulp.task('build', () =>
          gulp.src(srcs)
              .pipe(babel())
          .pipe(gulp.dest('dist')));

gulp.task('default', ['build', 'webpack']);

gulp.task('watch:server', () =>
          gulp.watch(srcs, ['default']));

gulp.task('watch', ['build', 'webpack', 'watch:server']);

gulp.task('webpack', () =>
          gulp.src(webpackConfig.entry)
              .pipe(webpack(webpackConfig))
              .pipe(gulp.dest('assets')));

gulp.task('open', () => {
  return launcher((err, launch) => {
    if (err) {
      console.error(err);
      return;
    }
    console.log('# available browsers:');
    console.dir(launch.browsers);
    const opts = {
      headless: false,
      browser: 'chrome',
      options: [
        '--args',
        '--allow-file-access-from-files',
        '--disable-web-security']
    };
    launch('http://localhost:3000/', opts, (err, ps) => {
      if (err) {
        console.error(err);
        return;
      }
    });
  });
});
