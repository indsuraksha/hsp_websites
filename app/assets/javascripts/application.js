// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require lightbox
//= require jquery-ui.min
//= require jquery.lightbox-0.5.min
//= require jquery.datetimepicker
//= require jquery.bxSlider.min
//= require jquery.pin
//= require slick
//= require jwplayer
//= require soundmanager2-nodebug-jsmin
//= require inline_player
//= require global_functions
//= require product_tabs
//= require buy_it_now
//= require maps
//= require slideshow
//= require twitter
//= require swfobject
//= require tools
//= require math.min
//= require homepage
//= require configurator

document.createElement("article");
document.createElement("footer");
document.createElement("header");
document.createElement("hgroup");
document.createElement("nav");
document.createElement("section");

soundManager.url = '/swfs/';
soundManager.flashVersion = 9; // optional: shiny features (default = 8)
soundManager.useFlashBlock = false; // optionally, enable when you're ready to dive in
soundManager.debugMode = false;
soundManager.preferFlash = false;

$(function(){
  $('.featured-slider').slick({
    slidesToShow: 3,
    slidesToScroll: 1,
    autoplay: true,
    autoplaySpeed: 4000
  });
});
