$('#outsContainer').html("<%= escape_javascript(render partial: 'users/event', collection: @outs, as: :event) %>");
$('#outsContainer').masonry('reload');