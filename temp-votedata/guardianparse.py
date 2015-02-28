import json
json_data=open('guardianprettydata.json')
data = json.load(json_data)
for const in data['results']['called-constituencies']:
  print const['name']
