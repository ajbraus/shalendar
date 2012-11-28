$(function(){
  $('.idea_container').masonry({
    itemSelector : '.event',
    isAnimated: true
    columnWidth: 240,
  	animationOptions: {
    duration: 400
  	}
  });
});