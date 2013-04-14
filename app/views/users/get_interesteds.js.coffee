<% if @interesteds.empty? %>
#$('.no_invites').children('#status').html("<h2>You have no .ins. To get more, search for friends in your city or invite your friends to hoos.in.</h2><br>")
<% else %>
$('#interestedsContainer').html("<%= escape_javascript(render partial: 'users/event', collection: @interesteds, as: :event) %>");
$('#interestedsContainer').imagesLoaded ->
	$('#interestedsContainer').masonry('reload')
<% end %>
$('#ajaxLoader').hide();
$('#explanation').hide();
#$('#interesteds_count').html(" " + <%= @interesteds.count %>)