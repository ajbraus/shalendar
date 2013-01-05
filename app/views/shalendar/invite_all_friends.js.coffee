$('div#littleTIP').remove();
<% if @event.is_parent? %>
event = $('.event').withEventId(<%= @event.id %>)
<% else %>
event = $('.time').withEventId(<%= @event.id %>)
<% end %>
event.find('.fadeInGreen').first().removeClass('fadeInGreen').addClass('green')
# rsvp_check.children('a').remove();
# rsvp_check.fadeOut('slow');
