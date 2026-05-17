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
- Optional logistic regression risk scoring ?????
- Case study writing

## Planned Deliverables

- Cleaned dataset
- R script
- Tableau Public dashboard
- GitHub documentation
- Portfolio case study

## Status

In progress.

## Data Cleaning Notes
- Column names were standardized for easier analysis.
- One record had an impossible age value of -1. Because the true age could not be verified from other records, this record was removed from the analysis.
- Five records had negative waiting days, meaning the appointment date occurred before the scheduled date. These records were removed because the scheduling interval was not logically valid. All five were no-shows, but the count was too small to interpret as a meaningful pattern.
