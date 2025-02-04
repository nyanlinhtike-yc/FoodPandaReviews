## Prepping the Data with Python

We perform data preparation steps such as removing outliers and adjusting data types to ensure smooth CSV import into the SQL database.

```python
import pandas as pd
from lingua import Language, LanguageDetectorBuilder

# Modify certain values for easier analysis in SQL.
def prepare_stores(provinces):
    for i in provinces:
        try:
            # Change the filepath here.
            filepath = r"N:\SQL\FoodPandaReviews\reviews\th_" + str(i) + "_reviews.csv"
            review = pd.read_csv(filepath)
            review['isAnonymous'] = [0 if isAnonymous == False else 1 for isAnonymous in review['isAnonymous']]
            review['likeCount'] = review['likeCount'].astype(int)
            review['isLiked'] = [0 if isLiked == False else 1 for isLiked in review['isLiked']]
            review = review[review['reviewerId'].str.len() <= 8]
            # Use the encoding parameter to enable Unicode support for non-English characters.
            review.to_csv(filepath, encoding='utf-8', index=False)
            print(f"Data preparation completed for {i}.") 
        except Exception as e:
            print(f"An error occurred while processing {i}: {e}")  
    print("Data preparation is completed for all files.")

provinces  = ['bangkok', 'buriram', 'chachoengsao', 'chai_nat', 'chanthaburi', 'chiang_mai', 'chiang_rai', 'chon_buri', 'kamphaeng_phet', 'kanchanaburi', 'khon_kaen']
prepare_stores(provinces)
```
---

We also implemented **language detection** on review texts to better understand the languages used by reviewers. For this, we used the [lingua.py] module, a powerful language detection tool that leverages natural language processing.

```python
# Detecting all supported languages for review texts
detector = LanguageDetectorBuilder.from_all_languages().build()

def detect_language(text):
    try:
        language = detector.detect_language_of(text)
        return language.iso_code_639_1.name
    except:
        return None

def get_languages(provinces):
    for i in provinces:
        try:
            # change the filepath here.
            filepath = r"N:\SQL\FoodPandaReviews\reviews\th_" + str(i) + "_reviews.csv"
            df = pd.read_csv(filepath)
            df['lang'] = df['text'].apply(detect_language)
            # Use the encoding parameter to enable Unicode support for non-English characters.
            df.to_csv(filepath, encoding='utf-8', index=False)
            print(f"Language Detection is completed for {i}.")
        except Exception as e:
            print(f"An error occured while processing {i}: {e}")
    print("All processes are completed.")

provinces  = ['bangkok', 'buriram', 'chachoengsao', 'chai_nat', 'chanthaburi', 'chiang_mai', 'chiang_rai', 'chon_buri', 'kamphaeng_phet', 'kanchanaburi', 'khon_kaen']
get_languages(provinces)
```

[Here] we go to the next step.

[Here]: https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/Setting%20Up%20the%20SQL%20Database.md
[lingua.py]: https://github.com/pemistahl/lingua-py