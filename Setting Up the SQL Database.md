# Setting Up the SQL Database

First of all, We create a schema for better manage for tables and improve the structure of the database.

```SQL
CREATE SCHEMA foodpanda_reviews;
GO
```

## Build Tables 𝄜

### Creating the Stores Table

This `stores` Table has each unique id, holds information about stores, locations, and food types.

```SQL
CREATE TABLE foodpanda_reviews.stores (
	store_id VARCHAR(4) PRIMARY KEY,
	store_name VARCHAR(MAX),
    -- Use NVARCHAR for non-English characters.
	food_type NVARCHAR(50),
	avg_rating DECIMAL(2, 1),
	reviewers VARCHAR(8),
	city VARCHAR(15)
);
GO
```

### Creating the Language Codes Table

This `language_codes` table contains only 75 ISO codes supported by the [lingua.py] module.

```SQL
CREATE TABLE foodpanda_reviews.language_codes (
    iso_code CHAR(2) PRIMARY KEY,  
    language_name NVARCHAR(50)
);

INSERT INTO foodpanda_reviews.language_codes (iso_code, language_name)
VALUES 
('AF', 'Afrikaans'),
('SQ', 'Albanian'),
('AR', 'Arabic'),
('HY', 'Armenian'),
('AZ', 'Azerbaijani'),
('EU', 'Basque'),
('BE', 'Belarusian'),
('BN', 'Bengali'),
('NO', 'Norwegian Bokmal'),
('BS', 'Bosnian'),
('BG', 'Bulgarian'),
('CA', 'Catalan'),
('ZH', 'Chinese'),
('HR', 'Croatian'),
('CS', 'Czech'),
('DA', 'Danish'),
('NL', 'Dutch'),
('EN', 'English'),
('EO', 'Esperanto'),
('ET', 'Estonian'),
('FI', 'Finnish'),
('FR', 'French'),
('LG', 'Ganda'),
('KA', 'Georgian'),
('DE', 'German'),
('EL', 'Greek'),
('GU', 'Gujarati'),
('HE', 'Hebrew'),
('HI', 'Hindi'),
('HU', 'Hungarian'),
('IS', 'Icelandic'),
('ID', 'Indonesian'),
('GA', 'Irish'),
('IT', 'Italian'),
('JA', 'Japanese'),
('KK', 'Kazakh'),
('KO', 'Korean'),
('LA', 'Latin'),
('LV', 'Latvian'),
('LT', 'Lithuanian'),
('MK', 'Macedonian'),
('MS', 'Malay'),
('MI', 'Maori'),
('MR', 'Marathi'),
('MN', 'Mongolian'),
('NN', 'Norwegian Nynorsk'),
('FA', 'Persian'),
('PL', 'Polish'),
('PT', 'Portuguese'),
('PA', 'Punjabi'),
('RO', 'Romanian'),
('RU', 'Russian'),
('SR', 'Serbian'),
('SN', 'Shona'),
('SK', 'Slovak'),
('SL', 'Slovene'),
('SO', 'Somali'),
('ST', 'Sotho'),
('ES', 'Spanish'),
('SW', 'Swahili'),
('SV', 'Swedish'),
('TL', 'Tagalog'),
('TA', 'Tamil'),
('TE', 'Telugu'),
('TH', 'Thai'),
('TS', 'Tsonga'),
('TN', 'Tswana'),
('TR', 'Turkish'),
('UK', 'Ukrainian'),
('UR', 'Urdu'),
('VI', 'Vietnamese'),
('CY', 'Welsh'),
('XH', 'Xhosa'),
('YO', 'Yoruba'),
('ZU', 'Zulu');
```

### Creating the Reviews Table

This `reviews` table contains customer reviews, ratings, and feedback for stores, along with reviewer details. It has two constraints that establish relationships with the `stores` table and the `language_codes` table.

```SQL
CREATE TABLE foodpanda_reviews.reviews (
	store_id VARCHAR(4),
	uuid UNIQUEIDENTIFIER,
	created_at DATETIME2,
	updated_at DATETIME2,
	review_text NVARCHAR(MAX),
	is_anonymous BIT,
	review_id VARCHAR(8),
	replies TEXT,
	like_count INT,
	is_liked BIT,
	overall INT,
	restaurant INT,
	rider DECIMAL(2, 1),
	lang CHAR(2),
	FOREIGN KEY (store_id) REFERENCES foodpanda_reviews.stores(store_id),
	FOREIGN KEY (lang) REFERENCES foodpanda_reviews.language_codes(iso_code)
);
GO
```

---

## Handle Repeated Tasks

we create a procedure to import various CSV files for setting up the SQL Database. It has three input parameters **TableName**, **FolderName** and **FileName**.

```SQL
-- Create a procedure for handling repeated tasks
CREATE PROCEDURE BulkInsertFile
	@TableName NVARCHAR(100),
	@FolderName NVARCHAR(255),
	@FileName NVARCHAR(255)
AS
BEGIN
	DECLARE @SQL NVARCHAR(1000)
	SET @SQL = '
		BULK INSERT ' + @Tablename + '
	FROM ''' + @FolderName + '\' +  @FileName + '''
	WITH (
		FORMAT = ''CSV'',
		CODEPAGE = ''65001'',
		FIRSTROW = 2,
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''\n'',
		TABLOCK
	);';
	EXEC sp_executesql @SQL
END;
GO
```

