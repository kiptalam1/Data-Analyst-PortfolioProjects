/*
	cleaning data in sql queries
*/

use PortfolioProject
select *
from PortfolioProject..Nashvillehousing




--standardize date format
select SaleDateConverted, CONVERT(date, SaleDate)
from PortfolioProject..Nashvillehousing

UPDATE Nashvillehousing
set SaleDate = CONVERT(date, SaleDate)

ALTER TABLE Nashvillehousing
ADD SaleDateConverted date;

UPDATE Nashvillehousing
set SaleDateConverted = CONVERT(date, SaleDate)




--Populate property address data
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..Nashvillehousing a
join PortfolioProject..Nashvillehousing b
	on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashvillehousing a
join PortfolioProject..Nashvillehousing b
	on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




--Breaking out the address into individual columns(address, city, state)
	--1. PropertyAddress
select *
from PortfolioProject..Nashvillehousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(propertyAddress)) as city
from PortfolioProject..Nashvillehousing

ALTER TABLE Nashvillehousing
ADD PropertyAddressSplit nvarchar(255);

UPDATE Nashvillehousing
set PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE Nashvillehousing
ADD PropertySplitCity nvarchar(255);

UPDATE Nashvillehousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(propertyAddress)) 




	--2. OwnerAddress
select OwnerAddress
from PortfolioProject..Nashvillehousing


select
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
from PortfolioProject..Nashvillehousing


ALTER TABLE Nashvillehousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE Nashvillehousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)


ALTER TABLE Nashvillehousing
ADD OwnerSplitCity nvarchar(255);

UPDATE Nashvillehousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)


ALTER TABLE Nashvillehousing
ADD OwnerSplitState nvarchar(255);

UPDATE Nashvillehousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)




--Changing Y and N to Yes and No in SoldAsVacant
select distinct SoldAsVacant
from PortfolioProject..Nashvillehousing


select SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END
from PortfolioProject..Nashvillehousing

UPDATE PortfolioProject..Nashvillehousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END




--Remove duplicates
WITH row_numCTE AS (
select *, ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					PropertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
					ORDER BY 
					UniqueID)as row_num
from PortfolioProject..Nashvillehousing
		)

delete
FROM row_numCTE
where row_num > 1
--order by PropertyAddress





--Delete unused columns
SELECT *
From PortfolioProject..Nashvillehousing


ALTER TABLE PortfolioProject..Nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, SaleDate, PropertyAddress