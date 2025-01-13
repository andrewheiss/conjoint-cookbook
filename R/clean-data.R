library(tidyverse)
library(haven)

responses_long <- read_spss(
  here::here("data", "raw_data", "ResearchBox 712", "Data", "Study 5.sav")
) |> 
  mutate(condition = if_else(CONDITION == 0, "Control", "Sticker")) |> 
  select(
    resp_id = sys_CBCVersion_CBC, condition, 
    gender = Gender, age = Age, starts_with("CBC_Random")
  ) |> 
  mutate(gender = case_match(gender,
    1 ~ "Male",
    2 ~ "Female",
    3 ~ "Other"
  )) |> 
  pivot_longer(
    cols = starts_with("CBC_Random"),
    names_to = "question_raw",
    values_to = "chosen_alt"
  ) |> 
  mutate(question = as.numeric(str_extract(question_raw, "\\d+"))) |> 
  select(-question_raw)

alternatives <- alternatives <- bind_rows(
  Control = alternatives_5_control,
  Sticker = alternatives_5_sticker,
  .id = "condition"
) |> 
  mutate(
    price = case_match(`Att 1 - Price`,
      1 ~ "$2",
      2 ~ "$3",
      3 ~ "$4"),
    packaging = case_match(`Att 2 - Packaging`,
      1 ~ "Plastic + paper",
      2 ~ "Plastic + sticker"),
    flavor = case_match(`Att 3 - Flavor`,
      1 ~ "Nuts",
      2 ~ "Chocolate")
  ) |> 
  mutate(
    price = factor(price),
    packaging = fct_relevel(packaging, "Plastic + paper"),
    flavor = factor(flavor)
  ) |> 
  rename(version = Version, question = Task, alt = Concept) |> 
  select(-starts_with("Att "))

responses_long_expanded <- responses_long |>
  expand(condition, resp_id, question, alt = 1:2) |> 
  left_join(responses_long, by = join_by(condition, resp_id, question))

combined <- responses_long_expanded |> 
  left_join(alternatives, by = join_by(resp_id == version, condition, question, alt)) |> 
  mutate(choice = as.numeric(alt == chosen_alt))

# Save data
combined |> 
  filter(condition == "Sticker") |> 
  mutate(packaging = fct_drop(packaging)) |> 
  saveRDS(here::here("data", "processed_data", "study_5_sticker.rds"))

combined |> 
  filter(condition == "Control") |> 
  mutate(packaging = fct_drop(packaging)) |> 
  saveRDS(here::here("data", "processed_data", "study_5_control.rds"))

combined |> 
  saveRDS(here::here("data", "processed_data", "study_5_both.rds"))
