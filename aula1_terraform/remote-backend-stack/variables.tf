variable "authentication" {
    type = object ({
        assume_role_arn = string
        region = string
    })

    default = {
        region = "us-west-1"
        assume_role_arn = "arn:aws:iam::516723929672:role/mini-curso-devOPsCloud-AWSRole"
    }
}

variable "tags" {
    type = map(string)
    
    default = {
        Environment = "production"
        Project = "live-minicurso-devops-cloud-d1"
    }
    
}

variable "remote_backend" {
    type = object ({
        s3_bucket = object({
        name = string
        })
        
        dynamodb_table = object({
            name = string
            billing_mode = string
            hash_key = string
        })
    })

    default = {
        dynamodb_table = {
        name           = "live-minicurso-devops-cloud-d1" 
        billing_mode   = "PAY_PER_REQUEST"
        hash_key       = "LockID" 
        }

        s3_bucket = {
        name = "live-minicurso-devops-cloud-d1"
        }
    }
}