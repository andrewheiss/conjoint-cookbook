library(tidyverse)
library(haven)

responses <- read_spss(
  here::here("data", "raw_data", "ResearchBox 712", "Data", "Study 5.sav")
) |> 
  filter(CONDITION == 1) |> 
  select(resp_id = sys_CBCVersion_CBC, gender = Gender, age = Age, starts_with("CBC_Random")) |> 
  mutate(gender = case_match(gender,
    1 ~ "Male",
    2 ~ "Female",
    3 ~ "Other"
  ))

alternatives <- read_csv(
  here::here(
    "data", "raw_data", "ResearchBox 712", "Materials", 
    "Study 5 - Descriptions of CBC surveys in intervention.csv")
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
  select(-starts_with("Att ")) |> 
  filter(version %in% responses$resp_id)

saveRDS(responses, here::here("data", "processed_data", "responses_illustration.rds"))
saveRDS(alternatives, here::here("data", "processed_data", "alternatives_illustration.rds"))
