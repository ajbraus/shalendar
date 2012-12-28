$('div#littleTIP').remove();
event = $('.event').withEventId(<%= @event.id %>)

event.find('.rsvp_check').fadeOut();
rsvp_check.children('a').remove();
rsvp_check.fadeOut('slow');
