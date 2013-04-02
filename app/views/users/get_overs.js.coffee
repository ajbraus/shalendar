$('#oversContainer .idea_container').html("<%= escape_javascript(render partial: 'users/event', collection: @overs, as: :event) %>");
$('#oversContainer .idea_container').masonry('reload');
$('#ajaxLoader').hide();