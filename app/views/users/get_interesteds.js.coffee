$('#interestedsContainer').html("<%= escape_javascript(render partial: 'users/event', collection: @interesteds, as: :event) %>");
$('#interestedsContainer').masonry('reload');
$('#ajaxLoader').hide();