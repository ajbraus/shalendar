$('#invitedIdeasContainer .idea_container').html("<%= escape_javascript(render partial: 'users/event', collection: @invited_ideas, as: :event) %>");
$('#invitedIdeasContainer .idea_container').masonry('reload');
$('#ajaxLoader').hide();