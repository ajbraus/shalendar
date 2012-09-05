$.fn.withPicId = (id) ->
	@filter ->
		$(this).data('pic-id') == id

$.fn.withUserId = (uid) ->
	@filter ->
		$(this).data('user-id') == uid

$.fn.raster_toggle = (forecastHTML) ->
	if $(@).hasClass("toggled-off")
		$(@).removeClass("toggled-off").addClass("toggled-on")
	else if $(@).hasClass("toggled-on")
		$(@).removeClass("toggled-on").addClass("toggled-off")
	
	$("#forecast").html(forecastHTML)

		#$("td").withUserId.fadeOut(400)
		#$("td").withUserId.fadeIn(400)

