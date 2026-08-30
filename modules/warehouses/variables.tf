variable "warehouse_name" {
  type        = string
  description = "The root name of the virtual warehouse"
}

variable "environment" {
  type        = string
  description = "The target deployment environment (e.g., dev, prod)"
}

variable "warehouse_size" {
  type        = string
  description = "Compute power tier (XSMALL, SMALL, MEDIUM, etc.)"
}

variable "credit_quota" {
  type        = number
  description = "Credit quota per monitor_frequency period, enforced by this warehouse's resource monitor"
  default     = 50
}

variable "monitor_frequency" {
  type        = string
  description = "Reset frequency for the resource monitor's credit_quota (MONTHLY, DAILY, WEEKLY, YEARLY, NEVER)"
  default     = "MONTHLY"
}

variable "suspend_trigger" {
  type        = number
  description = "Percent of credit_quota at which the warehouse is suspended (new queries blocked, in-flight queries finish)"
  default     = 90
}

variable "suspend_immediate_trigger" {
  type        = number
  description = "Percent of credit_quota at which the warehouse is suspended immediately, cancelling in-flight queries"
  default     = 100
}

variable "notify_triggers" {
  type        = set(number)
  description = "Percent thresholds of credit_quota at which to send an email notification only, without suspending anything"
  default     = [75]
}

variable "notify_users" {
  type        = set(string)
  description = "Snowflake usernames to notify when notify_triggers or suspend thresholds are crossed"
  default     = []
}
