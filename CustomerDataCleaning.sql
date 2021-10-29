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


select * from customers limit 5;
select * from formula limit 5;
select * from subscriptions limit 5;
select * from delivery limit 5;
select * from complaints limit 5;
select * from credit limit 5;