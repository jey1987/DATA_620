library(wordcloud)
library(tidyr)
library(dplyr)
library(stringr)
library(tm)
library(tidytext)
library(textdata)
library(rvest)
library(xml2)
library(data.table)
library(RMySQL)

listings <- data.frame(title=character(),
                       company=character(), 
                       location=character(), 
                       summary=character(), 
                       link=character(), 
                       description = character(),
                       stringsAsFactors=FALSE) 

for (i in seq(0, 636, 1)){
  print(i)
  url_ds <- paste0('https://www.indeed.com/jobs?q=data+scientist&l=all&start=',i)
  var <- read_html(url_ds)
}

title <-  var %>% 
  html_nodes('#resultsCol .jobtitle') %>%
  html_text() %>%
  str_extract("(\\w+.+)+") 
title

company <- var %>% 
  html_nodes('#resultsCol .company') %>%
  html_text() %>%
  str_extract("(\\w+).+") 
company

location <- var %>%
  html_nodes('#resultsCol .location') %>%
  html_text() %>%
  str_extract("(\\w+.)+,.[A-Z]{2}") 
location

summary <- var %>%
  html_nodes('#resultsCol .summary') %>%
  html_text() %>%
  str_extract(".+")
summary

link <- var %>%
  html_nodes('#resultsCol .jobtitle .turnstileLink, #resultsCol a.jobtitle') %>%
  html_attr('href') 
link <- paste0("https://www.indeed.com",link)

listings <- rbind(listings, as.data.frame(cbind(title,
                                                company,
                                                location,
                                                summary,
                                                link)))
for (i in (1:length(listings$link))){
  desciption <- tryCatch(
    html_text(html_node(read_html(as.character(listings$link[i])),'.jobsearch-JobComponent-description')),
    error=function(e){NA}
  )
  if (is.null(desciption)){
    desc <- NA
  }
  listings$description[i] <- desciption
}

table_listings <- data.table(joblistings)

# Replacing single quotes with space
table_listings$title <- str_replace_all(table_listings$title,"'","")
table_listings$company <- str_replace_all(table_listings$company,"'","")
table_listings$link <- str_replace_all(table_listings$link,"'","")
table_listings$location <- str_replace_all(table_listings$location,"'","")
table_listings$summary <- str_replace_all(table_listings$summary,"'","")
table_listings$description <- str_replace_all(table_listings$description,"'","")


#Conneciton to Mysql
mydb = dbConnect(MySQL(), user='root', password='root', dbname='sys', host='localhost')

#Delete Existing Records
dbSendQuery(mydb,"delete from job_listings;")

#Load Dataframe to mysql table
for(i in 1:nrow(table_listings))
{
insert_query <- paste("INSERT INTO job_listings (X1,title,company,location,summary,link,description) VALUES ('",table_listings[i,1],"','",table_listings[i,2],"','",table_listings[i,3],"','",table_listings[i,4],"','",table_listings[i,5],"','",table_listings[i,6],"','",table_listings[i,7],"')") 
dbSendQuery(mydb,insert_query)
}

#joblistings<- as.data.frame(readr::read_csv("https://raw.githubusercontent.com/joshuargst/607project3/master/joblistings.csv"))

#Read Mysql Table into dataframe
mydb = dbConnect(MySQL(), user='root', password='root', dbname='sys', host='localhost')
joblistings_rs <- dbSendQuery(mydb,"select * from job_listings")
joblistings = fetch(joblistings_rs,n=-1)

#extracting all description words into a vector
descriptionwords <- joblistings$description %>% str_replace_all("^<[:graph:]*>$","")%>%
  str_replace_all("\\\n"," ") %>%
  str_replace_all("[^[:alpha:] ]"," ") %>% tolower()


#pulling all individual words into a dataframe and counting
word_counts <- as.data.frame(table(unlist(strsplit(descriptionwords, "\\s+") )))
colnames(word_counts)<-c("word","Freq")


#removing filler words and sentimental words
word_counts <-anti_join(word_counts,get_stopwords())%>%
  anti_join(get_sentiments())

#removing noisy words with low counts for table reduction
word_counts<-word_counts[word_counts$Freq>200,]



#preliminary wordcloud
wordcloud(words = word_counts$word, freq = word_counts$Freq, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))


