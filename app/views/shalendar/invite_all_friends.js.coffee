$('div#littleTIP').remove();
event = $('.event').withEventId(<%= @event.id %>)

event.find('div.btn_invite_all_friends')
		 .html("<i class='icon icon-ok-circle'></i>")
		 .removeClass("btn_invite_all_friends")
		 .addClass("going");
		 
event.find('.icon-group').first().removeClass('purple').addClass('gold');
event.children('.rsvp_check').children('a').click (e) ->
	e.stopPropigation()
