# ============================================================================ #
# A1 (alternative): Introduction to Python
# Econometrics (Master) -- Otto von Guericke University Magdeburg
# Instructor: Felix Noth
#
# R is the mandatory language of this course -- all exercises and solutions
# are in R. This script is the OPTIONAL Python twin of intro_to_r.R: same
# sections, same datasets, same analyses, so you can read them side by side
# and see that the ideas, not the language, are what matters.
#
# How to use this script
#   The lines with "# %%" split the script into cells. Open it in VS Code
#   (with the Python extension) or Spyder and run cell by cell with
#   Shift+Enter, watching each result appear before moving on. Jupyter users
#   can open it as a notebook (VS Code does this automatically).
#
#   Lines starting with # are comments. Blocks marked TRY IT are small tasks
#   for you; solutions sit at the very bottom -- try first, peek later.
#
# Before you start (once)
#   1. Install Python via Anaconda (simplest): https://www.anaconda.com/download
#      -- or plain Python from https://www.python.org
#   2. In a terminal (Anaconda Prompt on Windows) run:
#        pip install pandas seaborn matplotlib causaldata
#
# Course page: https://felixnoth.github.io/teaching/econometrics-master.html
# Textbook:    Huntington-Klein (2021), The Effect -- theeffectbook.net
# ============================================================================ #

# %% ------------------------------------------------------------------------- #
# 0. Finding your way around
# ---------------------------------------------------------------------------- #
# Python has no single RStudio, but the layout is the same everywhere:
# a script (your lab notebook -- everything worth keeping goes here) and an
# interactive console where cells you run show their results. VS Code and
# Spyder both give you a variable explorer and a plots pane as well.
#
# The habit that matters is identical to R: work in the script, run cell by
# cell, treat the console as scratch paper.

1 + 1

# Help works with help() -- or put the cursor on a name in VS Code/Spyder
# and hover:
help(len)

# Where on your computer is Python currently working? (Matters when reading
# and saving files.)
import os
os.getcwd()

# %% ------------------------------------------------------------------------- #
# 1. Objects, lists, functions
# ---------------------------------------------------------------------------- #
# Python is a calculator with memory. Assignment uses = (there is no <-).

x = 5           # nothing prints -- the value went into the object
x               # a bare name at the end of a cell prints the object
x * 2

# The basic collection is the list:
age = [35, 42, 29, 51, 38]
name = ["Anna", "Ben", "Carla", "David", "Emma"]

# CAREFUL, first real difference from R: plain lists are NOT vectorized.
age + [1]       # + concatenates lists, it does not add 1 to each element!

# Built-in functions cover the basics:
sum(age) / len(age)
sorted(age)
max(age)

# Square brackets select by position -- and Python counts from 0, not 1:
age[0]          # FIRST element (in R this was age[1])
age[0:2]        # elements 0 and 1 -- the right end is EXCLUDED
name[-1]        # negative indices count from the end: last element

# Vectorized math on whole columns is what pandas (next section) is for.
# That asymmetry is the single biggest R-to-Python adjustment: in R the
# vector is the basic object; in Python you get vectors from a library.

# Missing values: Python's general "nothing" is None; in data work you will
# mostly meet NaN (not-a-number), which behaves like R's NA in pandas --
# contagious in arithmetic, needs dedicated functions to detect.

# Types:
type(age)       # list
type(x)         # int
type("text")    # str
type(True)      # bool

# TRY IT #1 -----------------------------------------------------------------
# (a) Create a list `grades` with the values 1.0, 1.7, 2.3, 3.0, 5.0.
# (b) Compute its mean (sum / len) and its maximum.
# (c) Select the first two grades using a slice.
# -----------------------------------------------------------------------------

# %% ------------------------------------------------------------------------- #
# 2. Packages and real data
# ---------------------------------------------------------------------------- #
# Libraries are imported once per session. The two conventions to memorize:

import pandas as pd                    # THE data library; always "pd"
from causaldata import Mroz            # the textbook's datasets

# Loading a dataset from causaldata (the .data at the end gives a pandas
# DataFrame -- the Python equivalent of R's data frame):
mroz = Mroz.load_pandas().data

# The Python package ships the data with a leftover row-index column called
# "Unnamed: 0". Real data always has some artifact like this; drop it:
mroz = mroz.drop(columns="Unnamed: 0")

