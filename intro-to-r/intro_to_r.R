# ============================================================================ #
# A1: Introduction to R
# Econometrics (Master) -- Otto von Guericke University Magdeburg
# Instructor: Felix Noth
#
# How to use this script
#   Open it in RStudio and run it LINE BY LINE: put the cursor on a line and
#   press Ctrl+Enter (Windows) or Cmd+Enter (Mac). Watch each result appear
#   in the console before moving on. Do not run the whole file at once; the
#   point of this session is to see what every line does.
#
#   Lines starting with # are comments. R ignores them; you should not.
#   Blocks marked TRY IT are small tasks for you. Solutions are at the very
#   bottom of the script -- try first, peek later.
#
# Before class (see Alexander 2023, chapters A.3.1 and A.3.2)
#   1. Install R:       https://cran.r-project.org
#   2. Install RStudio: https://posit.co/download/rstudio-desktop/
#   3. Run this once in the RStudio console (not needed again afterwards):
#        install.packages(c("tidyverse", "causaldata"))
#
# Course page: https://felixnoth.github.io/teaching/econometrics-master.html
# Textbook:    Huntington-Klein (2021), The Effect -- theeffectbook.net
# ============================================================================ #


# ---------------------------------------------------------------------------- #
# 0. Finding your way around RStudio
# ---------------------------------------------------------------------------- #
# RStudio shows four panes:
#   top-left:     this script (your lab notebook -- everything worth keeping
#                 goes here, so you can redo your analysis at any time)
#   bottom-left:  the console (where code actually runs; good for quick
#                 experiments, bad for anything you want to keep)
#   top-right:    Environment (every object currently in memory)
#   bottom-right: Files / Plots / Packages / Help
#
# The single most important habit from day one: work in a script, run line by
# line, and treat the console as scratch paper. If your analysis only exists
# in the console, it is gone tomorrow.

# Run your first line (Ctrl+Enter / Cmd+Enter):
1 + 1

# R evaluates the line and prints the result in the console. The [1] in front
# of the output is just R numbering the elements of the result.

# Help works with a question mark. This opens the Help pane:
?mean

# Where on your computer is R currently working? (This matters when reading
# and saving files. In this session we won't read files from disk -- but note
# the concept. Best practice for your own projects: RStudio Projects,
# File > New Project, which pin the working directory to a folder.)
getwd()


# ---------------------------------------------------------------------------- #
# 1. Objects, vectors, functions
# ---------------------------------------------------------------------------- #
# R is a calculator with memory. You store results in named objects using the
# arrow <- (RStudio shortcut: Alt+Minus).

x <- 5          # nothing prints -- the value went into the object
x               # typing the name prints the object
x * 2

# The fundamental data structure is the vector: an ordered collection of
# values of the SAME type. c() ("combine") builds one.

age  <- c(35, 42, 29, 51, 38)
name <- c("Anna", "Ben", "Carla", "David", "Emma")

# Operations are vectorized -- they apply to every element at once, no loop:
age + 1
age >= 40                       # comparisons give TRUE/FALSE vectors

# Functions take inputs in parentheses and return a result:
mean(age)
sd(age)
length(age)
sort(age)

# Square brackets select elements by position or condition:
age[1]                          # first element (R counts from 1!)
age[c(1, 3)]                    # first and third
age[age >= 40]                  # condition inside brackets: only TRUE positions
name[age >= 40]                 # conditions from one vector can select another

# Missing values are NA, and they are contagious -- one NA poisons a mean:
income <- c(3200, 2800, NA, 4100)
mean(income)                    # NA -- R refuses to guess
mean(income, na.rm = TRUE)      # explicitly remove missings first
is.na(income)                   # where are the missings?

# Every object has a type ("class"). The big three for us:
class(age)                      # numeric
class(name)                     # character
class(age >= 40)                # logical

# TRY IT #1 -----------------------------------------------------------------
# (a) Create a vector `grades` with the values 1.0, 1.7, 2.3, 3.0, 5.0.
# (b) Compute its mean and standard deviation.
# (c) Select all grades better (smaller) than 2.5.
# -----------------------------------------------------------------------------


# ---------------------------------------------------------------------------- #
# 2. Packages and real data
# ---------------------------------------------------------------------------- #
# Base R is extended by packages. You installed two before class; now you load
# them (loading is needed once per R session):

library(tidyverse)    # data manipulation (dplyr) + plotting (ggplot2) + more
library(causaldata)   # the datasets used in our textbook, The Effect

# Our first dataset: Mroz (1987, Econometrica) -- 753 married women from the
# Panel Study of Income Dynamics. The Effect uses it in the chapter on
# describing relationships. Variables include:
#   lfp   labor-force participation (TRUE/FALSE)
#   k5    number of children aged 5 or younger
#   age   age in years
#   wc    wife attended college
#   lwg   log expected wage rate
#   inc   family income excluding the wife's income

