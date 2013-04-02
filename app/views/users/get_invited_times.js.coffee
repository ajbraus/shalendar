$('#invitedTimesContainer .idea_container').html("<%= will_paginate @invited_times %><%= escape_javascript(render partial: 'users/event', collection: @invited_times, as: :event) %>");
$('#invitedTimesContainer .idea_container').masonry('reload');
$('#ajaxLoader').hide();