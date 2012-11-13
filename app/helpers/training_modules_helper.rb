module TrainingModulesHelper

	def show_module(training_module)
		if training_module.training_module_file_name.to_s.match(/swf$/i)
	        width = (training_module.width.blank?) ? "100%" : training_module.width
	        height = (training_module.height.blank?) ? "100%" : training_module.height
	        new_content = swf_tag(training_module.training_module.url, size: "#{width}x#{height}")
	    elsif training_module.training_module_file_name.to_s.match(/flv|mp4|mpeg|mp3|m4v$/i)
	        width = (training_module.width.blank?) ? "640" : training_module.width
	        height = (training_module.height.blank?) ? "480" : training_module.height
        	media_url = request.protocol + request.host_with_port + training_module.training_module.url('original', false)
        	new_content = render_partial("shared/player", media_url: media_url, height: height, width: width)
        elsif training_module.training_module_file_name.to_s.match(/mov$/i)
        	new_content = link_to("Download Quicktime Movie", training_module.training_module.url('original', false))
    	end
    	raw(new_content)
    end

end