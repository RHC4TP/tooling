class API
  BASE_URI = "https://connect.redhat.com/api/v2/projects/"

  #Initial call to API
  def self.response(project_id)
    response =  HTTParty.get("#{BASE_URI + project_id}").parsed_response
    print_response(response)
  end

  #Builds project
  def self.build(project_id, tag)
    response = HTTParty.post(
      "#{BASE_URI + project_id}/build",
      headers: {'Content-Type'=>'application/json'},
      body: { tag: "#{tag}"}.to_json
    )

    puts "#{response["status"]} : #{response["message"]}"
    # puts response.parsed_response
  end

  #Formats whats gets printed
  def self.print_response(response)
    puts "\nProject:"
    project = <<-EOF
      \tRebuild: #{response["data"]["rebuild"]}
      \tHealth Index: #{response["data"]["repo_health_index"]}
      \tAuto Rebuild: #{response["data"]["auto_rebuild"]}
      \tAuto Publish: #{response["data"]["auto_publish"]}\n
    EOF
    puts project
    get_tags(response["data"]["tags"])
  end

  #Retrieves project tags
  def self.get_tags(tags)
    puts "Tags:"
    tags.each do |tag|
      tag = <<-TAGS
        Name:\t#{tag["name"]}
        Health Index:\t#{tag["health_index"]}
        Published:\t#{tag["published"]}
        Scan Status:\t#{tag["scan_status"]}\n
      TAGS
      puts tag
    end
  end
end
