$ ->
	$('#ins').click ->
		if $(@).hasClass("unselected") 
			$(@).removeClass("unselected")
			$(@).addClass("selected")
			$('#invites').removeClass("selected")
			$('#invites').addClass('unselected')
		$('#ideaContainer').hide();
		$('#insContainer').fadeIn();
		$('#insContainer').masonry('reload')

	$('#invites').click ->
		if $(@).hasClass("unselected") 
			$(@).removeClass("unselected")
			$(@).addClass("selected")
			$('#ins').removeClass("selected")
			$('#ins').addClass('unselected')
		$('#insContainer').hide();
		$('#ideaContainer').fadeIn();
		$('#ideaContainer').masonry('reload')