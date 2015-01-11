sources =
  bower:  'bower.json'
  static: 'public/**/*'

libs =
  js: [
    'jquery/dist/jquery.min.js'
    'semantic-ui/dist/semantic.min.js'
  ]
  css:    ['semantic-ui/dist/**/*.min.css']
  static: ['semantic-ui/dist/**/*']


bower       = require 'bower'
del         = require 'del'
gulp        = require 'gulp'
coffee      = require 'gulp-coffee'
concat      = require 'gulp-concat'
nodemon     = require 'gulp-nodemon'
uglify      = require 'gulp-uglify'


gulp.task 'default', ['clean'], ->
  gulp.start 'compile:lib', 'compile:static'

gulp.task 'clean', (cb) ->
  del 'public/assets', cb

gulp.task 'watch', ->
  gulp.watch sources.bower,  ['compile:lib']
  gulp.watch sources.static, ['compile:static']


gulp.task 'compile:lib', ->
  bower.commands.install().on 'end', ->
    gulp.src libs.js.map (e) -> "bower_components/#{e}"
      .pipe concat 'lib.js'
      .pipe gulp.dest 'public/assets'
    gulp.src libs.css.map (e) -> "bower_components/#{e}"
      .pipe concat 'lib.css'
      .pipe gulp.dest 'public/assets'
    gulp.src libs.static.map (e) -> "bower_components/#{e}"
      .pipe gulp.dest 'public/assets'

gulp.task 'compile:static', ->
  gulp.src sources.static
    .pipe gulp.dest 'public/assets'


gulp.task 'server', ->
  gulp.start 'watch', 'watch:apimock'
  nodemon
    watch: ['public/assets']
    env:
      port: 8888
      webapp: "#{__dirname}/public/assets"

