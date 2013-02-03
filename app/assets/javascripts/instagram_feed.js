
// INSTAGRAM HASHTAG FEED

$(function(){
  var
    insta_container = $(".instagram")
  , insta_next_url

  insta_container.instagram({
      hash: 'hoosin'
    , clientId : '4b92d403b8324f2294a4aa3b7e2bf407'
    , show : 40
    , onComplete : function (photos, data) {
      insta_next_url = data.pagination.next_url
    }
  })

  $('#instaButton').on('click', function(){
    var 
      button = $(this)
    , text = button.text()

    if (button.text() != 'Loading…'){
      button.text('Loading…')
      insta_container.instagram({
          next_url : insta_next_url
        , show : 6
        , onComplete : function(photos, data) {
          insta_next_url = data.pagination.next_url
          button.text(text)
        }
      })
    }		
  }) 
});
