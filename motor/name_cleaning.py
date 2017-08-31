# want the naming convention to be:
# motor_[trial_type]_[direction]_[whisker]_[trial_modifier]_[trial_index]_[view]
# trial modifier indicates different peg positions or speed choices.

import os
import re
import shutil
import sqlite3 as sql
import sys
import optparse

def clean_names(file):

    modifier = ''
    direction = ''
    trial_type = ''
    whisker = ''
    trial_idx = ''

    ext = os.path.splitext(file)[1]
    file.replace('_proc','')

    whisker = re.search('(?<![A-Z])[A-Z]{1,2}\d',file).group().upper().strip('_')

    # get trial type
    trial_type = re.search('(?i)collision|(?i)sinewave|(?i)ping',file).group().lower()
    # get direction if it exists
    if  trial_type=='collision':
        direction = re.search('(?i)neg|(?i)pos',file).group()
        # get modifier
        token = '(?<={}).*(?={})'.format(direction, whisker)
        modifier = re.search(token, file).group().strip('_')
        direction = direction.lower()
    else:
        direction = 'X'

    # shorten trial type to 4 chars
    if trial_type == 'collision':
        trial_type = 'coll'
    elif trial_type == 'sinewave':
        trial_type = 'sine'


    # map direction to one letter
    if direction == 'neg':
        direction = 'N'
    elif direction == 'pos':
        direction = 'P'
    else:
        direction = 'X'
    # if there is no array side, mark it as X
    if len(whisker) < 3:
        whisker = 'R' + whisker
    # get trial index
    trial_idx = re.search('(?<=_)t\d{2}(?=_)',file).group().lower()
    trial_idx_num = int(trial_idx[1:])

    view = re.search('(?i)front|(?i)top',file).group().lower()

    newname= '_'.join(['motor',whisker,trial_type,direction,'e'+modifier.zfill(4),trial_idx,view+ext])
    newname=re.sub('_+', '_', newname)

    return newname


def init_data_table(main_dir):
    connection = sql.connect(os.path.join(main_dir, 'motor.db'))
    with connection:
        cur = connection.cursor()
        cur.execute("SELECT name FROM sqlite_master WHERE type='table';")
        if len(cur.fetchall()) == 0:
            cur.execute('CREATE TABLE data(ID,whisker,trial_type,direction,modifier,trial_idx,view,fname,ext,quality)')
        else:
            print("Table 'data' found in motor.db")


def add_file_to_db(filename):
    basename = os.path.basename(filename)

    whisker = re.search('(?<![A-Z])[A-Z]{1,2}\d', basename).group().upper().strip('_')
    trial_type = re.search('coll|sine|ping',basename).group()
    direction = re.search('N|P|X',basename).group()
    modifier = re.search('(?<=_)e....(?=_)',basename).group()
    trial_idx = re.search('(?<=_)t\d\d(?=_)',basename).group()
    view = re.search('front|top')
    ext = os.path.splitext(basename)[1]


    connection = sql.connect(os.path.join(main_dir, 'motor.db'))
    with connection:
        cur = connection.cursor()
        cur.execute('INSERT INTO data VALUES (?,?,?,?,?,?,?,?,?)',
                    (whisker, trial_type, direction, modifier, trial_idx_num, view, newname, ext, quality))


def main():
    parser = optparse.OptionParser()
    parser.add_option('-m', action='store', dest='main_dir', default='')
    parser.add_option('-d', action='store', dest='sub_dir', default='')
    parser.add_option('--cleaning', action='store', dest='clean_flag', default=False)
    parser.add_option('--database', action='store', dest='db_flag', default=False)
    if main_dir == '' or sub_dir == '':
        raise ValueError('no directories given')

    cur_dir = os.path.join(main_dir, sub_dir)

    for root, dirs, files in os.walk(cur_dir):
        for file in files:

            # clean name
            if clean_flag:
                newname = clean_names(cur_dir)
                if not os.path.isfile(os.path.join(cur_dir, newname)):
                    shutil.move(os.path.join(cur_dir, file), os.path.join(cur_dir, newname))
                else:
                    print('COLLISION!')
            # add to DB
            if db_flag:
                init_data_table(main_dir)
                add_file_to_db(file)


if __name__=='__main__':
    main()





    # main_dir = r'J:\motor_experiment\video_data'
    # good_dir = os.path.join(main_dir, '_good')
    # bad_dir = os.path.join(main_dir, '_bad')
    # unfinished_dir = os.path.join(main_dir, '_unfinished')
    #
    # cur_dir = unfinished_dir
    # quality = 'unfinished'
