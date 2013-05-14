module ProvRequests


#pass in @user.prov_username, @user.prov_access_token and the bundle id you wish to access.
def self.get_request(username, apikey, bundle_number)
	require 'net/https'
	require 'net/http'
	require 'uri'

	uri = URI.parse("#{ENV['PROV_SERVER']}/api/v0/bundle/"+bundle_number.to_s)
	
	if uri.scheme == "https"
		http = Net::HTTP.new(uri.host, 443) 
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	else
		http = Net::HTTP.new(uri.host, uri.port)
	end


	request = Net::HTTP::Get.new(uri.path) 
	request["Authorization"] = "ApiKey "+username+":"+apikey.to_s

	response = http.request(request)

	#if it's a redirect, then follow it.
	case response 
	when Net::HTTPRedirection then
	  uri = URI.parse(response['location'])
	  if uri.scheme == "https"
	  	http = Net::HTTP.new(uri.host, 443) 
	  	http.use_ssl = true
	  	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	  else
	  	http = Net::HTTP.new(uri.host, uri.port)
	  end
	  request = Net::HTTP::Get.new(uri.path) 
	  request["Authorization"] = "ApiKey "+username+":"+apikey.to_s
	  response = http.request(request)
	end

	return response.body
end

#pass in @user.prov_username, @user.prov_access_token, the JSON bundle you wish to send and the name of the file.
#default permissions is private.
def self.post_request(username, apikey, bundle, rec_id)
	require 'net/https'
	require 'net/http'
	require 'uri'

	uri = URI.parse("#{ENV['PROV_SERVER']}/api/v0/bundle/")

	if uri.scheme == "https"
		http = Net::HTTP.new(uri.host, 443) 
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	else
		http = Net::HTTP.new(uri.host, uri.port)
	end

	request = Net::HTTP::Post.new("/api/v0/bundle/")

	request.body = '{"rec_id":"'+rec_id+'","private":"True","content":'+bundle.to_json+'}'
	
	request["Authorization"] = "ApiKey "+username+":"+apikey.to_s
	request["Content-Type"] = "application/json"

	response = http.request(request)

	case response 
	when Net::HTTPRedirection then
 	  request = Net::HTTP::Post.new("/api/v0/bundle/")
	  request.body = '{"rec_id":"'+rec_id+'","private":"True","content":'+bundle.to_json+'}'
	  request["Authorization"] = "ApiKey "+username+":"+apikey.to_s
	  request["Content-Type"] = "application/json"
	  response = http.request(request)
	end

	return response.body

end

end