# First contact with ANY dataset -- always these three:
nrow(Mroz)            # how many observations?
glimpse(Mroz)         # all columns, their types, first values
summary(Mroz)         # quick distribution overview per column

# A single column is extracted with $ -- it is just a vector, so everything
# from section 1 applies:
mean(Mroz$age)
table(Mroz$k5)        # frequency table (Stata users: this is -tab-)

# View(Mroz) opens a spreadsheet view -- useful for looking, useless for
# analysis; nothing you click there is reproducible.


# ---------------------------------------------------------------------------- #
# 3. Processing data with dplyr
# ---------------------------------------------------------------------------- #
# dplyr gives you five verbs that cover most of what you did in the data
# section of any empirical paper. Each takes a dataset, returns a dataset:
#
#   filter()     keep rows meeting a condition
#   select()     keep columns
#   mutate()     create or change columns
#   arrange()    sort rows
#   summarize()  collapse to summary numbers (often after group_by())
#
# The pipe |> passes the result of one line into the next, so code reads like
# a sentence: "take Mroz, THEN filter, THEN select ...". (In the textbook you
# will also see %>%, an older pipe -- for our purposes they are the same.)

# Keep only women in the labor force. First look at how the variable is
# coded -- ALWAYS check before you filter, so you know what you are asking:
table(Mroz$lfp)

working <- Mroz |>
  filter(lfp == TRUE)
nrow(working)                       # 428 of the 753

# Conditions combine with & (and) and | (or):
Mroz |>
  filter(lfp == TRUE & k5 == 0) |>
  nrow()

# Keep a few columns, sort by income, look at the top:
Mroz |>
  select(age, wc, lwg, inc) |>
  arrange(desc(inc)) |>             # desc() = descending
  head()

# Create new variables with mutate():
mroz2 <- Mroz |>
  mutate(
    kids       = k5 + k618,              # total number of children
    inc_person = inc / (2 + kids)        # crude per-head family income
  )
glimpse(mroz2)

# Collapse to summaries -- first overall, then by group:
Mroz |>
  summarize(
    n        = n(),                      # n() counts rows
    mean_age = mean(age),
    mean_inc = mean(inc)
  )

# group_by() + summarize() is the workhorse of descriptive tables
# (Stata users: this is -collapse- / -tabstat, by()-):
Mroz |>
  group_by(wc) |>                        # wife went to college vs not
  summarize(
    n         = n(),
    mean_lwg  = mean(lwg),
    mean_inc  = mean(inc)
  )

# Read that table like an economist: college-educated women have higher
# expected wages AND richer husbands -- a first taste of why raw differences
# are not causal effects (much more on this in A2 and the whole course).

# TRY IT #2 -----------------------------------------------------------------
# (a) How many women in Mroz are NOT in the labor force? (filter + nrow)
# (b) Among working women (lfp == TRUE), what is the average number of small
#     children k5 for women with and without a college degree wc?
#     (filter, then group_by, then summarize)
# -----------------------------------------------------------------------------


# ---------------------------------------------------------------------------- #
# 4. Moments of a distribution
# ---------------------------------------------------------------------------- #
# Empirical work starts with knowing your variables' distributions. The
# moments and quantiles, one line each:

inc <- Mroz$inc

mean(inc)                             # 1st moment: location
var(inc)                              # 2nd central moment: spread (squared)
sd(inc)                               # its square root -- same units as inc
median(inc)                           # robust location
quantile(inc, c(.10, .25, .50, .75, .90))   # where the distribution sits
IQR(inc)                              # 75th minus 25th percentile

# Mean far above median = right skew: a few rich families pull the mean up.
# The standardized 3rd moment (skewness) measures this. Base R has no
# skewness function -- so we compute it ourselves, which R makes trivial:
mean(((inc - mean(inc)) / sd(inc))^3)      # > 0 confirms right skew

# For a paper or a seminar presentation you want moments for several
# variables at once -- summarize() with across() does that:
Mroz |>
  summarize(across(
    c(age, lwg, inc),
    list(mean = mean, sd = sd, median = median)
  ))

# TRY IT #3 -----------------------------------------------------------------
# Compute mean, median, and sd of lwg separately for working and
# non-working women (group_by(lfp)). For which group is lwg not an actual
# wage but an imputed one? (Hint: re-read the variable list in section 2.)
# -----------------------------------------------------------------------------


