create table customer(
    CustomerID text,
    Gender text,
    DOB date,
    District integer,
    ZIP text,
    StreetID INTEGER
);

select * from customer;

copy customer from 'C:\Users\abhis\OneDrive\Desktop\Python\CustomerDefection\customer.txt' with 
(format csv, header true, delimiter ';')
