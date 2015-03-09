python scrape-predictionrange.py
awk 'NR > 2' predictions-range.csv > temp.csv ; mv temp.csv predictions-range.csv
python parse-prediction.py > predictions-range.json
scp predictions-range.json zur@edu.lahti.fi:public_html
