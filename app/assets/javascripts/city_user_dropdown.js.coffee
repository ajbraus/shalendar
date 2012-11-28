$ ->
	$('#resource_city_id').change ->
		$('.small_ajax_loader').toggle();
		$(@).closest('form').trigger('submit');