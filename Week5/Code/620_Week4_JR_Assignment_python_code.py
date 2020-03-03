from bs4 import BeautifulSoup
import requests
import pandas as pd
import json


title_df = pd.DataFrame()
location_df = pd.DataFrame()
company_df = pd.DataFrame()


URL = "https://www.indeed.com/jobs?q=data+scientist+%2420%2C000&l=New+York&start=10"

def writeToJSONFile(path, fileName, data):
    filePathNameWExt = path + '/' + fileName + '.json'
    with open(filePathNameWExt, 'w') as fp:
        json.dump(data, fp)
        
def extract_location_from_result(soup): 
  locations = []
  spans = soup.findAll("div", attrs={"class": "location"})
  for span in spans:
        locations.append(span.text)
  return(locations)


def extract_summary_from_result(soup): 
  summaries = []
  spans = soup.findAll('span', attrs={'class': 'summary'})
  for span in spans:
    summaries.append(span.text.strip())
  return(summaries)


def extract_company_from_result(soup): 
  companies = []
  for div in soup.find_all(name="div", attrs={"class":"row"}):
    company = div.find_all(name="span", attrs={"class":"company"})
    for b in company:
     companies.append(b.text.strip())
  return(companies)


def extract_job_title_from_result(soup): 
  jobs = []
  for div in soup.find_all(name="div", attrs={"class":"row"}):
      for a in div.find_all(name="a", attrs={"data-tn-element":"jobTitle"}):
          jobs.append(a["title"])
  return(jobs)

def extract_df_from_URL(URL,title_df,location_df,company_df): 
  page = requests.get(URL)
  soup = BeautifulSoup(page.text, "html.parser")
  title = extract_job_title_from_result(soup)
  location = extract_location_from_result(soup)
  company = extract_company_from_result(soup)
  title_df.append(pd.DataFrame(title))
  location_df.append(pd.DataFrame(location))
  company_df.append(pd.DataFrame(company))

title = []
location = []
summary = []
company = []

title_df = pd.DataFrame()
location_df = pd.DataFrame()
company_df = pd.DataFrame()

for i in range(2,3):
    URL = "https://www.indeed.com/jobs?q=data+scientist&l=all&start="+str(i)
    extract_df_from_URL(URL,title_df,location_df,company_df)

json_title = title_df.to_json(orient='records')
json_location = location_df.to_json(orient='records')
json_company = company_df.to_json(orient='records')



writeToJSONFile('./','title',json_title)
writeToJSONFile('./','location',json_location)
writeToJSONFile('./','company',json_company)

print("JSON Export Complete")
