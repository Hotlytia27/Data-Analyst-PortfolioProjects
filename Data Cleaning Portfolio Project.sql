/*

Cleaning Data in SQL  Queries

*/

Select *
From NashvilleHousing

...........................................................................................................

-- Standardize Date Format (Standarisasi Format Tanggal)

Select SaleDateConverted, Convert(date, saledate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(date, saledate)

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(date, saledate)


...........................................................................................................

-- Populate Property Addres Data (Mengisi Data Alamat Properti)

Select *
From NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	 on a.ParcelID =b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	 on a.ParcelID =b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


...........................................................................................................

-- Breaking out Address into Individual Colums (Address, City, State)

Select PropertyAddress
From NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address
From NashvilleHousing


Alter table NashvilleHousing
Add  PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1)

Alter table NashvilleHousing
Add  PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))


Select *
From NashvilleHousing



Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing

Alter table NashvilleHousing
Add  OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
Add  OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add  OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From NashvilleHousing


...........................................................................................................

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldasVacant), Count(SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldasVacant,
Case when SoldasVacant = 'Y' then 'Yes'
	 when SoldasVacant = 'N' then 'No'
	 Else SoldasVacant
	 end
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case when SoldasVacant = 'Y' then 'Yes'
	 when SoldasVacant = 'N' then 'No'
	 Else SoldasVacant
	 end


...........................................................................................................

-- Remove Duplicates

with RowNumCTE AS(
Select *,
	Row_Number() over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num
							
From NashvilleHousing
)
Delete
From RowNumCTE
where row_num > 1
order by PropertyAddress
--where row_num > 1



...........................................................................................................

-- Delete Unused Column

Select *
From NashvilleHousing

Alter table NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table NashvilleHousing
Drop column SaleDate

