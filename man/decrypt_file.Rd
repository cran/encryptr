% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/decrypt_file.R
\name{decrypt_file}
\alias{decrypt_file}
\title{Decrypt a file}
\usage{
decrypt_file(.path, file_name = NULL, private_key_path = "id_rsa")
}
\arguments{
\item{.path}{Quoted path to file to encrypt.}

\item{file_name}{Optional new name for unencrypted file.}

\item{private_key_path}{Quoted path to private key, created with
\code{\link{genkeys}}.}
}
\value{
The decrypted file is saved with optional file name.
}
\description{
See \code{\link{encrypt_file}} for details.
}
\examples{

#' # For CRAN and testing:
\dontrun{
# Run only once in decrypt_file example
temp_dir = tempdir() # temp directory for testing only
genkeys(file.path(temp_dir, "id_rsa"))
write.csv(gp, file.path(temp_dir, "gp.csv"))
encrypt_file(file.path(temp_dir, "gp.csv"), public_key_path = file.path(temp_dir, "id_rsa.pub"))
}

\dontrun{
# For CRAN and testing:
temp_dir = tempdir() # temp directory for testing only
genkeys(file.path(temp_dir, "id_rsa4"))
write.csv(gp, file.path(temp_dir, "gp.csv"))
encrypt_file(file.path(temp_dir, "gp.csv"), public_key_path = file.path(temp_dir, "id_rsa4.pub"))
decrypt_file(file.path(temp_dir, "gp.csv.encryptr.bin"),
  private_key_path = file.path(temp_dir, "id_rsa4"),
  file_name = "file.path(temp_dir, gp2.csv)")
  }
}
