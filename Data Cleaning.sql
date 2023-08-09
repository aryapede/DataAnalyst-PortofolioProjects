use portofolio
select * from rumah

--standarisasi format date

select saledatebaru, convert(date, saledate) as tanggal
from rumah 

update rumah
set saledate = convert(date, saledate)

alter table rumah
add saledatebaru date

update rumah
set saledatebaru = convert(date, saledate)

--populate property address data

select * from rumah
--where propertyaddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress, b.PropertyAddress)
from rumah a
join rumah b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
--where a.propertyaddress is null

update a
set PropertyAddress = isnull(a.propertyaddress, b.PropertyAddress)
from rumah a
join rumah b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null

--breaking out address into individual column (address, city, state)

select PropertyAddress from rumah
--where propertyaddress is null
--order by ParcelID

select
substring(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) as address
, substring(propertyaddress, CHARINDEX(',',propertyaddress)+1, len(propertyaddress)) as address
from rumah

alter table rumah
add propertysplitaddress varchar(255)

update rumah
set propertysplitaddress = substring(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1)

alter table rumah
add propertysplitcity varchar(255)

update rumah
set propertysplitcity = substring(propertyaddress, CHARINDEX(',',propertyaddress)+1, len(propertyaddress))

select * from rumah


select owneraddress from rumah
 

select
parsename(replace(owneraddress, ',','.'),3)
, parsename(replace(owneraddress, ',','.'),2)
, parsename(replace(owneraddress, ',','.'),1)
from rumah

alter table rumah
add ownersplitaddress varchar(255)

update rumah
set ownersplitaddress = parsename(replace(owneraddress, ',','.'),3)

alter table rumah
add ownersplitcity varchar(255)

update rumah
set ownersplitcity = parsename(replace(owneraddress, ',','.'),2)

alter table rumah
add ownersplitstate varchar(255)

update rumah
set ownersplitstate = parsename(replace(owneraddress, ',','.'),1)


--change Y and N to Yes and No in "Sold as Vacant" Field

select distinct(soldasvacant), count(soldasvacant)
from rumah
group by SoldAsVacant
order by 2

select soldasvacant, case when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end
from rumah

update rumah
set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end
from rumah

--remove duplicates


with rownumCTE AS(
select *,
row_number() over (
partition by parcelid, 
				propertyaddress,
				saleprice,
				saledate,
				legalreference
				order by
				uniqueid) row_num
from rumah
--order by parcelid
)
select * from rownumCTE 
where row_num > 1
order by propertyaddress

--delete unused columns

select *
from rumah

alter table rumah
drop column owneraddress, taxdistrict, propertyaddress

alter table rumah
drop column saledate