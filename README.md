# Medical-Appointment-No-Show-Risk-Dashboard  

## Project Overview  

In this project I analyze medical appointment no-show patterns using a healthcare appointment dataset, identifying patterns related to missed appointments and building a dashboard that could help healthcare, non-profit or public health programs prioritize supportive outreach.  

## Research Questions

1. What is the overall no-show rate?
2. Do no-show rates vary by age group, gender, neighborhood, or weekday?
3. Is waiting time between scheduling and appointment date associated with missed appointments?
4. Are SMS reminders associated with different no-show patterns?
5. How could a healthcare or public health program use these findings to improve outreach?

## Tools Used

- R
- Tableau 

## Planned Methods

- Data cleaning
- Exploratory data analysis
- Feature engineering
- Dashboard development
- Logistic regression risk scoring
- Case study writing

## Planned Deliverables

- Cleaned dataset
- R script
- Tableau Public dashboard
- GitHub documentation
- Portfolio case study

## Status

Completed: 
- Cleaned and validated the raw appointment dataset
- Created analysis-ready variables
- Generated exploratory summary tables and charts
- Built an interactive Tableau dashboard
- Drafted preliminary case study notes

In progress:
- Final case study
- Logistic regression / risk scoring

## Data Cleaning Notes
- Column names were standardized for easier analysis.
- One record had an impossible age value of -1. Because the true age could not be verified from other records, this record was removed from the analysis.
- Five records had negative waiting days, meaning the appointment date occurred before the scheduled date. These records were removed because the scheduling interval was not logically valid. All five were no-shows, but the count was too small to interpret as a meaningful pattern.

## Selected Exploratory Charts

- No-show percentage by age group
- No-show percentage by gender
- No-show percentage by waiting time
- No-show percentage by SMS reminder status
- No-show percentage by waiting time and SMS reminder status
- No-show percentage by appointment weekday
- No-show percentage by scheduled weekday
- Top neighbourhoods by no-show percentage

## Key Preliminary Findings

- The overall no-show rate was approximately 20.2%.
- No-show percentages were higher among teens and younger adults than among older adults.
- Waiting time showed a clear pattern: appointments scheduled farther in advance had higher no-show percentages.
- Appointments with an SMS reminder recorded had a higher no-show percentage, but after stratifying by waiting time, the pattern changed. Within waiting-time groups where both SMS and no-SMS appointments were present, appointments with SMS reminders generally had lower no-show percentages than appointments without SMS reminders. 
- Neither neighbourhood nor gender did appear to meaningfully differentiate no-show percentages.

## Tableau Dashboard

I created an interactive Tableau dashboard to explore appointment no-show patterns and identify patterns that may help prioritize patient outreach.

[View the Tableau Public dashboard](https://public.tableau.com/app/profile/ver.nica.kurka/viz/MedicalAppointmentNo-ShowAnalysis_17796763435720/Dashboard1)

The dashboard highlights:

- Overall appointment volume, no-show count, no-show rate, and average waiting time
- No-show percentage by waiting time and SMS reminder status
- No-show percentage by age group
- No-show percentage by weekday of appointment and day scheduled
- Neighbourhood-level no-show patterns interpreted alongside appointment volume

## Baseline Logistic Regression Model

As an extension to the exploratory analysis and Tableau dashboard, I fit a baseline logistic regression model to evaluate adjusted associations with appointment no-show odds and assess basic predictive performance.

The model used an 80/20 stratified train-test split. Predictors included waiting time group, age group, SMS reminder status, gender, scholarship status, selected health indicators, appointment weekday, and scheduled weekday.

Model diagnostics included checks for convergence, multicollinearity, influential observations, predicted probability range, ROC-AUC, and calibration.

Key findings:
- Longer waiting times were strongly associated with higher no-show odds.
- Younger age groups had higher no-show odds than the 50–64 reference group.
- SMS reminder status was associated with lower no-show odds after adjustment.
- The model showed decent discrimination, with ROC-AUC around 0.73.
- At a 0.25 outreach threshold, the model identified about 67% of actual no-shows, but precision was modest.

The model should be interpreted as a baseline outreach-prioritization model, not as a definitive individual prediction tool.
