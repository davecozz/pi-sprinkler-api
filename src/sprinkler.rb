require 'json'

module Sprinkler
  @active_sprinklers = ['s0', 's1', 's2', 's3']
  @gpio_bin = '/usr/local/bin/gpio'
  @coil_time = 0.3 #length of time in sec to energize the valve coils
  @pin_offset = 4 #physical offset between on and off gpio pins
  @status_file = '/dev/shm/sprinkler_status.json'

  def self.active_sprinklers()
    @active_sprinklers
  end

  def self.get_status(sprinkler)
    _init_file()
    s_status = JSON.parse(File.read(@status_file))
    if s_status.length > 0
      if s_status.has_key?(sprinkler)
        return s_status[sprinkler]
      else
        return false
      end
    else
      return false
    end
  end

  def self.get_status_all()
    _init_file()
    status_all = {}
    @active_sprinklers.each do |s|
      status_all[s] = get_status(s)
    end
    return status_all
  end

  def self.on(sprinkler)
    spk_num = sprinkler[1..-1] #trim first character
    _reset(spk_num)
    system("#{@gpio_bin} write #{spk_num} 0")
    sleep( @coil_time )
    system("#{@gpio_bin} write #{spk_num} 1")
    _set_status(sprinkler, true)
  end

  def self.off(sprinkler)
    spk_num = sprinkler[1..-1] #trim first character
    spk_off = spk_num.to_i + @pin_offset
    _reset(spk_off)
    system("#{@gpio_bin} write #{spk_off} 0")
    sleep(@coil_time)
    system("#{@gpio_bin} write #{spk_off} 1")
    _set_status(sprinkler, false)
  end

  def self.timer(sprinkler, min)
    sec = min.to_i * 60
    on(sprinkler)
    _set_status(sprinkler, true)
    sleep(sec)
    off(sprinkler)
    _set_status(sprinkler, false)
  end

  ## private methods
  def self._reset(pin)
    system("#{@gpio_bin} mode #{pin} output")
    sleep(1)
  end

  def self._init_file()
    unless File.file?(@status_file)
      File.write(@status_file, '{}')
    end
  end

  def self._set_status(sprinkler, status)
    _init_file()
    s_status = JSON.parse(File.read(@status_file))
    s_status.merge!({sprinkler => status})
    File.write(@status_file, s_status.to_json)
  end

  class << self
    private :_reset
    private :_init_file
    private :_set_status
  end
end
