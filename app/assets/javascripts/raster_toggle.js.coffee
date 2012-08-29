$.fn.withPicId = (id) ->
	@filter ->
		$(this).data('pic-id') == id

$.fn.raster_toggle = (forecastHTML) ->
	if $(@).hasClass("toggle-off")
		$(@).removeClass("toggled-off").addClass("toggled-on")
	else
		$(@).removeClass("toggled-on").addClass("toggled-off")
	
	#$(@).find('#forecast').html(forecastHTML)