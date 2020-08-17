echo "Getting data from Scot.giv"
curl -o scot.covid.deaths.csv -L https://statistics.gov.scot/downloads/cube-table?uri=http%3A%2F%2Fstatistics.gov.scot%2Fdata%2Fdeaths-involving-coronavirus-covid-19
curl -o scot.covid.testing.csv -L https://statistics.gov.scot/downloads/cube-table?uri=http%3A%2F%2Fstatistics.gov.scot%2Fdata%2Fcoronavirus-covid-19-management-information

echo "Generating summary CSV"
./gov.stats.pl

echo "Generating Charts"
python3 ./gov.stats.plot.py ./gov.stats.result.csv 
