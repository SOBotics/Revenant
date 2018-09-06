require 'se/api'
require 'chatx'
require 'yaml'
require 'csv'
require 'httparty'

settings = YAML.load_file('settings.yml')

@cb = ChatBot.new(settings['chatx_username'], settings['chatx_password'])
cli = SE::API::Client.new(settings['api_key'], site: 'stackoverflow')
@cb.login(cookie_file: 'cookie.yml')

def say(msg)
  puts "I SPEAK: #{msg}"
  @cb.say msg, 167908, server: 'stackoverflow'
end

say "Starting up!"

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

if existant_tags.empty?
  say "Check completed! No tags have risen from the dead!"
else
  uri = "https://stackoverflow.com/questions/tagged/"
  say "Uh oh, I still see some tags! Specifically these tags:"
  puts existant_tags.map(&:name).join(';')
  existant_tags.sort_by(&:count).reverse.map { |t| "[tag:#{t.name}] _(×#{t.count})_" }.each_slice(4) do |to_speak|
    puts "LAST TAG: #{to_speak.last}"
    say to_speak.join(' ')
    sleep 2
  end
end
