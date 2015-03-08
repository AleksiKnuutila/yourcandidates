from bs4 import BeautifulSoup
import urllib2
import pdb 
import csv
#site = "http://electionforecast.co.uk/tables/predicted_vote_by_seat.html"
site = "http://electionforecast.co.uk/tables/predicted_interval_by_seat.html"
header = {'User-Agent': 'Mozilla/5.0'} #Needed to prevent 403 error on Wikipedia
req = urllib2.Request(site,headers=header)
page = urllib2.urlopen(req)
soup = BeautifulSoup(page)
 
area = ""
district = ""
town = ""
county = ""
 
table = soup.find("table", { "class" : "tablesorter" })
 
f = open('predictions-range.csv', 'wb')
wr = csv.writer(f, quoting=csv.QUOTE_ALL)
 
header = ['Conservatives','Labour','Liberal democrats','Snp','Plaid Cymru','Greens','Ukip','Other','Seat','Region','2010']
wr.writerow(header)

for row in table.findAll("tr"):
    cells = row.findAll("td")
    #For each "tr", assign each "td" to a variable.
    for i in range(len(cells)):
        cells[i] = cells[i].find(text=True)
#    pdb.set_trace()
    wr.writerow(cells)
    
#    if len(cells) == 4:
#        area = cells[0].find(text=True)
#        district = cells[1].findAll(text=True)
#        town = cells[2].find(text=True)
#        county = cells[3].find(text=True)

f.close()

