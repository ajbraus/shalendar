$(document).ready(function() {


// REMOVE ALERT 

	$("div.alert").delay(2500).fadeOut(400);


// LOADING AJAX


$('#loading').ajaxStart(function(){
  $(this).show();
}).ajaxStop(function(){
  $(this).hide();
});


// $('#someFormID')
// .ajaxStart(function() {
//     $('#loading').show();
// })
// .ajaxStop(function() {
//     $('#loading').hide();
// });

  // var toggleLoading = function() { $("#loading").toggle() };

  // $("#new_relationship").on("ajax:before", toggleLoading);
  //   // .bind("ajax:success", function(data, status, xhr) {
  //   //   $("#response").html(status);
  //   // });

  // $("#tipPin").ajaxStart(toggleLoading);

  //   // .bind("ajax:success", function(data, status, xhr) {
  //   //   $("#response").html(status);
  //   // });

  // $('#new_rsvp').bind("ajax:beforeSend", toggleLoading);


// NEW INVITED EVENTS

  if ( $('#new_invited_events_count').text() == 0 ) {
    $('#new_invited_events_count').hide();
  }

  if ( $('.invited_events'))

// DATEPICKERDAY

$('.datePickerDay').click(function(){
  dw_position = $(this).position();
  $('#datewindow').animate({ left: dw_position.left - 5}, 1000);
  date = $(this).attr('data-date');
  forecast_original_position = $('#forecast').position();
  forecast_day_position = $('dl').withDate(date).position();
  //frame_position = $('.forecast').position();
  $('#forecast').animate({ right: forecast_day_position.left + 10 }, 1000);
});

// NEW IDEA CHECKBOX SWTICHES

$("input[type=checkbox].switch").each(function() {
  $(this).before(
      '<span class="switch">' +
      '<span class="mask" /><span class="background" />' +
      '</span>'
    );
  $(this).hide();
    // Set inital state
  if (!$(this)[0].checked) {
      $(this).prev().find(".background").css({left: "-56px"});
    }
  }); // End each()

// Toggle switch when clicked
  $("span.switch").click(function() {
    // If on, slide switch off
    if ($(this).next()[0].checked) {
      $(this).find(".background").animate({left: "-56px"}, 200);
    // Otherwise, slide switch on
    } else {
      $(this).find(".background").animate({left: "0px"}, 200);
    }
    // Toggle state of checkbox
    $(this).next()[0].checked = !$(this).next()[0].checked;
  });

// YESTERDAY AND TOMORROW

$('#yesterday').click(function(){
  fc_position = $('#forecast').position();
  $('#forecast').animate({ left: fc_position.left +=340 }, 1000);
  $('#datewindow').animate({ left: '-=38.3' }, 500);
});

$('#tomorrow').click(function(){
  fc_position = $('#forecast').position();
  $('#forecast').animate({ right: fc_position.right -=340 }, 1000);
  $('#datewindow').animate({ left: '+=38.3' }, 500);
});

$('#yt').buttonset();
$('#categories').buttonset();

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

	// $(".btn-new-idea").click(
 //    var blerb = $('#new_idea_blerb').val();
 //    $(this).fancybox();
 //    $('#new_idea_title').text(blerb);
 //  );

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

// NEW IDEA FORM VALIDATION
	$("#new_event_form").validate({
		rules: {
      "event[title]": {
        maxlength: 140
      },
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

  $( "#suggestions" ).tabs();


// google map address picker
// http://jquerybyexample.blogspot.com/2011/11/jquery-addresspicker-plugin-explained.html
	
// $(function() {
//     var addresspickerMap = $( "#addresspicker_map" ).addresspicker({
//       elements: {
//         map:      "#autocompleteMap",
//         lat:      "#lat",
//         lng:      "#lng",
//         locality: '#locality',
//         country:  '#country'
//       }
//     });
//     var gmarker = addresspickerMap.addresspicker( "marker");
//     gmarker.setVisible(true);
//     addresspickerMap.addresspicker( "updatePosition");
    
//   });

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
    , show : 5
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

