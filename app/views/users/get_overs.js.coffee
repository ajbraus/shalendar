$('#oversContainer').html("<%= escape_javascript(render partial: 'users/event', collection: @overs, as: :event) %>");
$('#oversContainer').masonry('reload');
$('#ajaxLoader').hide();