use rumah
select * from rumah

--1. standarisasi format date

select saledatebaru
from rumah 

alter table rumah
add saledatebaru date

update rumah
set saledatebaru = convert(date, saledate)

--2. Mengisi data kolom propertyaddress yang kosong (NULL)

select * from rumah
--where propertyaddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress, b.PropertyAddress) as propertyaddressnew
from rumah a
join rumah b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null

update a
set PropertyAddress = isnull(a.propertyaddress, b.PropertyAddress)
from rumah a
join rumah b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null

--3. memecah alamat menjadi individual column (address, city)

select PropertyAddress from rumah

select
substring(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) as address
, substring(propertyaddress, CHARINDEX(',',propertyaddress)+1, len(propertyaddress)) as city
from rumah

alter table rumah
add propertysplitaddress varchar(255)

alter table rumah
add propertysplitcity varchar(255)

update rumah
set propertysplitaddress = substring(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1)

update rumah
set propertysplitcity = substring(propertyaddress, CHARINDEX(',',propertyaddress)+1, len(propertyaddress))

select * from rumah

--4. memecah alamat owner menjadi individual column (address, city, state)

select owneraddress from rumah
 
select
parsename(replace(owneraddress, ',','.'),3) as address
, parsename(replace(owneraddress, ',','.'),2) as city
, parsename(replace(owneraddress, ',','.'),1) as state
from rumah

alter table rumah
add ownersplitaddress varchar(255)

alter table rumah
add ownersplitcity varchar(255)

alter table rumah
add ownersplitstate varchar(255)

update rumah
set ownersplitaddress = parsename(replace(owneraddress, ',','.'),3)

update rumah
set ownersplitcity = parsename(replace(owneraddress, ',','.'),2)

update rumah
set ownersplitstate = parsename(replace(owneraddress, ',','.'),1)


--5.mengubah Y and N to Yes and No in "Sold as Vacant" Field

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

--6. removing duplicates dengan CTE's

with rownumCTE AS(

select *, row_number() over (
partition by parcelid, 
				propertyaddress,
				saleprice,
				saledate,
				legalreference
				order by
				uniqueid) as row_num
from rumah
--order by parcelid
)
delete from rownumCTE 
where row_num > 1
--order by propertyaddress


--7. delete unused columns

select *
from rumah

alter table rumah
drop column owneraddress, taxdistrict, propertyaddress, saledate

