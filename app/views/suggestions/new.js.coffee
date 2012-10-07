$('#new_suggestion_element').html("<%= escape_javascript(render partial: 'shalendar/new_suggestion_form') %>");
$('#new_suggestion').fancybox({"type: "ajax"});