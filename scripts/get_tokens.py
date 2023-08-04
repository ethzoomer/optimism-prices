import os
import requests
import pandas as pd

session = requests.Session()

api_key = os.getenv('DUNE_KEY', '')

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
     
