$(document).ready(function() {
  $('.idea_container').imagesLoaded( function(){
    $('.idea_container').masonry({
      itemSelector : '.event',
      // column_width: 100,
      isFitWidth: true,
      isAnimated: true,
    	animationOptions: {
      duration: 50,
      // cornerStampSelector: '.suggested_friends'
    	}
    });
  });
});