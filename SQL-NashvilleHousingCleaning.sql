select * from portfolioproject.dbo.NashvilleHousing
=========================================================================================
-- standardize date format

select SaleDateConverted,CONVERT(Date,SaleDate)
from portfolioproject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date; 

update NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate)

=========================================================================================

-- Populate property address data
--property address was compared against parcelid wherein the add which was null for one row and null for other for the similar parcelid 
was replicted. We thought of doing selfjoin in order to replecate the same address for similar parcelid. join was done based of parcelid 
and uniqueid

select PropertyAddress from portfolioproject.dbo.NashvilleHousing
-- where propertyaddress is null

select a.parcelid,a.propertyaddress, b.parcelid, b.propertyaddress,isnull(a.propertyaddress,b.propertyaddress)
from portfolioproject.dbo.NashvilleHousing a 
join portfolioproject.dbo.NashvilleHousing b
on a.parcelid = b.parcelid
and a.[uniqueid]<>b.[uniqueid]
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from portfolioproject.dbo.NashvilleHousing a 
join portfolioproject.dbo.NashvilleHousing b
on a.parcelid = b.parcelid
and a.[uniqueid]<>b.[uniqueid]
where a.propertyaddress is null

=========================================================================================

-- Breaking out address into 3 different columns (Address, city, state), used substring and instring to split

select PropertyAddress from portfolioproject.dbo.NashvilleHousing

select substring(propertyaddress,1,charindex(',',propertyaddress)-1)as Address, 
substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) as Address
from portfolioproject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255); 

update NashvilleHousing
set PropertySplitAddress = substring(propertyaddress,1,charindex(',',propertyaddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255); 

update NashvilleHousing
set PropertySplitCity = substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress))

=========================================================================================
-- Breaking out owneraddress into 3 different columns (Address, city, state),Used Parsename and replace function. This is lot more easeier than
using substring and instring. Parsename and replace should be used in backward direction that is 3,2,1 in order to split add,city and state

select owneraddress from portfolioproject.dbo.NashvilleHousing

select Parsename(Replace(OwnerAddress,',','.'),3) 
 ,Parsename(Replace(OwnerAddress,',','.'),2)
 ,Parsename(Replace(OwnerAddress,',','.'),1)
from portfolioproject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255); 

update NashvilleHousing
set OwnerSplitAddress = Parsename(Replace(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255); 

update NashvilleHousing
set OwnerSplitCity = Parsename(Replace(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255); 

update NashvilleHousing
set OwnerSplitState = Parsename(Replace(OwnerAddress,',','.'),1)

select * from portfolioproject.dbo.NashvilleHousing

=========================================================================================

-- change Y and N to Yes and No in "SoldAs Vacant" column
-- to update this we have first used case by statement to derive change. Then the output of case is then used to update.
------------
select distinct SoldAsVacant,count (SoldAsVacant)
from portfolioproject.dbo.NashvilleHousing
group by SoldAsVacant
order by count(SoldAsVacant) asc
------------
select SoldAsVacant 
,case 
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from portfolioproject.dbo.NashvilleHousing
------------
Update portfolioproject.dbo.NashvilleHousing
set SoldAsVacant = case 
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
------------
=========================================================================================
--- Remove Duplicates
used Partition function to identify dupe rows.CTE function and then Window function to remove dupes

identify dupe
-------------
with RowNumCTE as(
select *,
Row_number() over(
Partition by ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
Order by UniqueID) row_num
from portfolioproject.dbo.NashvilleHousing
-- order by ParcelID
)
select * from RowNumCTE where row_num > 1
order by PropertyAddress

delete dupe
-----------
with RowNumCTE as(
select *,
Row_number() over(
Partition by ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
Order by UniqueID) row_num
from portfolioproject.dbo.NashvilleHousing
)
Delete from RowNumCTE where row_num > 1

=========================================================================================

-- Delete unused columns
-- used alter and drop function to delete the unused columns from the table.

select * from portfolioproject.dbo.NashvilleHousing

alter table portfolioproject.dbo.NashvilleHousing
drop column PropertyAddress,OwnerAddress,TaxDistrict

alter table portfolioproject.dbo.NashvilleHousing
drop column SaleDate