## Import Various CSV Files

We execute a procedure to import various CSV files into the `stores` and `reviews` tables. Since the files have different names, using a procedure is more efficient than the manual import method.

```SQL
-- For stores Table
EXEC BulkInsertFile 'foodpanda_reviews.stores', 'N:\SQL\FoodPandaReviews\stores', 'th_bangkok_restos.csv';
EXEC BulkInsertFile 'foodpanda_reviews.stores', 'N:\SQL\FoodPandaReviews\stores', 'th_buriram_restos.csv';
EXEC BulkInsertFile 'foodpanda_reviews.stores', 'N:\SQL\FoodPandaReviews\stores', 'th_chachoengsao_restos.csv';
EXEC BulkInsertFile 'foodpanda_reviews.stores', 'N:\SQL\FoodPandaReviews\stores', 'th_chai_nat_restos.csv';
EXEC BulkInsertFile 'foodpanda_reviews.stores', 'N:\SQL\FoodPandaReviews\stores', 'th_chanthaburi_restos.csv';
EXEC BulkInsertFile 'foodpanda_reviews.stores', 'N:\SQL\FoodPandaReviews\stores', 'th_chiang_mai_restos.csv';
EXEC BulkInsertFile 'foodpanda_reviews.stores', 'N:\SQL\FoodPandaReviews\stores', 'th_chiang_rai_restos.csv';
EXEC BulkInsertFile 'foodpanda_reviews.stores', 'N:\SQL\FoodPandaReviews\stores', 'th_chon_buri_restos.csv';
EXEC BulkInsertFile 'foodpanda_reviews.stores', 'N:\SQL\FoodPandaReviews\stores', 'th_kamphaeng_phet_restos.csv';
EXEC BulkInsertFile 'foodpanda_reviews.stores', 'N:\SQL\FoodPandaReviews\stores', 'th_kanchanaburi_restos.csv';
EXEC BulkInsertFile 'foodpanda_reviews.stores', 'N:\SQL\FoodPandaReviews\stores', 'th_khon_kaen_restos.csv';

-- For reviews Table
EXEC BulkInsertFile 'foodpanda_reviews.reviews', 'N:\SQL\FoodPandaReviews\reviews', 'th_bangkok_reviews.csv';
EXEC BulkInsertFile 'foodpanda_reviews.reviews', 'N:\SQL\FoodPandaReviews\reviews', 'th_buriram_reviews.csv';
EXEC BulkInsertFile 'foodpanda_reviews.reviews', 'N:\SQL\FoodPandaReviews\reviews', 'th_chachoengsao_reviews.csv';
EXEC BulkInsertFile 'foodpanda_reviews.reviews', 'N:\SQL\FoodPandaReviews\reviews', 'th_chai_nat_reviews.csv';
EXEC BulkInsertFile 'foodpanda_reviews.reviews', 'N:\SQL\FoodPandaReviews\reviews', 'th_chanthaburi_reviews.csv';
EXEC BulkInsertFile 'foodpanda_reviews.reviews', 'N:\SQL\FoodPandaReviews\reviews', 'th_chiang_mai_reviews.csv';
EXEC BulkInsertFile 'foodpanda_reviews.reviews', 'N:\SQL\FoodPandaReviews\reviews', 'th_chiang_rai_reviews.csv';
EXEC BulkInsertFile 'foodpanda_reviews.reviews', 'N:\SQL\FoodPandaReviews\reviews', 'th_chon_buri_reviews.csv';
EXEC BulkInsertFile 'foodpanda_reviews.reviews', 'N:\SQL\FoodPandaReviews\reviews', 'th_kamphaeng_phet_reviews.csv';
EXEC BulkInsertFile 'foodpanda_reviews.reviews', 'N:\SQL\FoodPandaReviews\reviews', 'th_kanchanaburi_reviews.csv';
EXEC BulkInsertFile 'foodpanda_reviews.reviews', 'N:\SQL\FoodPandaReviews\reviews', 'th_khon_kaen_reviews.csv';
```

## Data Preparation

We modify the `reviewers` column and remove certain values.

```SQL
-- Modify reviewers column value.
UPDATE foodpanda_reviews.stores
SET reviewers = TRANSLATE(reviewers, '-()+', '    ');

-- Check if there are any null values.
SELECT reviewers 
FROM foodpanda_reviews.stores
WHERE TRY_CAST(reviewers AS INT) IS NULL AND reviewers IS NOT NULL;

ALTER TABLE foodpanda_reviews.stores
ALTER COLUMN reviewers INT;

UPDATE foodpanda_reviews.stores
SET store_name = REPLACE(store_name, '?', '');

-- Remove a certain amount of total reviews
DELETE foodpanda_reviews.reviews
WHERE store_id IN (
	SELECT store_id
	FROM foodpanda_reviews.stores
	WHERE LEN(TRIM(store_name)) < 2
);

DELETE foodpanda_reviews.stores
WHERE LEN(TRIM(store_name)) < 2;
```

[Here] we go to the next step.

[Here]: https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/Diving%20into%20the%20Analysis.md
[lingua.py]: https://github.com/pemistahl/lingua-py
