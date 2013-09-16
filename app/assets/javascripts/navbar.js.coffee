$ ->
	$('.sidebar-nav').click ->
		$('.sidebar-nav.active i.icon-caret-right').remove();
		$(@).append("<i class='icon-caret-right'></i>")