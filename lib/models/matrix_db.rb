require 'mongo'

class MatrixDB

  attr_accessor :mongo, :collection

  Mongo::Logger.logger.level = ::Logger::FATAL

  def initialize(opts = {})
    env = opts[:env] || "production"
    opts.merge!({connect_timeout: 15}) if !opts.include?(:connect_timeout)
    opts.merge!({wait_queue_timeout: 15}) if !opts.include?(:wait_queue_timeout)

    cluster = $conf["mongo"][env]["host"].split(",") rescue []
    database = $conf["mongo"][env]["database"]
    @mongo = Mongo::Client.new(cluster, opts)
  end

  def on(collection)
    @collection = mongo[collection] rescue @collection = mongo[collection]
    self
  end

  def insert_one(data)
    @collection.insert_one(data) rescue @collection.insert_one(data)
  end

  def insert_many(data)
    @collection.insert_many(data) rescue @collection.insert_many(data)
  end

  def delete(opts = {})
    @collection.delete_many(opts) rescue @collection.delete_many(opts)
  end

  def find(filters, opts = {})
    @collection.find(filters, opts) rescue @collection.find(filters, opts)
  end

  def close
    @mongo.close rescue @mongo.close
  end
end
