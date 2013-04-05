<% if @ins.empty? %>
#$('.no_invites').children('#status').html("<h2>You have no .ins. To get more, search for .intros in your city or invite your friends to hoos.in.</h2><br>")
<% else %>
$('#insContainer').html("<%= escape_javascript(render partial: 'users/event', collection: @ins, as: :event) %>");
$('#insContainer').imagesLoaded ->
	$('#insContainer').masonry('reload')
<% end %>
$('#ajaxLoader').hide();
$('#explanation').hide();
#$('#ins_count').html(" " + <%= @ins.count %>)