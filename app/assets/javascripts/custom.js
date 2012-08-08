$(document).ready(function() {

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

  $("#minmax").click(function () {
     $('#minmaxp').slideToggle();
  });

  $("#visibility").click(function () {
   $('#visibilityp').slideToggle();
  });

  $("#addmap").click(function () {
   $('#addmapp').slideToggle();
  });


 
});
