$.fn.withDate = (date) ->
	@filter ->
		$(this).data('date') == date