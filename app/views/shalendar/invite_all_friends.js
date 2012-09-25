var event = $('.event').withEventId(<%= @event.id %>)

event.children('.rsvp_check').children().children().html("<i class='icon icon-ok-circle'></i>").removeClass("btn_invite_all_friends").addClass("going");
event.children('a').children('.guest_count').children('i').removeClass('purple').addClass('gold');
event.children('.rsvp_check').children('a').click(function(e){
	e.stopPropigation();
});