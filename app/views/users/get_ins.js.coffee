$('#insContainer').html("<%= escape_javascript(render partial: 'users/event', collection: @ins, as: :event) %>");
$('#insContainer').masonry('reload');