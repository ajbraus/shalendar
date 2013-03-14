$(document).ready(function() {
// REMOVE ALERT 
$("div.alert").delay(6000).fadeOut(400);

$('#fb_invite_img').click(function(){
  $('#ajaxLoader').toggle();
  $('#hi_invite_img').removeClass('box');
  //$('#fb_invite_img').addClass('box');
  $('#hiFriends').toggle(); 
})

// NEW INVITED EVENTS

  if ( $('#new_invited_events_count').text() == 0 ) {
    $('#new_invited_events_count').hide();
  }

  if ( $('.invited_events'))

// NEW IDEA CHECKBOX SWTICHES

$("input[type=checkbox].switch").each(function() {
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

//$('#categories').buttonset();

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

  $('#eventFancyBox').fancybox({
    autoSize : true,
    fitToView : false,
    mouseWheel : false,
    openEffect : 'elastic',
    closeEffect : 'fade'
  });

  $('#newIdeaButton').fancybox({
        closeBtn    : true,
        scrolling   : 'auto',
        autoSize    : true,
        mouseWheel : false
  });

	$('.find_friends').fancybox({
        closeBtn    : true,
        scrolling   : 'auto',
        autoSize    : true,
        mouseWheel : false
  });
  //$('.city_vendors').fancybox();
  
  $('#makeAGroup').fancybox({
        closeBtn    : true,
        scrolling   : 'auto',
        autoSize    : true,
        mouseWheel : false
  });

  $('#eventRepeat').fancybox({
        closeBtn    : true,
        scrolling   : 'auto',
        autoSize    : true,
        mouseWheel : false
  });

  // {
  //   'transitionIn'    : 'none',
  //   'transitionOut'   : 'none',
  //   'titlePosition'   : 'over',
  //   'titleFormat'       : function(title, currentArray, currentIndex, currentOpts) {
  //       return '<span id="fancybox-title-over">Image ' +  (currentIndex + 1) + ' / ' + currentArray.length + ' ' + title + '</span>';
  //   }
  $('#shareByEmail').fancybox({
        closeBtn    : true,
        scrolling   : 'auto',
        autoSize    : true
  });

// TABS

	$("#views_list").tabs();
	$("#guest_raster").tabs();
  $('#public').tabs();
  $('#tabs-nested').tabs();
  $('#events').tabs();
  //$('#invite_raster').tabs();
  $('#terms').tabs();

//Get local time zone- TRYING TO DO IT JavaScript
// Event.observe(window, 'load', function(e) {
// var now = new Date();
// var gmtoffset = now.getTimezoneOffset();
// // use ajax to set the time zone here.
//   var set_time = new Ajax.Request('/gmtoffset/?gmtoffset='+gmtoffset, {
// onSuccess: function(transport) {}
// });
// });


//FORM JS

//$('#categories').buttonset();
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
  });
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

$("#visibility").click(function () {
  if ($("#visibilityp").hasClass("open")) {
   $("#visibilityp").slideUp();
   $('#visibilityp').removeClass("open");
  }
  else {
   $('.open').slideUp();
   $('.open').removeClass("open");
   $('#visibilityp').slideDown();
   $("#visibilityp").addClass("open");
   $("#visibility").css("color", "#EB8325")
  }
});

// $("#addDateTime").click(function () {
//   if ($("#dateTime").hasClass("open")) {
//    $("#dateTime").slideUp();
//    $('#dateTime').removeClass("open");
//   }
//   else {
//    $('.open').slideUp();
//    $('.open').removeClass("open");
//    $('#dateTime').slideDown();
//    $("#dateTime").addClass("open");
//    $("#addDateTime").css("color", "#EB8325")
//   }
// });

 $("#addLink").click(function () { 
 if ($("#addLinkp").hasClass("open")) { 
   $("#addLinkp").slideUp();
   $('#addLinkp').removeClass("open");
  }
 else {
 $('.open').slideUp();
 $('.open').removeClass("open");
 $("#addLinkp").slideDown();
 $("#addLinkp").addClass("open");
 $("#addLink").css("color", "#EB8325")
  }
});

$("#addcategories").click(function () {
  if ($("#addcategoriesp").hasClass("open")) {
   $("#addcategoriesp").slideUp();
   $('#addcategoriesp').removeClass("open");
  }
  else {
   $('.open').slideUp();
   $('.open').removeClass("open");
   $('#addcategoriesp').slideDown();
   $("#addcategoriesp").addClass("open");
   $("#addcategories").css("color", "#EB8325")
  }
});

$("#addmap").click(function () {
 if ($("#addmapp").hasClass("open")) {
   $("#addmapp").slideUp();
   $('#addmapp').removeClass("open");
 }
 else {
   $('.open').slideUp();
   $('.open').removeClass("open");
   $('#addmapp').slideDown();
   $("#addmapp").addClass("open");
   $("#addmap").css("color", "#EB8325")
 }
});

$("#addimg").click(function () {
  if ($("#addimgp").hasClass("open")) {
   $("#addimgp").slideUp();
   $('#addimgp').removeClass("open");
  }
  else {
   $('.open').slideUp();
   $('.open').removeClass("open");
   $('#addimgp').slideDown();
   $("#addimgp").addClass("open");
   $("#addimg").css("color", "#EB8325")
  }
});


$("#addvid").click(function () {
  if ($("#addvidp").hasClass("open")) {
   $("#addvidp").slideUp();
   $('#addvidp').removeClass("open");
  }
  else {
   $('.open').slideUp();
   $('.open').removeClass("open");
   $('#addvidp').slideDown();
   $("#addvidp").addClass("open");
   $("#addvid").css("color", "#EB8325")
  }
});

$("#addcost").click(function () {
  if ($("#addcostp").hasClass("open")) {
   $("#addcostp").slideUp();
   $('#addcostp').removeClass("open");
  }
  else {
   $('.open').slideUp();
   $('.open').removeClass("open");
   $('#addcostp').slideDown();
   $("#addcostp").addClass("open");
   $("#addcost").css("color", "#EB8325")
  }
});

$("#addtipping").click(function () {
  if ($("#addtippingp").hasClass("open")) {
   $("#addtippingp").slideUp();
   $('#addtippingp').removeClass("open");
  }
  else {
   $('.open').slideUp();
   $('.open').removeClass("open");
   $('#addtippingp').slideDown();
   $("#addtippingp").addClass("open");
   $("#addtipping").css("color", "#EB8325")
  }
});

// VALIDATIONS
  $("#pickCity").validate();

  $('#fb_invite_friends').validate({
    rules: {
    submitHandler: function(f){
        $('form input[type=submit]').attr('disabled', 'disabled');
        form.submit();
    }
  }
  });
  $("#registration_form").validate({
    rules: {
      'user[name]': {
        required:true,
        maxlength:32
      },
    submitHandler: function(f){
        $('form input[type=submit]').attr('disabled', 'disabled');
        form.submit();
    }
  }
  });

  $("#new_comment").validate({
    rules: {
      'comment[content]': {
        required: true,
        maxlength: 250,
        minlength: 1
      },
    submitHandler: function(f){
        $('form input[type=submit]').attr('disabled', 'disabled');
        form.submit();
    }
  }
  });

//   $('input[type=file]').fileValidator({
//   onValidation: function(files){  $(this).attr('class',''); },
//   onInvalid:    function(validationType, file){ $(this).addClass("error"); },
//   maxSize:      '500kb', //optional
//   type:         'image' //optional
// });  


//$('form#bankAccount').validate();

//$('#new_suggestion_form').validate();

// NEW REGISTRATION VALIDATION

  $('#signUp').validate();

//  $('#vendorSignUp').validate();

// FOCUS ON FIRST TEXT FIELD OF PAGES

    //$("#new_idea_blerb").focus();
    //$("input[type=text]:first", document.forms[0]).focus();

// CARRIAGE RETURN IN NEW IDEA BOX SUBMITS FORM

$('#comment_content').keydown(function (e) {
  var keyCode = e.keyCode || e.which;

  if (keyCode == 13) {
    $("#new_comment_button").click();
    return false;
  }
});

$('#new_idea_blerb').keydown(function (e) {
  var keyCode = e.keyCode || e.which;
  var text = $(this).val();

  if (keyCode == 13) {
    $("#newIdeaButton").click();
    return false;
  }
});

//   $('input[type=file]').fileValidator({
//   onValidation: function(files){  $(this).attr('class',''); },
//   onInvalid:    function(validationType, file){ $(this).addClass("error"); },
//   maxSize:      '500kb', //optional
//   type:         'image' //optional
// });

// //INVITE ALL FACEBOOK FRIENDS IN EVENT#SHOW (LINK IN _TITLE.HTML.ERB)

//   $("#invite_all_friends").click(function(){
//     FB.login(function(response) {
//       if(response.authResponse) {
//         window.location = "/invite_all_fb_friends"
//         }
//     }, {scope: "publish_stream"});
//   });

// TOGGLE FRIEND BUTTON FOR NAME

  $(".friend").hover(function(){
    $(this).children("#friend_name").toggle();
    $(this).children("#friend_button").toggle();
  });

  $(".fb_friend").hover(function(){
    $(this).children("#friend_name").toggle();
    $(this).children("#friend_button").toggle();
  });

//Turn TWITTER BLUE

  // $('.icon-twitter').click(function(){
  //   $(this).css("color", "#01CBFB");
  // });

  // PREVIEW IMAGES


// END DOCUMENT.READY
});

