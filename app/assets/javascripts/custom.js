$(document).ready(function() {

// raster name hover (should instead extract the alt and split it on " " 
// and then take the [0] element of the array)
  $(".raster_hover").on({
      mouseenter: function (evt) {
          $(this).find('div:first').stop(true, true).show();
      },
      mouseleave: function () {
          $(this).find('div:first').stop(true, false).hide();
      }
  });


// new idea button box

	$(".btn_new_idea").fancybox();

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
