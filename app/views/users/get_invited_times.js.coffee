<% if @invited_times.empty? %>
#$('.no_invites').children('#status').html("<h2>You have no .ins. To get more, search for .intros in your city or invite your friends to hoos.in.</h2><br>")
<% else %>
$('#invitedTimesContainer').html("<%= escape_javascript(render partial: 'users/event', collection: @invited_times, as: :event) %>");
$('#invitedTimesContainer').imagesLoaded ->
	$('#invitedTimesContainer').masonry('reload');
<% end %>
$('#ajaxLoader').hide();
$('#invitesSpinner').hide();
$('#explanation').hide();
#$('#invited_times_count').html(" " + <%= @invited_times.count %>)