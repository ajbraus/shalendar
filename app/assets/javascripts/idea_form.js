$(document).ready(function() {
// NEW IDEA FORM VALIDATION
  $("#new_event").validate({
    rules: {
      "event[title]": {
        maxlength: 60
      },
      "event[min]": {
        number: true,
        min: 0
      },
      "event[max]": {
        number: true,
        max: 1000000
      },
      // "event[duration]": {
      //   required: true,
      //   number: true
      // },
      "event[link]": {
        maxlength:255
      },
      "event[promo_url]": {
        maxlength:255
      },
      "event[promo_vid]": {
        maxlength:255
      },
      "event[price]": {
        number: true,
        max: 10000
      },
      submitHandler: function(f){
        $('form input[type=submit]').attr('disabled', 'disabled');
        form.submit();
    }
  }
  });

  $.validator.addMethod(
        "regex",
        function(value, element, regexp) {
            var re = new RegExp(regexp);
            return this.optional(element) || re.test(value);
        }
  );

  if ($("#event_promo_vid").length){
  $("#event_promo_vid").rules("add", { 
    regex: "(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?(.{10,})",
    messages: { regex: "Please Enter a Valid YouTube URL" }
    });

  $("#event_link").rules("add", {
    regex: "^(((ftp|https?):\/\/)?(www\.)?)?[a-z0-9\-\.]{3,}\.[a-z]{3}(.{0,})?",
    messages: { regex: "Please Enter a Valid URL" }
    });

  $("#event_promo_url").rules("add", {
    regex: "\.(png|jpg|jpeg|gif)$",
    messages: { regex: "Please Enter a Valid URL" }
  });
}

// DATETIME PICKER

  $('#datetime').datetimepicker({
      minDate: 0,
      dateFormat: "D m/d/y",
      timeFormat: "h:mmt",
      ampm: true,
      stepMinute: 15,
      addSliderAccess: true,
      sliderAccessArgs: { touchonly: true },
      hour:12,
      minute:00
  });

// $('#datetime').datetimepicker({
//     minDate: 0,
//     dateFormat: "DD, d M",
//     timeFormat: "h:mm tt",
//     ampm: true,
//     stepMinute: 15,
//     addSliderAccess: true,
//     sliderAccessArgs: { touchonly: true },
//     hour:12,
//     minute:00
// });

});