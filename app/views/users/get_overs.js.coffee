<% if @overs.empty? %>
#$('.no_invites').children('#status').html("<h2>You have no .ins. To get more, search for friends in your city or invite your friends to hoos.in.</h2><br>")
<% else %>
$('#oversContainer').html("<%= escape_javascript(render partial: 'users/event', collection: @overs, as: :event) %>");
$('#oversContainer').imagesLoaded ->
	$('#oversContainer').masonry('reload');
<% end %>
$('#ajaxLoader').hide();