-- APAN 5310: SQL & RELATIONAL DATABASES




/*
 * QUESTION 1 
 * --------------------
 *
 * Provide the SQL statement that returns from the table 'idols', the stage names
 * of all the members of the group (grp) 'Twice'. Order the results by their stage 
 * names in alphabetical order (A to Z).
 *
 */


select stage_name
  from idols
 where grp = 'Twice'
 ORDER BY stage_name asc;
-- END ANSWER 1 --


/*
 * QUESTION 2 (10 points)
 * --------------------
 *
 * Provide the SQL statement that returns from the table 'idols', the full names,
 * stage names, and dates of birth (dob) of all the members of the group 'BTS'. 
 * Order the results by age (oldest to youngest).
 *
 */



SELECT full_name,
       stage_name,
       dob
  FROM idols
 WHERE grp = "BTS"
 ORDER BY dob ASC;


 * QUESTION 3 
 * --------------------
 *
 * Provide the SQL statement that returns from the table 'idols', the stage names of
 * the twenty youngest female solo performers. A solo performer is indicated by
 * his/her group being NULL. Order the results reverse-alphabetically (Z to A)
 * by stage name.
 *
 */


SELECT stage_name
  FROM idols
 WHERE gender = "F" AND 
       grp IS NULL
 ORDER BY dob DESC
 LIMIT 20;



 * QUESTION 4 
 * --------------------
 *
 * Provide the SQL statement that returns from the table 'idols', the full names,
 * stage names, and dates of birth of all the members of groups beginning with the
 * letter 'S', immediately followed by a vowel ('a', 'e', 'i', 'o', 'u'). Order
 * the results alphabetically first by group and then by full name.
 *
 */


SELECT full_name,
       stage_name,
       dob
  FROM idols
 WHERE full_name LIKE "Sa%" OR 
       full_name LIKE "Se%" OR 
       full_name LIKE "Si%" OR 
       full_name LIKE "So%" OR 
       full_name LIKE "Su%"
 ORDER BY grp,
          full_name;



 * QUESTION 5 
 * --------------------
 *
 * Using the same criteria from Question 4, what is the stage name of the 
 * fifth oldest idol from that dataset?
 *
 */



SELECT stage_name
  FROM idols
 WHERE full_name LIKE "Sa%" OR 
       full_name LIKE "Se%" OR 
       full_name LIKE "Si%" OR 
       full_name LIKE "So%" OR 
       full_name LIKE "Su%"
 ORDER BY dob ASC
 LIMIT 1 OFFSET 4;




 * QUESTION 6 
 * --------------------
 *
 * Provide the SQL statement that returns from the table 'songs'
 * the song names and ratings of exactly ten random songs with a rating 
 * of 4 or 5.
 *



SELECT song_name,
       rating
  FROM songs
 WHERE rating = 4 OR 
       rating = 5
 ORDER BY random() 
 LIMIT 10;


 * QUESTION 7 
 * --------------------
 *
 * Provide the SQL statement that returns all the columns from the table 'songs'
 * the 20 newest songs by an artist beginning with the letters 'EXO'.
 * A song is newer than another song if its date of release (dor) comes 
 * chronologically later.
 *
 */


SELECT song_name
  FROM songs
 WHERE artist LIKE "EXO%"
 ORDER BY dor DESC
 LIMIT 20;



 * QUESTION 8 
 * --------------------
 *
 * Provide the SQL statement that returns from the table 'songs'
 * all of the highest rated songs (artist, song_name, rating, rating2)
 * where 'rating2' is defined as:
 *
 *   rating2 = [(rating + day of release) mod 7] + 1
 *
 * For example, for song_id 3280, rating = 5, dor = '2019-04-12'.
 *
 *   day of release = 12
 *   rating + day of release = 5 + 12 = 17
 *   17 mod 7 = 3
 *   rating2 = 3 + 1 = 4
 *   
 */



SELECT artist,
       song_name,
       rating,
       ( (strftime('%d', dor) + rating) % 7) + 1 AS rating2
  FROM songs
 WHERE rating = 5;



 * QUESTION 9 
 * --------------------
 *
 * Provide the SQL statement that returns from the table 'plays'
 * a list of distinct song names and artists meeting ALL of the following
 * criteria:
 *
 *  - played between the hours of 8 AM and 4 PM inclusively
 *  - played during the Summer of 2019 (between 6/21 and 9/22)
 *  - not played during the Fall of 2019 (between 9/23 and 12/20)
 *
 */


SELECT DISTINCT song_name,artist
  FROM plays
 WHERE strftime("%H %M  %S", play_dt) BETWEEN "07 59 59" AND "16 00 01" AND 
       strftime("%Y %m %d ", play_dt) BETWEEN "2019 06 21" AND "2019 09 22"
EXCEPT
SELECT DISTINCT song_name,artist
  FROM plays
 WHERE strftime("%Y %m %d ", play_dt) BETWEEN "2019 09 23" AND "2019 12 20";
 

