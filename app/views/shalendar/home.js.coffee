$("#forecast").html("<%= escape_javascript(render partial: 'shalendar/forecast' ) %>")
position = $('table').withDate("<%= params[:date] %>").position()
current_position = $('#datewindow').position()
$('#datewindow').animate({ left: position.left - 4}, 800)