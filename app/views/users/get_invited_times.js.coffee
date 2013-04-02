$('#invitedTimesContainer').html("<%= escape_javascript(render partial: 'users/event', collection: @invited_times, as: :event) %>");
$('#invitedTimesContainer').masonry('reload');