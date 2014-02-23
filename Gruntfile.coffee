module.exports = (grunt)->
  grunt.initConfig
    pkg: '<json:package.json>'
    coffee:
      app:
        files:
          'js/main.js': 'coffee/main.coffee'
        options:
          bare: true
          sourceMap: true
    watch:
      files:
        ['coffee/main.coffee']
      tasks:
        ['coffee']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'


