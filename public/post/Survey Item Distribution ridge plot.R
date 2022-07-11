#####
#
#
#
# author: eli jaffe
# date: 7/5/22
#
#
# see https://stats.stackexchange.com/questions/374413/how-to-simulate-likert-scale-data-in-r fir
# a good example of simulating likert data
# 
##############


# importing required packages
library(readxl)
library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)
library(ggridges)


## simulate data
# our data comes from employee responses to the "My Manager" section of the annual
# engagement survey. Employees responded to 13 questions on a 5 point scale:
#
# My manager communicates clear goals for our team.
# My manager ensures that I am well-informed about issues that affect my work.
# My manager supports my professional growth and development.
# My manager has had a meaningful discussion with me about my career development in the past six months.
# My manager gives actionable feedback on a regular basis.
# My manager provides the autonomy I need to do my job.
# The actions of my manager show they value the perspective I bring to the team, even if it is different from their own.
# My manager does a good job in focusing our team on the most important work
# My manager does an effective job at helping me and my teammates adapt to changes affecting our department.
# My manager effectively collaborates across departments.
# I would consider my manager to be an effective decision maker.
# My manager holds the team accountable for demonstrating [Company]'s values while driving results.
#
# Response options were 'Strongly Disagree', 'Disagree', 'Neutral', 'Agree', and 'Strongly Agree'
# A manager's Manager Dashboard then became their average of each of their direct reports'
# responses to  each item.
#
#
# While each manager would see only their scores based on their direct reports, I wanted to 
# better understand how employees tended to respond to each of these items across the entire
# company. To visualize the distribution of responses on each item, I created density ridge plots.
#
# Since the data is confidential, I will simulate a response pattern and show how 
# item distributions can be visualized using ggplot and ggridges.

# we have 13 items. 


set.seed(1234)
N = 100            # let's say we had 100 respondents

# each respondent has a 'true' score on the latent variable we are measuring
# let's model that here, assuming a normal distribution
latent = rnorm(N, mean = 0, sd = 1)

# each measurement will have a slight error on top of the true score
# define that error for each of the 13 items we will generate
sds <- runif(n=13, min=0, max=1.5)


# initialize our items and vals list
items = c()
vals <- list()

# create item responses for each 13 items
for (i in seq(length(sds))) {
  items <- append(items, paste0('item', i))
  scores <- latent + rnorm(N, mean=0, sd=sds[i])
  vals[i] <- list(scores)
}

# name the list and cast to dataframe
names(vals) <- items
dat <- as.data.frame(vals)  # we now have a dataframe of each employee's score on each item

##### generate latent responses to items
# each employee has a 'true' level on the latent variable and a corresponding 'response' level they
# would indicate based on the question design. For example, Sam is experiencing moderate-high levels
# of burnout - their true burnout level is 7 out of 10. Sam reads a survey question aimed at identifying
# burnout: "I feel burnout out from the demands of my job" with 5 response options ranging from
# Strongly Disagree to Agree. Sam selects 'Agree'. Another employee, Jordan, is not as burned out -
# their true level is a 5 out of 10. Jordan reads the same question and thinks, "well, I do *feel*
# burnout from the demands of my job. It's mostly manageable but I still agree with the statement, so
# I will indicate 'Agree'". Both Sam and Jordan responded to the item with the same response, even
# though their 'true' score, the level of burnout they are experiencing, is different.

# we can model this interaction by defining interval buckets to categorize how an employee would 
# respond based on their true score. For now, we will assume all items are positively scored (i.e
# the higher the response score, the higher the underlying True score).
# In most companies I've worked with that use survey questions measured on the scale described
# previously, the majority of employees will select 'Agree' or 'Strongly Agree'.
# Those that do not will tend to select the neutral option, and the very few employees remaining
# will indicate some level of disagreement.
# Therefore, we will define our response intervals as follows:
# if an employee's true score is very very low (2.5 or more standard deviations below the mean),
# they will respond with 'Strongly Disagree'.
# For those employees 2.5-2 deviations below the mean, they will select 'Disagree'
# Employees who are 2 to -0.5 deviations below the mean indicate 'Neutral'
# Employees 0.5 below the mean to 1 deviation above will select 'Agree'.
# The rest will select 'Strongly Agree'

# c(-Inf, -2.5, -2, -.5, 1, Inf)

# apply findInterval function to convert latent scores to ordered categories
dat <- dat |>
  mutate(across(starts_with('item'), ~ findInterval(.x, vec = c(-Inf, -2.5, -2, -.5, 1, Inf))))


#### plot the results
# create ridgeline density plot (uses ggridges packages)
dat |>
  # we pivot longer so we can use item# as Y and Fill value
  pivot_longer(where(is.numeric), names_to = 'Question', values_to = 'Score') |>
  ggplot(aes(x=Score, y = Question, fill = Question)) +
  # call the geom_density_ridge() function
  geom_density_ridges() +
  theme_ridges() +
  theme(legend.position = "none") +
  # use the limit function to properly order our items
  # since they are alphanumeric, the default sort would 
  # be item1, item10, item11, item12, item13, item2, item3...
  scale_y_discrete(limits = items)




