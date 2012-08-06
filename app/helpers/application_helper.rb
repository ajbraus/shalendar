module ApplicationHelper

	def icon(name, size=1)
    #icon("camera-retro")
    #<i class="icon-camera-retro"></i> 
    
    html = "<i class='icon-#{name}' "
    html += "style='font-size:#{size}em' "
    html += "></i>"
    html.html_safe
  end
  
  def button_icon(text, url, name, size=1.5, *options)
    #button_icon("Camera Retro button", "#","refresh",1)
		#<a class="button refresh" href="#"><i style="font-size:1.5em" class="icon-refresh"></i> Camera Retro button</a>
    class_to_add = "button #{name}"
    options.each { |opt| class_to_add += " #{opt}" } if !options.empty?
    link_to(url, html_options = { :class => class_to_add }) {icon(name, 1.5) + " " + text}
  end
  
  def link_icon(text, url, name, size=1, *options)
    #link_icon("Camera Retro button", "#","refresh",1)
    # <a class="refresh" href="#"><i style="font-size:1.5em" class="icon-refresh"></i> Camera Retro button</a>
    
    class_to_add = "#{name}"
    options.each { |opt| class_to_add += " #{opt}" } if !options.empty?
    link_to(url, html_options = { :class => class_to_add }) {icon(name, size) + " " + text}
  end

end
