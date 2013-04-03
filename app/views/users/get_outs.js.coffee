<% if @outs.empty? %>
#$('.no_invites').children('#status').html("<h2>You have no .ins. To get more, search for .intros in your city or invite your friends to hoos.in.</h2><br>")
<% else %>
$('#outsContainer').html("<%= escape_javascript(render partial: 'users/event', collection: @outs, as: :event) %>");
$('#outsContainer').masonry('reload');
<% end %>
$('#ajaxLoader').hide();