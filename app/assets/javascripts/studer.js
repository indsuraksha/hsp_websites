// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui.min
//= require jquery.lightbox-0.5.min
//= require jquery.datetimepicker
//= require jquery.pin.min
//= require global_functions
//= require maps
//= require twitter
//= require homepage
//= require foundation
//= require add2home
//= require jwplayer
//= require swfobject
//= require tools
//= require studer_application
//= require_self

document.createElement("article");
document.createElement("footer");
document.createElement("header");
document.createElement("hgroup");
document.createElement("nav");
document.createElement("section");

$(function(){
  $(document).foundation({
    "magellan-expedition": {
      fixed_top: 44,
      destination_threshold: 40,
    }
  });
});