# Carsten Langer, 2015-05-06
# Coursera Data Science Specialization, Exploratory Data Analysis, Course Project 1

###########
# First part of the code is the same for all 4 plots.
# Normally is should be carved out to a function and a separate file and then sourced in.
# However, the assignment says: "Your code file should include code for reading the data ..."
# Therefore I duplicate tha code, to follow the assignment.
###########

# Read the data from Internet
url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
local.zip.file <- "household_power_consumption.zip"
local.file <- "household_power_consumption.txt"

if (!file.exists(local.file)) {
        download.file(url, local.zip.file)
        unzip(local.zip.file)
}

# Rough estimation of memory comsumption: 2,075,259 * 9 * 8 Byte / (1,024 * 1,024 Byte / MiB) = 142 MiB.
# It is worth using data.tab.e instead of data.frame
require(data.table)
require(lubridate)  # Must load libraries in this order, as lubridate masks some date functions of data.table.

# Loading and cleaning the data

# Read file. Missing values are noted by either "?" for non-last fields and by nothing in the last field.
# There is a pending issue with fread() (https://github.com/Rdatatable/data.table/issues/504).
# This issue makes that despite defining na.strings = "?", the import yields warnings and converts
# all columns to character. They have to be converted back explicitely later on.
# In order to remove the warning, I use the colClasses option to override automatic detection.
dt <- fread(input = local.file, na.strings = "?", colClasses = rep("character", 9))

# check memory usage of table, turns out to be 144 MiB, i.e. quite near the estimation.
tables()

# Create a new i.date column to a new column with class data.table::IDate
# I do not use datetime values yet, as then the filter for the 2 days becomes more complicated.
# With datetimes, the filter would be to include 2007-02-01 00:00 and to exclude 2007-02-03 00:00,
# and I would have to pay attention to timezones. It is easier to use the plane date without times.
# I do not overwrite the Date column, as I need it later on for creating the datatime values.
# As data tables are not copy-on-write, technically no assignment to a new variable needed,
# as the dt variable itself will be changed through the := operator. However, running the script would
# print out the changed dt. To avoid that, use invisible() or assign to a dummy variable.
dummy <- dt[, i.date := as.IDate(Date, format = "%d/%m/%Y")]

# Subset to the date span needed. Subset as early as possible in order to speed up the following operations.
# As i.date has no time part, it is easy to include 2 full days.
dt <- dt[between(dt$i.date, "2007-02-01", "2007-02-02"), ]

# Do nothing on the Time column yet, it will be used for the datetime later on.

# Convert 7 columns to numeric.
dummy <- dt[, 3:9 := lapply(dt[, 3:9, with = F], as.numeric), with = F]
# The more general approach, which would also have worked with a by=, is to use .SD instead of dt within lapply.
# For usage of .SD see http://stackoverflow.com/questions/8508482/what-does-sd-stand-for-in-data-table-in-r
# dt[, 3:9 := lapply(.SD[, 3:9, with = F], as.numeric), with = F]

###########
# Second part is unique per plot.
###########

# Plot 1
# Plot directly to png
png(filename = "plot1.png") # png() creates by default 480x480 pixel
hist(dt[, Global_active_power], main = "Global Active Power", col = "red", xlab = "Global Active Power (kilowatts)")
dev.off()
