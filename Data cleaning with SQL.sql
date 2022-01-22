
-------Cleaning data with SQL queries--------

-------------------Start---------------------

SELECT *
FROM PortfolioProjects.dbo.DataHousing

-------Standardize the format of data--------

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProjects.dbo.DataHousing

UPDATE DataHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE DataHousing
ADD SaleDateConverted Date;

UPDATE DataHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-------Populate property Address Data-------

SELECT *
FROM PortfolioProjects.dbo.DataHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProjects.dbo.DataHousing A
JOIN PortfolioProjects.dbo.DataHousing B
    on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProjects.dbo.DataHousing A
JOIN PortfolioProjects.dbo.DataHousing B
    on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

--------Split address into individual columns-------

SELECT PropertyAddress
FROM PortfolioProjects.dbo.DataHousing

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
,SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM PortfolioProjects.dbo.DataHousing


ALTER TABLE DataHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE DataHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE DataHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE DataHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProjects.dbo.DataHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM PortfolioProjects.dbo.DataHousing



ALTER TABLE DataHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE DataHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE DataHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE DataHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)


ALTER TABLE DataHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE DataHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


SELECT *
FROM PortfolioProjects.dbo.DataHousing


-------Replacing values in SoldAsVacant column------

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProjects.dbo.DataHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProjects.dbo.DataHousing

UPDATE DataHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


---------Remove duplicates rows----------
WITH CTE AS(
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 OwnerName,
				 LegalReference
				 ORDER BY 
				    UniqueID
				 ) row_num

FROM PortfolioProjects.dbo.DataHousing
)
--DELETE
SELECT *
FROM CTE
WHERE row_num > 1
--ORDER BY PropertyAddress

----------Delete unused columns----------------

SELECT *
FROM PortfolioProjects.dbo.DataHousing

ALTER TABLE PortfolioProjects.dbo.DataHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, TaxDistrict, OwnerSplitAddress, OwnerSplitCity
            
------------End data cleaning---------

