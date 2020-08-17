import argparse
import csv
import matplotlib
import matplotlib.pyplot as plt
import numpy as np

## ----------------------------------------------------------------------------
## Main code block
## ----------------------------------------------------------------------------
def main ():

   ## get the command line args
   args = processArgs()
   
   if (args.d):
       # print some debug stuff
       print(args.csv[0])
       print(args.d)
   
   ## Read the CSV file
   with open(args.csv[0]) as csvFile:
       reader = csv.reader(csvFile)
       data = [r for r in reader]
   
   if (args.d):
       print(len(data))
       print(len(data[0]))
   
   ## Data is loaded, create the plot
   plotOurData(args, data)

## ----------------------------------------------------------------------------
## Methods
## ----------------------------------------------------------------------------
def processArgs():
	## Put all the arg parsing in a method and return the args.
    parser = argparse.ArgumentParser(description='Create chart from CSV data.')

    parser.add_argument('csv', metavar='c', type=str, nargs=1,
                   help='CSV filename')

    parser.add_argument('-d', action="store_true", help='Print debug')

    parser.add_argument('-s', default=1, type=int,
                   help='Starting sample')

    args = parser.parse_args()
    return args

## ----------------------------------------------------------------------------
## 
## ----------------------------------------------------------------------------
def plotOurData(args, data):
   ## form our data to plot
   labels = [data[i][2] for i in range(args.s,len(data), 1)]
   yaxis  = np.arange(len(data) - 1)
   xaxis1 = [int(data[i][3]) for i in range(args.s,len(data), 1)]
   xaxis2 = [float(data[i][4]) for i in range(args.s,len(data), 1)]

   # Div by 1000, to make axis more readable
   xaxis3 = [float(data[i][1])/1000 for i in range(args.s,len(data), 1)]
   
   ## plot the data
   fig, axes = plt.subplots(1, 3)
   fig.suptitle('Scottish C19 stats per region(consistent on horizontal) as of 2020_08_03', fontsize=16)

   plt.rcParams['font.family'] = 'sans-serif'
   plt.rcParams['font.sans-serif'] = 'Helvetica'
   plt.rcParams['axes.edgecolor']='#333F4B'
   plt.rcParams['axes.linewidth']=0.8
   plt.rcParams['xtick.color']='#333F4B'
   plt.rcParams['ytick.color']='#333F4B'

   SMALL_SIZE = 7
   MEDIUM_SIZE = 10
   BIGGER_SIZE = 12
   
   plt.rc('font', size=SMALL_SIZE)          # controls default text sizes
   plt.rc('axes', titlesize=SMALL_SIZE)     # fontsize of the axes title
   plt.rc('axes', labelsize=SMALL_SIZE)     # fontsize of the x and y labels
   plt.rc('xtick', labelsize=SMALL_SIZE)    # fontsize of the tick labels
   plt.rc('ytick', labelsize=SMALL_SIZE)    # fontsize of the tick labels
   plt.rc('legend', fontsize=SMALL_SIZE)    # legend fontsize
   plt.rc('figure', titlesize=BIGGER_SIZE)  # fontsize of the figure title

   myAlpha  = 0.7
   myColors = ('green','blue','red','black')

   # Select plot 1
   plt.sca(axes[0])
   line1 = plt.barh(yaxis, xaxis1, align='center', alpha=myAlpha, color=myColors)
   plt.yticks(yaxis, labels, fontsize=SMALL_SIZE)
   plt.xlabel('Region', fontsize=SMALL_SIZE)
   plt.ylabel('Deaths', fontsize=SMALL_SIZE)
   plt.title('ScotlandTotalCovid19Deaths')

   # Select plot 2
   plt.sca(axes[1])
   line1 = plt.barh(yaxis, xaxis2, align='center', alpha=myAlpha, color=myColors, tick_label='')
   plt.xlabel('Deaths per 100k', fontsize=SMALL_SIZE)
   plt.title('ScotlandTotalCovid19DeathsPer100K')

   # Select plot 3
   plt.sca(axes[2])
   line1 = plt.barh(yaxis, xaxis3, align='center', alpha=myAlpha, color=myColors, tick_label='')
   plt.xlabel('People(K)', fontsize=SMALL_SIZE)
   plt.title('ScotlandPopulation')
      
   plt.show()
   
## ----------------------------------------------------------------------------
## 
## ----------------------------------------------------------------------------
if __name__=="__main__":
   main()

## ----------------------------------------------------------------------------
## The end
## ----------------------------------------------------------------------------
