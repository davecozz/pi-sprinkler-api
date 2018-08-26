require 'json'
require './sprinkler.rb'

module Validate
  @active_sprinklers = Sprinkler.active_sprinklers
  @actions = ['on', 'off']
  @max_time = 180

  def self.sprinkler(sprinkler)
    spk_valid = _sprinkler(sprinkler)
    if spk_valid.has_key?('ERROR')
      puts spk_valid.to_s
      return spk_valid
    else
      return {}
    end
  end

  def self.input_onoff(sprinkler, body)
    spk_valid = _sprinkler(sprinkler)
    bdy_valid = _onoff_body(body)
    if spk_valid.has_key?('ERROR')
      puts spk_valid.to_s
      return spk_valid
    elsif bdy_valid.has_key?('ERROR')
      puts bdy_valid.to_s
      return bdy_valid
    else
      return {}
    end
  end

  def self.input_timer(sprinkler, body)
    spk_valid = _sprinkler(sprinkler)
    bdy_valid = _timer_body(body)
    if spk_valid.has_key?('ERROR')
      puts spk_valid.to_s
      return spk_valid
    elsif bdy_valid.has_key?('ERROR')
      puts bdy_valid.to_s
      return bdy_valid
    else
      return {}
    end
  end

  ## private methods
  def self._sprinkler(sprinkler)
    unless @active_sprinklers.include?(sprinkler)
      return {"ERROR" => "sprinkler '#{sprinkler}' not in list: #{@active_sprinklers.to_s}"}
    end
    return {}
  end

  def self._onoff_body(body)
    puts "got '#{body}'"
    begin
      body_h = JSON.parse(body)
    rescue JSON::ParserError => e
      return {"ERROR" => "input '#{body}' does not appear to be valid JSON, #{e}"}
    end
    unless body_h.has_key?('action') || @actions.include?(body_h['action'])
      return {"ERROR" => "action '#{body_h['action']}' not in list: #{@actions.to_s}"}
    end
    return {}
  end

  def self._timer_body(body)
    puts "got '#{body}'"
    begin
      body_h = JSON.parse(body)
    rescue JSON::ParserError => e
      return {"ERROR" => "input '#{body}' does not appear to be valid JSON, #{e}"}
    end
    unless body_h.has_key?('time') || body_h['time'].to_i <= @max_time
      return {"ERROR" => "time '#{body_h['time']}' not <= #{@max_time.to_s}"}
    end
    return {}
  end

  class << self
    private :_sprinkler
    private :_onoff_body
    private :_timer_body
  end
end
