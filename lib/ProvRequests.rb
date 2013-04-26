module ProvRequests


#pass in @user.prov_username, @user.access_token and the bundle id you wish to access.
def self.get_request(username, apikey, bundle_number)
	require 'net/http'
	require 'uri'

	uri = URI.parse("#{ENV['PROV_SERVER']}/api/v0/bundle/"+bundle_number.to_s)

	http = Net::HTTP.new(uri.host, uri.port) 
	#used for secure connections
	# # http.use_ssl = true
	# # http.verify_mode = OpenSSL::SSL::VERIFY_NONE

	request = Net::HTTP::Get.new(uri.path) 
	request.add_field("Authorization", "ApiKey "+username+":"+apikey.to_s)

	response = http.request(request)

	#if it's a redirect, then follow it.
	case response 
	when Net::HTTPRedirection then
	  uri = URI.parse(response['location'])
	  http = Net::HTTP.new(uri.host, uri.port) 
	  request = Net::HTTP::Get.new(uri.path) 
	  request.add_field("Authorization", "ApiKey "+username+":"+apikey.to_s)
	  response = http.request(request)
	end

	# puts "***************"
	# puts response.body
	# puts "***************"

	# debugger
	#return the body of the response.
	return response.body
end

#pass in @user.prov_username, @user.access_token, the JSON bundle you wish to send and the name of the file
def self.post_request(username, apikey, bundle, rec_id)
	# username = current_user.prov_username
	# apikey = current_user.access_token
	require 'net/http'
	require 'uri'

	puts "***************"

	uri = URI.parse("#{ENV['PROV_SERVER']}/api/v0/bundle/")


	net = Net::HTTP.new(uri.path, uri.port)
	request = Net::HTTP::Post.new("/api/v0/bundle/")

	request.body = '{"rec_id":"'+rec_id+'","public":"False","content":'+bundle.to_json+',"url":"https://dl.dropbox.com/u/13708408/test.json"}'
	
	request["Authorization"] = "ApiKey "+username+":"+apikey.to_s
	request["Content-Type"] = "application/json"

	response = Net::HTTP.start(uri.hostname, uri.port) do |http|
		http.request(request)
	end

	# puts "***************"
	# puts response.body
	# puts "***************"

	# debugger
	#return the body of the response.
	return response.body

end

end