$ ->
	$('.navbar').click ->
		$('.navbar.active i.icon-caret-right').remove();
		$('.navbar.active').removeClass('active');
		$(@).addClass('active');
		$(@).append("<i class='icon-caret-right'></i>")