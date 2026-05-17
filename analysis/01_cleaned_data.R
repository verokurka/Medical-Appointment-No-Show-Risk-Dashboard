library(tidyverse)
library(lubridate)
library(janitor)

noshow_raw <- read_csv("data/raw/noshow-raw.csv")

glimpse(noshow_raw)
summary(noshow_raw)

# cleaning column names, to start with.
noshow_clean <- noshow_raw %>%
  clean_names() 

# checking for missing data 
noshow_clean %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "missing_count"
  ) %>%
  arrange(desc(missing_count)) # no missing values

# investigating the patient aged -1
wrong_age_patient <- noshow_clean %>% 
  filter(age < 0) %>% 
  pull(patient_id)

noshow_clean %>%
  filter(patient_id %in% wrong_age_patient)

# investigating the patient(s) aged 115 (feasible, but improbable?)
very_old_patients <- noshow_clean %>% 
  filter(age == 115) %>% 
  distinct(patient_id) %>%
  pull(patient_id)

noshow_clean %>%
  filter(patient_id %in% very_old_patients) # seems legit!

# investigating the neighborhoods
noshow_clean %>%
  distinct(neighbourhood) %>%
  arrange(neighbourhood) %>%
  print(n = 81) # no apparent typos

noshow_clean %>%
  mutate(neighbourhood_trimmed = str_squish(neighbourhood)) %>%
  summarise(
    original_unique = n_distinct(neighbourhood),
    trimmed_unique = n_distinct(neighbourhood_trimmed)
  ) # all 81 neighbourhoods seem legitimate!


# investigating the fact that handicap goes all the way to 4
noshow_clean %>%
  count(handcap) # the data dictionary states it should be T/F

# checking for duplicate appointment IDs. There should be none.
noshow_clean %>%
  summarise(
    total_rows = n(),
    unique_appointment_ids = n_distinct(appointment_id),
    duplicate_appointment_ids = n() - n_distinct(appointment_id)
  ) # no duplicates found

# investigating for typos in appointment and patient IDs
investigating <- noshow_clean %>%
  mutate(
    patient_id_chr = format(patient_id, scientific = FALSE, trim = TRUE),
    appointment_id_chr = format(appointment_id, scientific = FALSE, trim = TRUE)
  ) %>%
  mutate(
    patient_id_length = str_length(patient_id_chr),
    appointment_id_length = str_length(appointment_id_chr)
  )

investigating %>% 
  count(patient_id_length, sort = TRUE) # so these vary SUBSTANTIALLY
  
investigating %>%
  count(appointment_id_length, sort = TRUE) # all length 7. Nice.

# checking age consistency
noshow_clean %>%
  group_by(patient_id) %>%
  summarise(
    min_age = min(age),
    max_age = max(age),
    age_range = max_age - min_age,
    .groups = "drop"
  ) %>%
  arrange(desc(age_range))

# checking that all schedule_day are "in the past"
noshow_clean <- noshow_clean %>%
  mutate(scheduled_date= as_date(scheduled_day),
         appointment_date = as_date(appointment_day),
         waiting_days = as.numeric(appointment_date - scheduled_date)) # NOT DONE YET

negative_waiting_records <- noshow_clean %>%
  filter(waiting_days < 0) # only a small percentage, no real data-quality issue

nrow(negative_waiting_records)

# cleaning
noshow_clean <- noshow_clean %>%
  mutate(
    gender = as.factor(gender), # change from chr to factor
    no_show_flag = if_else(no_show == "Yes", 1, 0), # change from chr to dbl
    handicap_status = if_else(handcap > 0, 1, 0)
  ) %>%
  filter(
    !(patient_id %in% wrong_age_patient), # drop unborn patient
    waiting_days >= 0 # drop time travelers
         ) %>%
  select(-c(handcap, no_show)) %>%
  rename(hipertension = hypertension)

summary(noshow_clean)

write_csv(noshow_clean, "data/processed/appointments_clean_base.csv")








         
         