"""
latent = rnorm(N, mean = 4, sd = .3)
item1 = latent + rnorm(N, mean=0, sd=0.2)  # the strongest correlate
item2 = latent + rnorm(N, mean=0, sd=0.3)
item3 = latent + rnorm(N, mean=0, sd=0.5)
item4 = latent + rnorm(N, mean=0, sd=1.0)
item5 = latent + rnorm(N, mean=0, sd=1.2)  # the weakest
"""



# apply findInterval function to each latent value
# i.e. for each latent value on trait, how would employee respond to item
# convert latent scores to ordered categories
dat <- dat |>
  #mutate(across(starts_with('item'), ~ findInterval(.x, vec = c(-Inf, 2, 3.4, 3.6, 4.2, Inf))))
  #mutate(across(starts_with('item'), ~ findInterval(.x, vec = c(-Inf, 2, 3, 3.5, 4, Inf))))
  mutate(across(starts_with('item'), ~ findInterval(.x, vec = c(-Inf, -2.5, -2, -.5, 1, Inf))))

# create ridgeline density plot (uses ggridges packages)
dat |>
  # we pivot longer so we can use item# as Y and Fill value
  pivot_longer(where(is.numeric), names_to = 'Question', values_to = 'Score') |>
  ggplot(aes(x=Score, y = Question, fill = Question)) +
  # call the geom_density_ridge() function
  geom_density_ridges() +
  theme_ridges() +
  theme(legend.position = "none") +
  # use the limit function to properly order our items
  # since they are alphanumeric, the defaul sort would 
  # be item1, item10, item11, item12, item13, item2, item3...
  scale_y_discrete(limits = items)




#sds <- seq(0.1, 1.3, by=0.1)


##### convert latent responses to ordered categories
item1 = findInterval(item1, vec=c(-Inf, 2, 3.4, 3.6, 4.2, Inf))  # fairly unbiased
item2 = findInterval(item2, vec=c(-Inf, 2, 3.4, 3.6, 4.2, Inf))
item3 = findInterval(item3, vec=c(-Inf, 2, 3.4, 3.6, 4.5, Inf))  # middle values typical
item4 = findInterval(item4, vec=c(-Inf, 2, 3.4, 3.6, 4,  Inf))
item5 = findInterval(item5, vec=c(-Inf, 1, 2, 3, 4, Inf))  # high ratings typical

##### combined into final scale
manifest = round(rowMeans(cbind(item1, item2, item3, item4, item5)), 1)
manifest
# [1]  3.4  3.6  3.4  3.8  2.6  3.4  3.2  2.0  3.8  3.2
round(latent, 1)
# [1]  1.3  0.6  0.2  1.0 -1.5  0.1  0.4 -2.5  2.3 -0.3
cor(manifest, latent)
# [1] 0.9280074

# build dataframe
dat <- data.frame(cbind(item1, item2, item3, item4, item5))




# we could also label them by the StdDev used to generate the data
dat |>
  # we pivot longer so we can use item# as Y and Fill value
  pivot_longer(where(is.numeric), names_to = 'Question', values_to = 'Score') |>
  ggplot(aes(x=Score, y = Question, fill = Question)) +
  # call the geom_density_ridge() function
  geom_density_ridges() +
  theme_ridges() +
  theme(legend.position = "none") +
  # use the limit function to properly order our items
  # since they are alphanumeric, the defaul sort would 
  # be item1, item10, item11, item12, item13, item2, item3...
  scale_y_discrete(limits = items,
                   labels = sds)



# Lattice - Manager Results for Engagement Survey 2022

# the multiplesheets function takes an excel file with multiple sheets that has
# the same data structure on each (i.e. manager scores for each manager on a
# different sheet) and reads it all into one dataframe
multiplesheets <- function(fname) {
  
  # getting info about all excel sheets
  sheets <- readxl::excel_sheets(fname)
  tibble <- lapply(sheets, function(x) readxl::read_excel(fname, sheet = x))
  data_frame <- lapply(tibble, as.data.frame)
  
  # clean up individual sheets
  data_frame <- lapply(data_frame, function(x) x %>%
                         # take just the My Manager theme
                         filter(Theme == 'My Immediate Manager') %>%
                         # discard the columns we don't need
                         select(!c(Theme, Score, `Sentiment Score`)) %>%
                         # remove the theme intro to each question, keeping just the text to the right of the ":"
                         # simplify = TRUE allows us to access the correct text for each row observation
                         mutate(Question = str_trim(str_split(Question, ":", simplify = TRUE)[,2])) %>%
                         # cast count cols to numeric
                         mutate(across(ends_with('Count'), as.numeric)) %>%
                         # score agreement count, get total_n, and calculate manager score per question
                         mutate(SA_scored = `Strongly Agree Count` * 5,
                                A_scored  = `Agree Count` * 4,
                                N_scored  = `Neutral Count` * 3,
                                D_scored  = `Disagree Count` * 2,
                                SD_scored = `Strongly Disagree Count` * 1,
                                total_n   = rowSums(across(ends_with('Count')), na.rm = TRUE),
                                manager_score = rowSums(across(ends_with('scored'))) / total_n))
  
  # assigning names to data frames
  names(data_frame) <- sheets
  
  # print data frame
  return(data_frame)
}

