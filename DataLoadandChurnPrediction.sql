drop table if exists customers ;
drop table if exists formula ;
drop table if exists subscriptions ;
drop table if exists delivery ;
drop table if exists complaints ;
drop table if exists credit ;

set DateStyle to 'DMY' ;

-- Customers Table creation

create table customers (
    CustomerID text,
    Gender char(1),
    DOB date,
    District int,
    ZIP int,
    StreetID int
);

-- Loading customers data

copy customers
from PROGRAM
'curl "http://ballings.co/hidden/aCRM/data/chapter6/customers.txt"' with (format csv, header
true, delimiter ";");

select * from customers;

-- Formula Table creation

create table formula (
    FormulaID text,
    FormulaCode smallint,
    FormulaType char(3),
    Duration smallint
);

-- Loading formula data

copy formula
from PROGRAM
'curl "http://ballings.co/hidden/aCRM/data/chapter6/formula.txt"' with (format csv, header
true, delimiter ";");

select * from formula;

-- Subscriptions Table creation

create table subscriptions (
    SubscriptionID text,
    CustomerID text,
    ProductID text,
    Pattern text,
    StartDate date,
    EndDate date,
    NbrNewspapers smallint,
    NbrStart smallint,
    RenewalDate date,
    PaymentType char(2),
    PaymentStatus text,
    PaymentDate date,
    FormulaID text,
    GrossFormulaPrice float,
    NetFormulaPrice float,
    NetNewspaperPrice float,
    ProductDiscount float,
    FormulaDiscount float,
    TotalDiscount float,
    TotalPrice float,
    TotalCredit float
);

copy subscriptions
from PROGRAM
'curl "http://ballings.co/hidden/aCRM/data/chapter6/subscriptions.txt"' with (format csv, header
true, delimiter ";");

select * from subscriptions; 
--WHERE TotalDiscount > 0;


create table delivery (
    DeliveryID text,
    SubscriptionID text,
    DeliveryType char(2),
    DeliveryClass char(3),
    DeliveryContext char(3),
    StartDate date,
    EndDate date
) ;

drop table delivery;

copy delivery
from PROGRAM
'curl "http://ballings.co/hidden/aCRM/data/chapter6/delivery.txt"' with (format csv, header
true, delimiter ";");

-- 100 subscription delivery is impact due to NPA
select * from delivery where DeliveryContext = 'NPA' AND StartDate < '20100105';


-- Complaints

create table complaints (
    ComplaintID text,
    CustomerID text,
    ProductID text,
    ComplaintDate date,
    ComplaintType smallint,
    SolutionType smallint,
    FeedbackType smallint
) ;

copy complaints
from PROGRAM
'curl "http://ballings.co/hidden/aCRM/data/chapter6/complaints.txt"' with (format csv, header
true, delimiter ";");



-- Credit
drop table credit;

create table credit (
    CreditID text,
    SubscriptionID text,
    ActionType char(2),
    ProcessingDate date,
    CreditScore char(3),
    Amount float, --need to look into this one
    NbrNewspapers smallint
) ;

--779 subscriptions received complaint credit but we see 364 customers churn 
-- need to do further deep dive on churn at subscription level
select * from credit left outer join subscriptions on credit.subscriptionid = subscriptions.subscriptionid
where CreditScore = 'COM' AND ProcessingDate < '2010-01-05' ;

copy credit
from PROGRAM
'curl "http://ballings.co/hidden/aCRM/data/chapter6/credit.txt"' with (format csv, header
true, delimiter ";");


-- Churning Algorithm

select * from complaints where complaintDate < '2010-01-05' AND
-- Customer with maximum number of entries in Complaints Table 
--are more likely to churn out
--select count(CustomerID) as NumComplaints, CustomerID  from complaints
--where complaintDate < '2010-01-05'
--GROUP BY CustomerID
--ORDER BY NumComplaints DESC;
customerID IN (
    select distinct customerid 
from (  select customerid 
        from subscriptions 
        where customerid not in (   select customerid 
                                    from subscriptions 
                                    where '2010-01-05' between startdate and enddate ) -- Active Subscriptions
     ) as churnTbl -- Select customerid which do not have an active subscription at 2010-01-05
where customerid not in (select customerid 
                         from (select customerid, min(startdate) ,min(startdate) > '2010-01-05' as AfterReference 
                               from subscriptions group by customerid) as AfterReferenceTbl -- customers who joined after the reference date
                         where AfterReference = True) -- filter out customers who joined after the reference date
);


-- Customers associated with the Product IDs with maximum numbers of 
-- complaints are likely to churn out
select ProductID ,count(ProductID) as ProductCount from complaints 
where complaintDate < '2010-01-05'
-- GROUP BY ProductID;
-- SELECT * from complaints where ProductID = '8' 
-- AND complaintDate < '2010-01-05';
AND customerID IN (
    select distinct customerid 
from (  select customerid 
        from subscriptions 
        where customerid not in (   select customerid 
                                    from subscriptions 
                                    where '2010-01-05' between startdate and enddate ) -- Active Subscriptions
     ) as churnTbl -- Select customerid which do not have an active subscription at 2010-01-05
where customerid not in (select customerid 
                         from (select customerid, min(startdate) ,min(startdate) > '2010-01-05' as AfterReference 
                               from subscriptions group by customerid) as AfterReferenceTbl -- customers who joined after the reference date
                         where AfterReference = True) -- filter out customers who joined after the reference date
)
GROUP BY ProductID;

select productid, count(productid) from subscriptions group by productid;


--Master Table
-- CustomerID
-- ProductID
-- Churnflag
-- SubscriptionCount
-- CustomerLifeTime
-- ProductsperCustomer
-- TotalPrice by Customer


-- Reference Date 2010-01-05
-- These are customers who have churned
select distinct customerid 
from (  select customerid 
        from subscriptions 
        where customerid not in (   select customerid 
                                    from subscriptions 
                                    where '2010-01-05' between startdate and enddate ) -- Active Subscriptions
     ) as churnTbl -- Select customerid which do not have an active subscription at 2010-01-05
where customerid not in (select customerid 
                         from (select customerid, min(startdate) ,min(startdate) > '2010-01-05' as AfterReference 
                               from subscriptions group by customerid) as AfterReferenceTbl -- customers who joined after the reference date
                         where AfterReference = True) ; -- filter out customers who joined after the reference date


-- These are customers who have NOT churned
select distinct customerid 
from (  select customerid 
        from subscriptions 
        where '2010-01-05' between startdate and enddate -- Active Subscriptions
     ) as NotChurnTbl -- Select customerid which do not have an active subscription at 2010-01-05
where customerid not in (select customerid 
                         from (select customerid, min(startdate) ,min(startdate) > '2010-01-05' as AfterReference 
                               from subscriptions group by customerid) as AfterReferenceTbl -- customers who joined after the reference date
                         where AfterReference = True) ; -- filter out customers who joined after the reference date

-- 364 Churn
-- 1004 Not Churn

-- Next Steps
-- Data Engineering to find predictors of Churn