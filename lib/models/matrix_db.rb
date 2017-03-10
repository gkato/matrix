require 'mongo'

class MatrixDB

  attr_accessor :mongo, :collection

  Mongo::Logger.logger.level = ::Logger::FATAL

  def initialize(cluster, opts = {})
    opts.merge!({connect_timeout: 15}) if !opts.include?(:connect_timeout)
    opts.merge!({wait_queue_timeout: 15}) if !opts.include?(:wait_queue_timeout)
    self.mongo = Mongo::Client.new(cluster, opts)
  end

  def on(collection)
    self.collection = mongo[collection] rescue self.collection = mongo[collection]
    self
  end

  def insert_one(data)
    self.collection.insert_one(data) rescue self.collection.insert_one(data)
  end

  def insert_many(data)
    self.collection.insert_many(data) rescue self.collection.insert_many(data)
  end

  def delete(opts = {})
    self.collection.delete_many(opts) rescue self.collection.delete_many(opts)
  end

  def find(filters, opts = {})
    self.collection.find(filters, opts) rescue self.collection.find(filters, opts)
  end

  def close
    self.mongo.close rescue self.mongo.close
  end
end
