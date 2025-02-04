import pandas as pd

# creat function to make easy to apply on creating tables for sql analysis
def prepare_stores(provinces):
    for i in provinces:
        try:
            filepath = r"N:\SQL\FoodPandaReviews\reviews\th_" + str(i) + "_reviews.csv"
            review = pd.read_csv(filepath)
            review['isAnonymous'] = [0 if isAnonymous == False else 1 for isAnonymous in review['isAnonymous']]
            review['likeCount'] = review['likeCount'].astype(int)
            review['isLiked'] = [0 if isLiked == False else 1 for isLiked in review['isLiked']]
            review = review[review['reviewerId'].str.len() <= 8]
            review.to_csv(filepath, encoding='utf-8', index=False)
            print(f"Data preparation completed for {i}.") 
        except Exception as e:
            print(f"An error occurred while processing {i}: {e}")  
    print("Data preparation is completed for all files.")

provinces  = ['bangkok', 'buriram', 'chachoengsao', 'chai_nat', 'chanthaburi', 'chiang_mai', 'chiang_rai', 'chon_buri', 'kamphaeng_phet', 'kanchanaburi', 'khon_kaen']
prepare_stores(provinces)