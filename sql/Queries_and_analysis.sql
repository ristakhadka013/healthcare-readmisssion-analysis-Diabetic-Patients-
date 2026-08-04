CREATE DATABASE Diabetic_Readmission_Project;

USE Diabetic_Readmission_Project;

-- creating and loading data from csv file through import wizard

SELECT 
	COUNT(encounter_id) as Count
FROM diabetic_data_cleaned;

ALTER TABLE diabetic_data_cleaned RENAME TO diabetic;

SELECT * 
FROM diabetic
LIMIT 5;

-- BUSINESS PROBLEM : which patient, treatment, and encounter characteristics are most associated with readmission risk?

-- 1. Do patient with older age get readmitted more often?

SELECT 
	readmitted,
    ROUND(AVG(new_age), 2) as AverageAge 
FROM diabetic
GROUP BY readmitted
ORDER BY AverageAge DESC;

/* ---FINDING---------------------------------------------------
<30	66.76
>30	66.41
NO	65.52

---Observation--------------------------------------------------
Older patient shows slightly higher average age among readmitted groups,
but the difference is minimal so, age alone is not the strong indicator for readmission. 

-------------------------------------------------------------------------------------------*/

--  2. Do patient with longer hospital stay get readmitted more often?

SELECT 
	readmitted,
    ROUND(AVG(time_in_hospital), 2) as AvgHospitalStay
FROM diabetic
GROUP BY readmitted
ORDER BY AvgHospitalStay DESC ;

/* ---------RESULT---------------------------------------------------------------------
<30	4.77
>30	4.50
NO	4.25

----------Observation----------------------------------------------------------------
The average hospital stay is slightly higher (4.77) than other readmitted group. 
The difference is minimal like avg age.
so, suggesting hospital stay alone is not strong predictor for readmission.
------------------------------------------------------------------------------------------------------------------------ */

--  3. which admission type has the highest readmission ?

SELECT 
	admission_type_id,
    (CASE admission_type_id
		WHEN 1 THEN 'Emergency'
        WHEN 2 THEN 'Urgent'
        WHEN 3 THEN 'Elective'
        WHEN 4 THEN 'Newborn'
        WHEN 7 THEN 'Trauma Center'
        ELSE 'others'
        END
	) AS descriptions,
    COUNT(*) AS TotalReadmission,
    ROUND(AVG(
			CASE when readmitted = '<30' then 1 else 0 end
		) * 100, 2) as AvgReadmissionRate
FROM diabetic
GROUP BY admission_type_id, descriptions
ORDER BY AvgReadmissionRate DESC; 

/* RESULT --------------------------------------------------------
1	Emergency	53990	11.52
2	Urgent	18480	11.18
6	others	5291	11.08
3	Elective	18869	10.39
5	others	4785	10.34
4	Newborn	10	10.00
8	others	320	8.44
7	Trauma Center	21	0.00

-Observation-------------------------------------------------------------
Admission type 1(emergency) and  2(urgent) have higher readmission rate among others admission type.
In these Admission type 1, 2 and 6, admission type 1 have slightly more readmission rate (11.52).
So, may be admission type should be considered, as there is high chance of readmission with in 30 days.
---------------------------------------------------------------------------------------------------------*/

-- 4. Do patient with more medication is likely to return with in 30 day ? 

SELECT 
	readmitted,
    ROUND(AVG(num_medications),2) as AvgMedication
FROM diabetic
GROUP BY readmitted
ORDER BY AvgMedication DESC;

/* RESULT ---------------------------------------------------------------------------
<30	16.90
>30	16.28
NO	15.67

--Observation --------------------------------------------------------------------------------------------------
The average medication taken where slightly less than other readmitted group. This differences is small, so
suggesting avg medication is also not strongly associated to readmission within 30 days 
----------------------------------------------------------------------------------------------------------- */

-- 5. Do patient taking insulin increases the chance of readmission ?

SELECT 
	readmitted,
    ROUND(
		AVG( CASE WHEN insulin = 'Up' OR insulin = 'Steady' THEN 1 ELSE 0 END ) * 100,
        2) AS InsulinTakenRate
FROM diabetic
GROUP BY readmitted
ORDER BY InsulinTakenRate DESC;

/* RESULT ----------------------------------------------------------------------------------
<30	43.17
>30	41.76
NO	40.86

Observation ---------------------------------------------------------------------------------
The Average InsulinTakenRate is higher (43.17 %) than other readmitted rate. 
Meaning, the patient who haven taken insulin might readmitted to the hospital with 30 days.alter
--------------------------------------------------------------------------------------------------- */

-- 6. Does change in medication also leads to readmission ?

SELECT 
	readmitted,
    ROUND(
		AVG( CASE WHEN `change` = 'Ch' THEN 1 ELSE 0 END) * 100,
        2) AS ChangeRate
FROM diabetic
GROUP BY readmitted
ORDER BY ChangeRate DESC;

/* RESULT -------------------------------------------------------------------------------------
<30	48.94
>30	48.59
NO	44.07

observation-------------------------------------------------------------------------------------
The change medication rate is slightly higher among other readmitted rate (48.94 %).
The difference is not huge, so suggesting this alone is not affecting the readmission.
---------------------------------------------------------------------------------------------- */

