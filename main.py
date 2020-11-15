import json
import re
import requests
import time
import unicodedata

from bs4 import BeautifulSoup
from collections import Counter
import matplotlib.pyplot as plt
from wordcloud import WordCloud, STOPWORDS, ImageColorGenerator


# Time constants
TIME_HOUR_SECONDS = 3600
TIME_DAY_HOURS = 24
TIME_MONTH_DAYS = 30

# HTTP query settings
GOOGLE_NEWS_DOMAIN = 'https://news.google.com'
#GOOGLE_NEWS_PARAMS = 'search?q=russia%20when%3A1m%20when%3A1y&hl=en-US&gl=US&ceid=US%3Aen'
GOOGLE_NEWS_PARAMS = 'search?q=russia&hl=en-US&gl=US&ceid=US:en'
HTTP_TIMEOUT = 5

# Words filtering settings
MIN_PARAGRAPH_LEN = 40
MIN_WORD_LEN = 5
exclude_words = [
    'that', 'with', 'were', 'have', 'from', 'this', 'like', 'they', 'been', 'more', 'will', 'said', 'also',
    'over', 'only',

    'about', 'their', 'which', 'would', 'there', 'after', 'could', 'these', 'those', 'under', 'being', 'where', 'while',
    
    'before', 'former', 'during',

    'because', 'between', 'through', 'according',
]
exclude_regs = ('russia\S*',)
reg_filter = re.compile('|'.join(['[^a-z ]', *exclude_regs]))

words_counter = Counter()


# Getting google news contents
html_text = requests.get('/'.join([GOOGLE_NEWS_DOMAIN, GOOGLE_NEWS_PARAMS]), timeout=HTTP_TIMEOUT).text
html_main_text = re.search(r'<main.*/main>', html_text).group(0)
news_list_bs4 = BeautifulSoup(html_main_text, 'lxml').main.next.next

for news_bs4 in (obj.article for obj in news_list_bs4.contents if obj.article is not None):
    article_link = '/'.join([GOOGLE_NEWS_DOMAIN, re.search(r'articles.*', news_bs4.a['href']).group(0)])
    
    time_now = time.mktime(time.gmtime())
    time_article = time.mktime(time.strptime(news_bs4.time['datetime'], '%Y-%m-%dT%H:%M:%SZ'))
    time_diff_hours = (time_now - time_article) / TIME_HOUR_SECONDS

    # Articles older than 30 days are excluded
    if time_diff_hours < TIME_MONTH_DAYS*TIME_DAY_HOURS:
        try:
            article_text = requests.get(article_link, timeout=HTTP_TIMEOUT).text
        except (requests.exceptions.Timeout, requests.exceptions.ConnectionError):
            continue
            
        article_bs4 = BeautifulSoup(article_text, 'lxml')
        
        for p in article_bs4.find_all('p'):
            # Filtering paragraphs from bytes
            p_text = reg_filter.sub('', p.get_text().encode().decode('ascii', 'ignore').lower())
            if len(p_text) < MIN_PARAGRAPH_LEN:
                continue

            filtered_words = [word for word in p_text.split() if len(word) >= MIN_WORD_LEN and word not in exclude_words]
            words_counter += Counter(filtered_words)


word_cloud = WordCloud(background_color='white').generate_from_frequencies(dict(words_counter.most_common(50)))

# Display the generated image
plt.imshow(word_cloud, interpolation='bilinear')
plt.axis('off')
plt.show()
