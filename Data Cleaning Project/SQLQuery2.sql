-- Standardize Date Format


Select saleDate, CONVERT(Date,SaleDate)     --original
From Portfolio.dbo.NashvilleHousing$


Update Portfolio.dbo.NashvilleHousing$      --updated
SET SaleDate = CONVERT(Date,SaleDate)

---------------------------------------------------------------------------------------------------

-- Populate Property Address data where it is null

Select *
From Portfolio.dbo.NashvilleHousing$
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio.dbo.NashvilleHousing$ a
JOIN Portfolio.dbo.NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio.dbo.NashvilleHousing$ a
JOIN Portfolio.dbo.NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

select
substring(propertyaddress,1,4) from Portfolio.dbo.NashvilleHousing$

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From Portfolio.dbo.NashvilleHousing$
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From Portfolio.dbo.NashvilleHousing$


ALTER TABLE Portfolio.dbo.NashvilleHousing$
Add PropertySplitAddress Nvarchar(255);

Update Portfolio.dbo.NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Portfolio.dbo.NashvilleHousing$
Add PropertySplitCity Nvarchar(255);

Update Portfolio.dbo.NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From Portfolio.dbo.NashvilleHousing$

-----------------------------------------------------------------------------------------------------------------


-- Doing th same thing  for owner adress but this time we have three things we need to seperate like address,
-- city ,state


Select OwnerAddress
From Portfolio.dbo.NashvilleHousing$
where OwnerAddress is not null


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Portfolio.dbo.NashvilleHousing$
where OwnerAddress is not null



ALTER TABLE Portfolio.dbo.NashvilleHousing$
Add OwnerSplitAddress Nvarchar(255);

Update Portfolio.dbo.NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Portfolio.dbo.NashvilleHousing$
Add OwnerSplitCity Nvarchar(255);

Update Portfolio.dbo.NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Portfolio.dbo.NashvilleHousing$
Add OwnerSplitState Nvarchar(255);

Update Portfolio.dbo.NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

---------------------------------------------------------------------------------------------------

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio.dbo.NashvilleHousing$
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Portfolio.dbo.NashvilleHousing$


Update Portfolio.dbo.NashvilleHousing$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


---------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, 
							SaleDate,LegalReference
				            ORDER BY UniqueID) as row_num From Portfolio.dbo.NashvilleHousing$)


Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

---------------------------------------------------------------------------------------------------
-- Delete Unused Columns

ALTER TABLE Portfolio.dbo.NashvilleHousing$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate