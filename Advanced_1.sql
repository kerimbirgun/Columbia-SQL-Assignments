-- APAN 5310: SQL & RELATIONAL DATABASES

/*
 * The bank data dictionary

 *
 * The 'bank' database has been structured to represent a normalized relational
 * database comprised of three tables containing data for a fictitious
 * consumer bank:
 *
 *   1. custs - a table of customers of our bank
 *        a. cust_id - the unique customer number of each customer
 *        b. first_name - the first name of the customer
 *        c. last_name - the last name of the customer
 *        d. street - the street address of the customer
 *        e. city - the city of residence of the customer
 *        f. state - the US state (plus DC) of residence of the customer
 *        g. zip - the five digit zip code of residence of the customer
 *        h. dob - the date of birth of the customer (yyyy-mm-dd)
 *   2. accts - a table of bank accounts owned by our customers
 *        a. acct_id - the unique account number for each account
 *        b. acct_type - the account type (S = savings, C = checking, M = money mkt)
 *        c. cust_id - the customer number of customer who owns the account
 *   3. txns - a table of transactions performed by our customers
 *        a. txn_id - a unique identifier of each transaction
 *        b. txn_type - the type of transaction (D = deposit, W = withdrawal)
 *        c. txn_dt - the date and time of transaction (yyyy-mm-dd HH:MM)
 *        d. amt - the dollar amount of the transaction; withdrawals are shown as
 *                 positive amounts but should be deducted from any balance calcs
 *        e. acct_id - the account number to which the amout was added or
 *                     from which the amount was subtracted
 *
 */


/*
 * QUESTION 1 
 * --------------------
 *
 * - Provide the SQL statement that lists all the customers living in the state
 *   of New York (NY) with more than one account.
 * - Order alphabetically by city.
 * - Label the columns as 'Full_Name' (concatenate first and last name with
 *   a space in between), 'City', 'DOB';
 

SELECT c.first_name || ' ' || c.last_name AS Full_Name,
       c.city AS City,
       c.dob AS DOB
  FROM custs c
       JOIN
       accts a ON c.cust_id = a.cust_id
 WHERE state = "NY"
 GROUP BY Full_Name
HAVING count(a.acct_type) > 1
 ORDER BY City;



 * QUESTION 2 
 * --------------------
 *
 * - Provide the SQL statement that returns the average deposit amount
 *   (rounded to 2 dp) for customers older than 35 years of age as of 12/31/2019
 *   (including those whose dob falls on New Year's Eve).
 * - Customers must have total deposit amounts in 2019 greater than $9,999.99.
 * - Group the results by each age (35, 36, ..., 60), including ages for which no
 *   selected customers are of that age.
 * - Do not include withdrawal amounts in your average, just the gross deposits.
 * - Label the columns as 'Age', 'Avg_Dep_Amt;



SELECT strftime('%Y %m %d', date('2020-01-01') ) - c.dob AS age,
       round(avg(t.amt), 2) Avg_Dep_Amt
  FROM custs c
       JOIN
       accts a ON c.cust_id = a.cust_id
       JOIN
       txns t ON a.acct_id = t.acct_id
 WHERE age >= 35 AND 
       t.acct_id IN (
           SELECT t.acct_id
             FROM txns t
            GROUP BY t.acct_id
           HAVING t.amt > 9999.99
       )
AND 
       t.txn_type = "D"
 GROUP BY age;





 * QUESTION 3 
 * --------------------
 *
 * - Provide the SQL statement that returns the number of WD transactions, the
 *   total WD amounts of those transactions, grouped by month of transaction.
 * - Include only customers living in the 25 cities most represented in the db. That
 *   is, the 25 cities where the most customers live.
 * - Include only checking (C) and savings (S) accounts.
 * - Include all months.
 * - Label the columns as 'Month', 'Number_WDs', 'Total_WD_Amt';



SELECT strftime("%m", t.txn_dt) Month,
       count(t.txn_id) Number_WDs,
       round(sum(amt), 0) Total_WD_Amt
  FROM custs c
       JOIN
       accts a ON c.cust_id = a.cust_id
       JOIN
       txns t ON a.acct_id = t.acct_id
 WHERE c.city IN (
           SELECT c.city
             FROM custs c
            GROUP BY c.city
            ORDER BY count(c.cust_id) DESC
            LIMIT 25
       )
AND 
       a.acct_type IN ("C", "S") AND 
       t.txn_type = "W"
 GROUP BY Month;


/*
 * QUESTION 4 
 * --------------------
 *
 * - Provide the SQL statement that returns for selected customers and accounts in the
 *   Pacific coast states (WA, OR, CA, AK, HI), the minimum starting balance
 *   on 1/1/2019 00:00 to avoid having an overdrawn account as of end of day 9/30/2019.
 * - There must be at least 1.05x the overdrawn amount in the account to keep the
 *   account active on 10/1/2019.
 * - Include only customers who have a negative balance at that time.
 * - Label the columns as 'Customer_ID', 'State', 'Acct_Num', 'Acct_Type',
 *   'Net_Txn_Amt_AsOf_0930', 'Req_Min_Bal_On_0101'.
 * - Order the results by Req_Min_Bal_On_0101 (largest to smallest).
 * - For example, let's say a customer (acct num 0000) has a savings account with
 *   net transaction amount of -2,500 by 9/30. Then, the output would be:
 *     0000, CA, A99999, S, -2500, 2625;


create view "derivative" as 
 SELECT c.cust_id,
                  c.state,
                  t.acct_id,
                  a.acct_type,
                  t.txn_type,
                  t.amt amt
          FROM txns t left join accts a ON a.acct_id = t.acct_id
          left join custs c on c.cust_id = a.cust_id
            WHERE strftime("%Y %m %d %H %M", txn_dt) BETWEEN "2019 01 01 00 00" AND "2019 09 30 23 59" 
            and  state IN ('WA', 'OR', 'CA', 'AK', 'HI');


SELECT cust_id Customer_ID,
       state State,
       acct_id Acct_Num,
       acct_type Acct_Type,
       round( (amt * (txn_type = 'D') - amt * (txn_type = 'W') ), 0) AS Net_Txn_Amt_AsOf_0930,
       round( ( -1.05) * (amt * (txn_type = 'D') - amt * (txn_type = 'W') ) ) Req_Min_Bal_On_0101
  FROM derivative
 GROUP BY Acct_Num
HAVING Net_Txn_Amt_AsOf_0930 < 0
 ORDER BY Req_Min_Bal_On_0101 DESC;



