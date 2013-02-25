$(document).ready(function() {
  $('#ideaContainer').imagesLoaded( function(){
    $('#ideaContainer').masonry({
      itemSelector : '.event',
      // column_width: 100,
      isAnimated: true,
    	animationOptions: {
      duration: 50,
      // cornerStampSelector: '.suggested_friends'
    	}
    });
  });

  $('#insContainer').imagesLoaded( function(){
    $('#insContainer').masonry({
      itemSelector : '.event',
      // column_width: 100,
      isAnimated: true,
      animationOptions: {
      duration: 50,
      // cornerStampSelector: '.suggested_friends'
      }
    });
  });

  $('#ideaContainer').imagesLoaded( function(){
    $(this).masonry('reload');
  });

  $('.idea_container').imagesLoaded( function(){
    $('.idea_container').masonry({
      itemSelector : '.event',
      // column_width: 100,
      isAnimated: true,
      animationOptions: {
      duration: 50,
      }
    });
  });
});