# Same dataset as in the R session: 753 married women from the PSID
# (Mroz 1987, Econometrica). Variables:
#   lfp   labor-force participation (True/False)
#   k5    number of children aged 5 or younger
#   age   age in years
#   wc    wife attended college (True/False)
#   lwg   log expected wage rate
#   inc   family income excluding the wife's income

# First contact with ANY dataset -- always these three:
mroz.shape                             # (rows, columns)
mroz.info()                            # columns, types, missing counts
mroz.describe()                        # distribution overview per column

# A single column is extracted with brackets -- it is a pandas Series, and
# unlike a list it IS vectorized:
mroz["age"].mean()
mroz["k5"].value_counts()              # frequency table (R: table(); Stata: tab)

# %% ------------------------------------------------------------------------- #
# 3. Processing data with pandas
# ---------------------------------------------------------------------------- #
# The same five operations as dplyr's verbs, in pandas idiom:
#
#   filter rows      df[condition]           (a "boolean mask")
#   select columns   df[["col1", "col2"]]
#   new column       df["new"] = ...
#   sort             df.sort_values()
#   collapse         df.groupby().agg()

# Look at the coding BEFORE filtering -- always:
mroz["lfp"].value_counts()

# Keep only women in the labor force:
working = mroz[mroz["lfp"] == True]
len(working)                           # 428 of the 753

# Conditions combine with & (and) and | (or) -- parentheses are REQUIRED:
len(mroz[(mroz["lfp"] == True) & (mroz["k5"] == 0)])

# Keep a few columns, sort by income, look at the top:
(mroz[["age", "wc", "lwg", "inc"]]
    .sort_values("inc", ascending=False)
    .head())
# Note the outer parentheses: they let a chain of operations span several
# lines -- the pandas equivalent of R's pipe |>.

# Create new variables:
mroz2 = mroz.copy()                    # work on a copy, keep the original
mroz2["kids"] = mroz2["k5"] + mroz2["k618"]
mroz2["inc_person"] = mroz2["inc"] / (2 + mroz2["kids"])
mroz2.info()

# Collapse to summaries -- overall, then by group:
mroz.agg(n=("age", "size"), mean_age=("age", "mean"), mean_inc=("inc", "mean"))

# groupby + agg is the workhorse of descriptive tables
# (R: group_by + summarize; Stata: collapse / tabstat, by()):
mroz.groupby("wc").agg(
    n=("age", "size"),
    mean_lwg=("lwg", "mean"),
    mean_inc=("inc", "mean"),
)

# Read it like an economist, same as in the R session: college-educated
# women have higher expected wages AND richer husbands -- raw differences
# are not causal effects.

# TRY IT #2 -----------------------------------------------------------------
# (a) How many women in mroz are NOT in the labor force?
# (b) Among working women, what is the average number of small children k5
#     for women with and without a college degree wc?
#     (filter first, then groupby + agg)
# -----------------------------------------------------------------------------

# %% ------------------------------------------------------------------------- #
# 4. Moments of a distribution
# ---------------------------------------------------------------------------- #
inc = mroz["inc"]

inc.mean()                             # 1st moment: location
inc.var()                              # 2nd central moment: spread (squared)
inc.std()                              # its square root -- same units as inc
inc.median()                           # robust location
inc.quantile([0.10, 0.25, 0.50, 0.75, 0.90])
inc.quantile(0.75) - inc.quantile(0.25)    # interquartile range

# Mean far above median = right skew. The standardized 3rd moment
# (skewness), computed by hand exactly as in the R session:
(((inc - inc.mean()) / inc.std()) ** 3).mean()     # > 0 confirms right skew

# Moments for several variables at once, presentable:
mroz[["age", "lwg", "inc"]].agg(["mean", "std", "median"])

# TRY IT #3 -----------------------------------------------------------------
# Compute mean, median, and std of lwg separately for working and
# non-working women (groupby("lfp")). For which group is lwg not an actual
# wage but an imputed one? (Hint: re-read the variable list in section 2.)
# -----------------------------------------------------------------------------

# %% ------------------------------------------------------------------------- #
# 5. Plotting with seaborn
# ---------------------------------------------------------------------------- #
# seaborn plays the role ggplot2 played in R: a high-level plotting library
# (built on matplotlib, Python's plotting engine -- we use matplotlib
# directly only for labels and saving).