-- 7. Do patient with A1Cresult test get readmitted more often??

SELECT 
	readmitted,
    ROUND(
		AVG( CASE WHEN A1Cresult != 'Not Tested' THEN 1 ELSE 0 END ) * 100,
        2) AS A1CresultRate
FROM diabetic
GROUP BY readmitted
ORDER BY A1CresultRate DESC;

/* RESULT ------------------------------------------------------------------------------------
NO	17.39
>30	16.32
<30	14.76

-- Observation -----------------------------------------------------------------------------------
The Avg A1Cresult rate is less than other readmitted group.
--------------------------------------------------------------------------------------------------*/

-- 8. Do patient with more previous inpatient get readmitted more often?

SELECT 
	readmitted,
    ROUND(
		AVG(number_inpatient), 2) AS PreviousInpatient
FROM diabetic 
GROUP BY readmitted
ORDER BY PreviousInpatient DESC;

/* RESULT -----------------------------------------------------------------------------------------
<30	1.22
>30	0.84
NO	0.38

Observation ------------------------------------------------------------------------------------
The avg previous inpatient is more in <30. Meaning the inpatient history is more than other readmitted.alter
-------------------------------------------------------------------------------------------------------------*/

-- 9. Do patient with past emergency history get readmitted more often?

SELECT 
	readmitted,
    ROUND(
		AVG(number_emergency), 2) AS PastEmergency
FROM diabetic 
GROUP BY readmitted
ORDER BY PastEmergency DESC;

/* RESULT ---------------------------------------------------------------------------------------
<30	0.36
>30	0.28
NO	0.11

Observation-------------------------------------------------------------------------------------------
The past emergency is only slightly more than other readmitted (0.36). 
This mean, Past emergency might not seem to have more impact in readmission
------------------------------------------------------------------------------------------------------ */

-- 10. Which discharge disposition has the highest readmission ? 

SELECT 
	discharge_disposition_id,
    (CASE discharge_disposition_id
			WHEN 1 THEN 'Discharged to home'
            WHEN 2 THEN 'Discharged/transferred to another short term hospital'
            WHEN 3 THEN 'Discharged/transferred to SNF'
            WHEN 4 THEN 'Discharged/transferred to ICF'
            WHEN 12 THEN ' Still patient or expected to return for outpatient services'
            WHEN  15 THEN 'Discharged/transferred within this institution to Medicare approved swing bed'
            WHEN 28 THEN 'Discharged/transferred/referred to a psychiatric hospital of psychiatric distinct part unit of a hospital'
            WHEN 22 THEN 'Discharged/transferred to another rehab fac including rehab units of a hospital .'
            WHEN 5 THEN 'Discharged/transferred to another type of inpatient care institution'
            ELSE 'Others'
            END
	) as Descriptions,
    COUNT(*) AS TotalReadmission,
	ROUND(AVG( CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) * 100, 2) AS AVGReadmissionRate
FROM diabetic 
GROUP BY discharge_disposition_id, Descriptions
ORDER BY AVGReadmissionRate DESC;


/* RESULT ---------------------------------------------------------------------------
12	 Still patient or expected to return for outpatient services	3	66.67
15	Discharged/transferred within this institution to Medicare approved swing bed	63	44.44
9	Others	21	42.86
28	Discharged/transferred/referred to a psychiatric hospital of psychiatric distinct part unit of a hospital	139	36.69
22	Discharged/transferred to another rehab fac including rehab units of a hospital .	1993	27.70
5	Discharged/transferred to another type of inpatient care institution	1184	20.86
2	Discharged/transferred to another short term hospital	2128	16.07
3	Discharged/transferred to SNF	13954	14.66
24	Others	48	14.58
7	Others	623	14.45
8	Others	108	13.89
4	Discharged/transferred to ICF	815	12.76
6	Others	12902	12.70
18	Others	3691	12.44
25	Others	989	9.30
1	Discharged to home	60234	9.30
23	Others	412	7.28
14	Others	372	6.45
13	Others	399	4.76
11	Others	1642	0.00
10	Others	6	0.00
16	Others	11	0.00
17	Others	14	0.00
20	Others	2	0.00
19	Others	8	0.00
27	Others	5	0.00

Observation -----------------------------------------------------------------------------------------
Although Discharge 12 has the highest observed rate, it includes only 3 patients. More meaningful 
patterns are seen in discharge groups with larger patient populations, such as rehabilitation facilities
and psychiatric hospitals.
------------------------------------------------------------------------------------------------*/

/* 

OVERALL FINDINGS

1. Age and hospital stay show only small differences between readmitted and non-readmitted patients.

2. Previous inpatient utilization is the strongest indicator of future readmission.

3. Emergency and urgent admissions demonstrate higher readmission rates than elective admissions.

4. Patients receiving insulin or medication changes show slightly higher readmission rates, likely reflecting higher disease severity.

5. Certain discharge destinations, particularly rehabilitation facilities and psychiatric hospitals, are associated with higher readmission rates than discharge to home.

These findings suggest that prior healthcare utilization, admission context, and discharge planning are more informative indicators of readmission risk than age or length of stay alone.

*/