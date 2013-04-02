$('#invitedIdeasContainer').html("<%= escape_javascript(render partial: 'users/event', collection: @invited_ideas, as: :event) %>");
$('#invitedIdeasContainer').masonry('reload');