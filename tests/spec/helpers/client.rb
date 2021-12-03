require 'rest-client'

module Client
  include RestClient

  def self.get(*args)
    begin
      RestClient.get(*args)
    rescue => e
      e.response
    end
  end

  def self.post(*args)
    begin
      RestClient.post(*args)
    rescue => e
      e.response
    end
  end

  def self.put(*args)
    begin
      RestClient.put(*args)
    rescue => e
      e.response
    end
  end

  def self.delete(*args)
    begin
      RestClient.delete(*args)
    rescue => e
      e.response
    end
  end
end
