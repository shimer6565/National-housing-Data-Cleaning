--National housing data set - Data cleaning

--Showing National housing table

select *
from DataCleaning..NationalHousing;
------------------------------------------------------------------------------------------------------------------------------------------

--Standardizing date format
--Removing time from SaleDate

select SaleDate
from DataCleaning..NationalHousing;

Alter table DataCleaning..NationalHousing
add SaleDateUpdated Date;

Update DataCleaning..NationalHousing
set SaleDateUpdated = Convert(Date,SaleDate);

select SaleDateUpdated 
from DataCleaning..NationalHousing;
------------------------------------------------------------------------------------------------------------------------------------------

--Updating the missing Property address 

select x.ParcelID, x.PropertyAddress, y.ParcelID, y.PropertyAddress, isnull(x.PropertyAddress,y.PropertyAddress)
from DataCleaning..NationalHousing x
join DataCleaning..NationalHousing y
   on x.ParcelID = y.ParcelID
   and x.[UniqueID ] <> y.[UniqueID ]
where x.PropertyAddress is NULL;

update x
set PropertyAddress = isnull(x.PropertyAddress,y.PropertyAddress)
from DataCleaning..NationalHousing x
join DataCleaning..NationalHousing y
   on x.ParcelID = y.ParcelID
   and x.[UniqueID ] <> y.[UniqueID ]
where x.PropertyAddress is NULL;

select PropertyAddress
from DataCleaning..NationalHousing;

------------------------------------------------------------------------------------------------------------------------------------------
--Splitting the PropertyAddress column into street and city for easy usage

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as address,
substring(PropertyAddress, charindex(',', PropertyAddress) + 1 , len(PropertyAddress)) as address
from DataCleaning..NationalHousing;

--creating new column for street names
alter table DataCleaning..NationalHousing
add addressSplitStreet varchar(255);

update DataCleaning..NationalHousing
set addressSplitStreet = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1);

--creating new column for city names
alter table DataCleaning..NationalHousing
add addressSplitCity varchar(255);

update DataCleaning..NationalHousing
set addressSplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1 , len(PropertyAddress));
------------------------------------------------------------------------------------------------------------------------------------------

--Splitting the OwnerAddress column into street, city and state for easy usage

select ownerAddress
from DataCleaning..NationalHousing;

select 
parsename(replace(ownerAddress,',','.'), 3),
parsename(replace(ownerAddress,',','.'), 2),
parsename(replace(ownerAddress,',','.'), 1)
from DataCleaning..NationalHousing;

--creating new column for street names
alter table DataCleaning..NationalHousing
add ownerSplitStreet varchar(255);

update DataCleaning..NationalHousing
set ownerSplitStreet = parsename(replace(ownerAddress,',','.'), 3);

--creating new column for city names
alter table DataCleaning..NationalHousing
add ownerSplitCity varchar(255);

update DataCleaning..NationalHousing
set ownerSplitCity = parsename(replace(ownerAddress,',','.'), 2);

--creating new column for state names
alter table DataCleaning..NationalHousing
add ownerSplitState varchar(255);

update DataCleaning..NationalHousing
set ownerSplitState = parsename(replace(ownerAddress,',','.'), 1);
------------------------------------------------------------------------------------------------------------------------------------------

--Updating the 'Y' and 'N' values to 'Yes' and 'No'

select distinct(SoldAsVacant), count(SoldAsVacant)
from DataCleaning..NationalHousing
group by SoldAsVacant
order by 2 desc;

select SoldAsVacant,
case
   when SoldAsVacant = 'Y' then 'Yes'
   when SoldAsVacant = 'N' then 'No'
   else SoldAsVacant
end
from DataCleaning..NationalHousing;

update DataCleaning..NationalHousing
set SoldAsVacant =
case
   when SoldAsVacant = 'Y' then 'Yes'
   when SoldAsVacant = 'N' then 'No'
   else SoldAsVacant
end
from DataCleaning..NationalHousing;
------------------------------------------------------------------------------------------------------------------------------------------

--Removing duplicates using a CTE
with rowNumCTE as (
select *,
ROW_NUMBER() over(
   partition by ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by 
				   uniqueID
				   ) row_num
from DataCleaning..NationalHousing
)
delete 
from rowNumCTE
where row_num > 1;
------------------------------------------------------------------------------------------------------------------------------------------

--Deleting unused columns

alter table DataCleaning..NationalHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
------------------------------------------------------------------------------------------------------------------------------------------


--CLEANED DATA:

select *
from DataCleaning..NationalHousing;