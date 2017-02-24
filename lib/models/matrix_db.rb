require 'mongo'

class MatrixDB

  attr_accessor :mongo, :collection

  def initialize(cluster, opts = {})
    self.mongo = Mongo::Client.new(cluster, opts)
  end

  def on(collection)
    self.collection = mongo[collection]
    self
  end

  def insert_one(data)
    self.collection.insert_one(data)
  end

  def insert_many(data)
    self.collection.insert_many(data)
  end

  def delete(opts = {})
    self.collection.delete_many(opts)
  end

  def find(filters, opts = {})
    self.collection.find(filters, opts)
  end

end
