class UserSearch
	constructor: ->
		@lastEvent = undefined
		@timer = undefined
		@oldValue = undefined
		$('#btn_user_search').on('click', @performSearch)
		$('#user_search_field').on('keyup', @setEventTimer)
		$('body').on('click', @checkHideResults)
		$('#search_form').on 'submit', ->
			return false

	checkHideResults: (e) =>
		window.target = e
		unless $(e.target).closest('#search_results').length || $(e.target).attr('id') == 'user_search_field' || $(e.target).attr('id') == 'btn_user_search'
			@hideResults()

	hideResults: ->
		$('#search_results').remove()
		$('#user_search_field').val('')
		$('.search_spinner').css({'background-position': 'right 21900915389012px'})

	setEventTimer: =>
		if $('#user_search_field').val().length == 0
			@hideResults()

		if $('#user_search_field').val().length > 1 and $('#user_search_field').val() != @oldValue
			clearTimeout(@timer)
			@timer = setTimeout(@performSearch, 500)
			$('.search_spinner').css({'background-position': 'right'})
		@oldValue = $('#user_search_field').val()

	performSearch: (e) =>
		e?.preventDefault()
		$.ajax
			url: window.location
			success: -> 
				$('.search_spinner').css({'background-position': 'right 2000000px'})
			data:
				'search': $('#user_search_field').val()



$ ->
	new UserSearch() if $('#user_search_field').length