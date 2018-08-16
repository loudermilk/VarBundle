# VarBundle
<img src="inst/images/varbundle.png" align="center" height="300"/>

**Author:** Brandon C. Loudermilk  

**Introduction:** VarBundles support defensive programming by making it easy for R developers to bundle conceptually related read-only variables in a named, list-like object of unmutable constants. 

```
library(VarBundle)
thresholds <- varbundle(list(min = 1, max = 100))

# Read-only Access
thresholds$max #100
thresholds[["min"]] #1

# Assignment throws error
thresholds$min <- 25 # VarBundle fields are read only.

# Cannot create new fields after object creation
thesholds$foo <- 10 # Cannot add new fields to VarBundle
```
The quickest way to learn about {VarBundle} is to install the package and read the vignette.

```
browseVignettes(package = "VarBundle")
```