# specifying the path name
path <- "C:\\Users\\ejaffe\\OneDrive\\Documents\\Engagement Survey\\Engagement Survey April 2022\\Lattice - Manager Results for Engagement Survey 2022.xlsx"

# the actual excel file needs to be closed in order for this to work
import <- multiplesheets(path)

# create the flat dataframe and assign column names based on the Questions
flat <- data.frame(matrix(ncol=13, nrow = 0))
colnames(flat) <- c('Manager', import$`Adam Abdulhafid`$Question)

# loop through `import` and extract manager scores for each question
# then bind to the dataframe flat
for (name in names(import)) {
  
  # create the empty tmp df
  tmp <- data.frame(matrix(ncol = 13, nrow = 1))
  # Adam Abdulhafid is justthe first manager in the list. this could be anyone
  colnames(tmp) <- c('Manager', import$`Adam Abdulhafid`$Question)
  
  # assign scores
  tmp$Manager <- name
  tmp$`My manager communicates clear goals for our team.` <- import[name][[1]][1, 'manager_score']
  tmp$`My manager ensures that I am well-informed about issues that affect my work.`<- import[name][[1]][2, 'manager_score']
  tmp$`My manager supports my professional growth and development.` <- import[name][[1]][3, 'manager_score']
  tmp$`My manager has had a meaningful discussion with me about my career development in the past six months.` <- import[name][[1]][4, 'manager_score']
  tmp$`My manager gives actionable feedback on a regular basis.` <- import[name][[1]][5, 'manager_score']
  tmp$`My manager provides the autonomy I need to do my job.` <- import[name][[1]][6, 'manager_score']
  tmp$`The actions of my manager show they value the perspective I bring to the team, even if it is different from their own.` <- import[name][[1]][7, 'manager_score']
  tmp$`My manager does a good job in focusing our team on the most important work.` <- import[name][[1]][8, 'manager_score']
  tmp$`My manager does an effective job at helping me and my teammates adapt to changes affecting our department.` <- import[name][[1]][9, 'manager_score']
  tmp$`My manager effectively collaborates across departments.` <- import[name][[1]][10, 'manager_score']
  tmp$`I would consider my manager to be an effective decision maker.` <- import[name][[1]][11, 'manager_score']
  tmp$`My manager holds the team accountable for demonstrating [Company]'s values while driving results.` <- import[name][[1]][12, 'manager_score']
  
  # bind to flat
  flat <- rbind(flat, tmp)
}


# finally, calculate manager average score and round everything to two decimals
flat <- flat %>%
  mutate(average = rowMeans(across(where(is.numeric))),
         across(where(is.numeric), ~ round(.x, 2)))


# we can get the percentiles for each column
pct25 <- apply(flat %>% select(!Manager), 2, function(x) quantile(x, probs = .25))
pct50 <- apply(flat %>% select(!Manager), 2, function(x) quantile(x, probs = .50))
pct75 <- apply(flat %>% select(!Manager), 2, function(x) quantile(x, probs = .75))

flat <- rbind(flat, c('25th Percentile', pct25))
flat <- rbind(flat, c('50th Percentile', pct50))
flat <- rbind(flat, c('75th Percentile', pct75))

# save the file
#write.csv(flat, "C:\\Users\\ejaffe\\OneDrive\\Documents\\Engagement Survey\\Manager Overview.csv", row.names = FALSE)

"""
# plot
for (name in unique(flat$Manager)){
  flat %>% pivot_longer(!Manager, names_to = 'Question', values_to = 'Score') %>%
    filter(Manager == name) %>%
    ggplot(aes(x=Score, y = Question)) +
    geom_bar(stat='identity') +
    coord_flip()
  
}

flat %>% pivot_longer(!Manager, names_to = 'Question', values_to = 'Score') %>%
  filter(Manager == 'Patti Gera') %>%
  ggplot(aes(x=Question, y = Score)) +
  geom_bar(stat='identity') +
  geom_hline(yintercept = 3, color = 'red') +
  coord_flip()
"""

# we next want to assign each question text a corresponding question number
# and store a mapping for future reference
question_text <- flat |>
  select(!Manager) |>
  colnames()

mapping <- data.frame(Question = question_text,
                      Key = seq(length(question_text))) |>
  mutate(Key = paste0("Q", Key))

# create variable lvls which will store the ordered question mapping
lvls <- str_sort(mapping$Key, numeric = TRUE)


# create ridgeline density plot (uses ggridges packages)
flat |>
  pivot_longer(where(is.numeric), names_to = 'Question', values_to = 'Score') |>
  left_join(mapping, by = "Question") |>
  # cast Key to ordered factor
  mutate(Key = factor(Key, levels = lvls, ordered = TRUE)) |>
  ggplot(aes(x=Score, y = Key, fill = Key)) +
  geom_density_ridges() +
  theme_ridges() +
  theme(legend.position = "none")

