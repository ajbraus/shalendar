$('#plansContainer').html("<%= escape_javascript(render partial: 'users/event', collection: @plans, as: :event) %>");
$('#plansContainer').masonry('reload');