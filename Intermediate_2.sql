-- APAN 5310: SQL & RELATIONAL DATABASES


/*
 * QUESTION 1 
 * --------------------
 *
 * Provide the SQL statement that returns from the table 'idols', the gender and
 * the number of total idols within each gender category. Also, show one row with
 * the total count for all genders. Label the columns as 'Gender' and 'Count'.
 *
 */


SELECT gender Gender,
       count(gender) Count
  FROM idols
 GROUP BY gender
UNION
SELECT 'Total' Gender,
       n Count
  FROM (
           SELECT 'Total',
                  count(gender) n
             FROM idols
       );



 * QUESTION 2 
 *
 * Provide the SQL statement that returns from the table 'songs', the top ten
 * artists with the highest average rating. The minimum number of songs to
 * qualify for this list is 5 per artist. That is, do not include any artists
 * who have less than 5 songs in the database. Label these columns 'Artist'
 * and 'Avg_Rating'.
 *
 */


SELECT artist Artist,
       avg(rating) Avg_Rating
  FROM songs
 GROUP BY Artist
HAVING count(Artist) >= 5
 ORDER BY Avg_Rating DESC
 LIMIT 10;


/*
 * QUESTION 3 
 * --------------------
 *
 * Provide the SQL statement that returns from the table 'plays',
 * a report showing the monthly average number of played songs by quarter.
 * Quarter 1 = (Jan, Feb, Mar), Quarter 2 = (Apr, May, Jun), etc.
 * Include only songs played in the year 2019.
 * Round the monthly averages to 0 dp.
 * Label the columns 'Qtr' and 'Mthly_Avg'.
 *


SELECT Qtr,
       round(avg(play_id), 0) Mthly_Avg
  FROM (
           SELECT round( (strftime("%m", play_dt) + 0.51) / 3) AS Qtr,
                  play_id
             FROM (
                      SELECT play_dt,
                             count(play_id) play_id
                        FROM plays
                       WHERE strftime("%Y", play_dt) = "2019"
                       GROUP BY strftime("%m", play_dt) 
                  )
       )
 GROUP BY Qtr;


 * QUESTION 4 
 *
 * Provide the SQL statement that returns from the table 'plays', a list of
 * 20 song names and the date of play ('yyyy-mm-dd') played most recently.
 * Duplicates are allowed. To be included, the song must meet ALL of the
 * following requirements:
 *
 *  - is among the top fifty songs played during months 1 through 5
 *  - is by a 'favorite' artist which means the artist is among the 25 most played
 *    artists within the 'plays' table
 *
 * Label the columns 'Song' and 'Play Date'.
 *

SELECT song_name Song,
       strftime("%Y %m %d", play_dt) as 'Play Date'
  FROM plays
 WHERE song_name IN (
           SELECT song_name
             FROM plays
            WHERE strftime("%m", play_dt) BETWEEN "01" AND "05"
            GROUP BY song_name
            ORDER BY COUNT(song_name) DESC
            LIMIT 50
       )
AND 
       artist IN (
           SELECT artist
             FROM plays
            GROUP BY artist
            ORDER BY COUNT(artist) DESC
            LIMIT 25
       )
 GROUP BY song_name
 ORDER BY play_dt DESC
 LIMIT 20;



 * QUESTION 5 
 * --------------------
 *
 * Provide the SQL statement that returns from the table 'songs', all song names
 * rated 5 and the year of release. The songs must be from artists that
 * have at least triple (3x) the average songs per artist in the 'songs' table.
 * Order by year of release and then by song name. Label the columns 'Song' and
 * 'YOR'.
 *
 */


SELECT song_name Song,
       dor YOR
  FROM songs
 WHERE rating = 5 AND 
       artist IN (
           SELECT artist
             FROM (
                      SELECT artist,
                             count(song_name) 
                        FROM songs
                       GROUP BY artist
                      HAVING count(song_name) >= 3 * (
                                                         SELECT CountS / CountA AVG
                                                           FROM (
                                                                    SELECT count(DISTINCT artist) CountA,
                                                                           count(song_name) CountS
                                                                      FROM songs
                                                                )
                                                     )
                  )
       )
 ORDER BY YOR,
          Song;


