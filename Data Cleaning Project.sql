/* Cleaning Data in SQL Queries
*/

SELECT * FROM PortfolioProject..NashvilleHousing

--Standardize Data Format
SELECT SaleDate, CONVERT(Date,SaleDate) FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing ADD SaleDateConverted Date
UPDATE NashvilleHousing SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address Data
SELECT * FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT x.ParcelID, x.PropertyAddress,y.ParcelID,y.PropertyAddress,ISNULL(x.PropertyAddress,y.PropertyAddress) 
FROM PortfolioProject..NashvilleHousing x
JOIN PortfolioProject..NashvilleHousing y
on x.ParcelID = y.ParcelID
AND x.UniqueID <> y.UniqueID
WHERE x.PropertyAddress is null

UPDATE x SET PropertyAddress = ISNULL(x.PropertyAddress,y.PropertyAddress) 
FROM PortfolioProject..NashvilleHousing x
JOIN PortfolioProject..NashvilleHousing y
on x.ParcelID = y.ParcelID
AND x.UniqueID <> y.UniqueID
WHERE x.PropertyAddress is null

--Breaking Out Address Data into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing 

ALTER TABLE NashvilleHousing 
ADD PropertySplit NVARCHAR(255)
UPDATE NashvilleHousing SET PropertySplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE NashvilleHousing 
ADD PropertySplitCity NVARCHAR(255)
UPDATE NashvilleHousing SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


SELECT OwnerAddress FROM PortfolioProject..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress NVARCHAR(255)
UPDATE NashvilleHousing SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity NVARCHAR(255)
UPDATE NashvilleHousing SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing 
ADD OwnerSplitState NVARCHAR(255)
UPDATE NashvilleHousing SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Change Y and N to Yes and No in 'Sold as Vacant' Field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant ='N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing SET 
SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant ='N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing


--Remove Duplicates
WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)

DELETE FROM RowNumCTE
WHERE row_num > 1

WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)

DELETE FROM RowNumCTE
WHERE row_num > 1

--DELETE Unused Columns
SELECT * FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

EXEC sp_rename 'PortfolioProject..NashvilleHousing.PropertySplit', 'PropertyAddress', 'COLUMN'

EXEC sp_rename 'PortfolioProject..NashvilleHousing.SaleDateConverted', 'SaleDate', 'COLUMN'

EXEC sp_rename 'PortfolioProject..NashvilleHousing.PropertySplitCity', 'PropertyCity', 'COLUMN'

EXEC sp_rename 'PortfolioProject..NashvilleHousing.OwnerSplitAddress', 'OwnerAddress', 'COLUMN'

EXEC sp_rename 'PortfolioProject..NashvilleHousing.OwnerSplitCity', 'OwnerCity', 'COLUMN'

EXEC sp_rename 'PortfolioProject..NashvilleHousing.OwnerSplitState', 'OwnerState', 'COLUMN'