$(document).ready(function() {

	$("div.alert").delay(5000).fadeOut(1000);

// user settings icon
	$("#user-settings").hover(function(){
		$(".user_settings").show();
		$(".logout").show();
	},
		function(){
		$(".user_settings").hide();
		$(".logout").hide();
	});

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

	$( "#radio" ).buttonset();

// fade in hover of new idea
// 	$(".btn_new_idea").hover(function(){
// 		$(".btn_new_idea").style.-webkit-box-shadow = "0px 0px 50px 15px rgba(235, 131, 37, 1)";
// 		$(".btn_new_idea").style.-moz-box-shadow: = "0px 0px 50px 15px rgba(235, 131, 37, 1)";
// 		$(".btn_new_idea").style.box-shadow: = "0px 0px 50px 15px rgba(235, 131, 37, 1)";
// 	},
// 	function(){
// 		$(".btn_new_idea").css("");
// 	}
// });


// new idea button box

	$(".btn_new_idea").fancybox();

	$(".find_friends").fancybox();

// new idea visibility/map show/hide

  $("#addLink").click(function () {
   $("#addLinkp").slideToggle();
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