import matplotlib.pyplot as plt
import seaborn as sns
from causaldata import restaurant_inspections

rest = restaurant_inspections.load_pandas().data
rest.info()
# Same data as in the R session: 27,178 health inspections in Anchorage.

# (1) The distribution of one variable: histogram
sns.histplot(data=rest, x="inspection_score", binwidth=1)
plt.xlabel("Inspection score"); plt.ylabel("Count")
plt.show()

# Never accept a default binwidth without looking twice: try 5 and 0.5.
# The spikes just below round numbers are real -- graders bunch.

# (2) A smoothed version: density
sns.kdeplot(data=rest, x="inspection_score")
plt.xlabel("Inspection score")
plt.show()

# (3) Distributions BY GROUP: boxplots put the moments on display
sns.boxplot(data=rest, x="Weekend", y="inspection_score")
plt.xlabel("Weekend inspection"); plt.ylabel("Inspection score")
plt.show()

# (4) Relationship between two variables: scatter plot, with transparency
#     (alpha) so 27,178 overlapping points show where the mass is
sns.scatterplot(data=rest, x="NumberofLocations", y="inspection_score",
                alpha=0.1)
plt.xlabel("Number of chain locations"); plt.ylabel("Inspection score")
plt.show()

# (5) Add a fitted line: regplot = scatter + linear fit. Your first
#     regression line of the course, drawn before we ever run one.
sns.regplot(data=rest, x="NumberofLocations", y="inspection_score",
            scatter_kws={"alpha": 0.1})
plt.xlabel("Number of chain locations"); plt.ylabel("Inspection score")
plt.title("Bigger chains get better inspection scores")
plt.show()

# Same question as in R: is that the causal effect of chain size on
# hygiene? Describing the relationship is step one; the rest of the course
# is about when a line like this means what we want it to mean.

# (6) Saving a figure for your term paper / slides:
sns.regplot(data=rest, x="NumberofLocations", y="inspection_score",
            scatter_kws={"alpha": 0.1})
plt.xlabel("Number of chain locations"); plt.ylabel("Inspection score")
plt.savefig("scatter_inspections.png", dpi=200, bbox_inches="tight")
plt.close()

# TRY IT #4 -----------------------------------------------------------------
# (a) Draw the histogram of lwg in the mroz data. Choose a sensible binwidth.
# (b) Scatter lwg (y) against age (x) for working women only, with a linear
#     fit (filter first, then regplot).
# -----------------------------------------------------------------------------

# %% ------------------------------------------------------------------------- #
# 6. Putting it all together: one complete descriptive analysis
# ---------------------------------------------------------------------------- #
# The same capstone as in the R session: look at the data, describe the
# variables, then study a relationship -- graphs first, then correlations.
# Data: gapminder -- life expectancy and GDP per capita, 142 countries,
# 1952-2007, one row per country-year.

import numpy as np
from causaldata import gapminder

gap = gapminder.load_pandas().data
gap.info()

# Step 1: restrict to the sample you want -- the most recent cross-section
gm = gap[gap["year"] == 2007].copy()
len(gm)                                # one row per country now

# Step 2: descriptive statistics of the variables of interest
gm[["lifeExp", "gdpPercap"]].agg(["mean", "median", "std", "min", "max"])

# Mean far above median for gdpPercap -- right skew again. Confirm by eye:
sns.histplot(data=gm, x="gdpPercap", bins=30)
plt.xlabel("GDP per capita (USD)"); plt.ylabel("Count")
plt.show()

# Step 3: the relationship, as a graph
sns.regplot(data=gm, x="gdpPercap", y="lifeExp",
            scatter_kws={"alpha": 0.6})
plt.xlabel("GDP per capita (USD)"); plt.ylabel("Life expectancy (years)")
plt.show()

# Strong -- but clearly not linear: gains flatten out at high incomes.
# Money variables usually live on a log scale; create the log variable and
# re-draw (np.log is the vectorized natural log):
gm["log_gdp"] = np.log(gm["gdpPercap"])

sns.regplot(data=gm, x="log_gdp", y="lifeExp", scatter_kws={"alpha": 0.6})
plt.xlabel("log GDP per capita"); plt.ylabel("Life expectancy (years)")
plt.show()

