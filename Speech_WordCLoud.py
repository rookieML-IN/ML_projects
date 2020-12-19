'''
Full Text of PM Narendra Modi's Speech on coronavirus lockdown extension.
url - https://www.livemint.com/news/india/full-text-of-pm-narendra-modi-s-speech-on-lockdown-extension-11586843333652.html
'''

# Loading the Text File containing the Speech
f = open("C:/Users/ASHUTOSH DAS/OneDrive/Documents/Text Analysis/Modi's_Speech.txt", 'r')
Speech = f.read()
print(Speech)

# Importing Libraries
import re
import pandas as pd
import matplotlib.pyplot as plt
from wordcloud import WordCloud, STOPWORDS

# Text Cleaning

## Substituting the Special Characters
cleanedspeech = re.sub(r'[? | $ | .|!]', r' ', Speech)

## Substituting the Non-alphabetic characters
cleanedspeech = re.sub(r'[^a-z A-z]', r' ', cleanedspeech)

## Deleting words with lenght less than 3/ Specifically STOPWORDS
cleanedspeech = re.sub(r'\b\w{1,3}\b', ' ', cleanedspeech)

## Stripping Extra Spaces
cleanedspeech = re.sub(r' +', ' ', cleanedspeech)

## Converting the Entire Speech to Lower Case
cleanedspeech = cleanedspeech.lower()

# Determining the Word Frequency

WordList = cleanedspeech.split()
WordData = pd.DataFrame(data=pd.Series(WordList), columns=['words'])
Word_freq = WordData.groupby('words').size().nlargest(10)
print(Word_freq)

# Plotting
customlist = list(STOPWORDS) + ['will','well']
cloudimage = WordCloud(max_words=50,font_step=2,stopwords=customlist,width=1000,height=720).generate(cleanedspeech)
plt.figure(figsize=(15,7))
plt.imshow(cloudimage)
plt.axis("off")
plt.show()