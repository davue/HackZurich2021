import pandas as pd

rssi = pd.read_csv('data/rssi.csv', nrows=100)
#events = pd.read_csv('data/events.csv')
#disruptions = pd.read_csv('data/disruptions.csv')

print('import done')
print(rssi)