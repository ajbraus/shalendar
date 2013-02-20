$ ->
	$("#fancyboxTrigger").click (e)->
		e.preventDefault();
		$.fancybox({
			height: 'auto',
			width: 'auto',
			topRatio: 0.3,
			hideOnOverlayClick: false,
			transitionIn: 'elastic',
			transitionOut: 'elastic',
			speedIn: 300,
			speedOut: 400,
			content: "<iframe width='600' height='330' frameborder='0' scrolling='no' src='http://api.dmcloud.net/player/embed/5122cd8706361d6a3600001b/5122dae506361d6ae300003f?auth=1676658910-0-lu3ru55p-39002d66b87bdc96f4e08a5084468def'></iframe>
			<div>
			<a href='http://www.facebook.com/plugins/like.php?href=http%3A%2F%2Fwww.facebook.com%2Fhoosinapp&send=false&layout=standard&width=450&show_faces=true&font&colorscheme=light&action=like&height=80&appId=327936950625049'></a>
				<ul class='social_buttons'>
  			<li>
  			<a href='mailto:?
								subject=a%20video%20.introduction%20to%20hoos.in&
								body=hi,%0a%0aI%20just%20watched this video .introduction to a neat new web service at www.hoos.in. Check it out.%0a%0a' class='email_share'>
					<span class='orange'><i class='icon-envelope-alt'></i></span><br>mail
				</a>
				</li>
				<li>
				<a href='https://twitter.com/share?url=http://www.hoos.in&text=A video .introduction to hoos.in ' 
  					class='email_share' 
  					target='_blank'>
  				<span class='twitter_blue'><i class='icon-twitter'></i></span><br>tweet
				</a>
				</li>
				<li>
				<a target='_blank' href='https://www.facebook.com/dialog/feed?
			  				app_id=327936950625049&
			  				link=http://www.hoos.in&
			  				picture=http://www.hoos.in/assets/video.png&
			  				name=A%20video%20.introduction%20to%20hoos.in&
			  				caption=more%20social,%20less%20network&
			  				description=hoos.in%20is%20a%20shared%20activites%20calendar%20that%20makes%20it%20easy%20to%20enjoy%20more%20creativity%20and%20adventure%20with%20colleagues,%20family,%20and%20friends.&
			  				redirect_uri=http://www.hoos.in' class='email_share'>
    			<span class='fb_blue'><i class='icon-facebook-sign'></i></span><br>share
  			</a>
  			</li>
			</ul>
  		</div>
  "

			});


# $ ->
# 	$("#fancyboxTrigger").click (e)->
# 		e.preventDefault();
# 		$.fancybox({
# 			href: "http://api.dmcloud.net/player/embed/5122cd8706361d6a3600001b/5122dae506361d6ae300003f?auth=1676656933-0-6f5zar56-8fae056da3cd3b3c950e26f0dd8a35d6",
# 			type: "iframe",
# 			height: 350,
# 			width: 630,
# 			content: '<p>your html here</p>'
# 			});