$ ->
	alert 'Toggle Interests File Loaded'
	$('#interestsDropdown').click ->
		alert 'Interest Dropdown Clicked'
		$('#interests').toggle();