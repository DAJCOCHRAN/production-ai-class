variable "studentSubscriptionId" {
  type = string
}

variable "studentLocation" {
  type    = string
  default = "East US"
}

variable "studentRGName" {
  type = string
}

variable "studentStorageAccountName" {
  type        = string
  description = "Storage account name (must be 3-24 chars, lowercase letters and numbers only)"
}

variable "studentTrainingDataContainerName" {
  type        = string
  default     = "training-data"
  description = "Blob container name for AI training datasets"
}

variable "studentModelArtifactsContainerName" {
  type        = string
  default     = "model-artifacts"
  description = "Blob container name for trained model outputs"
}
