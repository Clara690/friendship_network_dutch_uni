# load the necessary libraries
library(igraph)
library(dplyr)
library(sna)
library(tidyverse)
library(modelsummary)


# Data handling

# load the adjacency matr1ix 
df1 <- read.csv('./data/t1.dat', header = FALSE, sep = '')
df4 <- read.csv('./data/t4.dat', header = FALSE, sep = '')

# handling missing values
df1[df1 == 6| df1 == 9] <- 0
df4[df4 == 6| df4 == 9] <- 0

# attributes 
atr1 <- read.csv('./data/cov1.dat', header = FALSE, sep = '') 
atr4 <- read.csv('./data/cov4.dat', header = FALSE, sep = '')
atr1$node_id <- colnames(df1)
atr4$node_id <- colnames(df4)

# turn original data frame into a matr1ix
mtx_t1 <- as.matrix(df1)
mtx_t4 <- as.matrix(df4)

# positive ties 
mtx_t1[mtx_t1 %in% 1:3] <- 1
mtx_t4[mtx_t4 %in% 1:3] <- 1
 # neutral ties
mtx_t1[mtx_t1 == 4] <- 0
mtx_t4[mtx_t4 == 4] <- 0
 # negative ties 
mtx_t1[mtx_t1 == 5] <- 0
mtx_t4[mtx_t4 == 5] <- 0

# turn matr1ix into a graph
diag(mtx_t1) <- 0 # set the values in diagonal dir to 0 
diag(mtx_t4) <- 0

#Initial exploration of the network

# period 1 
grph1 <- graph_from_adjacency_matrix(mtx_t1, weighted = FALSE, 
                                     mode = 'directed')
# fixed position
set.seed(7)
pos = layout_with_fr(grph1)
# length(E(grph1))
# length(as_edgelist(grph1))
plot.igraph(grph1, vertex.label = V(grph1)$name,vertex.size= 4,
            edge.color='darkgrey',edge.arrow.size=.2,
            layout= pos, 
            main='Friendship Network at Time 1')
# period 4 
grph4 <- graph_from_adjacency_matrix(mtx_t4, weighted = FALSE,
                                     mode = 'directed')
plot.igraph(grph4, vertex.label = V(grph4)$name,vertex.size= 4,
            edge.color='darkgrey',edge.arrow.size=.2,
            layout= pos, 
            main='Friendship Network at Time 4')


# average degree
  # period 1 
avg_in_degree_t1 <- round(mean(igraph::degree(grph1, mode = 'in')), 2)
avg_out_degree_t1 <- round(mean(igraph::degree(grph1, mode = 'out')), 2)
  # period 4 
avg_in_degree_t4 <- round(mean(igraph::degree(grph4, mode = 'in')), 2)
avg_out_degree_t4 <- round(mean(igraph::degree(grph4, mode = 'out')), 2)
# standard deviation of degree
  # period 1
sd_ind_t1 <- round(sd(igraph::degree(grph1, mode = 'in')), 2)
sd_outd_t1 <- round(sd(igraph::degree(grph1, mode = 'out')), 2)
  # period 4
sd_ind_t4 <- round(sd(igraph::degree(grph4, mode = 'in')), 2)
sd_outd_t4 <- round(sd(igraph::degree(grph4, mode = 'out')), 2)

# density
d_t1 <- round(igraph::edge_density(grph1), 2)
d_t4 <- round(igraph::edge_density(grph4), 2)
# reciprocity 
rp_t1 <- round(igraph::reciprocity(grph1), 2)
rp_t4 <- round(igraph::reciprocity(grph4), 2)
# transitivity 
tv_t1 <- round(igraph::transitivity(grph1), 2) 
tv_t4 <- round(igraph::transitivity(grph4), 2) 

# table 
tribble(
  ~'' , ~Time_1, ~Time_4,
  I("in degree (mean)"), avg_in_degree_t1, avg_in_degree_t4,
  I("in degree (sd)"), sd_ind_t1, sd_ind_t4,
  I("out degree (mean)"), avg_out_degree_t1, avg_out_degree_t4,
  I("out degree (sd)"), sd_outd_t1, sd_outd_t4,
  "density", d_t1, d_t4,
  "reciprocity", rp_t1, rp_t4,
  "transitivity", tv_t1, tv_t4)

# period 1
# in degree
shortest_paths_t1 <- shortest_paths(grph1, from = 1, to = 38)
shortest_paths_mtx_t1 <- distances(grph1, mode = 'in')
  # remove self loop
