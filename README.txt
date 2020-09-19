This file has more technical details about generating the pre-processed data and the results to the second project of SPBD


For generating the pre-processed data, follow the following steps:

1. Execute the file project2_pre_processing.sql (hive -f project2_pre_processing.sql). This generates a directory called pre_processed.

2. In the pre_processed directory, multiple files were created with a name like 000000_0, 000000_1, etc. Change their extension to become a CSV.

3. Merge them in the same CSV file using the cat command (cat 000000_0.csv 000000_1.csv 000000_2.csv 000000_3.csv 000000_4.csv > pre_processed.csv)

You can now execute the project2.sql file to query upon this new pre-processed data.


For generating the results files, follow the following steps:

1. Execute the file project2.sql (hive -f project2.sql). This generates four directories, one for each exercise (e.g. for exercise 1, there will be a 
directory named results_ex1).

2. In the directory results_ex1, there will be a file named 000000_0. Change its extension to become a CSV. You can also change its name to 
results_ex1.csv, in order to be according to our report.

3. Do the same for the directories created for each of the remaining exercises (results_ex2, results_ex3 and results_ex4).