$(document).ready(function() {

	$("div.alert").delay(5000).fadeOut(1000);

// user settings icon
	$(".dashboard").hover(function(){
		$(".user_settings").show();
		$(".logout").show();
	},
		function(){
		$(".user_settings").hide();
		$(".logout").hide();
	});

// NEW IDEA LIGHTBOX

	$(".btn-new-idea").fancybox();

	$(".find_friends").fancybox();

// SHOW/HIDE LINK AND MAP

  $("#addLink").click(function () {
   $("#addLinkp").slideToggle();
  });

  $("#addmap").click(function () {
   $('#addmapp').slideToggle();
  });

// VISIBILITY RADIO BUTTONSET

	$( "#radio" ).buttonset();

// NEW IDEA FORM VALIDATION
	$("#new_event_form").validate({
		rules: {
			"event[min]": {
				number: true
			},
			"event[max]": {
				number: true
			},
			"event[duration]": {
				required: true,
				number: true
			},
			"event[link]": {
				url: true
			}
		}
	});


// TABS

	$( "#views_list" ).tabs();

// $( '#public_tabs' ).tabs();

	$( "#guest_raster" ).tabs();


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
