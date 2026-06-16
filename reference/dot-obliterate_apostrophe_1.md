# Remove apostrophe

Removes commas to make ease creation of regular expressions. After
implmenting this function, "ball's" should become balls and l'Alba
should become lAlba and balls' into balls.

## Usage

``` r
.obliterate_apostrophe_1(article)
```

## Arguments

- article:

  A List with paragraphs of interest.

## Value

The list of paragraphs without mentions of financial COIs.
