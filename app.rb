require 'se/api'
require 'chatx'
require 'yaml'
require 'csv'
require 'httparty'

settings = YAML.load_file('settings.yml')

@cb = ChatBot.new(settings['chatx_username'], settings['chatx_password'])
cli = SE::API::Client.new(settings['api_key'], site: 'stackoverflow')
@cb.login(cookie_file: 'cookie.yml')
ROOMS = settings['rooms'].keys
def say(msg)
  ROOMS.each do |room|
    @cb.say msg, room, server: 'stackoverflow'
  end
end

resp = HTTParty.get('https://raw.githubusercontent.com/SOBotics/Tagdor/master/SplitTags.csv')
csv = resp.body

tags = []

CSV.parse(csv, headers: true, return_headers: true) do |row|
  tags << row['tagname'][1..-2].split(', ') if row['synonym'].nil?
end

tags = tags.flatten.uniq

existant_tags = tags.each_slice(50).map do |batch|
  sleep 1
  cli.tags(*batch)
end.flatten.reject(&:nil?).reject { |t| t.count == 0 }

settings['rooms'].each do |room_id, max_q_in_tag|
  tags = existant_tags.reject { |t| t.count > max_q_in_tag }
  if tags.empty?
    @cb.say "Check completed! No tags have risen from the dead (unless the tags have > #{max_q_in_tag} questions)", room_id, server: 'stackoverflow'
  else
    uri = "https://stackoverflow.com/questions/tagged/"
    @cb.say "[ [Revenant](https://git.io/fhInH) ] Uh oh, I still see some tags! Specifically these tags:", room_id, server: 'stackoverflow'
    puts tags.map(&:name).join(';')
    tags.sort_by(&:count).reverse.map { |t| "[tag:#{t.name}] _(×#{t.count})_" }.each_slice(4) do |to_speak|
      puts "LAST TAG: #{to_speak.last}"
      @cb.say to_speak.join(' '), room_id, server: 'stackoverflow'
      sleep 2
    end
  end
end
