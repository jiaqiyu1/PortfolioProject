/*

Cleasing Data in SQL Queries

*/



--make a copy of [dbo].[NashvilleHousing] table, just in case

SELECT *
INTO NashvilleHousing_duplicate
FROM [dbo].[NashvilleHousing];


SELECT*
FROM [dbo].[NashvilleHousing_duplicate]

-----------------------------------------------------------------------------------------------

--Standardize Date Format


--Convert SaleDate Into DATE

--- add a new column called SaleDate_Converted(still blank)

ALTER TABLE [dbo].[NashvilleHousing_duplicate]
ADD SaleDate_Converted DATE

UPDATE [dbo].[NashvilleHousing_duplicate]
SET SaleDate_Converted = CONVERT(DATE,SaleDate) 

---delect the orginal column SaleDate
ALTER TABLE [dbo].[NashvilleHousing_duplicate]
DROP COLUMN SaleDate

------------------------------------------------------------------------------------

--Populate Property Address Data ( where data is null)

--Solution 1 

SELECT * 
FROM [dbo].[NashvilleHousing_duplicate]
--WHERE PropertyAddress IS NULL 
ORDER BY ParcelID  --> If the ParcelID is the same, then the PropertyAddress is also the same


WITH ParcelID_Duplicates AS (
	SELECT ParcelID
	FROM [dbo].[NashvilleHousing_duplicate]
	GROUP BY ParcelID
	HAVING COUNT(*) > 1
	--->  pick up the ParcelId which has duplicate values 

), ParcelID_Properties AS (
	SELECT ParcelID, PropertyAddress
	FROM [dbo].[NashvilleHousing_duplicate]
	WHERE PropertyAddress IS NOT NULL
)    
    --->  pick up PropertyAddress is NOT NULL 

UPDATE [dbo].[NashvilleHousing_duplicate]
SET PropertyAddress = (
	SELECT TOP 1 PropertyAddress
	FROM ParcelID_Properties t2
	WHERE t2.ParcelID = [dbo].[NashvilleHousing_duplicate].ParcelID
)
WHERE ParcelID IN (
	SELECT ParcelID
	FROM ParcelID_Duplicates
) AND PropertyAddress IS NULL;



--check 

SELECT PropertyAddress 
FROM [dbo].[NashvilleHousing_duplicate]
WHERE PropertyAddress  IS NULL 


--Solution 2

-- same table self join (inner join) 

SELECT 
	t1.ParcelID,
	t1.PropertyAddress,
	t2.ParcelID,
	ISNULL(t1.PropertyAddress,t2.PropertyAddress)  --> check if it is null, if yes, populate it with data
FROM [dbo].[NashvilleHousing_duplicate] t1
INNER JOIN [dbo].[NashvilleHousing_duplicate] t2 
	ON t1.ParcelID = t2.ParcelID 
	AND t1.UniqueID != t2. UniqueID 


--Update 

UPDATE t1  --> must use alias 
SET PropertyAddress = ISNULL(t1.PropertyAddress,t2.PropertyAddress)
FROM [dbo].[NashvilleHousing_duplicate] t1
INNER JOIN [dbo].[NashvilleHousing_duplicate] t2 
	ON t1.ParcelID = t2.ParcelID 
	AND t1.UniqueID != t2. UniqueID 
WHERE t1.PropertyAddress IS NULL 

--check 
SELECT *
FROM [dbo].[NashvilleHousing_duplicate]
WHERE PropertyAddress IS NULL 


------------------------------------------------------------------------

-- Breaking out PropertyAddress into Individual Columns (Address, City, State) 



SELECT PropertyAddress
FROM [dbo].[NashvilleHousing_duplicate]


	--> CHAIRINDEX() find out the ',' position in PropertyAddress
	--> SUBSTRING() according to the position to extract the strings
	--> -1 means  length-1 to remove the comma

SELECT 
	PropertyAddress
	,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1 ) AS Address
	,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress) ) AS City
	   --> start with space and end up with the length of PropertyAddress
FROM [dbo].[NashvilleHousing_duplicate]



--add two new columns and populate data from above 
ALTER TABLE [dbo].[NashvilleHousing_duplicate]
ADD PropertySplitAddress VARCHAR(255);

UPDATE [dbo].[NashvilleHousing_duplicate]
SET PropertySplitAddress =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1 );

ALTER TABLE [dbo].[NashvilleHousing_duplicate]
ADD PropertySplitCity VARCHAR(255);

UPDATE [dbo].[NashvilleHousing_duplicate]
SET PropertySplitCity =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress) );

SELECT *
FROM [dbo].[NashvilleHousing_duplicate]



--Cleansing OwnerAddress
SELECT 
	OwnerAddress
	,PARSENAME(REPLACE(OwnerAddress,',','.'),3)  --> must use . as delimiter, so replace , with .
	,PARSENAME(REPLACE(OwnerAddress,',','.'),2)  --> must use . as delimiter, so replace , with .
	,PARSENAME(REPLACE(OwnerAddress,',','.'),1)  --> must use . as delimiter, so replace , with .

FROM [dbo].[NashvilleHousing_duplicate]

--add 3 new columns and populate data
ALTER TABLE [dbo].[NashvilleHousing_duplicate]
ADD OwnerSplitAddress VARCHAR(255);
UPDATE [dbo].[NashvilleHousing_duplicate]
SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress,',','.'),3);


ALTER TABLE [dbo].[NashvilleHousing_duplicate]
ADD OwnerSplitCity VARCHAR(255);
UPDATE [dbo].[NashvilleHousing_duplicate]
SET OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress,',','.'),2);


ALTER TABLE [dbo].[NashvilleHousing_duplicate]
ADD OwnerSplitState VARCHAR(255);
UPDATE [dbo].[NashvilleHousing_duplicate]
SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress,',','.'),1);



SELECT *
FROM [dbo].[NashvilleHousing_duplicate]


-----------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'SoldAsVacant' 
SELECT 
	DISTINCT SoldAsVacant,
	Count(SoldAsVacant)
FROM [dbo].[NashvilleHousing_duplicate]
GROUP BY SoldAsVacant
ORDER BY 2


SELECT 
	CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
		 WHEN SoldAsVacant ='N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM [dbo].[NashvilleHousing_duplicate]


UPDATE [dbo].[NashvilleHousing_duplicate]
SET SoldAsVacant = 
(	CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
			WHEN SoldAsVacant ='N' THEN 'No'
			ELSE SoldAsVacant
			END
	)

SELECT 
	DISTINCT SoldAsVacant,
	Count(SoldAsVacant)
FROM [dbo].[NashvilleHousing_duplicate]
GROUP BY SoldAsVacant
ORDER BY 2


------------------------------------------------------------

--Remove Duplicates




WITH RowNumber_CTE AS(

SELECT 
	*,
	ROW_NUMBER() OVER 
		(PARTITION BY ParcelID,
					  PropertyAddress,
					  SalePrice,
					  LegalReference
		ORDER BY UniqueID
		) AS row_num

FROM [dbo].[NashvilleHousing_duplicate]
)

DELETE 
FROM RowNumber_CTE
WHERE row_num >1 

--check
--SELECT *
--FROM RowNumber_CTE
--WHERE row_num >1


----------------------------------------------------------------------------------

--Delete Unused Columns

SELECT *
FROM [dbo].[NashvilleHousing_duplicate]

ALTER TABLE [dbo].[NashvilleHousing_duplicate]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


