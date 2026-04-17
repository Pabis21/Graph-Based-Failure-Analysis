library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)
library(forcats)

# -----------------------------
# Load scenario CSV files
# -----------------------------
baseline <- read_csv("../../output/impact_baseline.csv", show_col_types = FALSE)
low_p <- read_csv("../../output/impact_low_p.csv", show_col_types = FALSE)
high_p <- read_csv("../../output/impact_high_p.csv", show_col_types = FALSE)
high_mttr <- read_csv("../../output/impact_high_mttr.csv", show_col_types = FALSE)
high_failure <- read_csv("../../output/impact_high_failure.csv", show_col_types = FALSE)

# -----------------------------
# Add scenario labels
# -----------------------------
baseline$scenario <- "Baseline"
low_p$scenario <- "Low_P"
high_p$scenario <- "High_P"
high_mttr$scenario <- "High_MTTR"
high_failure$scenario <- "High_Failure"

# -----------------------------
# Combine all results
# -----------------------------
all_data <- bind_rows(
  baseline,
  low_p,
  high_p,
  high_mttr,
  high_failure
)

all_data$scenario <- factor(
  all_data$scenario,
  levels = c("Baseline", "Low_P", "High_P", "High_MTTR", "High_Failure")
)

# -----------------------------
# Reorder services by baseline expected impact
# -----------------------------
service_order <- baseline %>%
  arrange(desc(expected_system_impact)) %>%
  pull(service)

all_data$service <- factor(all_data$service, levels = service_order)
baseline$service <- factor(baseline$service, levels = service_order)

# -----------------------------
# Calculate SVI per scenario
# -----------------------------
svi_data <- all_data %>%
  group_by(scenario) %>%
  summarise(SVI = sum(expected_system_impact, na.rm = TRUE), .groups = "drop")

cat("System Vulnerability Index (SVI) by scenario:\n")
print(svi_data)

# -----------------------------
# Find max-risk service per scenario
# -----------------------------
max_risk <- all_data %>%
  group_by(scenario) %>%
  slice_max(order_by = expected_system_impact, n = 1, with_ties = FALSE) %>%
  ungroup()

cat("Max-risk service by scenario:\n")
print(max_risk)

# -----------------------------
# Graph 1: SVI comparison
# -----------------------------
p1 <- ggplot(svi_data, aes(x = scenario, y = SVI, fill = scenario)) +
  geom_col() +
  labs(
    title = "System Vulnerability Index Across Scenarios",
    x = "Scenario",
    y = "SVI"
  ) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "right")

print(p1)
ggsave("output/svi_comparison.png", plot = p1, width = 8, height = 5)

# -----------------------------
# Graph 2: Expected impact per service across scenarios
# -----------------------------
p2 <- ggplot(all_data, aes(x = service, y = expected_system_impact, fill = scenario)) +
  geom_col(position = "dodge") +
  labs(
    title = "Expected Impact per Service Across Scenarios",
    x = "Service",
    y = "Expected Impact"
  ) +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))

print(p2)
ggsave("output/expected_impact_by_service.png", plot = p2, width = 12, height = 6)

# -----------------------------
# Graph 3: Raw impact per service (baseline)
# -----------------------------
if ("raw_impact" %in% names(baseline)) {
  p3 <- ggplot(baseline, aes(x = service, y = raw_impact)) +
    geom_col() +
    labs(
      title = "Raw Impact per Service (Baseline)",
      x = "Service",
      y = "Raw Impact"
    ) +
    theme_minimal(base_size = 14) +
    theme(axis.text.x = element_text(angle = 60, hjust = 1))
  
  print(p3)
  ggsave("output/raw_impact.png", plot = p3, width = 12, height = 6)
}

# -----------------------------
# Graph 4: Raw vs Expected impact (baseline)
# -----------------------------
if (all(c("raw_impact", "expected_system_impact") %in% names(baseline))) {
  baseline_compare <- baseline %>%
    select(service, raw_impact, expected_system_impact) %>%
    pivot_longer(
      cols = c(raw_impact, expected_system_impact),
      names_to = "metric",
      values_to = "impact"
    ) %>%
    mutate(
      metric = recode(
        metric,
        raw_impact = "raw",
        expected_system_impact = "expected"
      )
    )
  
  p4 <- ggplot(baseline_compare, aes(x = service, y = impact, fill = metric)) +
    geom_col(position = "dodge") +
    labs(
      title = "Baseline: Raw vs Expected Impact",
      x = "Service",
      y = "Impact Value"
    ) +
    theme_minimal(base_size = 14) +
    theme(axis.text.x = element_text(angle = 60, hjust = 1))
  
  print(p4)
  ggsave("output/baseline_raw_vs_expected.png", plot = p4, width = 12, height = 6)
}

# -----------------------------
# Graph 5: Dependent service loss per service (baseline)
# -----------------------------
if ("dependent_service_loss" %in% names(baseline)) {
  p5 <- ggplot(baseline, aes(x = service, y = dependent_service_loss)) +
    geom_col() +
    labs(
      title = "Dependent Service Loss per Service (Baseline)",
      x = "Service",
      y = "Dependent Service Loss"
    ) +
    theme_minimal(base_size = 14) +
    theme(axis.text.x = element_text(angle = 60, hjust = 1))
  
  print(p5)
  ggsave("output/dependent_service_loss_baseline.png", plot = p5, width = 12, height = 6)
}

# -----------------------------
# Graph 6: Affected service ratio per service (baseline)
# -----------------------------
if ("affected_service_ratio" %in% names(baseline)) {
  p6 <- ggplot(baseline, aes(x = service, y = affected_service_ratio)) +
    geom_col() +
    labs(
      title = "Affected Service Ratio per Service (Baseline)",
      x = "Service",
      y = "Affected Service Ratio"
    ) +
    theme_minimal(base_size = 14) +
    theme(axis.text.x = element_text(angle = 60, hjust = 1))
  
  print(p6)
  ggsave("output/affected_service_ratio_baseline.png", plot = p6, width = 12, height = 6)
}

# -----------------------------
# Graph 7: Max-risk service per scenario
# -----------------------------
p7 <- ggplot(max_risk, aes(x = scenario, y = expected_system_impact, fill = service)) +
  geom_col() +
  geom_text(aes(label = service), vjust = -0.3, size = 3) +
  labs(
    title = "Max-Risk Service in Each Scenario",
    x = "Scenario",
    y = "Expected Impact"
  ) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "none")

print(p7)
ggsave("output/max_risk_service.png", plot = p7, width = 8, height = 5)