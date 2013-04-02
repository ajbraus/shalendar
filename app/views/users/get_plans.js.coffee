$('#plansContainer .idea_container').html("<%= will_paginate @plans %><%= escape_javascript(render partial: 'users/event', collection: @plans, as: :event) %>");
$('#plansContainer .idea_container').masonry('reload');
$('#ajaxLoader').hide();