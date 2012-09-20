$(document).ready(function() {

	$("div.alert").delay(5000).fadeOut(1000);

// DATEPICKERDAY

// $('.datePickerDay').click(function(){
//   dw_position = $(this).position();
//   $('#datewindow').animate({ left: dw_position.left - 5 }, 500);
//   for (i=-3; i<17; i++) {
//     $('dl.day').
//   }
// });

$('#yesterday').click(function(){
  fc_current_position = $('#forecast').position();
  $('#forecast').animate({ left: fc_current_position.left + 322 }, 500);
});

$('#tomorrow').click(function(){
  fc_current_position = $('#forecast').position();
  $('#forecast').animate({ left: fc_current_position.left + 322 }, 500);
});

// SETTINGS DROPDOWN

$(".dropdown dt a").click(function() {
    $(".dropdown dd ul").toggle();
});

$(".dropdown dd ul li a").click(function() {
    var text = $(this).html();
    $(".dropdown dt a span").html(text);
    $(".dropdown dd ul").hide();
}); 

$(document).bind('click', function(e) {
    var $clicked = $(e.target);
    if (! $clicked.parents().hasClass("dropdown"))
        $(".dropdown dd ul").hide();
});

// NEW IDEA LIGHTBOX

	$(".btn-new-idea").fancybox();

	$('.find_friends').fancybox();

	$(".howto").fancybox();

// SHOW/HIDE LINK AND MAP

  $("#addLink").click(function () {
   $("#addLinkp").slideToggle();
   $(".btn-new-idea").fancybox.update();
  });

  $("#addmap").click(function () {
   $('#addmapp').slideToggle();
   $(".btn-new-idea").fancybox.update();
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
			}
		}
	});

	$("#registration_form").validate();


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


//Get local time zone- TRYING TO DO IT JavaScript
// Event.observe(window, 'load', function(e) {
// var now = new Date();
// var gmtoffset = now.getTimezoneOffset();
// // use ajax to set the time zone here.
//   var set_time = new Ajax.Request('/gmtoffset/?gmtoffset='+gmtoffset, {
// onSuccess: function(transport) {}
// });
// });


// INSTAGRAM HASHTAG FEED

$(function(){
  var
    insta_container = $(".instagram")
  , insta_next_url

  insta_container.instagram({
      hash: 'hoosin'
    , clientId : '4b92d403b8324f2294a4aa3b7e2bf407'
    , show : 6
    , onComplete : function (photos, data) {
      insta_next_url = data.pagination.next_url
    }
  })

  $('#instaButton').on('click', function(){
    var 
      button = $(this)
    , text = button.text()

    if (button.text() != 'Loading…'){
      button.text('Loading…')
      insta_container.instagram({
          next_url : insta_next_url
        , show : 6
        , onComplete : function(photos, data) {
          insta_next_url = data.pagination.next_url
          button.text(text)
        }
      })
    }		
  }) 
});

