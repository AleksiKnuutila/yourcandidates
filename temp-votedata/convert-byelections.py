import json
import pdb

json_data=open('kimono.json').read()
data = json.loads(json_data)

partynameconversion = {
  'Labour': 'Labour Party',
  'Lib Dem': 'Liberal Democrats',
  'Conservative': 'Conservative Party',
  'Plaid Cymru': 'Plaid Cymru',
  'UKIP': 'UK Independence Party (UKIP)',
  'SNP': 'Scottish National Party',
  'Green': 'Green Party',
  'TUSC': 'Trade Unionist and Socialist Coalition',
  'Eng Democrats': 'English Democrats',
  'Christian': 'Christian Peoples Alliance',
  'Alliance': 'Alliance - Alliance Party of Northern Ireland',
  'DUP': 'Democratic Unionist Party - D.U.P.',
  'SDLP': 'SDLP (Social Democratic & Labour Party)',
  'Respect': 'The Respect Party'
}

new_data = []
parties_in_area = {}
area_name = ''
current_area = None
for r in data:
  elected = False
  if current_area != r['Area name']:
    new_data.append({'name': area_name,
      'parties': parties_in_area})
    current_area = r['Area name']
    parties_in_area = {}
    elected = True
  area_name = r['Area name']
  year = r['Year']
  party = r['Party']['text']
  candidate_name  = r['Candidate name']['text']
  if party in partynameconversion:
    party = partynameconversion[party]
  if party == 'Independent':
    party = 'Independent - ' + candidate_name
  percentage = r['Vote share']
  parties_in_area[party] = {
    'byelection': True,
    'elected': elected,
    'name': candidate_name,
    'percentage': float(percentage),
    'year': year}
new_data.append({'name': area_name,
  'parties': parties_in_area})

print json.dumps(new_data,indent=2,sort_keys=True)


