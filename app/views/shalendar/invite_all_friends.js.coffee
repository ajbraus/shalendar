$('div#littleTIP').remove();
event = $('.event').withEventId(<%= @event.id %>)

rsvp_check = event.find('div.rsvp_check');
rsvp_check.children('a').remove();
rsvp_check.html("<div class='going btn_icon' title='You''re in'><i class='icon-ok-circle'></i></div>");
		 
event.find('.icon-group').first().removeClass('purple').addClass('gold');
event.children('.rsvp_check').children('a').click (e) ->
	e.stopPropigation()
