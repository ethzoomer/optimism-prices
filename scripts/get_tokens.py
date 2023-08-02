import requests
import pandas as pd

session = requests.Session()

api_key = 'sSDjq4bVhSIbR9C9CoWqpzmID0LhZ8JH'

def run_request(link):
    finished = False
    while not finished:
        try:
            response = session.get(link)
            finished = True
        except:
            finished = False
            continue
    return response.json()

def get_tokens():
    url = "https://api.dune.com/api/v1/query/2678719/results?api_key=" + api_key
    response = pd.DataFrame(run_request(url))
    actual_data = response.loc['rows', 'result']
    return [element['token'] for element in actual_data], [element['symbol'] for element in actual_data]
     
