---Cleaning Data in SQL Queries

Select *
From [Portfolio Project]..NashVilleHousing

--Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From NashVilleHousing

UPDATE NashVilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashVilleHousing
Add SaleDateConverted Date

UPDATE NashVilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted, CONVERT(Date,SaleDate)
From NashVilleHousing

--Populate Property Address Data

Select *
From NashVilleHousing
where PropertyAddress is null
order by parcelID

Select a.parcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashVilleHousing a
JOIN NashVilleHousing b
	ON a.parcelID = b.parcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashVilleHousing a
JOIN NashVilleHousing b
	ON a.parcelID = b.parcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

Select ParcelID, PropertyAddress
from [Portfolio Project].dbo.NashVilleHousing
where PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)[PropertyAddress]
-- Using SUBSTRING

Select *
From NashVilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM NashVilleHousing

ALTER TABLE NashVilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE NashVilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashVilleHousing
Add PropertySplitCity nvarchar(255);

UPDATE NashVilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From NashVilleHousing


--Breaking out Address into Individual Columns (Address, City, State)[PropertyAddress]
-- Using PARSENAME

Select *
From NashVilleHousing

Select OwnerAddress
From NashVilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From NashVilleHousing


ALTER TABLE NashVilleHousing
Add OwnerSplitAddress nvarchar(255);

UPDATE NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashVilleHousing
Add OwnerSplitCity nvarchar(255);

UPDATE NashVilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashVilleHousing
Add OwnerSplitState nvarchar(255);

UPDATE NashVilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From NashVilleHousing


-- Change 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashVilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From NashVilleHousing

UPDATE NashVilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


Select *
From NashVilleHousing
where SoldAsVacant = null


-- Remove Duplicates


WITH RowNumCTE AS(
Select *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
						UniqueID) row_num
From NashVilleHousing
--Order by ParcelID
)
DELETE
From RowNumCTE
WHERE row_num >1
--ORDER BY PropertyAddress

-- After confirming the values under the row_num column with the query
/* Select *
From RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress
, you can now attach below query
--to the RowNumCTE, to Delete the duplicate values */

--DELETE
--From RowNumCTE
--WHERE row_num >1


-- Delete Unused Columns

Select *
From NashVilleHousing

ALTER TABLE NashVilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE NashVilleHousing
DROP COLUMN SaleDate