$(document).ready(function() {


	$("div.alert").delay(5000).fadeOut(1000);

// user settings icon
	$("#user-settings").hover(function(){
		$(".user_settings").show();
	},
		function(){
		$(".user_settings").hide();
	});


// new idea button box

	$(".btn_new_idea").fancybox();

	$(".find_friends").fancybox();

// new idea visibility/map show/hide

  $("#visibility").click(function () {
   $('#visibilityp').slideToggle();
  });

  $("#addmap").click(function () {
   $('#addmapp').slideToggle();
  });


// google map address picker
// http://jquerybyexample.blogspot.com/2011/11/jquery-addresspicker-plugin-explained.html
	
	$(function() {
		var addresspicker = $( "#addresspicker" ).addresspicker();
		var addresspickerMap = $( "#addresspicker_map" ).addresspicker({
		  elements: {
		    map:      "#map",
		    lat:      "#lat",
		    lng:      "#lng",
		    locality: '#locality',
		    country:  '#country'
		  }
		});
		var gmarker = addresspickerMap.addresspicker( "marker");
		gmarker.setVisible(true);
		addresspickerMap.addresspicker( "updatePosition");
		
	});

});
