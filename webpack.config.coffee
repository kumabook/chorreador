webpack = require("gulp-webpack").webpack
path    = require "path"

module.exports =
  watch: true
  entry: "./src/client.coffee"
  output:
    filename: "application.js"

  resolve:
    root: [path.join(__dirname, "bower_components")]
    moduleDirectories: ["bower_components"]
    extensions: ["", ".js", ".coffee", "cjsx"]
  module:
    loaders: [
      { test: /\.js?$/,         loader: 'babel-loader', exclude: 'node_modules' }
      { test: /client.coffee$/, loader: 'expose?chorreador'},
      { test: /.cjsx$/,         loaders: ['coffee-loader', 'cjsx-loader']},
      { test: /.coffee$/,       loader: 'coffee-loader'}
    ]

  plugins: [
    new webpack.ResolverPlugin(
      new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin "bower.json", ["main"]
    )
  ]
