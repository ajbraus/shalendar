event = $('.event').withEventId(<%= @event.id %>)

event.find("#eventMin").remove();
event.find("#guestCount").removeClass("red");
event.find(".force_tip").replaceWith("<div class='rsvp_check'><%= escape_javascript( render :partial => 'users/rsvp_check', :locals => { :event => @event } ) %></div>")
