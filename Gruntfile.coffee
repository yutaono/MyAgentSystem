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
      options:
        livereload: false
      files:
        ['coffee/main.coffee']
      tasks:
        ['coffee']

    connect:
      server:
        options:
          port: 8080
          hostname: 'localhost'


  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-watch'

#  grunt.registerTask 'default', ['coffee', 'connect', 'watch']
  grunt.registerTask 'default', ['coffee', 'watch']
