<% if @invited_ideas.empty? %>
$('#explanation').show();
#$('.no_invites').prepend("<h2>You have no new invited ideas. To get more, search for .intros in your city or invite your friends to hoos.in.</h2><br>")
<% else %>
$('#explanation').hide();
$('#invitedIdeasContainer').html("<%= escape_javascript(render partial: 'users/event', collection: @invited_ideas, as: :event) %>");
$('#invitedIdeasContainer').imagesLoaded ->
	$('#invitedIdeasContainer').masonry('reload');
<% end %>
$('#ajaxLoader').hide();
$('#explanation').hide();