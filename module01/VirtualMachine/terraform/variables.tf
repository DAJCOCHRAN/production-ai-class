variable "studentSubscriptionId" {
    type = string
}

variable "studentLocation" {
    type = string
    default = "East US"
}

variable "studentRGName" {
    type = string
}

variable "platformImageGalleryName" {
    type = string
}

variable "studentVNETName" {
	type = string
}

variable "studentIPName" {
	type = string
}

variable "studentNSGName" {
	type = string
}

variable "studentNICName" {
	type = string
}

variable "studentVMSTName" {
	type = string
}

variable "studentVMName" {
	type = string
}

variable "studentVMDiskName" {
	type = string
}

variable "studentVMUsername" {
	type = string
}

variable "studentVMPassword" {
	type = string
}

variable "diskSizeGB" {
	type = number
	description = "VM Disk size value that represents 'powers of two' in the form 2^n"
	default = 128
}
