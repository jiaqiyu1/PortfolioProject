
-----On Boarding Task 1 ANswer the following questions -----------------------------


--a.Display a list of all property names and their property id¡¦s for Owner Id: 1426. 

SELECT 
	P.Name AS PropertyName,
	OwnerP.PropertyId
FROM [dbo].[OwnerProperty] OwnerP
	INNER JOIN [dbo].[Property] P
		ON OwnerP.PropertyId = P.Id
WHERE OwnerP.OwnerId = 1426 


--b.Display the CURRENT home value for each property in question a). 

SELECT 
	P.Name AS PropertyName,
	OwnerP.PropertyId,
	PFinance.CurrentHomeValue
FROM [dbo].[OwnerProperty] OwnerP
	LEFT JOIN [dbo].[Property] P
		ON OwnerP.PropertyId = P.Id
	LEFT JOIN [dbo].[PropertyFinance] PFinance
		ON OwnerP.PropertyId= PFinance.PropertyId
WHERE 
	1=1
	AND OwnerP.OwnerId = 1426 
ORDER BY 1


/*
c. For each property in question a), return the following:                                                                      
	i. Using rental payment amount, rental payment frequency,
		tenant start date and tenant end date to write a query 
		that returns the sum of all payments from start date to end date. 

	ii.Display the yield. 

*/


SELECT 
	P.Name AS PropertyName,
	OwnerP.PropertyId,
	TPaymentFrequencies.Name AS PaymentFrequency,
	PFinance.CurrentHomeValue,
	PFinance.Mortgage,
	PFinance.TotalExpense,
	SUM(
		CASE 
			WHEN TPaymentFrequencies.Name = 'Weekly' 
				THEN (DATEDIFF(DAY, TenantP.StartDate, TenantP.EndDate) / 7.0) * TenantP.PaymentAmount
			WHEN TPaymentFrequencies.Name = 'Fortnightly' 
				THEN (DATEDIFF(DAY, TenantP.StartDate, TenantP.EndDate) / 14.0) * TenantP.PaymentAmount
			WHEN TPaymentFrequencies.Name = 'Monthly' 
				THEN DATEDIFF(MONTH, TenantP.StartDate, TenantP.EndDate) * TenantP.PaymentAmount
		END 
	) AS TotalPaymentAmount,

	(
		SUM(
			CASE 
				WHEN TPaymentFrequencies.Name = 'Weekly' 
					THEN (DATEDIFF(DAY, TenantP.StartDate, TenantP.EndDate) / 7.0) * TenantP.PaymentAmount
				WHEN TPaymentFrequencies.Name = 'Fortnightly' 
					THEN (DATEDIFF(DAY, TenantP.StartDate, TenantP.EndDate) / 14.0) * TenantP.PaymentAmount
				WHEN TPaymentFrequencies.Name = 'Monthly' 
					THEN DATEDIFF(MONTH, TenantP.StartDate, TenantP.EndDate) * TenantP.PaymentAmount
			END 
		) - PFinance.TotalExpense - PFinance.Mortgage
	) / (PFinance.CurrentHomeValue) * 100 AS Yield

FROM [dbo].[OwnerProperty] OwnerP
	INNER JOIN [dbo].[Property] P
		ON OwnerP.PropertyId = P.Id
	INNER JOIN [dbo].[TenantProperty] TenantP
		ON OwnerP.PropertyId = TenantP.PropertyId
	INNER JOIN [dbo].[TenantPaymentFrequencies] TPaymentFrequencies
		ON TenantP.PaymentFrequencyId = TPaymentFrequencies.Id
	INNER JOIN [dbo].[PropertyFinance] PFinance
		ON OwnerP.PropertyId = PFinance.PropertyId
WHERE OwnerP.OwnerId = 1426 
GROUP BY 
	P.Name,
	OwnerP.PropertyId,
	TPaymentFrequencies.Name,
	PFinance.CurrentHomeValue,
	PFinance.TotalExpense,
	PFinance.Mortgage
ORDER BY PropertyName, PaymentFrequency




--d.Display all the jobs available

SELECT 
	J.Id,
	J.JobDescription,
	JStatus.Status
FROM [dbo].[Job] J
	INNER JOIN [dbo].[JobStatus] JStatus
		ON J.JobStatusId = JStatus.Id
WHERE 
	1=1
	AND JStatus.Id IN (1,2,3)
	AND J.JobEndDate IS NULL
	AND J.JobStartDate IS NOT NULL


/*
e. Display all property names, 
	current tenants first and last names 
	and rental payments per week/ fortnight/month for the properties in question a). 

*/

SELECT 
	P.Name AS PropertyName,
	OwnerP.PropertyId,
	 Person.FirstName AS TenantFirstName,
	 Person.LastName AS TenantLastName,
	 TPaymentFrequencies.Name AS PaymentFrequency,
	 TenantP.PaymentAmount AS RentalPayment

FROM [dbo].[Person] Person
	INNER JOIN [dbo].[Tenant] Tenant
		ON Person.Id = Tenant.Id
	INNER JOIN [dbo].[TenantProperty] TenantP
		ON Tenant.Id = TenantP.TenantId
	INNER JOIN [dbo].[Property] P
		ON TenantP.PropertyId = P.Id
	INNER JOIN [dbo].[OwnerProperty] OwnerP
		ON OwnerP.PropertyId = P.Id
	INNER JOIN [dbo].[TenantPaymentFrequencies] TPaymentFrequencies
		ON TenantP.PaymentFrequencyId =TPaymentFrequencies.Id
	INNER JOIN [dbo].[PropertyFinance] PFinance
		ON OwnerP.PropertyId= PFinance.PropertyId
WHERE 
	1=1
	AND OwnerP.OwnerId = 1426 
GROUP BY 
	 P.Name,
	 OwnerP.PropertyId,
	 Person.FirstName, 
	 Person.LastName, 
	 TPaymentFrequencies.Name,
	 TenantP.PaymentAmount
ORDER BY 1,4

		

