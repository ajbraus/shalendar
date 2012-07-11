$(document).ready(function() {
  // $("#eventDate").datepicker();
  // $("#eventTime").timepicker();
  $("#eventStartsAt").datetimepicker({ ampm: true });
  $("#eventEndsAt").datetimepicker({ ampm: true });
  $('#ui-datepicker-div').removeClass('ui-helper-hidden-accessible')


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