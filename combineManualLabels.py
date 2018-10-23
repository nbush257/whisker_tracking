# Run this to combine csvs of manual labels from multiple images in the same folder
import glob
import pandas as pd
import sys
import os

def check_good_num_points(df):
    counts = df.groupby('Slice').count()
    if len(counts.X.unique())>1:
        print(counts)
        raise ValueError('Not every slice has the same number of points')
    if counts.X.unique()[0] % 10 != 0:
        print('Number of points per slice is: {}'.format(counts.X.unique()[0]))
        raise ValueError('Number oof points per slice is not divisible by 10')

if __name__=='__main__':
    p = sys.argv[1]
    # Check to see if we are going to overwrite something
    outname = os.path.join(p,'Results.csv')
    if os.path.isfile(outname):
        raise ValueError('Results file already exists')
    # init combined dataframe
    df = pd.DataFrame()
    file_list = glob.glob(os.path.join(p,'*.csv'))
    file_list.sort()
    # concatenate all csvs.
    for ii,f in enumerate(file_list,1):
        im_df = pd.read_csv(f,index_col=0)
        im_df['Slice'] = ii
        df = pd.concat([df,im_df])


    #save to a new csv
    df.reset_index(inplace=True,drop=True)
    check_good_num_points(df)
    df.to_csv(outname)
    print('Saved to {}'.format(outname))

