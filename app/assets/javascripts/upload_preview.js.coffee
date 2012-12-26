#http://strd6.com/tag/coffeescript/
# $.fn.uploadPreview = (callback) ->
#     stopFn = (event) ->
#       event.stopPropagation()
#       event.preventDefault()
 
#     element = this
#     $this = $(this)
#     $this.bind 'change', (e) ->
#       stopFn(e)

#       fileList = e.target.files
#       if fileList[0].type.match(/image.*/)
        # file = fileList[0]
        # img = document.createElement("img");
        # img.file = file;
        # console.log window.URL.createObjectURL(file)

        # $('#eventImage').html(img);
        # $('#eventPromoImg').html(img);
        # reader = new FileReader()
        # reader.onload = (evt) ->
        #   callback.call(element, file, evt)
        # reader.readAsDataURL(file)
 
 # change (e) ->
 #    fileList = e.target.files;
 #    if fileList[0].type.match(/image.*/)
 #      file = fileList[0]
 #      img = document.createElement("img");
 #      img.file = file;
 #      $('#eventImage').html(img);
 #      $('#eventPromoImg').html(img);
 #      reader = new FileReader()
 #      reader.onload = (evt) ->
 #        callback.call(element, file, evt)
 #      reader.readAsDataURL(file)