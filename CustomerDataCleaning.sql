drop table if exists customers ;
drop table if exists formula ;
drop table if exists subscriptions ;
drop table if exists delivery ;
drop table if exists complaints ;
drop table if exists credit ;

set DateStyle to 'DMY' ;

-- Customers

create table customers (
    CustomerID text,
    Gender char(1),
    DOB date,
    District int,
    ZIP int,
    StreetID int
);

copy customers
from PROGRAM
'curl "http://ballings.co/hidden/aCRM/data/chapter6/customers.txt"' with (format csv, header
true, delimiter ";");



-- Formula

create table formula (
    FormulaID text,
    FormulaCode smallint,
    FormulaType char(3),
    Duration smallint
);

copy formula
from PROGRAM
'curl "http://ballings.co/hidden/aCRM/data/chapter6/formula.txt"' with (format csv, header
true, delimiter ";");



-- Subscriptions

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



-- Delivery

create table delivery (
    DeliveryID text,
    SubscriptionID text,
    DeliveryType char(2),
    DeliveryClass char(3),
    DeliveryContext char(3),
    StartDate date,
    EndDate date
) ;

copy delivery
from PROGRAM
'curl "http://ballings.co/hidden/aCRM/data/chapter6/delivery.txt"' with (format csv, header
true, delimiter ";");



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

create table credit (
    CreditID text,
    SubscriptionID text,
    ActionType char(2),
    ProcessingDate date,
    CreditScore char(3),
    Amount float, --need to look into this one
    NbrNewspapers smallint
) ;

copy credit
from PROGRAM
'curl "http://ballings.co/hidden/aCRM/data/chapter6/credit.txt"' with (format csv, header
true, delimiter ";");



-- Customer with maximum number of entries in Complaints Table 
-- are more likely to churn out
select count(CustomerID) as NumComplaints, CustomerID  from complaints
GROUP BY CustomerID
ORDER BY NumComplaints DESC;

-- Customers associated with the Product IDs with maximum numbers of 
-- complaints are likely to churn out 
select count(ProductID), ProductID from complaints GROUP BY ProductID;

-- Customers with NULL Renewal date in Subscription table are more likely
-- to churn out
select count(*) from subscriptions where RenewalDate is NULL;
select count(*) from subscriptions;


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

drop table if exists referenceTbl ;
create table referenceTbl as (
    select * from subscriptions where startdate < '2010-01-05'
) ;

-- churn case when logic
create table churnTbl as (
select distinct customerid,
        case when customerid in (
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

        ) then TRUE
             else FALSE
        end as churn
from referenceTbl 
) ;

-- Number of products by customer
select customerid, count(distinct(productid)) from subscriptions group by customerid;

-- Customer Lifetime , this would fail if they had a gap
select customerid, max(enddate) - min(startdate) as CustomerLifetime from subscriptions group by customerid;

-- Number of subscriptions for each customer
select customerid, count(distinct(subscriptionid)) as NumSubscriptions from subscriptions group by customerid;

-- Total Price paid by each customer
select customerid, sum(totalprice) as TotalPaid from subscriptions group by customerid ;

-- Number of Times a customer was credited and Total Amount recieved
select customerid, sum(amount) as TotalCredit, count(creditid) as NumCredits from credit left outer join subscriptions on credit.subscriptionid = subscriptions.subscriptionid
where CreditScore = 'COM' AND ProcessingDate < '2010-01-05' 
group by customerid;


-- Merging churn table with predictors, this table we can use for modeling
select churnTbl.customerid, churn, NumProducts, CustomerLifetime, NumSubscriptions, TotalPaid from churnTbl 
left outer join (select customerid, count(distinct(productid)) as NumProducts
                 from subscriptions 
                 group by customerid) as NumProdTbl
on churnTbl.customerid = NumProdTbl.customerid 
left outer join (select customerid, max(enddate) - min(startdate) as CustomerLifetime 
                 from subscriptions 
                 group by customerid) as CustomerLifetimeTbl
on churnTbl.customerid = CustomerLifetimeTbl.customerid
left outer join (select customerid, count(distinct(subscriptionid)) as NumSubscriptions 
                 from subscriptions 
                 group by customerid) as NumSubscriptionsTbl
on churnTbl.customerid = NumSubscriptionsTbl.customerid 
left outer join (select customerid, sum(totalprice) as TotalPaid 
                 from subscriptions 
                 group by customerid) as TotalPaidTbl
on churnTbl.customerid = TotalPaidTbl.customerid
;

-- creating a model table from the above query for easy access in python
drop table if exists modelTbl ;
create table modelTbl as (
    select churnTbl.customerid, churn, NumProducts, CustomerLifetime, NumSubscriptions, TotalPaid, TotalCredit, NumCredits, NumComplaints from churnTbl 
    left outer join (select customerid, count(distinct(productid)) as NumProducts
                    from subscriptions 
                    group by customerid) as NumProdTbl
    on churnTbl.customerid = NumProdTbl.customerid 
    left outer join (select customerid, max(enddate) - min(startdate) as CustomerLifetime 
                    from subscriptions 
                    group by customerid) as CustomerLifetimeTbl
    on churnTbl.customerid = CustomerLifetimeTbl.customerid
    left outer join (select customerid, count(distinct(subscriptionid)) as NumSubscriptions 
                    from subscriptions 
                    group by customerid) as NumSubscriptionsTbl
    on churnTbl.customerid = NumSubscriptionsTbl.customerid 
    left outer join (select customerid, sum(totalprice) as TotalPaid 
                    from subscriptions 
                    group by customerid) as TotalPaidTbl
    on churnTbl.customerid = TotalPaidTbl.customerid
    left outer join (select customerid, sum(amount) as TotalCredit, count(creditid) as NumCredits 
                     from credit 
                     left outer join subscriptions 
                     on credit.subscriptionid = subscriptions.subscriptionid
                     where CreditScore = 'COM' AND ProcessingDate < '2010-01-05' 
                     group by customerid) as creditTbl
    on churnTbl.customerid = creditTbl.customerid
    left outer join (select customerid, count(complaintid) as NumComplaints  
                     from complaints 
                     where complaintDate < '2010-01-05'
                     group by customerid) as NumComplaintsTbl
    on churnTbl.customerid = NumComplaintsTbl.customerid
) ;

update modelTbl set totalcredit = 0
where totalcredit is null;

update modelTbl set numcredits = 0
where numcredits is null;

update modelTbl set numcomplaints = 0
where numcomplaints is null ;

alter table modelTbl
    add column badproduct boolean ;

update modelTbl set badproduct = TRUE
where customerid in (select customerid from subscriptions where productid = '4') ;

update modelTbl set badproduct = FALSE
where badproduct is null ;


-- remove customerid before sending to python

alter table modeltbl
    drop column customerid ;


select * from modelTbl ;