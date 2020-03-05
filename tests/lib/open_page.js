'use strict';

var Promise   = require("bluebird");

module.exports = Promise.promisify( function(args, callback){

  var url             = args.url,
      driver          = args.driver,
      result_callback = callback;

  // Open front page
  driver
    .get( url )
    .then(function(){
      // "export" current driver
      result_callback(null, { driver });
    })
    .catch(function(e){
      result_callback(e);
    });

});