# ---------------------------------------------------------------------------- #
# 5. Plotting with ggplot2
# ---------------------------------------------------------------------------- #
# Switching datasets: restaurant_inspections -- 27,178 health inspections in
# Anchorage, Alaska; The Effect uses it in the regression chapter.
#   inspection_score    health inspection score (the outcome)
#   NumberofLocations   how many locations the restaurant chain has
#   Year                year of the inspection
#   Weekend             was the inspection on a weekend?

glimpse(restaurant_inspections)

# ggplot2 builds figures in layers:
#   ggplot(data, aes(...))  what data, and which variables map to which axis
#   + geom_...()            how to draw it (histogram, points, lines, ...)
#   + labs(...)             labels -- always label your axes
#
# (1) The distribution of one variable: histogram
ggplot(restaurant_inspections, aes(x = inspection_score)) +
  geom_histogram(binwidth = 1) +
  labs(x = "Inspection score", y = "Count")

# Never accept a default binwidth without looking twice. TRY binwidth = 5
# and binwidth = 0.5 -- same data, different stories. That fine structure
# at scores just below round numbers is real: graders bunch.

# (2) A smoothed version: density
ggplot(restaurant_inspections, aes(x = inspection_score)) +
  geom_density() +
  labs(x = "Inspection score", y = "Density")

# (3) Distributions BY GROUP: boxplots put moments on display --
#     the box is the IQR, the line the median, dots are outliers
#     factor() turns a variable into an explicit grouping variable -- robust
#     no matter how Weekend is stored (logical, 0/1, or text)
ggplot(restaurant_inspections,
       aes(x = factor(Weekend), y = inspection_score)) +
  geom_boxplot() +
  labs(x = "Weekend inspection", y = "Inspection score")

# (4) Relationship between two variables: scatter plot.
#     27,178 points overlap heavily -- alpha makes points transparent so
#     mass becomes visible.
ggplot(restaurant_inspections,
       aes(x = NumberofLocations, y = inspection_score)) +
  geom_point(alpha = 0.1) +
  labs(x = "Number of chain locations", y = "Inspection score")

# (5) Add a fitted line: geom_smooth. method = "lm" is a linear fit -- your
#     first regression line of the course, drawn before we ever run one.
ggplot(restaurant_inspections,
       aes(x = NumberofLocations, y = inspection_score)) +
  geom_point(alpha = 0.1) +
  geom_smooth(method = "lm") +
  labs(
    x = "Number of chain locations",
    y = "Inspection score",
    title = "Bigger chains get better inspection scores"
  )

# Read it like an economist: is this the causal effect of chain size on
# hygiene? Or do chains standardize processes, choose locations, train
# staff...? Describing the relationship is step one; the rest of this course
# is about when a line like this means what we want it to mean.

# (6) Saving a figure for your term paper / slides:
#     ggsave writes the last plot to disk (into getwd(), see section 0)
ggsave("scatter_inspections.png", width = 8, height = 5)

# TRY IT #4 -----------------------------------------------------------------
# (a) Draw the histogram of lwg in the Mroz data. Choose a sensible binwidth.
# (b) Scatter lwg (y) against age (x) for working women only
#     (filter first, then pipe into ggplot), and add a linear fit.
# -----------------------------------------------------------------------------


# ---------------------------------------------------------------------------- #
# 6. Putting it all together: one complete descriptive analysis
# ---------------------------------------------------------------------------- #
# A final trial run, structured the way you would start ANY empirical
# project: look at the data, describe the variables, then study a
# relationship -- first with graphs, then as correlations.
#
# Data: gapminder -- life expectancy and GDP per capita for 142 countries,
# 1952-2007 (one row per country-year; also in causaldata).

glimpse(gapminder)

# Step 1: restrict to the sample you want -- the most recent cross-section
gm <- gapminder |>
  filter(year == 2007)
nrow(gm)                                # one row per country now

# Step 2: descriptive statistics of the variables of interest
gm |>
  summarize(across(
    c(lifeExp, gdpPercap),
    list(mean = mean, median = median, sd = sd, min = min, max = max)
  ))

# For GDP per capita the mean sits far above the median -- right skew, as
# with the family incomes in section 4. Confirm by eye:
ggplot(gm, aes(x = gdpPercap)) +
  geom_histogram(bins = 30) +
  labs(x = "GDP per capita (USD)", y = "Count")

# Step 3: the relationship, as a graph
ggplot(gm, aes(x = gdpPercap, y = lifeExp)) +
  geom_point() +
  geom_smooth(method = "lm") +
  labs(x = "GDP per capita (USD)", y = "Life expectancy (years)")

# Strong -- but clearly not linear: gains flatten out at high incomes, and
# the linear fit misses both ends. Money variables in economics usually live
# on a log scale; one added layer re-draws the picture:
ggplot(gm, aes(x = gdpPercap, y = lifeExp)) +
  geom_point() +
  geom_smooth(method = "lm") +
  scale_x_log10() +
  labs(x = "GDP per capita (USD, log scale)", y = "Life expectancy (years)")

