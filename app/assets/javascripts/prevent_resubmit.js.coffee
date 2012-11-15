# $ ->
# 	$('form').submit ->
# 	  $(':submit', @).click ->
# 	    return false
# 		$('body').click ->
# 			$('form:submit').click -> 
# 				return true

# 		$(':submit', @).click (event) ->
#   		event.stopPropagation();