shortest_path_lengths_t1 <- as.vector(shortest_paths_mtx_t1[shortest_paths_mtx_t1 > 0]) 

  # visualization
hist(shortest_path_lengths_t1, 
     main = I("Shortest Path Lengths \n 
at Time 1 -in degree"), 
     xlab = "Shortest Path Length", 
     ylab = "Paths", 
     xlim = c(0, 7),
     border = "white")

# out degree
sp_t1_out <- shortest_paths(grph1, from = 1, to = 38)
sp_mtx_t1 <- distances(grph1, mode = 'out')
  # remove self loop
sp_t1_out_lengths <- as.vector(sp_mtx_t1[sp_mtx_t1 > 0])
  # visualization
hist(sp_t1_out_lengths, 
     main = I("Shortest Path Lengths \n 
at Time 1 - out degree"), 
     xlab = "Shortest Path Length", 
     ylab = "Paths", 
     xlim = c(0, 7), 
     border = "white")

# period 4
shortest_paths_t4 <- shortest_paths(grph4, from = 1, to = 38)
shortest_paths_mtx_t4 <- distances(grph4, mode = 'in')
# remove self loop
shortest_path_lengths_t4 <- as.vector(shortest_paths_mtx_t4[shortest_paths_mtx_t4 > 0]) 

# visualization
hist(shortest_path_lengths_t4, 
     main = I("Shortest Path Lengths \n 
at Time 4 -in degree"), 
     xlab = "Shortest Path Length", 
     ylab = "Paths", 
     xlim = c(0, 7), 
     border = "white")
# out degree
sp_t4_out <- shortest_paths(grph4, from = 1, to = 38)
sp_mtx_t4 <- distances(grph4, mode = 'out')
  # remove self loop
sp_t4_out_lengths <- as.vector(sp_mtx_t4[sp_mtx_t4 > 0])
  # visualization
hist(sp_t4_out_lengths, 
     main = I("Shortest Path Lengths \n 
at Time 4 - out degree"), 
     xlab = "Shortest Path Length", 
     ylab = "Paths", 
     xlim = c(0, 7),
     border = "white")

# descriptive information on the node variables
# V2 = gender
# V3 = program 
# V4 = smkoing 
# V5 = using sofe drugs
# transforming the original data
atr1$gender <- ifelse(atr1$V2 == 1, 1, 0)
atr1$program <- ifelse(atr1$V3 == 1, 1, 0)
atr1$smoke <- ifelse(atr1$V4 == 0, 0, 1)
atr1$drug <- ifelse(atr1$V5 == 1, 0, 1)
atr1 <- atr1 %>% mutate(gender = factor(gender, levels = c(0, 1),
                                      labels = c('Female', 'Male'))) 
atr1 <- atr1 %>% mutate(program = factor(program, levels = c(0, 1),
                                         labels = c('2-year', '4-year')))
atr1 <- atr1 %>% mutate(smoke = factor(smoke, levels = c(0, 1),
                                       labels = c('No', 'Yes')))
atr1 <- atr1 %>% mutate(drug = factor(drug, levels = c(0, 1),
                                      labels = c('No', 'Yes')))
# table
atr1 %>% 
  datasummary(gender + program + smoke + drug ~ N, 
              data = ., 
              title = 'Descriptive data for nodes level variables')

# time 1
V(grph1)$gender <- atr1[match(V(grph1)$name, atr1$node_id), ]$V2
plot.igraph(grph1,
            vertex.label= V(grph1)$name, vertex.size= 4,
            vertex.color= ifelse(V(grph1)$gender == 1,'royalblue','pink'), 
            #1 = male, 2 = female
            edge.color='darkgrey',edge.arrow.size=.2,
            layout= pos,
            main='Friendship Network at Time 1 \nblue: male, pink: female')
# time 4
V(grph4)$gender <- atr1[match(V(grph4)$name, atr1$node_id), ]$V2
plot.igraph(grph4,vertex.label= V(grph4)$name, vertex.size= 4,
            vertex.color= ifelse(V(grph4)$gender == 1,'royalblue','pink'), 
            #1 = male, 2 = female
            edge.color='darkgrey',edge.arrow.size=.2,
            layout= pos,
            main='Friendship Network at Time 4 \nblue: male, pink: female'
            )

#Assortativity

# EI index
cat('EX index at Time 1 = ', assortativity_degree(grph1), '\n')
cat('EX index at Time 4 = ', assortativity_degree(grph4))
