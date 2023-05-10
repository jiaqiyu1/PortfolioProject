

-----------------On Boarding Task 2 Expense Report Of Property A ---------------------



----Text Part --> [TextDateSet] in Report Builder ---------------------


 SELECT 
	Person.FirstName AS OwnerName,
	CONCAT(A.Number,' ',A.Suburb,' ',A.Region) AS PropertyAddress,

	CONCAT(P.Bedroom,' ',
		(CASE 
			WHEN P.Bedroom =1 THEN 'Bedroom'
			ELSE 'Bedrooms'
		END) ,', ',P.Bathroom,' ',
		(CASE 
			WHEN P.Bathroom =1 THEN 'Bathroom'
			ELSE 'Bathrooms'
		END)

	) AS PropertyDetails,

	CONCAT('$',' ', CONVERT(INT, PRP.Amount),' ',
		(CASE 
			WHEN TPF.Name = 'Weekly'      THEN 'per week'
			WHEN TPF.Name = 'Fortnightly' THEN 'per fortnight'
			ELSE 'per month'
		END)
	 ) AS RentalPayment

 FROM [dbo].[Person] Person
	INNER JOIN [dbo].[OwnerProperty] OP 
		ON OP.OwnerId = Person.Id
	INNER JOIN [dbo].[Property] P
		ON P.Id = OP.PropertyId
	INNER JOIN [dbo].[Address] A
		ON P.AddressId = A.AddressId
	INNER JOIN 	[dbo].[PropertyRentalPayment] PRP
		ON PRP.PropertyId = P.Id
	INNER JOIN [dbo].[TenantPaymentFrequencies] TPF 
		ON PRP.FrequencyType = TPF.Id

 WHERE P.Name = 'Property A' 
 


 -----Table Part --> [DetailTableDateSet] in Report Builder  -----------------------

 --Detail Table: 

 	SELECT 
		Expense,
		Amount,
		Date
	FROM (
		SELECT 
			DISTINCT PE.Description AS Expense,
			CONCAT('$', CONVERT(INT, PE.Amount)) AS Amount,
			--PE.Date,
			CONVERT(VARCHAR(11), PE.Date,106) AS Date,
			ROW_NUMBER() OVER (ORDER BY PE.Date) AS RowNumber
		FROM 
			[dbo].[PropertyExpense] PE
			INNER JOIN [dbo].[Property] P ON PE.PropertyId = P.Id
		WHERE 
			P.Name = 'Property A'
	) T
	WHERE 
		RowNumber <= 3


-----------------------------END-------------------------------------------------------------------------------------

-- This is just Note for recording the logic process as below ------------------------


--  --OwnerName:ABDC

-- SELECT 
--	Person.FirstName AS OwnerName
--	--P.Id,--> 5643
--	--Person.PhysicalAddressId  --> 12722
-- FROM [dbo].[Person] Person
--	INNER JOIN [dbo].[OwnerProperty] OP 
--		ON OP.OwnerId = Person.Id
--	INNER JOIN [dbo].[Property] P
--		ON P.Id = OP.PropertyId
-- WHERE P.Name = 'Property A' 
 

-- --Property Address: 
 

--	SELECT 
--CONCAT(A.Number,' ',A.Suburb,' ',A.Region) AS PropertyAddress
--	FROM [dbo].[Property] P
--	INNER JOIN [dbo].[Address] A
--		ON P.AddressId = A.AddressId
--	WHERE P.Name = 'Property A' 

----Property Details:

--	SELECT 
--		CONCAT(P.Bedroom,' ',
--		(CASE 
--			WHEN P.Bedroom =1 THEN 'Bedroom'
--			ELSE 'Bedrooms'
--		END) ,', ',P.Bathroom,' ',
--		(CASE 
--			WHEN P.Bathroom =1 THEN 'Bathroom'
--			ELSE 'Bathrooms'
--		END)
--			 ) AS PropertyDetails
--	FROM [dbo].[Property] p
--	WHERE P.Name = 'Property A'

	
----Rental Payment:

--	SELECT 
--		CONCAT('$',' ', CONVERT(INT, PRP.Amount),' ',
--					(CASE 
--						WHEN TPF.Name = 'Weekly'      THEN 'per week'
--						WHEN TPF.Name = 'Fortnightly' THEN 'per fortnight'
--						ELSE 'per month'
--					END)
--			  ) AS RentalPayment
--	FROM 
--		[dbo].[PropertyRentalPayment] PRP
--		INNER JOIN [dbo].[TenantPaymentFrequencies] TPF
--			ON PRP.FrequencyType = TPF.Id
--		INNER JOIN [dbo].[Property] P 
--			ON PRP.PropertyId = P.Id
--	WHERE 
--		P.Name = 'Property A'

--),

----Detail Table


--	SELECT 
--		Expense,
--		Amount,
--		Date
--	FROM (
--		SELECT 
--			DISTINCT PE.Description AS Expense,
--			CONCAT('$', CONVERT(INT, PE.Amount)) AS Amount,
--			--PE.Date,
--			CONVERT(VARCHAR(11), PE.Date,106) AS Date,
--			ROW_NUMBER() OVER (ORDER BY PE.Date) AS RowNumber
--		FROM 
--			[dbo].[PropertyExpense] PE
--			INNER JOIN [dbo].[Property] P ON PE.PropertyId = P.Id
--		WHERE 
--			P.Name = 'Property A'
--	) T
--	WHERE 
--		RowNumber <= 3




	
