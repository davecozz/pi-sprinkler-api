require 'sinatra'
require 'json'
require './sprinkler.rb'
require './validate.rb'

set :bind, '0.0.0.0'

get '/sprinkler/all' do
  Sprinkler.get_status_all.to_json
end

get '/sprinkler/:sprinkler' do
  spk = params['sprinkler']
  return_error(Validate.sprinkler(spk))
  Sprinkler.get_status(spk).to_s
end

post '/sprinkler/:sprinkler' do
  spk = params['sprinkler']
  bdy = request.body.read
  return_error(Validate.input_onoff(spk, bdy))
  bdy_h = JSON.parse(bdy)
  case bdy_h['action']
  when 'on'
    unless Sprinkler.get_status(spk)
      puts "turning on #{spk}"
      Sprinkler.on(spk)
    else
      msg = "it appears sprinkler #{spk} is already on!"
      puts msg
      return_error( {'ERROR' => msg} )
    end
  when 'off'
    if Sprinkler.get_status(spk)
      puts "turning off #{spk}"
      Sprinkler.off(spk)
    else
      msg = "it appears sprinkler #{spk} is already off!"
      puts msg
      return_error( {'ERROR' => msg} )
    end
  else
    fail "can't determine what to do! got '#{bdy_h.to_s}'"
  end
  puts 'done'
  # return json
  return '{"done":true}'
end

post '/sprinkler/timer/:sprinkler' do
  spk = params['sprinkler']
  bdy = request.body.read
  return_error(Validate.input_timer(spk, bdy))
  bdy_h = JSON.parse(bdy)
  unless Sprinkler.get_status(spk)
    puts "turning on #{spk} for #{bdy_h['time']} min"
    Thread.new do
      Sprinkler.timer(spk, bdy_h['time'])
    end
  else
    msg = "it appears sprinkler #{spk} is already on!"
    puts msg
    return_error( {'ERROR' => msg} )
  end
  puts 'done'
  # return json
  return '{"done":true}'
end

def return_error(input)
  if input.has_key?('ERROR')
    halt(400, {'Content-Type' => 'application/json'}, {'ERROR': input['ERROR']}.to_json)
  end
end
