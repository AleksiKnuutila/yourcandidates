require 'json'
require 'pp'
file = File.read('data.json')
data_hash = JSON.parse(file)
PP.pp(data_hash)
