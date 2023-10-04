select *
From Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning

-- Filling Property Address blanks 

select PropertyAddress
From Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning
where PropertyAddress is null


select x.UniqueID,x.ParcelID,y.UniqueID,y.ParcelID ,x.PropertyAddress, y.PropertyAddress, ISNULL(x.propertyaddress,y.PropertyAddress)
From Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning x
join Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning y
on x.ParcelID = y.ParcelID
and 
x.UniqueID <> y.UniqueID
where x.PropertyAddress is null


Update x
Set PropertyAddress= ISNULL(x.propertyaddress,y.PropertyAddress)
From Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning x
join Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning y
on x.ParcelID = y.ParcelID
and 
x.UniqueID <> y.UniqueID
where x.PropertyAddress is null


-- Breaking out Property address according to Address, City

select PropertyAddress
From Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning


select 
SUBSTRING(propertyaddress, 1, CHARINDEX(';', PropertyAddress) -1) as Property_Address
,SUBSTRING(propertyaddress, CHARINDEX(';', PropertyAddress ) + 1, LEN(propertyaddress)) as Property_City
From Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning

Alter Table Nashville_Housing_Data_Data_Cleaning
add Property_Address varchar(255)

Alter Table Nashville_Housing_Data_Data_Cleaning
add Property_City varchar(255)

Update Nashville_Housing_Data_Data_Cleaning
Set Property_Address= SUBSTRING(propertyaddress, 1, CHARINDEX(';', PropertyAddress) -1)

Update Nashville_Housing_Data_Data_Cleaning
Set Property_City= SUBSTRING(propertyaddress, CHARINDEX(';', PropertyAddress ) + 1, LEN(propertyaddress))

select *
From Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning


-- Breaking out Owner's Address into Address, City, State

select OwnerAddress
From Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning

Select 
PARSENAME( Replace(owneraddress,';','.'),3) as Owner_Address,
PARSENAME( Replace(owneraddress,';','.'),2) as Owner_City,
PARSENAME( Replace(owneraddress,';','.'),1) as Owner_State
From Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning

Alter Table Nashville_Housing_Data_Data_Cleaning
add Owner_Address varchar(255)

Alter Table Nashville_Housing_Data_Data_Cleaning
add Owner_City varchar(255)

Alter Table Nashville_Housing_Data_Data_Cleaning
add Owner_State varchar(255)

Update Nashville_Housing_Data_Data_Cleaning
Set Owner_Address = PARSENAME( Replace(owneraddress,';','.'),3)

Update Nashville_Housing_Data_Data_Cleaning
Set Owner_City = PARSENAME( Replace(owneraddress,';','.'),2)

Update Nashville_Housing_Data_Data_Cleaning
Set Owner_State = PARSENAME( Replace(owneraddress,';','.'),1) 

select *
From Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning

-- Change Y, N with Yes and No in SoldAsVacant column

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
From Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning
group by SoldAsVacant

select SoldAsVacant,
Case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 Else SoldAsVacant
	 End
From Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning

Update Nashville_Housing_Data_Data_Cleaning
set SoldAsVacant= Case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 Else SoldAsVacant
	 End

-- Remove Duplicate
With RemoveD as(
select *, ROW_NUMBER() over 
	(Partition by
				  ParcelID, Propertyaddress,saledate,saleprice,legalreference 
				  Order By UniqueID) as row_no
From Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning

)

--select *
--From RemoveD
--where row_no>1
--order by LandUse

Delete
From RemoveD
where row_no>1

-- Deleting Unnecessary column

Alter Table Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning
Drop column Propertyaddress,Owneraddress,Taxdistrict

--- Final Table

select *
From Nashvilla_Housing.dbo.Nashville_Housing_Data_Data_Cleaning
Order by LandUse





