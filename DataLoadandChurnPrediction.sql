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


-- Churning Algorithm

select * from complaints;

-- Customer with maximum number of entries in Complaints Table 
--are more likely to churn out
select count(CustomerID), CustomerID  from complaints
GROUP BY CustomerID, ProductID;

-- Customers associated with the Product IDs with maximum numbers of 
-- complaints are likely to churn out
select count(ProductID), ProductID, from complaints GROUP BY ProductID;

-- Customers with NULL Renewal date in Subscription table are more likely
-- to churn out
select count(*) from subscriptions where RenewalDate is NULL;
select count(*) from subscriptions;