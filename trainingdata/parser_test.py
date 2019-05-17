import json
import random

shortlist = []
numSamples = [0,0,0,0,0,0,0]
badQuals = [2,5,6,7,8]
data = json.load(open('examples.json'))
for p in data:
	quals = 0
	for q in badQuals:
		quals += data[p]['qualities'][q]
	if data[p]['instrument_source'] == 0 and quals == 0:
		prob = random.uniform(0,1)
		if data[p]['instrument_family'] == 0 : #bass
			shortlist.append([p,1]) 
			numSamples[0] += 1
		if data[p]['instrument_family'] == 1 and prob < 0.05: #brass
			shortlist.append([p,2]) 
			numSamples[1] += 1
		if data[p]['instrument_family'] == 2 and prob < 0.1: #flute
			shortlist.append([p,3]) 
			numSamples[2] += 1
		if data[p]['instrument_family'] == 3 and prob < 0.041: #guitar
			shortlist.append([p,4]) 
			numSamples[3] += 1
		if data[p]['instrument_family'] == 6: #organ #the current badQuals list stops any organ samples from being selected
			shortlist.append([p,5]) 
			numSamples[4] += 1
		if data[p]['instrument_family'] == 7 and prob < 0.06: #reed
			shortlist.append([p,6]) 
			numSamples[5] += 1
		if data[p]['instrument_family'] == 8 and prob < 0.4: #string
			shortlist.append([p,7]) 
			numSamples[6] += 1
		
json.dump(shortlist,open('shortlist_test.json','w'))
json.dump(numSamples,open('stats_test.json','w'))