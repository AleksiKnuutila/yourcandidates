require 'json'
require 'pp'
file = File.read('data.json')
data_hash = JSON.parse(file)
file2 = File.read('byelections.json')
data_hash2 = JSON.parse(file2)
for row in data_hash
  ar = data_hash2.find { |c| c['name'] == row['name'] }
  if not ar
    data_hash2.concat([row])
  end
end
PP.pp(data_hash2)