# Step 4: the relationship, as a number. cor() gives the Pearson
# correlation coefficient; compare the linear and the log version:
cor(gm$lifeExp, gm$gdpPercap)             # linear:   understates the link
cor(gm$lifeExp, log(gm$gdpPercap))        # in logs:  much stronger

# The rank (Spearman) correlation ignores the functional form entirely --
# it asks only: do richer countries rank higher in life expectancy?
cor(gm$lifeExp, gm$gdpPercap, method = "spearman")

# Spearman close to the log-Pearson, both far above the linear Pearson:
# the association is tight and monotone, and approximately linear in logs.
# The graph told you this already -- the numbers now let you report it.

# Correlations by group: summarize() accepts any function, cor() included
gm |>
  group_by(continent) |>
  summarize(
    n          = n(),
    cor_loginc = cor(lifeExp, log(gdpPercap))
  )

# Step 5: say it in words. Across countries in 2007, life expectancy and
# log GDP per capita are strongly positively correlated; the association
# holds within every continent, though with varying strength. That is a
# DESCRIPTION, not a causal effect of income on health -- distinguishing
# the two is what the rest of this course is about.

# TRY IT #5 -----------------------------------------------------------------
# Repeat steps 1, 2, and 4 for the year 1952: descriptive statistics of
# lifeExp and gdpPercap, then the three correlations (linear, log,
# Spearman). Is the income-longevity association stronger or weaker than
# in 2007?
# -----------------------------------------------------------------------------


# ---------------------------------------------------------------------------- #
# 7. Wrap-up: working reproducibly
# ---------------------------------------------------------------------------- #
# The habits that matter from today:
#
#   1. Everything lives in a script. Rule of thumb: Session > Restart R,
#      then run your script top to bottom -- it must reproduce every result.
#      If it doesn't, something lives only in your console or environment.
#   2. First contact with data: nrow(), glimpse(), summary(). Every time.
#   3. Moments before models. Know the distribution of every variable you
#      will later put into a regression.
#   4. Label your axes. Your future referees thank you.
#
# Where to go from here:
#   - The Effect, chapters on describing variables and relationships
#     (free at theeffectbook.net) -- uses the same datasets you saw today
#   - Alexander (2023), Telling Stories with Data, appendix A and B
#     (free at tellingstorieswithdata.com)
#   - Cheatsheets in RStudio: Help > Cheat Sheets (dplyr and ggplot2)
#
# The five exercise sessions (E1-E5) build directly on today's toolkit; their
# scripts will appear in this repository under exercises/.


# ============================================================================ #
# Solutions to the TRY IT blocks -- no peeking before trying
# ============================================================================ #

# TRY IT #1
# grades <- c(1.0, 1.7, 2.3, 3.0, 5.0)
# mean(grades)
# sd(grades)
# grades[grades < 2.5]

# TRY IT #2
# (a)
# Mroz |> filter(lfp == FALSE) |> nrow()          # 325
# (b)
# Mroz |>
#   filter(lfp == TRUE) |>
#   group_by(wc) |>
#   summarize(mean_k5 = mean(k5))

# TRY IT #3
# Mroz |>
#   group_by(lfp) |>
#   summarize(mean = mean(lwg), median = median(lwg), sd = sd(lwg))
# For non-working women (lfp == FALSE) lwg is imputed from a regression --
# they report no wage. Note their lwg distribution is also less dispersed:
# imputations are smoother than reality.

# TRY IT #4
# (a)
# ggplot(Mroz, aes(x = lwg)) +
#   geom_histogram(binwidth = 0.25) +
#   labs(x = "Log expected wage", y = "Count")
# (b)
# Mroz |>
#   filter(lfp == TRUE) |>
#   ggplot(aes(x = age, y = lwg)) +
#   geom_point(alpha = 0.4) +
#   geom_smooth(method = "lm") +
#   labs(x = "Age", y = "Log wage")

# TRY IT #5
# gm52 <- gapminder |> filter(year == 1952)
# gm52 |>
#   summarize(across(
#     c(lifeExp, gdpPercap),
#     list(mean = mean, median = median, sd = sd, min = min, max = max)
#   ))
# cor(gm52$lifeExp, gm52$gdpPercap)
# cor(gm52$lifeExp, log(gm52$gdpPercap))
# cor(gm52$lifeExp, gm52$gdpPercap, method = "spearman")
# Compare all three across the two years. Note the 1952 income distribution
# is far more skewed (one extreme oil-state outlier), so the gap between the
# linear Pearson and the other two is especially instructive there.
