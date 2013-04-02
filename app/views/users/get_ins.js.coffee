$('#insContainer .idea_container').html("<%= escape_javascript(will_paginate @ins) %><%= escape_javascript(render partial: 'users/event', collection: @ins, as: :event) %>");
$('#insContainer .idea_container').masonry('reload');
$('#ajaxLoader').hide();