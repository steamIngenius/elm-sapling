var gulp = require('gulp');
var elm  = require('gulp-elm');
var plumber = require('gulp-plumber');
var browserSync = require('browser-sync');
var nodemon = require('gulp-nodemon');


var paths = { 
  server: './server.js',
  bundle_name: 'elmsrv.js',
  client_name: 'index.html',
  dest_server: './dist',
  dest_client: './dist/public/',
  elm_server: './src/Server.elm',
  elm_client: './src/Client.elm'
};


gulp.task('elm-init', elm.init);

gulp.task('copy-server', function() {
  return gulp.src(paths.server)
    .pipe(plumber())
    .pipe(gulp.dest(paths.dest_server));
});


gulp.task('elm-server', ['elm-init'], function(){
  return gulp.src(paths.elm_server)
    .pipe(elm.bundle(paths.bundle_name))
    .pipe(gulp.dest(paths.dest_server));
});

gulp.task('elm-client', ['elm-init'], function(){
  return gulp.src(paths.elm_client)
    .pipe(elm.bundle('index.html', {'filetype':'html'}))
    .pipe(gulp.dest(paths.dest_client));
});


// Rerun the task when a file changes
gulp.task('watch-server', ['elm-server'],  function() {
  gulp.watch([paths.elm_server], ['elm-server']);
});

gulp.task('watch-client', ['elm-client'],  function() {
  gulp.watch([paths.elm_client], ['elm-client']);
});

gulp.task('browser-sync', ['nodemon'], function() {
    browserSync.init(null, {
        proxy: "http://localhost:8080",
        files: ["dist/public/**/*.*"],
        browser: "google chrome",
        port: 7000,
    });
});

gulp.task('nodemon', function (cb) {
    
    var started = false;
    
    return nodemon({
        script: 'dist/server.js', 
        ext: 'html js'
    }).on('start', function () {
        // to avoid nodemon being started multiple times
        // thanks @matthisk
        if (!started) {
            cb();
            started = true; 
        } 
    });
});

gulp.task('default', ['copy-server', 'elm-server', 'watch-server', 'watch-client', 'browser-sync']);