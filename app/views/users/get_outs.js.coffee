$('#outsContainer .idea_container').html("<%= escape_javascript(render partial: 'users/event', collection: @outs, as: :event) %>");
$('#outsContainer .idea_container').masonry('reload');
$('#ajaxLoader').hide();