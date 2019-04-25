[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/encryptr)](https://cran.r-project.org/package=encryptr)
[![CRAN_Status_Badge](https://cranlogs.r-pkg.org/badges/encryptr)](https://cran.r-project.org/package=encryptr)
[![TravisCRAN_Status_Badge](https://travis-ci.com/SurgicalInformatics/encryptr.svg?branch=master)](https://travis-ci.com/SurgicalInformatics/encryptr)
[![Coverage status](https://codecov.io/gh/surgicalinformatics/encryptr/branch/master/graph/badge.svg)](https://codecov.io/github/surgicalinformatics/encryptr?branch=master)

# encryptr

## Easily encrypt and decrypt data frame/tibble columns and files using RSA public/private keys

The `encryptr` package provides functions to simply encrypt and decrypt columns of data. It also includes functions to encrypt and decrypt files. 

The motivation is around sensitive healthcare data, but the applications are wide. There are a number of packages providing similar functions. However, they tend to be complex and are not designed with `tidyverse` functions in mind. The package wraps `openssl` and is intended to be safe and straightforward for non-experts. Strong RSA (2048 bit) encryption using a public/private key pair is used. 

It is designed to work in [tidyverse](http://tidyverse.tidyverse.org/articles/manifesto.html) piped functions.


## Installation

You can install `encryptr` from GitHub:

``` r
devtools::install_github("SurgicalInformatics/encryptr")
```

## Documentation

Documentation is maintained at [encrypt-r.org](https://encrypt-r.org).


## Getting started: encrypt and decrypt data frame columns

The basis of RSA encryption is a public/private key pair and is the method used of many modern encryption applications. The public key can be shared and is used to encrypt the information.

The private key is sensitive and should not be shared. The private key requires a password to be set. This password should follow modern rules on password complexity. You know what you should do. If lost, it cannot be recovered. 

### Generate keys

The `genkeys()` function generates a public and private key pair. A password is required to be set in the dialogue box for the private key. Two files are written to the active directory. 

The default name for the private key is:

* `id_rsa`

And for the public key name is generated by default:

* `id_rsa.pub`

If the private key file is lost, nothing encrypted with the public key can be recovered. Keep this safe and secure. Do not share it without a lot of thought on the implications. 

``` r
genkeys()
> Private key written with name 'id_rsa'
> Public key written with name 'id_rsa.pub'
```

### Encrypt 

An example dataset containing the addresses general practioners (family doctors) in Scotland is included in the package.

``` r
data(gp)

# A tibble: 1,212 x 12
   organisation_code name    address1 address2 address3 city  county postcode opendate   closedate  telephone practice_type
   <chr>             <chr>   <chr>    <chr>    <chr>    <chr> <chr>  <chr>    <date>     <date>     <chr>             <dbl>
 1 S10002            MUIRHE… LIFF RO… MUIRHEAD NA       DUND… ANGUS  DD2 5NH  1995-05-01 NA         01382 58…             4
 2 S10017            THE BL… CRIEFF … KING ST… NA       CRIE… PERTH… PH7 3SA  1996-04-06 NA         01764 65…             4
```

Encrypting columns to a ciphertext is straightforward. An important principle is dropping sensitive data which is never going to be required. 

``` r
library(dplyr)
gp_encrypt = gp %>% 
  select(-c(name, address1, address2, address3)) %>% 
  encrypt(postcode, telephone)

gp_encrypt 

# A tibble: 1,212 x 10
   organisation_code name       address1      city  county postcode      opendate   closedate  telephone      practice_type
   <chr>             <chr>      <chr>         <chr> <chr>  <chr>         <date>     <date>     <chr>                  <dbl>
 1 S10002            619057f99… 54c39b3fa200… DUND… ANGUS  796284eb46ca… 1995-05-01 NA         5fcc30b04e260…             4
 2 S10017            371aa33c3… a996d07a84d2… CRIE… PERTH… 639dfc076ae3… 1996-04-06 NA         715909615a6ae…             4
```
### Decrypt 

Decryption requires the private key generated using `genkeys()` and the password set at the time. The password and file are not replaceable so need to be kept safe and secure. 

``` r
gp_encrypt %>%  
  decrypt(postcode, telephone)
  
# A tibble: 1,212 x 8
   organisation_code city        county     postcode opendate   closedate  telephone    practice_type
   <chr>             <chr>       <chr>      <chr>    <date>     <date>     <chr>                <dbl>
 1 S10002            DUNDEE      ANGUS      DD2 5NH  1995-05-01 NA         01382 580264             4
 2 S10017            CRIEFF      PERTHSHIRE PH7 3SA  1996-04-06 NA         01764 652283             4
 ```
 
### Using a lookup table

Rather than storing the ciphertext in the working dataframe, a lookup table can be used as an alternative. Using `lookup = TRUE` has the following effects:

* returns the dataframe / tibble with encrypted columns removed and a `key` column included;
* returns the lookup table as an object in the R environment;
* creates a lookup table `.csv` file in the active directory. file of the lookup 

``` r
gp_encrypt = gp %>% 
  select(-c(name, address1, address2, address3)) %>% 
  encrypt(postcode, telephone, lookup = TRUE)
  
Lookup table object created with name 'lookup'
Lookup table written to file with name 'lookup.csv'

gp_encrypt

# A tibble: 1,212 x 7
     key organisation_code city        county     opendate   closedate  practice_type
   <int> <chr>             <chr>       <chr>      <date>     <date>             <dbl>
 1     1 S10002            DUNDEE      ANGUS      1995-05-01 NA                     4
 2     2 S10017            CRIEFF      PERTHSHIRE 1996-04-06 NA                     4
```

The file creation can be turned off with `write_lookup = FALSE` and the name of the lookup can be changed with `lookup_name = "anyNameHere"`. 

Decryption is performed by passing the lookup object or file to the `decrypt()` function. 

```r
gp_encrypt %>%  
  decrypt(postcode, telephone, lookup_object = lookup)

# A tibble: 1,212 x 8
   postcode telephone    organisation_code city        county     opendate   closedate  practice_type
   <chr>    <chr>        <chr>             <chr>       <chr>      <date>     <date>             <dbl>
 1 DD2 5NH  01382 580264 S10002            DUNDEE      ANGUS      1995-05-01 NA                     4
 2 PH7 3SA  01764 652283 S10017            CRIEFF      PERTHSHIRE 1996-04-06 NA                     4
```

``` r
gp_encrypt %>%  
  decrypt(postcode, telephone, lookup_path = "lookup.csv")

# A tibble: 1,212 x 8
   postcode telephone    organisation_code city        county     opendate   closedate  practice_type
   <chr>    <chr>        <chr>             <chr>       <chr>      <date>     <date>             <dbl>
 1 DD2 5NH  01382 580264 S10002            DUNDEE      ANGUS      1995-05-01 NA                     4
 2 PH7 3SA  01764 652283 S10017            CRIEFF      PERTHSHIRE 1996-04-06 NA                     4
 
 ```
 
### Not a hash

The ciphertext produced for a given input will change with each encryption. This is a feature of the RSA algorithm. Ciphertexts should not therefore be attempted to be matched between datasets encrypted using the same public key. This is a conscious decision given the risks associated with sharing the necessary details (a salt).


## Getting started: encrypt and decrypt files

Encryption and decryption with asymmetric keys is computationally expensive. This is how `encrypt` above works. This makes it easy for each piece of data in a data frame to be decrypted without compromise of the whole data frame. This works on the presumption that each cell contains less than 245 bytes of data.

File encryption requires a different approach as files are often larger in size. `encrypt_file` encrypts a file using a symmetric "session" key and the AES-256 cipher. This key is itself then encrypted using a public key generated using genkeys. In OpenSSL this combination is referred to as an envelope.

### Generate keys 

``` r
genkeys()
> Private key written with name 'id_rsa'
> Public key written with name 'id_rsa.pub'
```

### Encrypt file

To demonstrate, the included dataset is written as a .csv file. 

``` r
write.csv(gp, "gp.csv")

encrypt_file("gp.csv")
> Encrypted file written with name 'gp.csv.encryptr.bin'
```

Check that the file can be decrypted prior to removing the original file from your system. Warning: it is strongly suggested that the original unencrypted data file is stored as a back-up in case unencryption is not possible, e.g., the private key file or password is lost

The `decrypt_file` function will not allow the original file to be overwritten, therefore use the option to specify a new name for the unencrypted file. 

``` r
decrypt_file("gp.csv.encryptr.bin", file_name = "gp2.csv")
> Decrypted file written with name 'gp2.csv'
```

## Providing a public key

In collaborative projects where data may be pooled, a public key can be made available by you via a link to enable collaborators to encrypt sensitive data, e.g. 

``` r
gp_encrypt = gp %>% 
  select(-c(name, address1, address2, address3)) %>% 
  encrypt(postcode, telephone, public_key_path = "https://argonaut.is.ed.ac.uk/public/id_rsa.pub")
```



## Caution

All confidential information must be treated with the utmost care. Data should never be carried on removable devices or portable computers. Data should never be sent by open email. Encrypting data provides some protection against disclosure. But particularly in healthcare, data often remains potentially disclosive (or only pseudonymised) even after encryption of identifiable variables. Treat it with great care and respect. 
