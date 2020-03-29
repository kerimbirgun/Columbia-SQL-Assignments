-- APAN 5310: SQL & RELATIONAL DATABASES

-------------------------------------------------------------------------------

/*
 * The bank data dictionary
 * ------------------------
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

-------------------------------------------------------------------------------

/*
 * QUESTION 1
 * --------------------
 *
 * - Provide the SQL statement that lists all the states in which the customers
 *   live and the account type (C, M, S) in greatest use by those customers.
 * - The columns should be labeled: 'State' and 'Greatest_Acct_Type'.
 * - Greatest use is defined by the number of transactions incurred for the 
 *   given account type
 * - If there are ties for the top account type, all tied account types must be 
 *   listed in one column separated by commas.
 * - For example, if state ZZ had 
 *     Checking accounts with 200 transactions
 *     Money Market acccounts with 200 transactions
 *     Savings accounts with 100 transactions
 *   Then, the output for this state should be: 'ZZ', 'C,M' since C & M are tied
 *     for the top spot with 200 transactions.    
 * - Order alphabetically by state.
 *
 */


CREATE VIEW state_ranks AS
    SELECT c.state,
           a.acct_type,
           count(t.txn_id) count
      FROM accts a
           JOIN
           custs c ON c.cust_id = a.cust_id
           JOIN
           txns t ON a.acct_id = t.acct_id
     GROUP BY c.state,
              a.acct_type;


SELECT state State, 
	   group_concat(acct_type,",") Greatest_Acct_Type
FROM 
	(SELECT state,acct_type
	FROM
		(SELECT state,acct_type, 
			RANK () 
			OVER (PARTITION by state order by count DESC) rnk
			FROM state_ranks) where rnk = 1) 
	GROUP BY state 
	ORDER BY state ASC 
 


 * QUESTION 2 
 * --------------------
 *
 * - Use four Common Table Expressions (CTEs) to help produce a report showing
 *     customers grouped by the first three digits of their zip code (zip3)
 *     and the number of customers by age groups.
 * - The columns should be labeled: 
 *     'Zip3', 
 *     'Customers_Age_0_to_35', 
 *     'Customers_Age_36_to_50', 
 *     'Customers_Age_51_and_Over',
 *     'Total_Customers'
 * - Each CTE (c1, c2, c3, c4) should show the zip3 code along with one of 
 *   the customer columns.
 * - There should be no NULL values in the final output. Replace with zeroes.
 * - Order by total customers (greatest to least).
 *
 */


CREATE VIEW CTE1 AS
    SELECT cust_id,
           zip,
           date('now') - dob - (strftime('%m %d', 'now') < strftime('%m %d', dob) ) AS age
      FROM custs c;


CREATE VIEW CTE2 AS
    SELECT substr(zip, 0, 4) zip3,
           SUM(COALESCE("<=35", 0) ) AS Customers_Age_0_to_35,
           SUM(COALESCE("36-50", 0) ) AS Customers_Age_36_to_50,
           SUM(COALESCE(">=51", 0) ) AS Customers_Age_51_and_Over
      FROM (
               SELECT cust_id,
                      zip,
                      CASE WHEN age <= 35 THEN 1 END "<=35",
                      CASE WHEN age >= 51 THEN 1 END ">=51",
                      CASE WHEN age > 35 AND 
                                age < 51 THEN 1 END "36-50"
                 FROM CTE1
           )
     GROUP BY zip3;


SELECT zip3,
       Customers_Age_0_to_35,
       Customers_Age_36_to_50,
       Customers_Age_51_and_Over,
       Customers_Age_0_to_35 + Customers_Age_36_to_50 + Customers_Age_51_and_Over AS Total_Customers
  FROM CTE2
 ORDER BY Total_Customers DESC;