# Step 4: the relationship, as a number. .corr() gives the Pearson
# correlation; compare the linear and the log version:
gm["lifeExp"].corr(gm["gdpPercap"])            # linear:  understates the link
gm["lifeExp"].corr(gm["log_gdp"])              # in logs: much stronger

# The rank (Spearman) correlation ignores the functional form entirely:
gm["lifeExp"].corr(gm["gdpPercap"], method="spearman")

# Spearman close to the log-Pearson, both far above the linear Pearson:
# the association is tight and monotone, approximately linear in logs.
# The graph told you this already -- the numbers let you report it.

# Correlations by group -- iterating over groups is the flexible pattern
# for any statistic that needs two columns at once:
for continent, d in gm.groupby("continent"):
    print(continent, len(d), round(d["lifeExp"].corr(d["log_gdp"]), 2))

# One of these numbers is a trap: Oceania shows a perfect 1.0 -- because it
# has exactly two countries, and through two points a line always fits
# perfectly. Statistics without their n are not statistics.

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

# %% ------------------------------------------------------------------------- #
# 7. Wrap-up: working reproducibly
# ---------------------------------------------------------------------------- #
# The habits are language-independent:
#
#   1. Everything lives in a script. Restart the kernel/console, run top to
#      bottom -- it must reproduce every result.
#   2. First contact with data: .shape, .info(), .describe(). Every time.
#   3. Moments before models.
#   4. Label your axes.
#
# R-to-Python rosetta stone for this session:
#
#   R / tidyverse                     Python / pandas
#   --------------------------------  -----------------------------------
#   read_csv() / data(pkg)            pd.read_csv() / load_pandas().data
#   glimpse(df)                       df.info()
#   df$col                            df["col"]
#   filter(df, cond)                  df[cond]
#   select(df, a, b)                  df[["a", "b"]]
#   mutate(df, y = x*2)               df["y"] = df["x"] * 2
#   arrange(df, desc(x))              df.sort_values("x", ascending=False)
#   group_by() |> summarize()         df.groupby().agg()
#   table(df$col)                     df["col"].value_counts()
#   cor(x, y)                         x.corr(y)
#   ggplot + geom_histogram           sns.histplot
#   ggplot + geom_boxplot             sns.boxplot
#   ggplot + geom_point + geom_smooth sns.regplot
#   ggsave()                          plt.savefig()
#
# Remember: the exercises of this course are in R. Use this script if you
# want to build the Python muscle alongside -- everything you learn about
# the econometrics transfers one-to-one.


# ============================================================================ #
# Solutions to the TRY IT blocks -- no peeking before trying
# ============================================================================ #

# TRY IT #1
# grades = [1.0, 1.7, 2.3, 3.0, 5.0]
# sum(grades) / len(grades)
# max(grades)
# grades[0:2]

# TRY IT #2
# (a)
# len(mroz[mroz["lfp"] == False])          # 325
# (b)
# (mroz[mroz["lfp"] == True]
#     .groupby("wc")
#     .agg(mean_k5=("k5", "mean")))

# TRY IT #3
# mroz.groupby("lfp")["lwg"].agg(["mean", "median", "std"])
# For non-working women (lfp == False) lwg is imputed from a regression --
# they report no wage. Their lwg is also less dispersed: imputations are
# smoother than reality.

# TRY IT #4
# (a)
# sns.histplot(data=mroz, x="lwg", binwidth=0.25)
# plt.xlabel("Log expected wage"); plt.show()
# (b)
# working = mroz[mroz["lfp"] == True]
# sns.regplot(data=working, x="age", y="lwg", scatter_kws={"alpha": 0.4})
# plt.xlabel("Age"); plt.ylabel("Log wage"); plt.show()

# TRY IT #5
# gm52 = gap[gap["year"] == 1952].copy()
# gm52[["lifeExp", "gdpPercap"]].agg(["mean", "median", "std", "min", "max"])
# gm52["lifeExp"].corr(gm52["gdpPercap"])
# gm52["lifeExp"].corr(np.log(gm52["gdpPercap"]))
# gm52["lifeExp"].corr(gm52["gdpPercap"], method="spearman")
# Compare all three across the two years. Note the 1952 income distribution
# is far more skewed (one extreme oil-state outlier), so the gap between the
# linear Pearson and the other two is especially instructive there.
